import SwiftUI
import AVFoundation

struct AudioRecording: Identifiable {
    let id = UUID()
    let url: URL  // URL to the saved audio file
    let date: Date
    let duration: TimeInterval
    var isApproved: Bool
}

struct JournalEntry: Identifiable {
    let id = UUID()
    let text: String
    let date: Date
    var audioRecording: AudioRecording?
}

struct WritingPrompt: Identifiable {
    let id = UUID()
    let text: String
}

class JournalViewModel: ObservableObject {
    @Published var currentEntry: JournalEntry?
    @Published var pastEntries: [JournalEntry] = []
    @Published var journalText = ""
    @Published var isRecording = false
    @Published var currentRecordingTime: TimeInterval = 0
    @Published var selectedDate = Date()
    @Published var audioPlayer: AVAudioPlayer?
    @Published var isPlaying = false
    @Published var currentPlaybackTime: TimeInterval = 0
    @Published var sliderValue: Double = 0
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var writingPrompts: [WritingPrompt] = []
    
    private var audioRecorder: AVAudioRecorder?
    private var recordingTimer: Timer?
    private var playbackTimer: Timer?
    private let maxRecordingDuration: TimeInterval = 180 // 3 minutes
    private var currentRecordingURL: URL?
    private let geminiService = GeminiService()
    
    init() {
        setupAudioSession()
        generatePrompts()
    }
    
    private func generatePrompts() {
        Task {
            do {
                let prompts = try await geminiService.generateJournalPrompts()
                DispatchQueue.main.async {
                    self.writingPrompts = prompts.map { WritingPrompt(text: $0) }
                }
            } catch {
                print("Failed to generate prompts: \(error)")
                // Fallback to default prompts
                self.writingPrompts = defaultPrompts
            }
        }
    }
    
    private var defaultPrompts: [WritingPrompt] {
        [
            WritingPrompt(text: "What made you feel strong today?"),
            WritingPrompt(text: "What healthy choice did you make instead of your addiction?"),
            WritingPrompt(text: "What are you most proud of today?"),
            WritingPrompt(text: "What was your biggest win today – even a small one?"),
            WritingPrompt(text: "What coping strategy worked for you today?"),
            WritingPrompt(text: "What's one thing you'll do differently tomorrow?"),
            WritingPrompt(text: "What's something you learned about yourself today?")
        ]
    }
    
    private func setupAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
            showAlert(message: "Failed to set up audio. Please check your device settings.")
        }
    }
    
    func startRecording() {
        guard !isRecording else { return }
        
        let fileName = "recording-\(Date().timeIntervalSince1970).m4a"
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioURL = documentsPath.appendingPathComponent(fileName)
        currentRecordingURL = audioURL
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
            audioRecorder?.record()
            isRecording = true
            
            recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                self.currentRecordingTime = self.audioRecorder?.currentTime ?? 0
                
                if self.currentRecordingTime >= self.maxRecordingDuration {
                    self.stopRecording()
                }
            }
        } catch {
            print("Failed to start recording: \(error)")
            showAlert(message: "Failed to start recording. Please try again.")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        recordingTimer?.invalidate()
        isRecording = false
        
        if let url = currentRecordingURL {
            do {
                let audioPlayer = try AVAudioPlayer(contentsOf: url)
                let duration = audioPlayer.duration
                
                let recording = AudioRecording(
                    url: url,
                    date: selectedDate,
                    duration: duration,
                    isApproved: false
                )
                
                currentEntry = JournalEntry(
                    text: journalText,
                    date: selectedDate,
                    audioRecording: recording
                )
            } catch {
                print("Failed to create audio player: \(error)")
                showAlert(message: "Failed to save recording. Please try again.")
            }
        }
        
        currentRecordingTime = 0
    }
    
    func playRecording(url: URL) {
        do {
            if audioPlayer?.url != url {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay()
                currentPlaybackTime = 0
                sliderValue = 0
            }
            
            audioPlayer?.play()
            isPlaying = true
            
            playbackTimer?.invalidate()
            playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                guard let self = self,
                      let player = self.audioPlayer else { return }
                
                self.currentPlaybackTime = player.currentTime
                self.sliderValue = player.currentTime / player.duration
                
                if player.currentTime >= player.duration {
                    self.isPlaying = false
                    self.playbackTimer?.invalidate()
                }
            }
        } catch {
            print("Failed to play recording: \(error)")
            showAlert(message: "Failed to play recording. Please try again.")
        }
    }
    
    func pausePlayback() {
        audioPlayer?.pause()
        isPlaying = false
        playbackTimer?.invalidate()
    }
    
    func seekTo(_ time: TimeInterval) {
        audioPlayer?.currentTime = time
        currentPlaybackTime = time
    }
    
    func scrubAudio(value: Double) {
        guard let player = audioPlayer else { return }
        let time = value * player.duration
        seekTo(time)
        
        if !isPlaying {
            playRecording(url: player.url!)
        }
    }
    
    func deleteRecording() {
        stopPlayback()
        
        if let url = currentEntry?.audioRecording?.url {
            do {
                try FileManager.default.removeItem(at: url)
                currentEntry?.audioRecording = nil
                showAlert(message: "Recording deleted successfully")
            } catch {
                print("Failed to delete recording: \(error)")
                showAlert(message: "Failed to delete recording. Please try again.")
            }
        }
    }
    
    private func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        playbackTimer?.invalidate()
        currentPlaybackTime = 0
        sliderValue = 0
    }
    
    func saveEntry() {
        guard let entry = currentEntry else {
            // Create new entry if none exists
            let newEntry = JournalEntry(
                text: journalText,
                date: selectedDate,
                audioRecording: nil
            )
            currentEntry = newEntry
            
            // Add to pastEntries
            pastEntries.append(newEntry)
            showAlert(message: "Entry saved successfully!")
            return
        }
        
        // Update existing entry
        if let index = pastEntries.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }) {
            pastEntries[index] = entry
        } else {
            pastEntries.append(entry)
        }
        
        showAlert(message: "Entry saved successfully!")
    }
    
    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
    
    func loadEntry(for date: Date) {
        // Load entry from persistent storage (to be implemented)
        // For now, we'll just reset the current entry
        currentEntry = nil
        journalText = ""
    }
    
    func isCurrentDate(_ date: Date) -> Bool {
        Calendar.current.isDate(date, inSameDayAs: Date())
    }
}

struct JournalView: View {
    @StateObject private var viewModel = JournalViewModel()
    @State private var showingPrompts = false
    @AppStorage("addictionType") private var addictionType: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.padding) {
            HStack {
                VStack(alignment: .leading) {
                    HStack(spacing: 4) {
                        Text("Your")
                        Text("Journal")
                            .foregroundColor(AppTheme.primaryPurple)
                        Text("Starts")
                    }
                    .font(.title)
                    .bold()
                    Text("Here")
                        .font(.title)
                        .bold()
                }
                
                Spacer()
                
                Button(action: { showingPrompts = true }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(AppTheme.primaryPurple)
                        .font(.title2)
                }
                .help("""
                Struggling to write? Here are some ideas to get you started:
                
                \(viewModel.writingPrompts.map { "– \($0.text)" }.joined(separator: "\n\n"))
                """)
            }
            
            // Date Picker
            DatePicker(
                "Select Date",
                selection: $viewModel.selectedDate,
                in: ...Date(),
                displayedComponents: [.date]
            )
            .datePickerStyle(.compact)
            .onChange(of: viewModel.selectedDate) { _ in
                viewModel.loadEntry(for: viewModel.selectedDate)
            }
            
            // Journal Text Input
            TextEditor(text: $viewModel.journalText)
                .frame(height: 150)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                        .stroke(AppTheme.primaryPurple.opacity(0.3), lineWidth: 1)
                )
                .overlay(
                    Group {
                        if viewModel.journalText.isEmpty {
                            Text("Write here...")
                                .foregroundColor(.gray)
                                .padding()
                                .allowsHitTesting(false)
                        }
                    }
                )
                .disabled(!viewModel.isCurrentDate(viewModel.selectedDate))
            
            // Recordings Section
            HStack {
                Text("Voice Note")
                    .font(.headline)
                
                if !viewModel.isCurrentDate(viewModel.selectedDate) {
                    Text("(Past entries are read-only)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            VStack(spacing: AppTheme.padding) {
                if let currentEntry = viewModel.currentEntry,
                   let recording = currentEntry.audioRecording {
                    // Playback View
                    VStack(spacing: 4) {
                        HStack {
                            Text(recording.date, style: .date)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.white)
                        .cornerRadius(AppTheme.cornerRadius)
                        
                        VStack(spacing: 8) {
                            // Slider for audio scrubbing
                            Slider(value: $viewModel.sliderValue, in: 0...1) { isEditing in
                                if !isEditing {
                                    viewModel.scrubAudio(value: viewModel.sliderValue)
                                }
                            }
                            .accentColor(AppTheme.primaryPurple)
                            
                            HStack {
                                // Delete button (only for current date)
                                if viewModel.isCurrentDate(viewModel.selectedDate) {
                                    Button(action: { viewModel.deleteRecording() }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                Spacer()
                                
                                // Playback controls
                                HStack(spacing: AppTheme.padding) {
                                    Text(formatTime(viewModel.currentPlaybackTime))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    
                                    Button(action: {
                                        if viewModel.isPlaying {
                                            viewModel.pausePlayback()
                                        } else {
                                            viewModel.playRecording(url: recording.url)
                                        }
                                    }) {
                                        Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                                            .foregroundColor(AppTheme.primaryPurple)
                                            .font(.title2)
                                    }
                                    
                                    Text(formatTime(recording.duration - viewModel.currentPlaybackTime))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                // Approve button (only for current date)
                                if viewModel.isCurrentDate(viewModel.selectedDate) {
                                    Button(action: {
                                        if let index = viewModel.currentEntry?.audioRecording {
                                            viewModel.currentEntry?.audioRecording?.isApproved.toggle()
                                        }
                                    }) {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(recording.isApproved ? AppTheme.primaryPurple : .gray)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                } else if viewModel.isCurrentDate(viewModel.selectedDate) {
                    // Record Button
                    VStack {
                        if viewModel.isRecording {
                            Text(formatTime(viewModel.currentRecordingTime))
                                .font(.title2)
                                .foregroundColor(.red)
                            Text("Maximum duration: 3 minutes")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Button(action: {
                            if viewModel.isRecording {
                                viewModel.stopRecording()
                            } else {
                                viewModel.startRecording()
                            }
                        }) {
                            Circle()
                                .fill(viewModel.isRecording ? Color.red : AppTheme.primaryPurple)
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 4)
                                        .padding(4)
                                )
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding()
            .background(AppTheme.primaryPurple.opacity(0.1))
            .cornerRadius(AppTheme.cornerRadius)
            
            if viewModel.isCurrentDate(viewModel.selectedDate) {
                Button(action: { viewModel.saveEntry() }) {
                    Text("Submit")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.primaryPurple)
                        .cornerRadius(AppTheme.cornerRadius)
                }
            }
            
            Spacer()
        }
        .padding()
        .sheet(isPresented: $showingPrompts) {
            WritingPromptsView(prompts: viewModel.writingPrompts)
        }
        .alert("Journal", isPresented: $viewModel.showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.alertMessage)
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct WritingPromptsView: View {
    @Environment(\.dismiss) var dismiss
    let prompts: [WritingPrompt]
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: AppTheme.padding) {
                Text("Struggling to write? Here are some ideas to get you started:")
                    .font(.headline)
                    .padding(.bottom)
                
                VStack(alignment: .leading, spacing: AppTheme.padding) {
                    ForEach(prompts) { prompt in
                        HStack(alignment: .top, spacing: 8) {
                            Text("–")
                                .foregroundColor(AppTheme.primaryPurple)
                            Text(prompt.text)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Writing Prompts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    JournalView()
} 
