import SwiftUI
import Combine

class SignUpViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    @Published var isLoggedIn: Bool = false
    @AppStorage("isLoggedIn") private var globalIsLoggedIn: Bool = false
    @AppStorage("userId") var userId: String = ""
    
    private let firebaseService: FirebaseService
    
    init(firebaseService: FirebaseService = .shared) {
        self.firebaseService = firebaseService
    }
    
    func signUp() {
        guard !name.isEmpty else {
            errorMessage = "Please enter your name"
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }
        
        errorMessage = ""
        isLoading = true
        
        // Async task to sign up the user
        Task {
            do {
                let _ = try await firebaseService.createUser(email: email, password: password, name: name)
                
                // Automatically sign in the user after successful sign-up
                let signedInUser = try await firebaseService.signIn(email: email, password: password)
                
                await MainActor.run {
                    self.isLoggedIn = true
                    self.globalIsLoggedIn = true
                    self.userId = signedInUser.id
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
