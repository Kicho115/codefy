import SwiftUI

struct QuestionDetailView: View {
    let question: Question
    @StateObject private var viewModel: QuestionDetailViewModel
    @AppStorage("userId") private var userId: String = ""
    
    init(question: Question) {
        self.question = question
        _viewModel = StateObject(wrappedValue: QuestionDetailViewModel(question: question, userId: UserDefaults.standard.string(forKey: "userId") ?? ""))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(question.text)
                    .font(.title2)
                    .bold()
                
                if viewModel.isAnswered || viewModel.wasPreviouslyAnswered {
                    // Show feedback after answering or for previously answered questions
                    HStack {
                        Image(systemName: (viewModel.isCorrect || viewModel.previousAnswerWasCorrect) ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor((viewModel.isCorrect || viewModel.previousAnswerWasCorrect) ? .green : .red)
                            .font(.title)
                        Text((viewModel.isCorrect || viewModel.previousAnswerWasCorrect) ? "Correct!" : "Incorrect")
                            .font(.title3)
                            .foregroundColor((viewModel.isCorrect || viewModel.previousAnswerWasCorrect) ? .green : .red)
                    }
                    .padding()
                    .background((viewModel.isCorrect || viewModel.previousAnswerWasCorrect) ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                    .cornerRadius(10)
                }
                
                ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                    Button(action: {
                        if !viewModel.isAnswered && !viewModel.wasPreviouslyAnswered {
                            viewModel.selectedAnswer = index
                            viewModel.checkAnswer(selectedIndex: index)
                        }
                    }) {
                        HStack {
                            Text("\(index + 1). \(option)")
                                .foregroundColor(.primary)
                            Spacer()
                            if viewModel.selectedAnswer == index {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                            if (viewModel.isAnswered || viewModel.wasPreviouslyAnswered) && index == question.correctOptionIndex {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.green)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(viewModel.selectedAnswer == index ? Color.blue.opacity(0.1) : Color(.systemGray6))
                        )
                    }
                    .disabled(viewModel.isAnswered || viewModel.wasPreviouslyAnswered)
                }
                
                if viewModel.isAnswered || viewModel.wasPreviouslyAnswered {
                    Text("Points: \(question.points)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.top)
                }
                
                Spacer()
            }
            .padding()
        }
        .task {
            await viewModel.checkIfQuestionWasAnswered()
        }
    }
} 