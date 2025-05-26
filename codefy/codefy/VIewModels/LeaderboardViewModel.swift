import Foundation
import FirebaseFirestore

class LeaderboardViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var isLoading = true
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    
    func fetchUsers() {
        isLoading = true
        errorMessage = nil
        
        db.collection("users")
            .order(by: "points", descending: true)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.errorMessage = "Error fetching users: \(error.localizedDescription)"
                    self.isLoading = false
                    return
                }
                
                if let documents = snapshot?.documents {
                    self.users = documents.compactMap { document in
                        User.fromFirestore(document)
                    }
                }
                self.isLoading = false
            }
    }
} 
