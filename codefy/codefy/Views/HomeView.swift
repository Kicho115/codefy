import SwiftUI

struct HomeView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @State private var showingCreateQuestion = false
    @StateObject private var questionsViewModel = QuestionsViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Section
                    VStack(spacing: 8) {
                        Text("Welcome to Codefy")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Your study partner")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
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
                }
                .padding(.bottom, 30)
            }
            .navigationBarHidden(true)
            .background(Color(.systemGroupedBackground))
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
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
        .background(color)
        .cornerRadius(16)
        .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    HomeView()
}

