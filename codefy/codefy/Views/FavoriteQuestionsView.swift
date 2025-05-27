import SwiftUI

struct FavoriteQuestionsView: View {
    @ObservedObject var questionsViewModel: QuestionsViewModel
    @State private var favoriteQuestions: [Question] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @AppStorage("userId") private var userId: String = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Favorite Questions")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .padding(.top)
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .turquoise))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.naplesYellow)
                        .padding()
                        .background(Color.naplesYellow.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                } else if favoriteQuestions.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "star.slash")
                            .font(.system(size: 50))
                            .foregroundColor(.white.opacity(0.7))
                        Text("No favorite questions yet")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 50)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(favoriteQuestions) { question in
                            NavigationLink(destination: QuestionDetailView(question: question)) {
                                QuestionCard(question: question)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .background(Color.spaceCadet)
        .task {
            await loadFavoriteQuestions()
        }
    }
    
    private func loadFavoriteQuestions() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let userData = try await FirebaseService.shared.getUserData(userId: userId)
            guard let userData = userData,
                  let favoriteQuestionIds = userData["favoriteQuestions"] as? [String] else {
                errorMessage = "Could not load favorite questions"
                isLoading = false
                return
            }
            
            favoriteQuestions = questionsViewModel.questions.filter { favoriteQuestionIds.contains($0.id) }
        } catch {
            errorMessage = "Error loading favorite questions: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
} 