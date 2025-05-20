import SwiftUI

struct CreateQuestionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var questionText = ""
    @State private var options = ["", "", "", ""]
    @State private var points = ""
    @State private var correctOptionIndex = 0
    @State private var pointsError = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Question")) {
                    TextField("Enter your question", text: $questionText)
                }
                
                Section(header: Text("Options")) {
                    ForEach(0..<4) { index in
                        TextField("Option \(index + 1)", text: $options[index])
                    }
                }
                
                Section(header: Text("Points")) {
                    TextField("Points (1-10)", text: $points)
                        .keyboardType(.numberPad)
                        .onChange(of: points) { oldValue, newValue in
                            // Remove any non-numeric characters
                            let filtered = newValue.filter { "0123456789".contains($0) }
                            if filtered != newValue {
                                points = filtered
                            }
                            
                            // Validate range
                            if let pointsInt = Int(filtered) {
                                pointsError = pointsInt < 1 || pointsInt > 10
                            } else {
                                pointsError = !filtered.isEmpty
                            }
                        }
                    
                    if pointsError {
                        Text("Points must be between 1 and 10")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                Section(header: Text("Correct Answer")) {
                    Picker("Select correct option", selection: $correctOptionIndex) {
                        ForEach(0..<4) { index in
                            Text("Option \(index + 1)").tag(index)
                        }
                    }
                }
                
                Section {
                    Button(action: saveQuestion) {
                        Text("Save Question")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(pointsError || points.isEmpty ? Color.gray : Color.blue)
                    .disabled(pointsError || points.isEmpty)
                }
            }
            .navigationTitle("Create Question")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
    
    private func saveQuestion() {
        // TODO: Implement saving the question
        // This will be implemented when we create the question model and service
        dismiss()
    }
}

#Preview {
    CreateQuestionView()
} 