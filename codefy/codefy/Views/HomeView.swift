import SwiftUI
import PhotosUI

struct HomeView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @State private var showingCreateQuestion = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var isUploading = false
    @State private var uploadError: String?
    
    @StateObject private var questionsViewModel = QuestionsViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome to Home")
                    .font(.title)
                
                // Botón para seleccionar y subir foto
                PhotosPicker(selection: $selectedItem,
                           matching: .images,
                           photoLibrary: .shared()) {
                    HStack {
                        Image(systemName: "photo.fill")
                        Text("Upload Photo")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
                }
                .onChange(of: selectedItem) { newItem in
                    Task {
                        await uploadPhoto(newItem)
                    }
                }
                .padding(.bottom)
                
                if isUploading {
                    ProgressView("Uploading...")
                }
                
                if let error = uploadError {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                NavigationLink(destination: DailyQuestionView(viewModel: DailyQuestionViewModel(questionsViewModel: questionsViewModel))) {
                    HStack {
                        Image(systemName: "sun.max.fill")
                        Text("Pregunta del Día")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(10)
                }

                NavigationLink(destination: QuestionsView(viewModel: questionsViewModel)) {
                    HStack {
                        Image(systemName: "list.bullet.rectangle")
                        Text("Ver Preguntas")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.purple)
                    .cornerRadius(10)
                }

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
                .sheet(isPresented: $showingCreateQuestion) {
                    CreateQuestionView(questionsViewModel: questionsViewModel)
                }


                
                
                NavigationLink(destination: InterviewModeSelection(questionsViewModel: questionsViewModel)) {
                    HStack {
                        Image(systemName: "list.bullet.rectangle")
                        Text("Entrevista Simulada")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.purple)
                    .cornerRadius(10)
                }

                Button(action: signOut) {
                    Text("Sign Out")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }
            }
            .navigationTitle("Home")
        }
    }
    
    private func uploadPhoto(_ item: PhotosPickerItem?) async {
        guard let item = item else { return }
        
        do {
            isUploading = true
            uploadError = nil
            
            guard let data = try await item.loadTransferable(type: Data.self) else {
                throw NSError(domain: "HomeView", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not load image data"])
            }
            
            let path = "photos/\(UUID().uuidString).jpg"
            let _ = try await StorageService.shared.uploadData(data, path: path)
            
            selectedItem = nil
            uploadError = nil
        } catch {
            uploadError = "Error uploading photo: \(error.localizedDescription)"
        }
        
        isUploading = false
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

