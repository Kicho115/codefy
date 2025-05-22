import Foundation
import FirebaseFirestore

enum QuestionError: Error {
    case creationFailed
    case fetchFailed
    case invalidData
}

class QuestionService {
    private let db = Firestore.firestore()
    private let questionsCollection = "questions"
    
    func createQuestion(_ question: Question) async throws {
        do {
            try db.collection(questionsCollection).document(question.id).setData(from: question)
        } catch {
            print("Error creating question: \(error)")
            throw QuestionError.creationFailed
        }
    }
    
    func fetchQuestions() async throws -> [Question] {
        do {
            let snapshot = try await db.collection(questionsCollection)
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            return try snapshot.documents.compactMap { document in
                try document.data(as: Question.self)
            }
        } catch {
            print("Error fetching questions: \(error)")
            throw QuestionError.fetchFailed
        }
    }
    
    func fetchQuestionsByUser(userId: String) async throws -> [Question] {
        do {
            let snapshot = try await db.collection(questionsCollection)
                .whereField("createdBy", isEqualTo: userId)
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            return try snapshot.documents.compactMap { document in
                try document.data(as: Question.self)
            }
        } catch {
            print("Error fetching user questions: \(error)")
            throw QuestionError.fetchFailed
        }
    }
} 
