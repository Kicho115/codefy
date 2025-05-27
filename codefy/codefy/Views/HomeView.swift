import SwiftUI

struct HomeView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @State private var showingCreateQuestion = false
    @StateObject private var questionsViewModel = QuestionsViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.spaceCadet.ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Header Section
                    VStack(spacing: 8) {
                        Text("Welcome to Codefy")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color.white)
                        
                        Text("Your study partner")
                            .font(.subheadline)
                            .foregroundColor(Color.tropicalIndigo)
                    }
                    .padding(.top, 20)
                    
                    // Main Actions Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        // Daily Question Card
                        NavigationLink(destination: DailyQuestionView(viewModel: DailyQuestionViewModel(questionsViewModel: questionsViewModel))) {
                            ActionCard(
                                title: "Daily Question",
                                icon: "sun.max.fill",
                                color: .orange
                            )
                        }
                        
                        // Questions List Card
                        NavigationLink(destination: QuestionsView(viewModel: questionsViewModel)) {
                            ActionCard(
                                title: "See All Questions",
                                icon: "list.bullet.rectangle",
                                color: .purple
                            )
                        }
                        
                        // Create Question Card
                        Button(action: { showingCreateQuestion = true }) {
                            ActionCard(
                                title: "Create Question",
                                icon: "plus.circle.fill",
                                color: .blue
                            )
                        }
                        .sheet(isPresented: $showingCreateQuestion) {
                            CreateQuestionView(questionsViewModel: questionsViewModel)
                        }
                        
                        // Interview Mode Card
                        NavigationLink(destination: InterviewModeSelection(questionsViewModel: questionsViewModel)) {
                            ActionCard(
                                title: "Mock Interview",
                                icon: "person.2.fill",
                                color: .green
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Recent Questions Feed
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recent Questions")
                            .font(.title2)
                            .bold()
                            .foregroundColor(Color.white)
                            .padding(.horizontal)
                        
                        ScrollView {
                            if questionsViewModel.isLoading {
                                ProgressView()
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                            else if !questionsViewModel.errorMessage.isEmpty {
                                Text(questionsViewModel.errorMessage)
                                    .foregroundColor(Color.naplesYellow)
                                    .padding()
                            } else {
                                LazyVStack(spacing: 12) {
                                    ForEach(questionsViewModel.questions.prefix(10)) { question in
                                        NavigationLink(destination: QuestionDetailView(question: question)) {
                                            QuestionCard(question: question)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .refreshable {
                            await questionsViewModel.fetchQuestions()
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Supporting Views
struct ActionCard: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(Color.white)
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color.white)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
        .background(color)
        .cornerRadius(16)
        .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

struct QuestionCard: View {
    let question: Question
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(question.text)
                .font(.headline)
                .foregroundColor(Color.white)
                .lineLimit(2)
            
            HStack {
                Text(question.category.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(categoryColor(question.category).opacity(0.2))
                    .foregroundColor(categoryColor(question.category))
                    .cornerRadius(8)
                
                Spacer()
                
                Text("\(question.points) pts")
                    .font(.caption)
                    .foregroundColor(Color.turquoise)
            }
        }
        .padding()
        .background(Color.spaceCadet.opacity(0.5))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.tropicalIndigo.opacity(0.2), lineWidth: 1)
        )
    }
    
    private func categoryColor(_ category: Category) -> Color {
        switch category {
        case .oop: return .blue
        case .webdev: return .green
        case .humanResources: return .orange
        case .structure: return .purple
        case .uncategorized: return .gray
        case .swift: return .red
        }
    }
}

#Preview {
    HomeView()
}

