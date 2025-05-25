//
//  QuestionsView.swift
//  codefy
//
//  Created by Jose Quezada Araiza on 23/05/25.
//

import SwiftUI
import FirebaseFirestore

struct QuestionsView: View {
    @ObservedObject var viewModel: QuestionsViewModel
    @State private var selectedCategory: Category? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Questions")
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)

                Text("Select your category")
                    .font(.system(size: 20, weight: .regular, design: .rounded))
                    .foregroundColor(.gray)
                    .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(Category.allCases, id: \.self) { category in
                            Button(action: {
                                selectedCategory = category
                            }) {
                                VStack {
                                    Image(systemName: iconForCategory(category))
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(colorForCategory(category))
                                        .clipShape(Circle())

                                    Text(titleForCategory(category))
                                        .font(.caption)
                                        .foregroundColor(.primary)
                                }
                                .padding(8)
                                .background(selectedCategory == category ? colorForCategory(category).opacity(0.3) : Color.clear)
                                .cornerRadius(12)
                            }
                        }
                    }.padding(.horizontal)
                }

                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                } else if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else if let category = selectedCategory, let questions = viewModel.groupedQuestions[category] {
                    Text("Questions in \(titleForCategory(category))")
                        .font(.title3)
                        .bold()
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(questions) { question in
                                NavigationLink(destination: QuestionDetailView(question: question)) {
                                    VStack(alignment: .leading) {
                                        Text(question.text)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                            .lineLimit(2)

                                        Text("Points: \(question.points)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding()
                                    .frame(width: 200, height: 120)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                } else {
                    Spacer().frame(height: 200)
                }
            }
        }
        .refreshable {
            await viewModel.fetchQuestions()
        }
    }

    private func iconForCategory(_ category: Category) -> String {
        switch category {
        case .oop: return "square.stack.fill"
        case .webdev: return "globe"
        case .humanResources: return "person.2.fill"
        case .structure: return "list.bullet.rectangle"
        case .uncategorized: return "questionmark.circle"
        case .swift: return "sparkles"
        }
    }
    
    private func titleForCategory(_ category: Category) -> String {
        switch category {
        case .oop: return "OOP"
        case .webdev: return "WebDev"
        case .humanResources: return "HR"
        case .structure: return "Data Structures"
        case .swift: return "Swift"
        case .uncategorized: return "Other"
        }
    }
    
    private func colorForCategory(_ category: Category) -> Color {
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

struct QuestionDetailView: View {
    var question: Question
    @State private var selectedAnswer: Int? = nil
    @State private var showFeedback = false
    @State private var isCorrect = false
    @State private var isAnswered = false
    @AppStorage("userId") private var userId: String = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(question.text)
                    .font(.title2)
                    .bold()
                
                if isAnswered {
                    // Show feedback after answering
                    HStack {
                        Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(isCorrect ? .green : .red)
                            .font(.title)
                        Text(isCorrect ? "Correct!" : "Incorrect")
                            .font(.title3)
                            .foregroundColor(isCorrect ? .green : .red)
                    }
                    .padding()
                    .background(isCorrect ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                    .cornerRadius(10)
                }
                
                ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                    Button(action: {
                        if !isAnswered {
                            selectedAnswer = index
                            checkAnswer(selectedIndex: index)
                        }
                    }) {
                        HStack {
                            Text("\(index + 1). \(option)")
                                .foregroundColor(.primary)
                            Spacer()
                            if selectedAnswer == index {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                            if isAnswered && index == question.correctOptionIndex {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.green)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(selectedAnswer == index ? Color.blue.opacity(0.1) : Color(.systemGray6))
                        )
                    }
                    .disabled(isAnswered)
                }
                
                if isAnswered {
                    Text("Points: \(question.points)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.top)
                }
                
                Spacer()
            }
            .padding()
        }
    }
    
    private func checkAnswer(selectedIndex: Int) {
        isAnswered = true
        isCorrect = selectedIndex == question.correctOptionIndex
        
        if isCorrect {
            Task {
                await updateUserStats()
            }
        }
    }
    
    private func updateUserStats() async {
        do {
            // Get current user data
            let userData = try await FirebaseService.shared.getUserData(userId: userId)
            guard var userData = userData else { return }
            
            // Update stats
            userData["totalQuestionsAnswered"] = (userData["totalQuestionsAnswered"] as? Int ?? 0) + 1
            userData["correctAnswers"] = (userData["correctAnswers"] as? Int ?? 0) + 1
            userData["points"] = (userData["points"] as? Int ?? 0) + question.points
            
            // Update completed questions
            var completedQuestions = userData["completedQuestions"] as? [String] ?? []
            if !completedQuestions.contains(question.id) {
                completedQuestions.append(question.id)
                userData["completedQuestions"] = completedQuestions
            }
            
            // Update daily streak if this is the first question answered today
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let lastLogin = (userData["lastLoginAt"] as? Timestamp)?.dateValue() ?? Date()
            let lastLoginDay = calendar.startOfDay(for: lastLogin)
            
            if calendar.isDate(today, inSameDayAs: lastLoginDay) {
                // Same day, no need to update streak
            } else if calendar.isDateInYesterday(lastLoginDay) {
                // Yesterday, increment streak
                userData["dailyQuestionStreak"] = (userData["dailyQuestionStreak"] as? Int ?? 0) + 1
            } else {
                // More than a day ago, reset streak
                userData["dailyQuestionStreak"] = 1
            }
            
            // Update last login time
            userData["lastLoginAt"] = Timestamp(date: Date())
            
            // Save updated user data
            try await FirebaseService.shared.saveUserData(userId: userId, data: userData)
        } catch {
            print("Error updating user stats: \(error)")
        }
    }
}
