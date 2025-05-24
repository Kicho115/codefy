import Foundation

enum Category: String, Codable, CaseIterable {
    case oop = "OOP"
    case webdev = "WebDev"
    case swift = "Swift"
    case estructure = "Data Estructure"
    case humanResources = "Human Resources"
    case uncategorized = "Uncategorized"
}

struct Question: Identifiable, Codable {
    var id: String
    var text: String
    var options: [String]
    var correctOptionIndex: Int
    var points: Int
    var createdAt: Date
    var createdBy: String
    var category: Category
    
    init(id: String = UUID().uuidString,
         text: String,
         options: [String],
         correctOptionIndex: Int,
         points: Int,
         createdAt: Date = Date(),
         createdBy: String,
         category: Category = .uncategorized) {
        self.id = id
        self.text = text
        self.options = options
        self.correctOptionIndex = correctOptionIndex
        self.points = points
        self.createdAt = createdAt
        self.createdBy = createdBy
        self.category = category
    }
} 
