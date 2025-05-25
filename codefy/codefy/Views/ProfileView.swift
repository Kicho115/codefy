import SwiftUI
import PhotosUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var selectedItem: PhotosPickerItem?
    @State private var showingImagePicker = false
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                } else if let user = viewModel.user {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Profile Header
                            VStack(spacing: 12) {
                                if let photoUrl = user.photoUrl,
                                   let url = URL(string: photoUrl) {
                                    Menu {
                                        Button(action: {
                                            showingImagePicker = true
                                        }) {
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
                                        .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                                    }
                                } else {
                                    Menu {
                                        Button(action: {
                                            showingImagePicker = true
                                        }) {
                                            Label("Change Profile Picture", systemImage: "photo")
                                        }
                                    } label: {
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .frame(width: 100, height: 100)
                                            .foregroundColor(.blue)
                                    }
                                }
                                
                                Text(user.name)
                                    .font(.title)
                                    .bold()
                                
                                HStack {
                                    if viewModel.isUserActive {
                                        HStack(spacing: 4) {
                                            Circle()
                                                .fill(Color.green)
                                                .frame(width: 8, height: 8)
                                            Text("Active now")
                                                .font(.subheadline)
                                                .foregroundColor(.green)
                                        }
                                    } else {
                                        Text("Last login: \(user.formattedLastLogin)")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Text("•")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text("Member since \(user.formattedMemberSince)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.top)
                            
                            // Stats Grid
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
                            
                            Spacer()
                        }
                    }
                } else if let error = viewModel.error {
                    VStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        Text("Error loading profile")
                            .font(.headline)
                        Text(error.localizedDescription)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                }
            }
            .navigationTitle("Profile")
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
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.title3)
                .bold()
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    ProfileView()
} 
