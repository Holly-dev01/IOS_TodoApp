//  AddEditTaskView.swift
//  TodoApp
//
//  Created by Asyst  on 4/22/26.
//

import SwiftUI

struct AddEditTaskView: View {
    @Environment(\.dismiss) var dismiss
    @State private var title: String = ""
    @State private var taskDescription: String = ""
    @State private var dueDate: Date = Date().addingTimeInterval(3600) // Par défaut, dans 1 heure
    @State private var showDatePicker = false
    
    var item: Item?
    var onSave: (String, String, Date) -> Void
    
    var body: some View {
        VStack {
            HStack {
                Button("Annuler") {
                    dismiss()
                }
                Spacer()
                Text(item == nil ? "Nouvelle Tâche" : "Modifier la Tâche")
                    .font(.headline)
                Spacer()
                Button("Enregistrer") {
                    if !title.isEmpty {
                        onSave(title, taskDescription, dueDate)
                        dismiss()
                    }
                }
                .disabled(title.isEmpty)
            }
            .padding()
            
            Form {
                Section("Titre de la tâche") {
                    TextField("Entrez le titre", text: $title)
                }
                
                Section("Description") {
                    TextEditor(text: $taskDescription)
                        .frame(height: 100)
                }
                
                Section("Date et Heure") {
                    DatePicker(
                        "Sélectionnez la date et l'heure",
                        selection: $dueDate,
                        in: Date()...,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.graphical)
                }
            }
        }
        .onAppear {
            if let item = item {
                title = item.title
                taskDescription = item.taskDescription
                dueDate = item.dueDate
            }
        }
    }
}

#Preview {
    AddEditTaskView(item: nil) { _, _, _ in }
}
