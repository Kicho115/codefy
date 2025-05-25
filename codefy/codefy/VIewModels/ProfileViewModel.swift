import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class ProfileViewModel: ObservableObject {
    @Published private(set) var user: User?
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    private let db = Firestore.firestore()
    
    private var userId: String? {
        UserDefaults.standard.string(forKey: "userId")
    }
    
    var isUserActive: Bool {
        guard let lastLogin = user?.lastLoginAt else { return false }
        let tenMinutesAgo = Date().addingTimeInterval(-600) // 10 minutes in seconds
        return lastLogin > tenMinutesAgo
    }
    
    func loadUserProfile() async {
        guard let userId = userId else {
            error = NSError(domain: "ProfileViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])
            return
        }
        
        isLoading = true
        error = nil
        
        do {
            let document = try await db.collection("users").document(userId).getDocument()
            if let user = User.fromFirestore(document) {
                self.user = user
            } else {
                throw NSError(domain: "ProfileViewModel", code: -2, userInfo: [NSLocalizedDescriptionKey: "Could not parse user data"])
            }
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func updateLastLogin() async {
        guard let userId = userId else { return }
        
        do {
            // We use updateData to prevent concurrent updates
            let updateData: [String: Any] = ["lastLoginAt": FieldValue.serverTimestamp()]
            try await db.collection("users").document(userId).updateData(updateData)
        } catch {
            print("Error updating last login: \(error)")
        }
    }
    
    func updateProfilePhoto(_ imageData: Data) async {
        guard let userId = userId else { return }
        
        isLoading = true
        error = nil
        
        do {
            // Upload image to Firebase Storage
            let path = "profile_photos/\(userId).jpg"
            let photoUrl = try await StorageService.shared.uploadData(imageData, path: path)
            
            // Update user document in Firestore
            try await db.collection("users").document(userId).updateData([
                "photoUrl": photoUrl.absoluteString
            ])
            
            // Reload user profile to reflect changes
            await loadUserProfile()
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
} 