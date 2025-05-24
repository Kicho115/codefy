//
//  InterviewModeView.swift
//  codefy
//
//  Created by Jose Quezada Araiza on 24/05/25.
//

import SwiftUI

struct InterviewModeView: View {
    @ObservedObject var questionsViewModel: QuestionsViewModel
    var selectedCategories: [Category]
    @State private var selectedQuestions: [Question] = []
    @State private var currentQuestionIndex = 0
    @State private var timeRemaining = 30
    @State private var score = 0
    @State private var correctAnswers = 0
    @State private var showResults = false
    @State private var timer: Timer?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 20) {
            if showResults {
                Text("¡Entrevista Terminada!")
                    .font(.title)
                    .bold()
                Text("Correctas: \(correctAnswers) de \(selectedQuestions.count)")
                Text("Puntuación: \(score) de \(totalPoints())")
                
                Button("Reiniciar") {
                    resetInterview()
                }
                .padding()
                .background(Color(hex: "007AFF"))
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Button("Nueva Entrevista") {
                    presentationMode.wrappedValue.dismiss()
                }
                .padding()
                .background(Color(hex: "34C759"))
                .foregroundColor(.white)
                .cornerRadius(10)
                
            } else if !selectedQuestions.isEmpty && currentQuestionIndex < selectedQuestions.count {
                let question = selectedQuestions[currentQuestionIndex]
                Text(question.text)
                    .font(.headline)
                    .padding()
                ForEach(0..<question.options.count, id: \.self) { index in
                    Button(action: {
                        if index == question.correctOptionIndex {
                            correctAnswers += 1
                            score += question.points
                        }
                        nextQuestion()
                    }) {
                        Text(question.options[index])
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(hex: "AF52DE").opacity(0.2))
                            .cornerRadius(10)
                    }
                }
                Text("Tiempo restante: \(timeRemaining) s")
                    .foregroundColor(.red)
            } else {
                Text("Cargando preguntas...")
            }
        }
        .padding()
        .onAppear {
            generateQuestions()
            startTimer()
        }
    }
    
    func generateQuestions() {
        var filtered = questionsViewModel.questions.filter { selectedCategories.contains($0.category) }
        
        if selectedCategories == [.uncategorized] {
            selectedQuestions = filtered.shuffled()
        } else {
            if filtered.count < 8 {
                let extra = questionsViewModel.questions
                    .filter { !selectedCategories.contains($0.category) }
                    .shuffled()
                    .prefix(8 - filtered.count)
                filtered.append(contentsOf: extra)
            }
            selectedQuestions = Array(filtered.shuffled().prefix(8))
        }
    }
    
    func totalPoints() -> Int {
        selectedQuestions.reduce(0) { $0 + $1.points }
    }
    
    func nextQuestion() {
        timeRemaining = 30
        currentQuestionIndex += 1
        if currentQuestionIndex >= selectedQuestions.count {
            showResults = true
            timer?.invalidate()
        }
    }
    
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                nextQuestion()
            }
        }
    }
    
    func resetInterview() {
        currentQuestionIndex = 0
        score = 0
        correctAnswers = 0
        showResults = false
        generateQuestions()
        startTimer()
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
