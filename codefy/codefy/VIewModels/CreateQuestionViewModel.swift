import Foundation
import SwiftUI

@MainActor
class CreateQuestionViewModel: ObservableObject {
    @Published var questionText: String = ""
    @Published var options: [String] = ["", "", "", ""]
    @Published var correctOptionIndex: Int = 0
    @Published var points: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var category: Category = .uncategorized
    
    private let questionService: QuestionService
    
    init(questionService: QuestionService = QuestionService()) {
        self.questionService = questionService
    }
    
    var isValidPoints: Bool {
        guard let pointsInt = Int(points) else { return false }
        return pointsInt >= 1 && pointsInt <= 10
    }
    
    var isValidForm: Bool {
        !questionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        options.allSatisfy { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty } &&
        isValidPoints
    }
    
    func createQuestion(userId: String) async {
        guard isValidForm,
              let pointsInt = Int(points) else {
            errorMessage = "Complete all fields correctly"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let question = Question(
            text: questionText,
            options: options,
            correctOptionIndex: correctOptionIndex,
            points: pointsInt,
            createdBy: userId,
            category: category
        )
        
        do {
            try await questionService.createQuestion(question)
            resetForm()
        } catch {
            errorMessage = "Error creating question: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func resetForm() {
        questionText = ""
        options = ["", "", "", ""]
        correctOptionIndex = 0
        points = ""
        category = .swift
    }
} 