//
//  DailyQuestionView.swift
//  codefy
//
//  Created by Jose Quezada Araiza on 24/05/25.
//
import SwiftUI

struct DailyQuestionView: View {
    @ObservedObject var viewModel: DailyQuestionViewModel
    @State private var feedbackMessage: String? = nil
    @State private var answered = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Pregunta del Día")
                    .font(.largeTitle)
                    .bold()
                
                if let question = viewModel.todayQuestion {
                    Text(question.text)
                        .font(.title3)
                        .padding()
                    
                    if viewModel.alreadyAnsweredToday {
                        Text("Ya contestaste, vuelve mañana.")
                            .foregroundColor(.red)
                            .font(.headline)
                            .padding()
                    } else {
                        ForEach(0..<question.options.count, id: \.self) { index in
                            Button(action: {
                                checkAnswer(selectedIndex: index, correctIndex: question.correctOptionIndex)
                            }) {
                                Text(question.options[index])
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(10)
                            }
                            .disabled(answered) // Desactiva botones tras contestar
                        }
                    }
                    
                    if let message = feedbackMessage {
                        Text(message)
                            .foregroundColor(message == "Correcto!" ? .green : .red)
                            .font(.headline)
                            .padding()
                    }
                    
                    Text("Categoría: \(question.category.rawValue)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.top, 10)
                } else {
                    ProgressView("Cargando pregunta...")
                }
            }
            .padding()
        }
    }
    
    private func checkAnswer(selectedIndex: Int, correctIndex: Int) {
        answered = true
        if selectedIndex == correctIndex {
            feedbackMessage = "Correcto!"
        } else {
            feedbackMessage = "Incorrecto"
        }
        viewModel.markQuestionAsAnswered()
    }
}
