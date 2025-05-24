//
//  DailyQuestionViewModel.swift
//  codefy
//
//  Created by Jose Quezada Araiza on 24/05/25.
//

import Foundation
import SwiftUI

@MainActor
class DailyQuestionViewModel: ObservableObject {
    @Published var todayQuestion: Question?
    @Published var alreadyAnsweredToday: Bool = false
    
    private let questionsViewModel: QuestionsViewModel
    private let calendar = Calendar.current
    private let userDefaults = UserDefaults.standard
    
    init(questionsViewModel: QuestionsViewModel) {
        self.questionsViewModel = questionsViewModel
        loadTodayQuestion()
    }
    
    func loadTodayQuestion() {
        let today = calendar.startOfDay(for: Date())
        let lastDateKey = "DailyQuestionDate"
        let questionIDKey = "DailyQuestionID"
        let answeredKey = "DailyQuestionAnswered"
        
        if let lastDate = userDefaults.object(forKey: lastDateKey) as? Date,
           calendar.isDate(today, inSameDayAs: lastDate),
           let questionID = userDefaults.string(forKey: questionIDKey),
           let question = questionsViewModel.questions.first(where: { $0.id == questionID }) {
            todayQuestion = question
            alreadyAnsweredToday = userDefaults.bool(forKey: answeredKey)
        } else {
            generateNewDailyQuestion()
        }
    }
    
    func generateNewDailyQuestion() {
        guard let randomQuestion = questionsViewModel.questions.randomElement() else { return }
        
        todayQuestion = randomQuestion
        userDefaults.set(Date(), forKey: "DailyQuestionDate")
        userDefaults.set(randomQuestion.id, forKey: "DailyQuestionID")
        userDefaults.set(false, forKey: "DailyQuestionAnswered")
        alreadyAnsweredToday = false
    }
    
    func markQuestionAsAnswered() {
        userDefaults.set(true, forKey: "DailyQuestionAnswered")
        alreadyAnsweredToday = true
    }
}
