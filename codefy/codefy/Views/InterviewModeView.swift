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
        ZStack {
            Color(hex: "1A1F36")
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                if showResults {
                    resultsView
                } else if !selectedQuestions.isEmpty && currentQuestionIndex < selectedQuestions.count {
                    questionView
                } else {
                    loadingView
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 30)
        }
        .onAppear {
            generateQuestions()
            startTimer()
        }
    }
    
    private var resultsView: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                Text("Interview Complete!")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Great job!")
                    .font(.title2)
                    .foregroundColor(Color(hex: "5EEAD4"))
            }
            
            VStack(spacing: 24) {
                resultCard(title: "Correct Answers", value: "\(correctAnswers) of \(selectedQuestions.count)")
                resultCard(title: "Final Score", value: "\(score) of \(totalPoints())")
            }
            
            VStack(spacing: 16) {
                Button(action: resetInterview) {
                    Text("Try Again")
                        .font(.headline)
                        .foregroundColor(Color(hex: "1A1F36"))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "5EEAD4"))
                        .cornerRadius(16)
                }
                
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Text("New Interview")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "818CF8"))
                        .cornerRadius(16)
                }
            }
        }
    }
    
    private var questionView: some View {
        let question = selectedQuestions[currentQuestionIndex]
        return VStack(spacing: 24) {
            // Timer
            HStack {
                Image(systemName: "timer")
                    .foregroundColor(Color(hex: "FFE45E"))
                Text("\(timeRemaining)s")
                    .font(.headline)
                    .foregroundColor(Color(hex: "FFE45E"))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(hex: "FFE45E").opacity(0.2))
            .cornerRadius(12)
            
            // Question
            Text(question.text)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.vertical)
            
            // Options
            VStack(spacing: 12) {
                ForEach(0..<question.options.count, id: \.self) { index in
                    Button(action: {
                        if index == question.correctOptionIndex {
                            correctAnswers += 1
                            score += question.points
                        }
                        nextQuestion()
                    }) {
                        Text(question.options[index])
                            .font(.body)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "818CF8").opacity(0.2))
                            .cornerRadius(16)
                    }
                }
            }
            
            // Progress
            Text("Question \(currentQuestionIndex + 1) of \(selectedQuestions.count)")
                .font(.subheadline)
                .foregroundColor(Color(hex: "5EEAD4"))
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "5EEAD4")))
            Text("Preparing your interview...")
                .font(.headline)
                .foregroundColor(.white)
        }
    }
    
    private func resultCard(title: String, value: String) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(Color(hex: "5EEAD4"))
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(hex: "818CF8").opacity(0.1))
        .cornerRadius(16)
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
