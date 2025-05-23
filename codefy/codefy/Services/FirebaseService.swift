import Foundation
import FirebaseAuth
import FirebaseFirestore

class FirebaseService {
    static let shared = FirebaseService()
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // MARK: - Authentication Methods
    
    func signIn(email: String, password: String) async throws -> User {
        let result = try await auth.signIn(withEmail: email, password: password)
        let firebaseUser = result.user
        
        // Get user data from Firestore
        let userData = try await getUserData(userId: firebaseUser.uid)
        
        // Create custom User object
        return User(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? "",
            name: userData?["name"] as? String ?? "",
            photoURL: firebaseUser.photoURL?.absoluteString,
            bio: userData?["bio"] as? String,
            country: userData?["country"] as? String,
            createdAt: (userData?["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
            lastLoginAt: Date(),
            streak: userData?["streak"] as? Int ?? 0,
            totalQuestionsAnswered: userData?["totalQuestionsAnswered"] as? Int ?? 0,
            correctAnswers: userData?["correctAnswers"] as? Int ?? 0,
            points: userData?["points"] as? Int ?? 0,
            dailyQuestionStreak: userData?["dailyQuestionStreak"] as? Int ?? 0,
            rank: userData?["rank"] as? Int ?? 0,
            favoriteQuestions: userData?["favoriteQuestions"] as? [String] ?? [],
            completedQuestions: userData?["completedQuestions"] as? [String] ?? [],
            notificationSettings: User.NotificationSettings(
                email: (userData?["notificationSettings"] as? [String: Any])?["email"] as? Bool ?? true,
                push: (userData?["notificationSettings"] as? [String: Any])?["push"] as? Bool ?? true,
                dailyReminder: (userData?["notificationSettings"] as? [String: Any])?["dailyReminder"] as? Bool ?? true
            ),
            activityHistory: (userData?["activityHistory"] as? [[String: Any]])?.compactMap { record in
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
    
    func signOut() throws {
        try auth.signOut()
    }
    
    func createUser(email: String, password: String, name: String) async throws -> User {
        let result = try await auth.createUser(withEmail: email, password: password)
        let firebaseUser = result.user
        
        // Create initial user data
        let initialUserData: [String: Any] = [
            "name": name,
            "createdAt": Timestamp(date: Date()),
            "lastLoginAt": Timestamp(date: Date()),
            "streak": 0,
            "totalQuestionsAnswered": 0,
            "correctAnswers": 0,
            "points": 0,
            "dailyQuestionStreak": 0,
            "rank": 0,
            "favoriteQuestions": [],
            "completedQuestions": [],
            "notificationSettings": [
                "email": true,
                "push": true,
                "dailyReminder": true
            ],
            "activityHistory": []
        ]
        
        // Save initial user data to Firestore
        try await saveUserData(userId: firebaseUser.uid, data: initialUserData)
        
        // Create and return custom User object
        return User(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? "",
            name: name,
            photoURL: nil,
            bio: nil,
            country: nil,
            createdAt: Date(),
            lastLoginAt: Date(),
            streak: 0,
            totalQuestionsAnswered: 0,
            correctAnswers: 0,
            points: 0,
            dailyQuestionStreak: 0,
            rank: 0,
            favoriteQuestions: [],
            completedQuestions: [],
            notificationSettings: User.NotificationSettings(
                email: true,
                push: true,
                dailyReminder: true
            ),
            activityHistory: []
        )
    }
    
    func getCurrentUser() -> User? {
        guard let firebaseUser = auth.currentUser else { return nil }
        
        // Create a basic User object with Firebase user data
        // Note: This is a simplified version since we can't make async calls here
        return User(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? "",
            name: "",
            photoURL: firebaseUser.photoURL?.absoluteString,
            bio: nil,
            country: nil,
            createdAt: Date(),
            lastLoginAt: Date(),
            streak: 0,
            totalQuestionsAnswered: 0,
            correctAnswers: 0,
            points: 0,
            dailyQuestionStreak: 0,
            rank: 0,
            favoriteQuestions: [],
            completedQuestions: [],
            notificationSettings: User.NotificationSettings(
                email: true,
                push: true,
                dailyReminder: true
            ),
            activityHistory: []
        )
    }
    
    // MARK: - Firestore Methods
    
    func saveUserData(userId: String, data: [String: Any]) async throws {
        try await db.collection("users").document(userId).setData(data)
    }
    
    func getUserData(userId: String) async throws -> [String: Any]? {
        let document = try await db.collection("users").document(userId).getDocument()
        return document.data()
    }
} 
