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
            
            if isCorrect {
                userData["correctAnswers"] = (userData["correctAnswers"] as? Int ?? 0) + 1
                userData["points"] = (userData["points"] as? Int ?? 0) + question.points
                
                // Update completed questions
                var completedQuestions = userData["completedQuestions"] as? [String] ?? []
                if !completedQuestions.contains(question.id) {
                    completedQuestions.append(question.id)
                    userData["completedQuestions"] = completedQuestions
                }
                
                // Update daily streak if this is the first question answered today
                let calendar = Calendar.current
                let today = calendar.startOfDay(for: Date())
                let lastLogin = (userData["lastLoginAt"] as? Timestamp)?.dateValue() ?? Date()
                let lastLoginDay = calendar.startOfDay(for: lastLogin)
                
                if calendar.isDate(today, inSameDayAs: lastLoginDay) {
                    // Same day, no need to update streak
                } else if calendar.isDateInYesterday(lastLoginDay) {
                    // Yesterday, increment streak
                    userData["dailyQuestionStreak"] = (userData["dailyQuestionStreak"] as? Int ?? 0) + 1
                } else {
                    // More than a day ago, reset streak
                    userData["dailyQuestionStreak"] = 1
                }
            }
            
            // Update activity history
            var activityHistory = userData["activityHistory"] as? [[String: Any]] ?? []
            activityHistory.append([
                "date": Timestamp(date: Date()),
                "type": "question",
                "questionId": question.id,
                "result": isCorrect ? "correct" : "incorrect"
            ])
            userData["activityHistory"] = activityHistory
            
            // Update last login time
            userData["lastLoginAt"] = Timestamp(date: Date())
            
            // Save updated user data
            try await FirebaseService.shared.saveUserData(userId: userId, data: userData)
        } catch {
            print("Error updating user stats: \(error)")
        }
    }
} 