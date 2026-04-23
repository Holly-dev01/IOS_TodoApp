//
//  Item.swift
//  TodoApp
//
//  Created by Asyst  on 4/22/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var id: UUID = UUID()
    var title: String
    var taskDescription: String
    var dueDate: Date
    var notificationId: String?
    var isCompleted: Bool = false
    
    init(title: String, taskDescription: String = "", dueDate: Date) {
        self.title = title
        self.taskDescription = taskDescription
        self.dueDate = dueDate
        self.notificationId = nil
    }
}
