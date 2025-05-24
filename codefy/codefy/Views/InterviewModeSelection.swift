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
        VStack(spacing: 16) {
            Text("Selecciona Categorías")
                .font(.title)
                .bold()
                .padding(.bottom, 8)
            
            ForEach(Category.allCases, id: \.self) { category in
                Button(action: {
                    if selectedCategories.contains(category) {
                        selectedCategories.remove(category)
                    } else {
                        selectedCategories.insert(category)
                    }
                }) {
                    HStack {
                        Text(category.rawValue)
                        Spacer()
                        if selectedCategories.contains(category) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .padding()
                    .background(Color(hex: "F2F2F7"))
                    .cornerRadius(10)
                }
                .foregroundColor(.primary)
            }
            
            Button("Iniciar Entrevista") {
                startInterview = true
            }
            .disabled(selectedCategories.isEmpty)
            .padding()
            .background(selectedCategories.isEmpty ? Color.gray : Color(hex: "34C759"))
            .foregroundColor(.white)
            .cornerRadius(10)
            
            NavigationLink(
                destination: InterviewModeView(questionsViewModel: questionsViewModel, selectedCategories: Array(selectedCategories)),
                isActive: $startInterview
            ) { EmptyView() }
        }
        .padding()
    }
}
