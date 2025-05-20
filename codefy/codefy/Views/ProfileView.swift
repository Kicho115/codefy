import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Perfil")
                    .font(.largeTitle)
                    .padding()
                
                Text("Contenido del perfil")
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Perfil")
        }
    }
}

#Preview {
    ProfileView()
} 