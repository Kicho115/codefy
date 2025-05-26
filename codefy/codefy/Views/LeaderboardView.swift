import SwiftUI
import FirebaseFirestore

struct LeaderboardView: View {
    @StateObject private var viewModel = LeaderboardViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.spaceCadet.ignoresSafeArea()
                
                Group {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.turquoise)
                    } else if let errorMessage = viewModel.errorMessage {
                        VStack(spacing: 20) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 50))
                                .foregroundColor(.naplesYellow)
                            Text(errorMessage)
                                .font(.headline)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            Button("Try Again") {
                                viewModel.fetchUsers()
                            }
                            .buttonStyle(.bordered)
                            .tint(.turquoise)
                        }
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(Array(viewModel.users.enumerated()), id: \.element.id) { index, user in
                                    LeaderboardRow(user: user, rank: index + 1)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .navigationTitle("Leaderboard")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color.spaceCadet, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .onAppear {
            viewModel.fetchUsers()
        }
    }
}

struct LeaderboardRow: View {
    let user: User
    let rank: Int
    
    var body: some View {
        HStack(spacing: 16) {
            // Rank
            Text("\(rank)")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(rankColor)
                .frame(width: 40)
            
            // User info
            VStack(alignment: .leading, spacing: 4) {
                Text(user.name)
                    .font(.headline)
                    .foregroundColor(.white)
                Text("\(user.totalQuestionsAnswered) questions answered")
                    .font(.subheadline)
                    .foregroundColor(.tropicalIndigo)
            }
            
            Spacer()
            
            // Points
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(user.points)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.turquoise)
                Text("points")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.spaceCadet.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.tropicalIndigo.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private var rankColor: Color {
        switch rank {
        case 1:
            return .naplesYellow
        case 2:
            return .tropicalIndigo
        case 3:
            return .turquoise
        default:
            return .white.opacity(0.7)
        }
    }
}

#Preview {
    LeaderboardView()
}
