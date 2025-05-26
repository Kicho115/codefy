//
//  InterviewModeSelection.swift
//  codefy
//
//  Created by Jose Quezada Araiza on 24/05/25.
//

import SwiftUI

struct InterviewModeSelection: View {
    @ObservedObject var questionsViewModel: QuestionsViewModel
    @State private var selectedCategories: Set<Category> = []
    @State private var startInterview = false
    
    var body: some View {
        ZStack {
            Color.spaceCadet
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("Select Categories")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 32)
                
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(Category.allCases, id: \.self) { category in
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    if selectedCategories.contains(category) {
                                        selectedCategories.remove(category)
                                    } else {
                                        selectedCategories.insert(category)
                                    }
                                }
                            }) {
                                HStack {
                                    Text(category.rawValue)
                                        .font(.system(size: 17, weight: .medium, design: .rounded))
                                    Spacer()
                                    if selectedCategories.contains(category) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.turquoise)
                                            .imageScale(.large)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white.opacity(0.1))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(selectedCategories.contains(category) ? Color.turquoise : Color.clear, lineWidth: 2)
                                )
                            }
                            .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        startInterview = true
                    }
                }) {
                    HStack {
                        Text("Start Mock Interview")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                        Image(systemName: "arrow.right.circle.fill")
                            .imageScale(.large)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(selectedCategories.isEmpty ? Color.gray.opacity(0.5) : Color.turquoise)
                    )
                    .foregroundColor(.white)
                }
                .disabled(selectedCategories.isEmpty)
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            
            NavigationLink(
                destination: InterviewModeView(questionsViewModel: questionsViewModel, selectedCategories: Array(selectedCategories)),
                isActive: $startInterview
            ) { EmptyView() }
        }
    }
}
