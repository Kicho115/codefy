import Foundation
import FirebaseFirestore
import SwiftUI

@MainActor
class QuestionDetailViewModel: ObservableObject {
    @Published var selectedAnswer: Int? = nil
    @Published var isCorrect = false
    @Published var isAnswered = false
    @Published var wasPreviouslyAnswered = false
    @Published var previousAnswerWasCorrect = false
    @Published var isFavorited = false
    @Published var creator: User?
    
    private let question: Question
    private let userId: String
    private let firebaseService = FirebaseService.shared
    
    init(question: Question, userId: String) {
        self.question = question
        self.userId = userId
        Task {
            await checkIfQuestionWasAnswered()
            await checkIfQuestionIsFavorited()
        }
    }
    
    func checkIfQuestionWasAnswered() async {
        // Fetch user data to check if question was previously answered
        if let userData = try? await firebaseService.getUserData(userId: userId),
           let completedQuestions = userData["completedQuestions"] as? [String] {
            wasPreviouslyAnswered = completedQuestions.contains(question.id)
        }
        
        // Fetch creator's information
        if let creatorData = try? await firebaseService.getUserData(userId: question.createdBy) {
            // Create User object from creator data
            creator = User(
                id: question.createdBy,
                email: creatorData["email"] as? String,
                name: creatorData["name"] as? String ?? "Unknown User",
                photoUrl: creatorData["photoUrl"] as? String,
                bio: creatorData["bio"] as? String,
                country: creatorData["country"] as? String,
                createdAt: (creatorData["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                lastLoginAt: (creatorData["lastLoginAt"] as? Timestamp)?.dateValue() ?? Date(),
                streak: creatorData["streak"] as? Int ?? 0,
                totalQuestionsAnswered: creatorData["totalQuestionsAnswered"] as? Int ?? 0,
                correctAnswers: creatorData["correctAnswers"] as? Int ?? 0,
                points: creatorData["points"] as? Int ?? 0,
                rank: creatorData["rank"] as? Int ?? 0,
                favoriteQuestions: creatorData["favoriteQuestions"] as? [String] ?? [],
                completedQuestions: creatorData["completedQuestions"] as? [String] ?? [],
                notificationSettings: User.NotificationSettings(
                    email: (creatorData["notificationSettings"] as? [String: Any])?["email"] as? Bool ?? true,
                    push: (creatorData["notificationSettings"] as? [String: Any])?["push"] as? Bool ?? true,
                    dailyReminder: (creatorData["notificationSettings"] as? [String: Any])?["dailyReminder"] as? Bool ?? true
                ),
                activityHistory: (creatorData["activityHistory"] as? [[String: Any]])?.compactMap { record in
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
                } ?? []
            )
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
    
    private func checkIfQuestionIsFavorited() async {
        do {
            let userData = try await FirebaseService.shared.getUserData(userId: userId)
            guard let userData = userData,
                  let favoriteQuestions = userData["favoriteQuestions"] as? [String] else { return }
            
            isFavorited = favoriteQuestions.contains(question.id)
        } catch {
            print("Error checking if question is favorited: \(error)")
        }
    }
    
    func toggleFavorite() async {
        do {
            let userData = try await FirebaseService.shared.getUserData(userId: userId)
            guard var userData = userData else { return }
            
            var favoriteQuestions = userData["favoriteQuestions"] as? [String] ?? []
            
            if isFavorited {
                favoriteQuestions.removeAll { $0 == question.id }
            } else {
                favoriteQuestions.append(question.id)
            }
            
            userData["favoriteQuestions"] = favoriteQuestions
            try await FirebaseService.shared.saveUserData(userId: userId, data: userData)
            
            isFavorited.toggle()
        } catch {
            print("Error toggling favorite status: \(error)")
        }
    }
} 