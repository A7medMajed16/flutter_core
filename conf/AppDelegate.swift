import Flutter
import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Initialize Firebase first
    FirebaseApp.configure()

    // Set UNUserNotificationCenter delegate for handling notifications
    UNUserNotificationCenter.current().delegate = self

    // Set Firebase Messaging delegate
    Messaging.messaging().delegate = self

    // Request notification permissions
    UNUserNotificationCenter.current().requestAuthorization(
      options: [.alert, .badge, .sound]
    ) { granted, error in
      if let error = error {
        print("Notification permission error: \(error.localizedDescription)")
      }
      print("Notification permission granted: \(granted)")
    }

    GeneratedPluginRegistrant.register(with: self)

    // Register for remote notifications (APNs)
    application.registerForRemoteNotifications()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // REQUIRED when FirebaseAppDelegateProxyEnabled is false:
  // Manually forward the APNs token to Firebase Messaging
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    Messaging.messaging().apnsToken = deviceToken
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  // Handle background notification receipt
  override func application(
    _ application: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable: Any],
    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
  ) {
    Messaging.messaging().appDidReceiveMessage(userInfo)
    super.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
  }
}

// REQUIRED when FirebaseAppDelegateProxyEnabled is false:
// Handle FCM token refresh
extension AppDelegate: MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("FCM Token: \(fcmToken ?? "nil")")
  }
}


