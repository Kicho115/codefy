import SwiftUI
import PhotosUI

// MARK: - Profile Header View
struct ProfileHeaderView: View {
    let user: User
    let isUserActive: Bool
    let showingImagePicker: Bool
    let photoUrl: String?
    let onImagePickerTap: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            ProfileImageView(
                photoUrl: photoUrl,
                showingImagePicker: showingImagePicker,
                onImagePickerTap: onImagePickerTap
            )
            
            Text(user.name)
                .font(.title)
                .bold()
                .foregroundColor(.white)
            
            UserStatusView(
                isUserActive: isUserActive,
                lastLogin: user.formattedLastLogin,
                memberSince: user.formattedMemberSince
            )
        }
        .padding(.top)
    }
}

// MARK: - Profile Image View
struct ProfileImageView: View {
    let photoUrl: String?
    let showingImagePicker: Bool
    let onImagePickerTap: () -> Void
    
    var body: some View {
        if let photoUrl = photoUrl,
           let url = URL(string: photoUrl) {
            Menu {
                Button(action: onImagePickerTap) {
                    Label("Change Profile Picture", systemImage: "photo")
                }
            } label: {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                }
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.tropicalIndigo, lineWidth: 2))
            }
        } else {
            Menu {
                Button(action: onImagePickerTap) {
                    Label("Change Profile Picture", systemImage: "photo")
                }
            } label: {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.tropicalIndigo)
            }
        }
    }
}

// MARK: - User Status View
struct UserStatusView: View {
    let isUserActive: Bool
    let lastLogin: String
    let memberSince: String
    
    var body: some View {
        HStack {
            if isUserActive {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.turquoise)
                        .frame(width: 8, height: 8)
                    Text("Active now")
                        .font(.subheadline)
                        .foregroundColor(.turquoise)
                }
            } else {
                Text("Last login: \(lastLogin)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Text("•")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
            Text("Member since \(memberSince)")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

// MARK: - Stats Grid View
struct StatsGridView: View {
    let user: User
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 20) {
            StatCard(title: "Points", value: "\(user.points)", icon: "star.fill")
            StatCard(title: "Rank", value: "\(user.rank)", icon: "trophy.fill")
            StatCard(title: "Streak", value: "\(user.streak) days", icon: "flame.fill")
            StatCard(title: "Questions Answered", value: "\(user.totalQuestionsAnswered)", icon: "questionmark.circle.fill")
        }
        .padding(.horizontal)
    }
}

// MARK: - Main Profile View
struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var selectedItem: PhotosPickerItem?
    @State private var showingImagePicker = false
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    LoadingView()
                } else if let user = viewModel.user {
                    ProfileContentView(
                        user: user,
                        isUserActive: viewModel.isUserActive,
                        showingImagePicker: showingImagePicker,
                        onImagePickerTap: { showingImagePicker = true },
                        onSignOut: signOut
                    )
                } else if let error = viewModel.error {
                    ErrorView(error: error)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color.spaceCadet, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .photosPicker(isPresented: $showingImagePicker,
                         selection: $selectedItem,
                         matching: .images)
            .onChange(of: selectedItem) { oldValue, newValue in
                if let newValue {
                    Task {
                        if let data = try? await newValue.loadTransferable(type: Data.self) {
                            await viewModel.updateProfilePhoto(data)
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.loadUserProfile()
            await viewModel.updateLastLogin()
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

// MARK: - Loading View
struct LoadingView: View {
    var body: some View {
        ProgressView()
            .scaleEffect(1.5)
            .foregroundColor(.turquoise)
    }
}

// MARK: - Error View
struct ErrorView: View {
    let error: Error
    
    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundColor(.naplesYellow)
            Text("Error loading profile")
                .font(.headline)
                .foregroundColor(.white)
            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding()
        }
        .background(Color.spaceCadet)
    }
}

// MARK: - Profile Content View
struct ProfileContentView: View {
    let user: User
    let isUserActive: Bool
    let showingImagePicker: Bool
    let onImagePickerTap: () -> Void
    let onSignOut: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ProfileHeaderView(
                    user: user,
                    isUserActive: isUserActive,
                    showingImagePicker: showingImagePicker,
                    photoUrl: user.photoUrl,
                    onImagePickerTap: onImagePickerTap
                )
                
                StatsGridView(user: user)
                
                SignOutButton(onSignOut: onSignOut)
                
                Spacer()
            }
        }
        .background(Color.spaceCadet)
    }
}

// MARK: - Sign Out Button
struct SignOutButton: View {
    let onSignOut: () -> Void
    
    var body: some View {
        Button(action: onSignOut) {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .foregroundColor(.naplesYellow)
                Text("Sign Out")
                    .foregroundColor(.naplesYellow)
                Spacer()
            }
            .padding()
            .background(Color.spaceCadet)
            .cornerRadius(12)
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.tropicalIndigo)
            
            Text(value)
                .font(.title3)
                .bold()
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.spaceCadet.opacity(0.5))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.tropicalIndigo.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    ProfileView()
}
