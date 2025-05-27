import SwiftUI
import FirebaseFirestore

struct ActivityHistoryView: View {
    @ObservedObject var questionsViewModel: QuestionsViewModel
    @State private var activities: [User.ActivityRecord] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @AppStorage("userId") private var userId: String = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Activity History")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .padding(.top)
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .turquoise))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.naplesYellow)
                        .padding()
                        .background(Color.naplesYellow.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                } else if activities.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 50))
                            .foregroundColor(.white.opacity(0.7))
                        Text("No activity yet")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 50)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(activities, id: \.date) { activity in
                            ActivityCard(activity: activity, question: questionsViewModel.questions.first { $0.id == activity.questionId })
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .background(Color.spaceCadet)
        .task {
            await loadActivityHistory()
        }
    }
    
    private func loadActivityHistory() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let userData = try await FirebaseService.shared.getUserData(userId: userId)
            guard let userData = userData,
                  let activityHistory = userData["activityHistory"] as? [[String: Any]] else {
                errorMessage = "Could not load activity history"
                isLoading = false
                return
            }
            
            activities = activityHistory.compactMap { record in
                guard let date = (record["date"] as? Timestamp)?.dateValue(),
                      let typeString = record["type"] as? String,
                      let type = User.ActivityType(rawValue: typeString),
                      let questionId = record["questionId"] as? String,
                      let resultString = record["result"] as? String,
                      let result = User.QuestionResult(rawValue: resultString) else {
                    return nil
                }
                return User.ActivityRecord(
                    date: date,
                    type: type,
                    questionId: questionId,
                    result: result
                )
            }.sorted { $0.date > $1.date }
        } catch {
            errorMessage = "Error loading activity history: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

struct ActivityCard: View {
    let activity: User.ActivityRecord
    let question: Question?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: iconForType(activity.type))
                    .foregroundColor(colorForType(activity.type))
                Text(titleForType(activity.type))
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                Spacer()
                Text(formattedDate(activity.date))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }
            
            if let question = question {
                Text(question.text)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(2)
            }
            
            HStack {
                Image(systemName: activity.result == .correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(activity.result == .correct ? .turquoise : .naplesYellow)
                Text(activity.result == .correct ? "Correct" : "Incorrect")
                    .font(.subheadline)
                    .foregroundColor(activity.result == .correct ? .turquoise : .naplesYellow)
            }
        }
        .padding()
        .background(Color.spaceCadet.opacity(0.5))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.tropicalIndigo.opacity(0.3), lineWidth: 1)
        )
    }
    
    private func iconForType(_ type: User.ActivityType) -> String {
        switch type {
        case .question: return "questionmark.circle.fill"
        case .daily: return "sun.max.fill"
        case .interview: return "person.2.fill"
        }
    }
    
    private func colorForType(_ type: User.ActivityType) -> Color {
        switch type {
        case .question: return .tropicalIndigo
        case .daily: return .orange
        case .interview: return .green
        }
    }
    
    private func titleForType(_ type: User.ActivityType) -> String {
        switch type {
        case .question: return "Practice Question"
        case .daily: return "Daily Question"
        case .interview: return "Mock Interview"
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
} 