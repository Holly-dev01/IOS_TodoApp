//
//  ContentView.swift
//  TodoApp
//
//  Created by Asyst  on 4/22/26.
//

import SwiftUI
import SwiftData


struct ContentView: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Item.dueDate) var items: [Item]
    
    @State private var showAddTaskSheet = false
    @State private var selectedItem: Item?
    @State private var showEditSheet = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                if items.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("Aucune Tâche")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Appuyez sur \"+\" pour ajouter une nouvelle tâche")
                            .foregroundColor(.gray)
                    }
                } else {
                    List {
                        ForEach(items) { item in
                            TaskRowView(item: item)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedItem = item
                                    showEditSheet = true
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        deleteTask(item)
                                    } label: {
                                        Label("Supprimer", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .listStyle(.inset)
                }
            }
            .navigationTitle("📝 Mes Tâches")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddTaskSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                    }
                }
            }
            .sheet(isPresented: $showAddTaskSheet) {
                AddEditTaskView(item: nil) { title, taskDescription, dueDate in
                    addTask(title: title, taskDescription: taskDescription, dueDate: dueDate)
                }
            }
            .sheet(isPresented: $showEditSheet) {
                if let item = selectedItem {
                    AddEditTaskView(item: item) { title, taskDescription, dueDate in
                        updateTask(item: item, title: title, taskDescription: taskDescription, dueDate: dueDate)
                    }
                }
            }
        }
        .onAppear {
            NotificationManager.shared.requestAuthorization()
        }
    }
    
    // MARK: - Actions
    
    private func addTask(title: String, taskDescription: String, dueDate: Date) {
        let newItem = Item(title: title, taskDescription: taskDescription, dueDate: dueDate)
        modelContext.insert(newItem)
        
        // Programmer la notification
        let notificationId = NotificationManager.shared.scheduleNotification(for: newItem)
        newItem.notificationId = notificationId
        
        try? modelContext.save()
    }
    
    private func updateTask(item: Item, title: String, taskDescription: String, dueDate: Date) {
        // Annuler l'ancienne notification
        NotificationManager.shared.cancelNotification(with: item.notificationId)
        
        // Mettre à jour les propriétés
        item.title = title
        item.taskDescription = taskDescription
        item.dueDate = dueDate
        
        // Programmer la nouvelle notification
        let notificationId = NotificationManager.shared.scheduleNotification(for: item)
        item.notificationId = notificationId
        
        try? modelContext.save()
        selectedItem = nil
    }
    
    private func deleteTask(_ item: Item) {
        // Annuler la notification
        NotificationManager.shared.cancelNotification(with: item.notificationId)
        
        // Supprimer l'élément
        modelContext.delete(item)
        try? modelContext.save()
    }
}

// MARK: - Task Row View

struct TaskRowView: View {
    let item: Item
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    if !item.taskDescription.isEmpty {
                        Text(item.taskDescription)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 14))
                    
                    Text(formatDate(item.dueDate))
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
            }
            
            // Barre de progression du temps jusqu'à l'alarme
            if item.dueDate > Date() {
                TimeProgressBar(dueDate: item.dueDate)
            } else {
                HStack {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.red)
                    Text("Tâche expirée")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date)
    }
}

// MARK: - Time Progress Bar

struct TimeProgressBar: View {
    let dueDate: Date
    @State private var progress: Double = 0
    
    var body: some View {
        VStack(spacing: 4) {
            ProgressView(value: progress)
                .tint(.green)
            
            HStack {
                Text("Temps restant: \(timeRemaining())")
                    .font(.caption2)
                    .foregroundColor(.gray)
                Spacer()
            }
        }
        .onAppear {
            updateProgress()
            Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                updateProgress()
            }
        }
    }
    
    private func updateProgress() {
        let now = Date()
        if dueDate > now {
            progress = Double(now.timeIntervalSince(Date(timeIntervalSince1970: 0))) / Double(dueDate.timeIntervalSince1970) * 0.5
        } else {
            progress = 1.0
        }
    }
    
    private func timeRemaining() -> String {
        let interval = dueDate.timeIntervalSince(Date())
        if interval <= 0 {
            return "Expiré"
        }
        
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
