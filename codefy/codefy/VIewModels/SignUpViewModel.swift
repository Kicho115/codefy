import SwiftUI
import Combine

class SignUpViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    @Published var isLoggedIn: Bool = false
    
    private let firebaseService: FirebaseService
    
    init(firebaseService: FirebaseService = .shared) {
        self.firebaseService = firebaseService
    }
    
    func signUp() {
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                // Primero creamos el usuario
                let user = try await firebaseService.createUser(email: email, password: password)
                
                // Luego iniciamos sesión automáticamente
                try await firebaseService.signIn(email: email, password: password)
                
                await MainActor.run {
                    isLoggedIn = true
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
} 
