import SwiftUI
import Combine

class SignInViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    @Published var isLoggedIn: Bool = false
    @AppStorage("isLoggedIn") private var globalIsLoggedIn: Bool = false
    
    private let firebaseService: FirebaseService
    
    init(firebaseService: FirebaseService = .shared) {
        self.firebaseService = firebaseService
    }
    
    func signIn() {
        isLoading = true
        errorMessage = ""
        
        // Async task to sign in the user
        Task {
            do {
                let user = try await firebaseService.signIn(email: email, password: password)
                await MainActor.run {
                    self.isLoggedIn = true
                    self.globalIsLoggedIn = true
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
} 
