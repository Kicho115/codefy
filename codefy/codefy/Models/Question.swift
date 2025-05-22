import Foundation

struct Question: Identifiable, Codable {
    var id: String
    var text: String
    var options: [String]
    var correctOptionIndex: Int
    var points: Int
    var createdAt: Date
    var createdBy: String
    
    init(id: String = UUID().uuidString,
         text: String,
         options: [String],
         correctOptionIndex: Int,
         points: Int,
         createdAt: Date = Date(),
         createdBy: String) {
        self.id = id
        self.text = text
        self.options = options
        self.correctOptionIndex = correctOptionIndex
        self.points = points
        self.createdAt = createdAt
        self.createdBy = createdBy
    }
} 