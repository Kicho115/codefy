import Foundation
import FirebaseFirestore

struct User: Codable, Identifiable {
    let id: String
    let email: String?
    var name: String
    var photoUrl: String?
    var bio: String?
    var country: String?
    let createdAt: Date
    var lastLoginAt: Date
    
    // Stats
    var streak: Int // Consecutive days streak
    var totalQuestionsAnswered: Int
    var correctAnswers: Int
    var points: Int
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
    
    var formattedMemberSince: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
    
    var formattedLastLogin: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: lastLoginAt, relativeTo: Date())
    }
}

// MARK: - Firestore Integration
extension User {
    static func fromFirestore(_ document: DocumentSnapshot) -> User? {
        guard let data = document.data() else { return nil }
        
        // Convert Firestore timestamps to ISO8601 strings
        var processedData = data
        // Add the document ID as the id field
        processedData["id"] = document.documentID
        
        if let createdAt = data["createdAt"] as? Timestamp {
            processedData["createdAt"] = createdAt.dateValue().ISO8601Format()
        }
        if let lastLoginAt = data["lastLoginAt"] as? Timestamp {
            processedData["lastLoginAt"] = lastLoginAt.dateValue().ISO8601Format()
        }
        
        // Process activity history timestamps
        if var activityHistory = processedData["activityHistory"] as? [[String: Any]] {
            for i in 0..<activityHistory.count {
                if let date = activityHistory[i]["date"] as? Timestamp {
                    activityHistory[i]["date"] = date.dateValue().ISO8601Format()
                }
            }
            processedData["activityHistory"] = activityHistory
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: processedData)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(User.self, from: jsonData)
        } catch {
            print("Error decoding user: \(error)")
            return nil
        }
    }
    
    func toFirestore() -> [String: Any] {
        var data: [String: Any] = [:]
        
        // Convert Date to Timestamp for Firestore
        data["id"] = id
        data["email"] = email
        data["name"] = name
        data["photoUrl"] = photoUrl
        data["bio"] = bio
        data["country"] = country
        data["createdAt"] = Timestamp(date: createdAt)
        data["lastLoginAt"] = Timestamp(date: lastLoginAt)
        
        // Stats
        data["streak"] = streak
        data["totalQuestionsAnswered"] = totalQuestionsAnswered
        data["correctAnswers"] = correctAnswers
        data["points"] = points
        data["rank"] = rank
        
        // Preferences
        data["favoriteQuestions"] = favoriteQuestions
        data["completedQuestions"] = completedQuestions
        
        // Notification settings
        data["notificationSettings"] = [
            "email": notificationSettings.email,
            "push": notificationSettings.push,
            "dailyReminder": notificationSettings.dailyReminder
        ]
        
        // Activity history
        data["activityHistory"] = activityHistory.map { record in
            [
                "date": Timestamp(date: record.date),
                "type": record.type.rawValue,
                "questionId": record.questionId,
                "result": record.result.rawValue
            ]
        }
        
        return data
    }
}
