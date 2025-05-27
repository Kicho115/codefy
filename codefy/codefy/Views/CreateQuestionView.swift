import SwiftUI

struct CreateQuestionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var questionsViewModel: QuestionsViewModel
    @StateObject private var viewModel: CreateQuestionViewModel
    @AppStorage("userId") private var userId: String = ""

    init(questionsViewModel: QuestionsViewModel) {
        self.questionsViewModel = questionsViewModel
        _viewModel = StateObject(wrappedValue: CreateQuestionViewModel())
    }

    private func iconForCategory(_ category: Category) -> String {
        switch category {
        case .oop:
            return "square.stack.fill"
        case .webdev:
            return "globe"
        case .humanResources:
            return "person.2.fill"
        case .structure:
            return "list.bullet.rectangle"
        case .uncategorized:
            return "questionmark.circle"
        case .swift:
            return "sparkles"
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

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    GroupBox(label: EmptyView()) {
                        HStack {
                            Image(systemName: "text.book.closed")
                                .foregroundColor(.white)
                            Text("Question")
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                        .padding(.bottom, 4)
                        CustomPlaceholderTextField(placeholder: "Enter your question", text: $viewModel.questionText)
                            .padding(5)
                    }
                    .groupBoxStyle(TransparentGroupBoxStyle())

                    GroupBox(label: EmptyView()) {
                        HStack {
                            Image(systemName: "tag")
                                .foregroundColor(.white)
                            Text("Category")
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                        .padding(.bottom, 4)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(Category.allCases, id: \.self) { category in
                                    Button(action: {
                                        viewModel.category = category
                                    }) {
                                        VStack {
                                            Image(systemName: iconForCategory(category))
                                                .font(.system(size: 24))
                                                .foregroundColor(.white)
                                                .padding()
                                                .background(colorForCategory(category))
                                                .clipShape(Circle())
                                                .shadow(color: colorForCategory(category).opacity(0.5), radius: 4, x: 0, y: 2)

                                            Text(category.rawValue)
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .foregroundColor(.white)
                                        }
                                        .padding(8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(viewModel.category == category ? 
                                                    colorForCategory(category).opacity(0.3) : 
                                                    Color.spaceCadet.opacity(0.7))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(viewModel.category == category ? 
                                                    colorForCategory(category) : 
                                                    Color.tropicalIndigo.opacity(0.3), 
                                                    lineWidth: viewModel.category == category ? 2 : 1)
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .groupBoxStyle(TransparentGroupBoxStyle())

                    GroupBox(label: EmptyView()) {
                        HStack {
                            Image(systemName: "list.bullet")
                                .foregroundColor(.white)
                            Text("Options")
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                        .padding(.bottom, 4)
                        VStack(spacing: 12) {
                            ForEach(0..<4) { index in
                                CustomPlaceholderTextField(placeholder: "Option \(index + 1)", text: $viewModel.options[index])
                                    .padding(.vertical, 2)
                            }
                        }
                    }
                    .groupBoxStyle(TransparentGroupBoxStyle())

                    GroupBox(label: EmptyView()) {
                        HStack {
                            Image(systemName: "number.circle")
                                .foregroundColor(.white)
                            Text("Points")
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                        .padding(.bottom, 4)
                        VStack(spacing: 8) {
                            CustomPlaceholderTextField(placeholder: "Points (1-10)", text: $viewModel.points, keyboardType: .numberPad)
                                .padding(5)
                            if !viewModel.isValidPoints && !viewModel.points.isEmpty {
                                Text("Points must be between 1 and 10")
                                    .foregroundColor(.naplesYellow)
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                        }
                    }
                    .groupBoxStyle(TransparentGroupBoxStyle())

                    GroupBox(label: EmptyView()) {
                        HStack {
                            Image(systemName: "checkmark.circle")
                                .foregroundColor(.white)
                            Text("Correct Answer")
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                        .padding(.bottom, 4)
                        HStack(spacing: 8) {
                            ForEach(0..<4) { index in
                                Button(action: {
                                    viewModel.correctOptionIndex = index
                                }) {
                                    Text("Option \(index + 1)")
                                        .fontWeight(viewModel.correctOptionIndex == index ? .bold : .regular)
                                        .foregroundColor(viewModel.correctOptionIndex == index ? .white : Color.white.opacity(0.7))
                                        .padding(.vertical, 8)
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            viewModel.correctOptionIndex == index ? Color.tropicalIndigo : Color.clear
                                        )
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.tropicalIndigo.opacity(0.5), lineWidth: 1)
                                        )
                                }
                            }
                        }
                        .background(Color.spaceCadet.opacity(0.7))
                        .cornerRadius(8)
                        .padding(.vertical, 4)
                    }
                    .groupBoxStyle(TransparentGroupBoxStyle())

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.naplesYellow)
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color.spaceCadet.opacity(0.7))
                            .cornerRadius(8)
                    }

                    Button(action: {
                        Task {
                            await viewModel.createQuestion(userId: userId)
                            dismiss()
                        }
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Save Question")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    viewModel.isValidForm ? 
                                        Color.tropicalIndigo : 
                                        Color.gray.opacity(0.5)
                                )
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .shadow(color: viewModel.isValidForm ? 
                                    Color.tropicalIndigo.opacity(0.3) : 
                                    Color.clear, 
                                    radius: 4, x: 0, y: 2)
                        }
                    }
                    .disabled(!viewModel.isValidForm || viewModel.isLoading)
                    .padding(.bottom)
                }
                .padding(.horizontal)
            }
            .background(Color.spaceCadet)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Create Question")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

struct DarkTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(10)
            .background(Color.spaceCadet.opacity(0.7))
            .cornerRadius(8)
            .foregroundColor(.white)
            .accentColor(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.tropicalIndigo.opacity(0.5), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct TransparentGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.content
            .padding()
            .background(Color.spaceCadet.opacity(0.7))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.tropicalIndigo.opacity(0.5), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// Custom TextField with placeholder color
struct CustomPlaceholderTextField: View {
    var placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(Color.white)
                    .padding(.leading, 16)
            }
            TextField("", text: $text)
                .keyboardType(keyboardType)
                .padding(10)
                .background(Color.spaceCadet.opacity(0.7))
                .cornerRadius(8)
                .foregroundColor(.white)
                .accentColor(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.tropicalIndigo.opacity(0.5), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
    }
}
