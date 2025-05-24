import Foundation
import FirebaseFirestore

enum Category: String, Codable, CaseIterable {
    case oop = "OOP"
    case webdev = "WebDev"
    case swift = "Swift"
    case structure = "Data Structures"
    case humanResources = "Human Resources"
    case uncategorized = "Uncategorized"
    
    enum CodingKeys: String, CodingKey {
        case rawValue
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        // Try to find a matching case
        if let category = Category.allCases.first(where: { $0.rawValue == rawValue }) {
            self = category
        } else {
            // Default to uncategorized if no match is found
            self = .uncategorized
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
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
    
    enum CodingKeys: String, CodingKey {
        case id
        case text
        case options
        case correctOptionIndex
        case points
        case createdAt
        case createdBy
        case category
    }
    
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
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        text = try container.decode(String.self, forKey: .text)
        options = try container.decode([String].self, forKey: .options)
        correctOptionIndex = try container.decode(Int.self, forKey: .correctOptionIndex)
        points = try container.decode(Int.self, forKey: .points)
        createdBy = try container.decode(String.self, forKey: .createdBy)
        
        // Handle Date decoding
        if let timestamp = try? container.decode(Timestamp.self, forKey: .createdAt) {
            createdAt = timestamp.dateValue()
        } else {
            createdAt = try container.decode(Date.self, forKey: .createdAt)
        }
        
        // Handle Category decoding
        if let categoryString = try? container.decode(String.self, forKey: .category),
           let category = Category.allCases.first(where: { $0.rawValue == categoryString }) {
            self.category = category
        } else {
            self.category = .uncategorized
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(text, forKey: .text)
        try container.encode(options, forKey: .options)
        try container.encode(correctOptionIndex, forKey: .correctOptionIndex)
        try container.encode(points, forKey: .points)
        try container.encode(createdBy, forKey: .createdBy)
        try container.encode(Timestamp(date: createdAt), forKey: .createdAt)
        try container.encode(category.rawValue, forKey: .category)
    }
} 
