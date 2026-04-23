//
//  NotificationManager.swift
//  TodoApp
//
//  Created by Asyst  on 4/22/26.
//

import Foundation
import UIKit
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()

    // Demander la permission pour les notifications
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                print("Notification autorisation accordee")
            } else if let error {
                print("Erreur notification: \(error.localizedDescription)")
            }
        }
    }

    // Programmer une alarme pour une tache
    func scheduleNotification(for item: Item) -> String {
        let content = UNMutableNotificationContent()
        content.title = "Rappel de Tache"
        content.body = item.title
        if !item.taskDescription.isEmpty {
            content.subtitle = item.taskDescription
        }
        content.sound = .default

        // Creer un identifiant unique pour la notification
        let notificationId = UUID().uuidString

        // Calculer le délai jusqu'à la date de la tâche
        let timeInterval = max(5, item.dueDate.timeIntervalSinceNow)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)

        // Creer la requete de notification
        let request = UNNotificationRequest(identifier: notificationId, content: content, trigger: trigger)

        // Programmer la notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("Erreur lors de la programmation de la notification: \(error.localizedDescription)")
            } else {
                print("Notification programmee pour: \(item.dueDate)")
            }
        }

        return notificationId
    }

    // Annuler une notification
    func cancelNotification(with id: String?) {
        guard let id else { return }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        print("Notification annulee: \(id)")
    }

    // Annuler toutes les notifications
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("Toutes les notifications ont ete annulees")
    }
}
