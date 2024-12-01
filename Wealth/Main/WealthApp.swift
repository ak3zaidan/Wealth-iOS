import SwiftUI
import OAuthSwift
import FirebaseMessaging
import FirebaseCore
import StripeApplePay

let APPVERSION = "1.0"

class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        StripeAPI.defaultPublishableKey = "pk_live_51NVNI8BfyPE6CREEPjE9MXSgD2nx8VPg4cCs77eVNJCDt5PfwR9bvxC1Xq63aiWJofaybcJsjukmXahWvLRnU7zf00V5aQPRDv"
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, _ in }
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        UNUserNotificationCenter.current().setBadgeCount(0, withCompletionHandler: nil)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        UNUserNotificationCenter.current().setBadgeCount(1, withCompletionHandler: nil)
        completionHandler([.banner, .sound, .badge])
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) { }
}

@main
struct YourApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase) var scenePhase
    @State private var notif = NotificationViewModel()
    @State private var feed = FeedViewModel()
    @State private var profile = ProfileViewModel()
    @State private var task = TaskViewModel()
    
    @StateObject var auth = AuthViewModel()
    @StateObject var popRoot = PopToRoot()
    @StateObject var subManager = SubscriptionsManager()
    @StateObject var AI = AIHistory()
    @StateObject var AI2 = ViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .dynamicTypeSize(.large)
                .environmentObject(auth)
                .environmentObject(popRoot)
                .environment(feed)
                .environment(profile)
                .environment(notif)
                .environment(task)
                .environmentObject(subManager)
                .environmentObject(AI)
                .environmentObject(AI2)
                .onAppear {
                    Task {
                        await subManager.updatePurchasedProducts()
                    }
                }
                .onChange(of: auth.currentUser?.id) { _, _ in
                    if let discordUID = auth.currentUser?.discordUID {
                        Task {
                            checkBandwidth(dUID: discordUID) { details in
                                if let details {
                                    DispatchQueue.main.async {
                                        popRoot.resisData = details
                                    }
                                }
                            }
                        }
                    }
                }
                .onChange(of: scenePhase) { prevPhase, newPhase in
                    if newPhase == .background {
                        DispatchQueue.main.async {
                            task.disconnect()
                        }
                    }
                }
        }
    }
}
