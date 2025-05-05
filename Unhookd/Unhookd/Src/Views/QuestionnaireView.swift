import SwiftUI

struct Question {
    let text: String
    let placeholder: String
    let inputType: InputType
    let ratingDescription: (String, String)?  // (low label, high label)
    
    enum InputType {
        case text
        case rating
        case time
        case yesNo
        case people
    }
}

struct QuestionnaireView: View {
    let addiction: String
    @State private var currentQuestionIndex = 0
    @State private var answers: [String] = Array(repeating: "", count: 8)
    @State private var shouldShowSummary = false
    @State private var showTimePicker = false
    
    var questions: [Question] {
        [
            Question(text: "What time did you crave \(addiction) the most today?", 
                    placeholder: "Select time", 
                    inputType: .time,
                    ratingDescription: nil),
            Question(text: "What triggered your cravings today?", 
                    placeholder: "Describe triggers", 
                    inputType: .text,
                    ratingDescription: nil),
            Question(text: "Did you meet your \(addiction) reduction goal today?", 
                    placeholder: "", 
                    inputType: .yesNo,
                    ratingDescription: nil),
            Question(text: "Rate your cravings today", 
                    placeholder: "Enter rating", 
                    inputType: .rating,
                    ratingDescription: ("1 - Mild", "10 - Intense")),
            Question(text: "How did you feel overall today?", 
                    placeholder: "Describe your feelings", 
                    inputType: .text,
                    ratingDescription: nil),
            Question(text: "What is your stress level today?", 
                    placeholder: "Enter rating", 
                    inputType: .rating,
                    ratingDescription: ("1 - Low stress", "10 - High stress")),
            Question(text: "Where were you when you felt the urge most?", 
                    placeholder: "Enter location", 
                    inputType: .text,
                    ratingDescription: nil),
            Question(text: "Who were you with during usage?", 
                    placeholder: "Enter people", 
                    inputType: .people,
                    ratingDescription: nil)
        ]
    }
    
    var body: some View {
        ZStack {
            AppTheme.backgroundWhite.ignoresSafeArea()
            
            // Accent lines
            AccentLines()
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                ProgressView(value: Double(currentQuestionIndex + 1), total: Double(questions.count))
                    .tint(AppTheme.primaryPurple)
                    .padding(.horizontal)
                    .padding(.top, 48)
                
                Spacer()
                
                VStack(spacing: 24) {
                    Text(questions[currentQuestionIndex].text)
                        .font(.system(size: 24, weight: .bold))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    
                    switch questions[currentQuestionIndex].inputType {
                    case .rating:
                        if let (lowLabel, highLabel) = questions[currentQuestionIndex].ratingDescription {
                            RatingSliderView(
                                rating: $answers[currentQuestionIndex],
                                lowLabel: lowLabel,
                                highLabel: highLabel
                            )
                        }
                    case .time:
                        Button(action: {
                            showTimePicker = true
                        }) {
                            HStack {
                                Text(answers[currentQuestionIndex].isEmpty ? "Select time" : answers[currentQuestionIndex])
                                    .foregroundColor(answers[currentQuestionIndex].isEmpty ? .gray : .black)
                                Spacer()
                                Image(systemName: "clock")
                                    .foregroundColor(AppTheme.primaryPurple)
                            }
                            .padding()
                            .background(AppTheme.inputBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(AppTheme.inputBorder, lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, 24)
                    case .yesNo:
                        YesNoInputView(selection: $answers[currentQuestionIndex])
                    case .people:
                        PeopleInputView(text: $answers[currentQuestionIndex])
                    case .text:
                        TextField(questions[currentQuestionIndex].placeholder,
                                text: $answers[currentQuestionIndex])
                            .padding()
                            .background(AppTheme.inputBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(AppTheme.inputBorder, lineWidth: 1)
                            )
                            .padding(.horizontal, 24)
                    }
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Button(action: {
                        if currentQuestionIndex < questions.count - 1 {
                            withAnimation {
                                currentQuestionIndex += 1
                            }
                        } else {
                            shouldShowSummary = true
                        }
                    }) {
                        HStack {
                            Text(currentQuestionIndex < questions.count - 1 ? "Next" : "Finish")
                            Image(systemName: "arrow.right")
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(shouldShowNextButton ? AppTheme.primaryPurple : Color.gray)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    .disabled(!shouldShowNextButton)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $shouldShowSummary) {
            HomeView()
                .navigationBarBackButtonHidden(true)
        }
        .sheet(isPresented: $showTimePicker) {
            TimePickerView(selectedTime: $answers[currentQuestionIndex])
                .presentationDetents([.height(300)])
        }
    }
    
    private var shouldShowNextButton: Bool {
        !answers[currentQuestionIndex].isEmpty
    }
} 