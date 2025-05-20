import SwiftUI

struct HomeView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @State private var showingCreateQuestion = false
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome to Home")
                    .font(.title)
                
                Button(action: { showingCreateQuestion = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Create Question")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                .padding(.bottom)
                
                Button(action: signOut) {
                    Text("Sign Out")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }
            }
            .navigationTitle("Home")
            .sheet(isPresented: $showingCreateQuestion) {
                CreateQuestionView()
            }
        }
    }
    
    private func signOut() {
        do {
            try FirebaseService.shared.signOut()
            isLoggedIn = false
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}

#Preview {
    HomeView()
} 