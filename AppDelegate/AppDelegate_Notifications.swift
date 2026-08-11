import Flutter
import UIKit
import Firebase
import UserNotifications
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // 🔹 Initialize Firebase
        FirebaseApp.configure()

        // 🔹 Flutter local notifications plugin callback for background isolate
        FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { registry in
            GeneratedPluginRegistrant.register(with: registry)
        }

        // 🔹 Register Flutter plugins
        GeneratedPluginRegistrant.register(with: self)

        // 🔹 Set UNUserNotificationCenter delegate for foreground notifications
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }

        // ✅ Call super AFTER setup
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // MARK: - Foreground Notification Handling
    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // 🔔 Forward to FlutterAppDelegate so firebase_messaging plugin receives it
        super.userNotificationCenter(center, willPresent: notification, withCompletionHandler: completionHandler)
    }

    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // 🔔 Forward to FlutterAppDelegate so firebase_messaging plugin handles taps
        super.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
    }
}
