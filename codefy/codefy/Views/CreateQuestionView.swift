import SwiftUI

struct CreateQuestionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CreateQuestionViewModel()
    @AppStorage("userId") private var userId: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Question")) {
                    TextField("Enter your question", text: $viewModel.questionText)
                }
                
                Section(header: Text("Options")) {
                    ForEach(0..<4) { index in
                        TextField("Option \(index + 1)", text: $viewModel.options[index])
                    }
                }
                
                Section(header: Text("Points")) {
                    TextField("Points (1-10)", text: $viewModel.points)
                        .keyboardType(.numberPad)
                    
                    if !viewModel.isValidPoints && !viewModel.points.isEmpty {
                        Text("Points must be between 1 and 10")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                Section(header: Text("Correct Answer")) {
                    Picker("Select correct option", selection: $viewModel.correctOptionIndex) {
                        ForEach(0..<4) { index in
                            Text("Option \(index + 1)").tag(index)
                        }
                    }
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                Section {
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
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                        }
                    }
                    .listRowBackground(!viewModel.isValidForm ? Color.gray : Color.blue)
                    .disabled(!viewModel.isValidForm || viewModel.isLoading)
                }
            }
            .navigationTitle("Create Question")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
}

#Preview {
    CreateQuestionView()
} 
