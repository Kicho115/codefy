import Foundation
import FirebaseFirestore

@MainActor
class QuestionDetailViewModel: ObservableObject {
    @Published var selectedAnswer: Int? = nil
    @Published var isCorrect = false
    @Published var isAnswered = false
    @Published var wasPreviouslyAnswered = false
    @Published var previousAnswerWasCorrect = false
    
    private let question: Question
    private let userId: String
    
    init(question: Question, userId: String) {
        self.question = question
        self.userId = userId
    }
    
    func checkIfQuestionWasAnswered() async {
        do {
            let userData = try await FirebaseService.shared.getUserData(userId: userId)
            guard let userData = userData,
                  let activityHistory = userData["activityHistory"] as? [[String: Any]] else { return }
            
            // Buscar la última actividad relacionada con esta pregunta
            if let lastActivity = activityHistory
                .filter({ ($0["questionId"] as? String) == question.id })
                .sorted(by: { 
                    let date1 = ($0["date"] as? Timestamp)?.dateValue() ?? Date()
                    let date2 = ($1["date"] as? Timestamp)?.dateValue() ?? Date()
                    return date1 > date2
                })
                .first {
                
                wasPreviouslyAnswered = true
                isAnswered = true
                
                // Verificar si la respuesta fue correcta
                if let result = lastActivity["result"] as? String {
                    previousAnswerWasCorrect = result == "correct"
                }
            }
        } catch {
            print("Error checking if question was answered: \(error)")
        }
    }
    
    func checkAnswer(selectedIndex: Int) {
        isAnswered = true
        isCorrect = selectedIndex == question.correctOptionIndex
        
        Task {
            await updateUserStats(selectedIndex: selectedIndex)
        }
    }
    
    private func updateUserStats(selectedIndex: Int) async {
        do {
            // Get current user data
            let userData = try await FirebaseService.shared.getUserData(userId: userId)
            guard var userData = userData else { return }
            
            // Update stats
            userData["totalQuestionsAnswered"] = (userData["totalQuestionsAnswered"] as? Int ?? 0) + 1
            
            // Update streak and stats based on correctness
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            
            // Get last activity date from activity history
            let activityHistory = userData["activityHistory"] as? [[String: Any]] ?? []
            let lastActivityDate = activityHistory
                .compactMap { ($0["date"] as? Timestamp)?.dateValue() }
                .sorted()
                .last ?? Date()
            let lastActivityDay = calendar.startOfDay(for: lastActivityDate)
            
            if isCorrect {
                userData["correctAnswers"] = (userData["correctAnswers"] as? Int ?? 0) + 1
                userData["points"] = (userData["points"] as? Int ?? 0) + question.points
                
                // Update completed questions
                var completedQuestions = userData["completedQuestions"] as? [String] ?? []
                if !completedQuestions.contains(question.id) {
                    completedQuestions.append(question.id)
                    userData["completedQuestions"] = completedQuestions
                }
                
                // Update streak
                var currentStreak = userData["streak"] as? Int ?? 0
                if calendar.isDate(today, inSameDayAs: lastActivityDay) {
                    // Same day, no need to update streak
                } else if calendar.isDateInYesterday(lastActivityDay) {
                    // Yesterday, increment streak
                    currentStreak += 1
                } else {
                    // More than a day ago, reset streak
                    currentStreak = 1
                }
                userData["streak"] = currentStreak
            }
            
            // Update activity history
            var updatedActivityHistory = activityHistory
            updatedActivityHistory.append([
                "date": Timestamp(date: Date()),
                "type": question.isDailyQuestion == true ? "daily" : "question",
                "questionId": question.id,
                "result": isCorrect ? "correct" : "incorrect"
            ])
            userData["activityHistory"] = updatedActivityHistory
            
            // Update last login time
            userData["lastLoginAt"] = Timestamp(date: Date())
            
            // Save updated user data
            try await FirebaseService.shared.saveUserData(userId: userId, data: userData)
            
            print("Updated user stats - Streak: \(userData["streak"] ?? 0)")
        } catch {
            print("Error updating user stats: \(error)")
        }
    }
} 