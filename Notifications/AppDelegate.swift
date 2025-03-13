//
//  AppDelegate.swift
//  Notifications
//
//  Created by Om Roy on 01/03/25.
//

import UIKit
import UserNotifications

// MARK: - Notification Manager
class NotificationManager {
    static let shared = NotificationManager()
    private init() {}
    
    // Now accepts a custom duration (interval between notifications in seconds)
    func scheduleWordNotifications(duration: TimeInterval) {
        // Use concise definitions for notifications
        guard let words = WordService.shared.loadWords(style: .concise) else {
            // If words can't be loaded, schedule a default notification
            scheduleDefaultWordNotification(duration: duration)
            return
        }
        
        // Remove any existing pending notifications.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removeAllPendingNotificationRequests()
        
        // Start scheduling batches beginning with index 0 using custom duration for interval
        scheduleBatch(wordList: words, batchStartIndex: 0, interval: duration)
    }
    
    // Schedules a default notification if word list can't be loaded
    private func scheduleDefaultWordNotification(duration: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = "Vocabulary Reminder"
        content.body = "It's time to learn a new word!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: duration, repeats: false)
        let request = UNNotificationRequest(identifier: "default_notification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling default notification: \(error.localizedDescription)")
            } else {
                print("Default notification scheduled at \(duration/60) minute(s) from launch.")
            }
        }
    }
    
    // Stops all scheduled notifications
    func stopAllNotifications() {
        // Remove all pending notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("All notifications have been cancelled")
        
        // Also reset the badge count
        UNUserNotificationCenter.current().setBadgeCount(0) { error in
            if let error = error {
                print("Error resetting badge count: \(error.localizedDescription)")
            }
        }
    }
    
    private func scheduleBatch(wordList: [Word], batchStartIndex: Int, interval: TimeInterval) {
        let batchSize = 64
        let count = wordList.count
        let endIndex = min(batchStartIndex + batchSize, count)
        
        // Schedule each notification in the current batch with the provided interval between notifications
        for i in batchStartIndex..<endIndex {
            let offset = TimeInterval(i - batchStartIndex + 1) * interval
            scheduleNotification(for: wordList[i], after: offset)
        }
        
        // Calculate the delay before scheduling the next batch
        let notificationsInBatch = endIndex - batchStartIndex
        let batchDuration = TimeInterval(notificationsInBatch) * interval
        let delayBeforeNextBatch = batchDuration + interval
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delayBeforeNextBatch) { [weak self] in
            guard let self = self else { return }
            var nextBatchStart = batchStartIndex + batchSize
            if nextBatchStart >= count {
                nextBatchStart = 0  // cycle back to the start
            }
            self.scheduleBatch(wordList: wordList, batchStartIndex: nextBatchStart, interval: interval)
        }
    }

    private func scheduleNotification(for word: Word, after timeInterval: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = word.word
        content.body = word.meaning
        content.sound = .default
        
        // Trigger the notification after the specified timeInterval.
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let identifier = "\(word.word)_notification_\(timeInterval)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification for \(word.word): \(error.localizedDescription)")
            } else {
                print("Notification scheduled for \(word.word) at \(timeInterval/60) minute(s) from launch.")
            }
        }
    }
}

// MARK: - Notification View Controller
class NotificationViewController: UIViewController {
    let intervalTextField = UITextField()
    let scheduleButton = UIButton(type: .system)
    let statusLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // Configure the text field for entering interval (in minutes)
        intervalTextField.placeholder = "Enter interval in minutes"
        intervalTextField.borderStyle = .roundedRect
        intervalTextField.keyboardType = .decimalPad
        view.addSubview(intervalTextField)
        
        // Configure the schedule button
        scheduleButton.setTitle("Schedule Notifications", for: .normal)
        scheduleButton.addTarget(self, action: #selector(scheduleNotifications), for: .touchUpInside)
        view.addSubview(scheduleButton)
        
        // Configure the status label
        statusLabel.text = "Notifications not scheduled."
        statusLabel.textAlignment = .center
        view.addSubview(statusLabel)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let safeTop = view.safeAreaInsets.top
        let padding: CGFloat = 20
        let width = view.bounds.width - 2 * padding
        
        intervalTextField.frame = CGRect(x: padding, y: safeTop + 20, width: width, height: 40)
        scheduleButton.frame = CGRect(x: padding, y: safeTop + 80, width: width, height: 50)
        statusLabel.frame = CGRect(x: padding, y: safeTop + 150, width: width, height: 40)
    }
    
    @objc func scheduleNotifications() {
        let minutesStr = intervalTextField.text ?? ""
        guard let minutes = Double(minutesStr), minutes > 0 else {
            statusLabel.text = "Please enter a valid number."
            return
        }
        let duration = minutes * 60  // convert minutes to seconds
        
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    NotificationManager.shared.scheduleWordNotifications(duration: duration)
                    self.statusLabel.text = "Notifications scheduled every \(minutes) minute(s)."
                } else {
                    self.statusLabel.text = "Notification permission not granted."
                }
            }
        }
    }
}

// MARK: - App Delegate
@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Setup notification delegate
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: - UNUserNotificationCenterDelegate Methods
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle notification response
        completionHandler()
    }
}
