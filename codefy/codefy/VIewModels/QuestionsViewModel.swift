//
//  QuestionsViewModel.swift
//  codefy
//
//  Created by Jose Quezada Araiza on 24/05/25.
//

import Foundation
import SwiftUI

@MainActor
class QuestionsViewModel: ObservableObject {
    @Published var questions: [Question] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    
    private let questionService: QuestionService
    
    init(questionService: QuestionService = QuestionService()) {
        self.questionService = questionService
        Task {
            await fetchQuestions()
        }
    }
    
    func fetchQuestions() async {
        isLoading = true
        errorMessage = ""
        
        do {
            questions = try await questionService.fetchQuestions()
        } catch {
            errorMessage = "Error fetching questions: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func addQuestion(_ question: Question) async {
        do {
            try await questionService.createQuestion(question)
            await fetchQuestions() // Refresh the questions list
        } catch {
            errorMessage = "Error adding question: \(error.localizedDescription)"
        }
    }
    
    var groupedQuestions: [Category: [Question]] {
        Dictionary(grouping: questions, by: { $0.category })
    }
    
    func getRandomQuestion() -> Question? {
        return questions.randomElement()
    }
}
