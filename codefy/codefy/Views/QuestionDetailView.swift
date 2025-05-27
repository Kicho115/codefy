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
                // Creator information
                if let creator = viewModel.creator {
                    HStack(spacing: 12) {
                        if let photoUrl = creator.photoUrl,
                           let url = URL(string: photoUrl) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Image(systemName: "person.circle.fill")
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(creator.name)
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("Created \(question.createdAt.formatted(.relative(presentation: .named)))")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        Spacer()
                    }
                    .padding(.bottom, 8)
                }
                
                HStack {
                    Text(question.text)
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        Task {
                            await viewModel.toggleFavorite()
                        }
                    }) {
                        Image(systemName: viewModel.isFavorited ? "star.fill" : "star")
                            .foregroundColor(viewModel.isFavorited ? .naplesYellow : .white)
                            .font(.title2)
                    }
                }
                
                if viewModel.isAnswered || viewModel.wasPreviouslyAnswered {
                    // Show feedback after answering or for previously answered questions
                    HStack {
                        Image(systemName: (viewModel.isCorrect || viewModel.previousAnswerWasCorrect) ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor((viewModel.isCorrect || viewModel.previousAnswerWasCorrect) ? .turquoise : .naplesYellow)
                            .font(.title)
                        Text((viewModel.isCorrect || viewModel.previousAnswerWasCorrect) ? "Correct!" : "Incorrect")
                            .font(.title3)
                            .foregroundColor((viewModel.isCorrect || viewModel.previousAnswerWasCorrect) ? .turquoise : .naplesYellow)
                    }
                    .padding()
                    .background((viewModel.isCorrect || viewModel.previousAnswerWasCorrect) ? Color.turquoise.opacity(0.1) : Color.naplesYellow.opacity(0.1))
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
                                .foregroundColor(.white)
                            Spacer()
                            if viewModel.selectedAnswer == index {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.tropicalIndigo)
                            }
                            if (viewModel.isAnswered || viewModel.wasPreviouslyAnswered) && index == question.correctOptionIndex {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.turquoise)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(viewModel.selectedAnswer == index ? Color.tropicalIndigo.opacity(0.2) : Color.tropicalIndigo.opacity(0.1))
                        )
                    }
                    .disabled(viewModel.isAnswered || viewModel.wasPreviouslyAnswered)
                }
                
                if viewModel.isAnswered || viewModel.wasPreviouslyAnswered {
                    Text("Points: \(question.points)")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top)
                }
                
                Spacer()
            }
            .padding()
        }
        .background(Color.spaceCadet)
        .task {
            await viewModel.checkIfQuestionWasAnswered()
        }
    }
} 