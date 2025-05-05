import SwiftUI
import Charts

struct GraphDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

// MARK: - Progress Section
struct ProgressSectionView: View {
    let level: Int
    let xp: Int
    let progressToNextLevel: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.padding / 2) {
            HStack {
                Text("See your")
                Text("Progress")
                    .foregroundColor(AppTheme.primaryPurple)
            }
            .font(.title)
            .bold()
            
            HStack {
                // Battle Card
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Battle Against")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("NICOTINE")
                        .font(.title2)
                        .bold()
                        .foregroundColor(AppTheme.primaryPurple)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.primaryPurple.opacity(0.1))
                .cornerRadius(AppTheme.cornerRadius)
                
                // Level Card
                VStack(alignment: .center) {
                    Text("Lv. \(level)")
                        .font(.system(size: 24, weight: .bold))
                    Text("exp \(xp)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                .frame(width: 100)
                .background(Color.pink.opacity(0.1))
                .cornerRadius(AppTheme.cornerRadius)
            }
            
            // Progress Bar
            HStack(spacing: 4) {
                Text("🐷")
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 10)
                        
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                            .fill(AppTheme.primaryPurple)
                            .frame(width: geometry.size.width * progressToNextLevel, height: 10)
                    }
                }
                Text("🐮")
            }
            .frame(height: 20)
        }
        .padding(AppTheme.padding)
    }
}

// MARK: - Graph Widget
struct GraphWidgetView: View {
    let graphData: [GraphDataPoint]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text("View Report")
                        .font(.headline)
                    Text("Progress Analysis")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text("128")
                    .font(.title2)
                    .foregroundColor(AppTheme.primaryPurple)
                    .bold()
            }
            
            Chart {
                ForEach(graphData) { item in
                    LineMark(
                        x: .value("Date", item.date),
                        y: .value("Value", item.value)
                    )
                    .foregroundStyle(AppTheme.primaryPurple)
                    
                    PointMark(
                        x: .value("Date", item.date),
                        y: .value("Value", item.value)
                    )
                    .foregroundStyle(AppTheme.primaryPurple)
                }
            }
            .frame(height: 100)
            .chartPlotStyle { plotContent in
                plotContent
                    .background(Color.purple.opacity(0.1))
            }
        }
        .padding(AppTheme.padding)
        .background(Color.white)
        .cornerRadius(AppTheme.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 10)
        .padding(.horizontal, AppTheme.padding)
    }
}

// MARK: - Temptation Buttons
struct TemptationButtonsView: View {
    let onRelapse: () -> Void
    let onResist: () -> Void
    
    var body: some View {
        VStack(spacing: AppTheme.padding * 2) {
            Text("In a situation where you were tempted...")
                .font(.headline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            HStack(spacing: AppTheme.padding * 2) {
                // Relapsed Button
                Button(action: onRelapse) {
                    VStack(spacing: 8) {
                        Text("😔")
                            .font(.system(size: 32))
                        Text("Relapsed")
                            .font(.headline)
                            .bold()
                    }
                    .foregroundColor(.white)
                    .frame(width: 130, height: 130)
                    .background(
                        Circle()
                            .fill(Color.red.opacity(0.8))
                            .shadow(
                                color: Color.red.opacity(0.3),
                                radius: 20
                            )
                    )
                }
                
                // Resisted Button
                Button(action: onResist) {
                    VStack(spacing: 8) {
                        Text("💪")
                            .font(.system(size: 32))
                        Text("Resisted")
                            .font(.headline)
                            .bold()
                    }
                    .foregroundColor(.white)
                    .frame(width: 130, height: 130)
                    .background(
                        Circle()
                            .fill(Color.green.opacity(0.8))
                            .shadow(
                                color: Color.green.opacity(0.3),
                                radius: 20
                            )
                    )
                }
            }
            .padding(.bottom, AppTheme.padding)
        }
        .padding(.vertical, AppTheme.padding * 2)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 10)
        )
        .padding(.horizontal, AppTheme.padding)
    }
}

// MARK: - Navigation Bar
struct NavigationBarView: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack {
            // Journal Tab (Left)
            TabBarButton(imageName: "pencil.line", isSelected: selectedTab == 1) {
                selectedTab = 1
            }
            
            // Home Tab (Middle)
            TabBarButton(imageName: "house.fill", isSelected: selectedTab == 0) {
                selectedTab = 0
            }
            
            // Guide/Chat Tab (Right)
            TabBarButton(imageName: "book.fill", isSelected: selectedTab == 2) {
                selectedTab = 2
            }
        }
        .padding(.horizontal, AppTheme.padding)
        .padding(.vertical, AppTheme.padding / 2)
        .background(Color.white)
        .cornerRadius(AppTheme.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 10)
        .padding(.horizontal, AppTheme.padding)
        .padding(.bottom, AppTheme.padding)
    }
}

// MARK: - Home View
struct HomeView: View {
    @StateObject private var progressModel = ProgressModel()
    @State private var selectedTab = 0
    
    private var graphData: [GraphDataPoint] {
        let calendar = Calendar.current
        let now = Date()
        return (0..<7).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: now) ?? now
            let value = Double.random(in: 0...10)
            return GraphDataPoint(date: date, value: value)
        }
    }
    
    @ViewBuilder
    private var selectedView: some View {
        switch selectedTab {
        case 0:
            // Home Screen
            VStack(spacing: AppTheme.padding) {
                ProgressSectionView(
                    level: progressModel.currentLevel.rawValue,
                    xp: progressModel.currentXP,
                    progressToNextLevel: progressModel.progressToNextLevel
                )
                
                GraphWidgetView(graphData: graphData)
                
                TemptationButtonsView(
                    onRelapse: { progressModel.logRelapsed() },
                    onResist: { progressModel.logResisted() }
                )
                
                Spacer()
            }
        case 1:
            // Journal Screen
            JournalView()
        case 2:
            // Guide Screen
            GuideView()
        default:
            EmptyView()
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundWhite.ignoresSafeArea()
                
                selectedView
                
                VStack {
                    Spacer()
                    NavigationBarView(selectedTab: $selectedTab)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct TabBarButton: View {
    let imageName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: imageName)
                .font(.system(size: 24))
                .foregroundColor(isSelected ? AppTheme.primaryPurple : .gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.padding / 1.5)
        }
    }
}

#Preview {
    HomeView()
} 
