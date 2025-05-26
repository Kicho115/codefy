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
            ZStack {
                Color.spaceCadet
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        Text("Daily Question")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.top, 20)
                        
                        if let question = viewModel.todayQuestion {
                            VStack(spacing: 16) {
                                Text(question.text)
                                    .font(.system(size: 20, weight: .medium, design: .rounded))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                
                                if viewModel.alreadyAnsweredToday {
                                    HStack {
                                        Image(systemName: "clock.fill")
                                            .foregroundColor(.naplesYellow)
                                        Text("You have already answered today. Come back tomorrow!")
                                            .foregroundColor(.naplesYellow)
                                            .font(.headline)
                                    }
                                    .padding()
                                    .background(Color.naplesYellow.opacity(0.1))
                                    .cornerRadius(12)
                                } else {
                                    VStack(spacing: 12) {
                                        ForEach(0..<question.options.count, id: \.self) { index in
                                            Button(action: {
                                                checkAnswer(selectedIndex: index, correctIndex: question.correctOptionIndex)
                                            }) {
                                                HStack {
                                                    Text(question.options[index])
                                                        .font(.system(size: 17, weight: .medium, design: .rounded))
                                                        .foregroundColor(.spaceCadet)
                                                        .multilineTextAlignment(.leading)
                                                    
                                                    Spacer()
                                                    
                                                    if answered {
                                                        Image(systemName: index == question.correctOptionIndex ? "checkmark.circle.fill" : "xmark.circle.fill")
                                                            .foregroundColor(index == question.correctOptionIndex ? .green : .red)
                                                    }
                                                }
                                                .padding()
                                                .frame(maxWidth: .infinity)
                                                .background(answered ? 
                                                    (index == question.correctOptionIndex ? Color.green.opacity(0.2) : Color.red.opacity(0.2)) :
                                                    Color.turquoise)
                                                .cornerRadius(12)
                                            }
                                            .disabled(answered)
                                        }
                                    }
                                }
                                
                                if let message = feedbackMessage {
                                    Text(message)
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .foregroundColor(message == "Correct!" ? .green : .red)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(message == "Correct!" ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                                        )
                                }
                                
                                HStack {
                                    Image(systemName: "tag.fill")
                                        .foregroundColor(.tropicalIndigo)
                                    Text(question.category.rawValue)
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundColor(.tropicalIndigo)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(Color.tropicalIndigo.opacity(0.1))
                                .cornerRadius(8)
                            }
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(20)
                            .padding(.horizontal)
                        } else {
                            ProgressView("Loading question...")
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private func checkAnswer(selectedIndex: Int, correctIndex: Int) {
        answered = true
        if selectedIndex == correctIndex {
            feedbackMessage = "Correct!"
        } else {
            feedbackMessage = "Incorrect"
        }
        viewModel.markQuestionAsAnswered()
    }
}
