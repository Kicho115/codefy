//
//  QuestionsView.swift
//  codefy
//
//  Created by Jose Quezada Araiza on 23/05/25.
//

import SwiftUI

struct QuestionsView: View {
    @ObservedObject var viewModel: QuestionsViewModel
    @State private var selectedCategory: Category? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Preguntas")
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)

                Text("Escoge tu categoría")
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
                    Text("Preguntas de \(titleForCategory(category))")
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

                                        Text("Puntos: \(question.points)")
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
        case .estructure: return "list.bullet.rectangle"
        case .uncategorized: return "questionmark.circle"
        case .swift: return "sparkles"
        }
    }
    
    private func titleForCategory(_ category: Category) -> String {
        switch category {
        case .oop: return "OOP"
        case .webdev: return "WebDev"
        case .humanResources: return "HR"
        case .estructure: return "Data Structures"
        case .swift: return "Swift"
        case .uncategorized: return "Other"
        }
    }
    
    private func colorForCategory(_ category: Category) -> Color {
        switch category {
        case .oop: return .blue
        case .webdev: return .green
        case .humanResources: return .orange
        case .estructure: return .purple
        case .uncategorized: return .gray
        case .swift: return .red
        }
    }
}

struct QuestionDetailView: View {
    var question: Question
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(question.text)
                    .font(.title2)
                    .bold()
                ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                    HStack {
                        Text("\(index + 1). \(option)")
                        if index == question.correctOptionIndex {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.green)
                        }
                    }
                }
                Spacer()
            }
            .padding()
        }
    }
}
