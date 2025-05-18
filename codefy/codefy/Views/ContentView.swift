import SwiftUI

struct ContentView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false

    var body: some View {
        NavigationStack {
            Group {
                if isLoggedIn {
                    HomeView()
                        .navigationBarBackButtonHidden(true)
                } else {
                    SignInView()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
