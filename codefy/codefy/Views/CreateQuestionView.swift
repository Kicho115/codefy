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

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
 
                    
                    GroupBox(label: Label("Question", systemImage: "text.book.closed").foregroundColor(.blue)) {
                        TextField("Enter your question", text: $viewModel.questionText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(5)
                    }

                    GroupBox(label: Label("Category", systemImage: "tag").foregroundColor(.purple)) {
                        Picker("Select category", selection: $viewModel.category) {
                            ForEach(Category.allCases, id: \.self) { category in
                                Text(category.rawValue).tag(category)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(5)
                    }

                    GroupBox(label: Label("Options", systemImage: "list.bullet").foregroundColor(.green)) {
                        ForEach(0..<4) { index in
                            TextField("Option \(index + 1)", text: $viewModel.options[index])
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.vertical, 2)
                        }
                    }

                    GroupBox(label: Label("Points", systemImage: "number.circle").foregroundColor(.orange)) {
                        TextField("Points (1-10)", text: $viewModel.points)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(5)
                        if !viewModel.isValidPoints && !viewModel.points.isEmpty {
                            Text("Points must be between 1 and 10")
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }

                    GroupBox(label: Label("Correct Answer", systemImage: "checkmark.circle").foregroundColor(.green)) {
                        Picker("Select correct option", selection: $viewModel.correctOptionIndex) {
                            ForEach(0..<4) { index in
                                Text("Option \(index + 1)").tag(index)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(5)
                    }

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.horizontal)
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
                                .background(viewModel.isValidForm ? Color.blue : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .disabled(!viewModel.isValidForm || viewModel.isLoading)
                    .padding(.bottom)
                }
                .padding(.horizontal)
            }
            .navigationTitle("Create Question")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
}
