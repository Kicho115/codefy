import Foundation
import FirebaseFirestore

class LeaderboardViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var isLoading = true
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private let firebaseService = FirebaseService.shared
    
    func fetchUsers() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // Update all user ranks first
                try await firebaseService.updateUserRanks()
                
                // Then fetch the updated user list
                let snapshot = try await db.collection("users")
                    .order(by: "points", descending: true)
                    .getDocuments()
                
                self.users = snapshot.documents.compactMap { document in
                    User.fromFirestore(document)
                }
                
                self.isLoading = false
            } catch {
                self.errorMessage = "Error fetching users: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
} 
