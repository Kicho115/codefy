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
        return result.user
    }
    
    func signOut() throws {
        try auth.signOut()
    }
    
    func createUser(email: String, password: String) async throws -> User {
        let result = try await auth.createUser(withEmail: email, password: password)
        return result.user
    }
    
    func getCurrentUser() -> User? {
        return auth.currentUser
    }
    
    // MARK: - Firestore Methods (to be implemented)
    
    func saveUserData(userId: String, data: [String: Any]) async throws {
        try await db.collection("users").document(userId).setData(data)
    }
    
    func getUserData(userId: String) async throws -> [String: Any]? {
        let document = try await db.collection("users").document(userId).getDocument()
        return document.data()
    }
} 