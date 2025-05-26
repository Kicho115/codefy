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
    @State private var isExpanded = false
    
    // Custom colors
    private let spaceCadet = Color(hex: "1A1F36")
    private let turquoise = Color(hex: "5EEAD4")
    private let tropicalIndigo = Color(hex: "818CF8")
    private let naplesYellow = Color(hex: "FFE45E")
    private let white = Color.white

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Questions")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(white)
                    .padding(.horizontal)
                    .padding(.top)

                Text("Select your category")
                    .font(.system(size: 20, weight: .regular, design: .rounded))
                    .foregroundColor(white.opacity(0.8))
                    .padding(.horizontal)

                VStack(spacing: 16) {
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 100, maximum: 120), spacing: 16)
                    ], spacing: 16) {
                        ForEach(Array(Category.allCases.prefix(isExpanded ? Category.allCases.count : 3)), id: \.self) { category in
                            CategoryButton(
                                category: category,
                                isSelected: selectedCategory == category,
                                icon: iconForCategory(category),
                                title: titleForCategory(category),
                                color: colorForCategory(category),
                                action: {
                                    withAnimation(.spring()) {
                                        selectedCategory = category
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    if Category.allCases.count > 3 {
                        Button(action: {
                            withAnimation(.spring()) {
                                isExpanded.toggle()
                            }
                        }) {
                            Text(isExpanded ? "Show Less" : "Show More")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(tropicalIndigo)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(tropicalIndigo.opacity(0.1))
                                .cornerRadius(20)
                        }
                    }
                }

                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: turquoise))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                } else if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(naplesYellow)
                        .padding()
                        .background(naplesYellow.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                } else {
                    VStack(alignment: .leading, spacing: 16) {
                        if let category = selectedCategory {
                            Text("Questions in \(titleForCategory(category))")
                                .font(.title3)
                                .bold()
                                .foregroundColor(white)
                                .padding(.horizontal)
                        }

                        LazyVStack(spacing: 12) {
                            ForEach(selectedCategory == nil ? viewModel.questions : viewModel.groupedQuestions[selectedCategory!] ?? []) { question in
                                NavigationLink(destination: QuestionDetailView(question: question)) {
                                    QuestionCard(question: question)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .background(spaceCadet)
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
        case .oop: return turquoise
        case .webdev: return tropicalIndigo
        case .humanResources: return naplesYellow
        case .structure: return turquoise
        case .uncategorized: return tropicalIndigo
        case .swift: return naplesYellow
        }
    }
}

struct CategoryButton: View {
    let category: Category
    let isSelected: Bool
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .padding()
                    .background(color)
                    .clipShape(Circle())
                
                Text(title)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(isSelected ? color.opacity(0.3) : Color.clear)
            .cornerRadius(16)
        }
    }
}
