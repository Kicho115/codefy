import SwiftUI

struct ContentView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    
    var body: some View {
        Group {
            if isLoggedIn {
                HomeView()
            } else {
                SignUp()
            }
        }
    }
}

#Preview {
    ContentView()
} 