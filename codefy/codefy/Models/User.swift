import Foundation
import FirebaseFirestore

struct User: Codable, Identifiable {
    let id: String
    let email: String
    var name: String
    var photoURL: String?
    var bio: String?
    var country: String?
    let createdAt: Date
    var lastLoginAt: Date
    
    // Stats
    var streak: Int // Consecutive days streak
    var totalQuestionsAnswered: Int
    var correctAnswers: Int
    var points: Int
    var dailyQuestionStreak: Int // Consecutive days with daily questions answered
    var rank: Int // Rank of the user

    
    // Preferences
    var favoriteQuestions: [String] // Id's of favorite questions
    var completedQuestions: [String] // Id's of answered questions
    
    // Notification settings
    var notificationSettings: NotificationSettings
    
    
    // History
    var activityHistory: [ActivityRecord]
    
    
    // MARK: - Types
    
    struct NotificationSettings: Codable {
        var email: Bool
        var push: Bool
        var dailyReminder: Bool
    }
    
    struct ActivityRecord: Codable {
        let date: Date
        let type: ActivityType
        let questionId: String
        let result: QuestionResult
    }
    
    enum ActivityType: String, Codable {
        case question
        case daily
        case interview
    }
    
    enum QuestionResult: String, Codable {
        case correct
        case incorrect
    }
    
    enum Difficulty: String, Codable {
        case easy
        case medium
        case hard
    }
}

// MARK: - Firestore Integration
extension User {
    static func fromFirestore(_ document: DocumentSnapshot) -> User? {
        guard let data = document.data() else { return nil }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data)
            return try JSONDecoder().decode(User.self, from: jsonData)
        } catch {
            print("Error decoding user: \(error)")
            return nil
        }
    }
    
    func toFirestore() -> [String: Any] {
        do {
            let jsonData = try JSONEncoder().encode(self)
            return try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] ?? [:]
        } catch {
            print("Error encoding user: \(error)")
            return [:]
        }
    }
}
