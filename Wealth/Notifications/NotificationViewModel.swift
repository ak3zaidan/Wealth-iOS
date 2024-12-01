import Foundation
import Firebase
import SwiftUI

@Observable class NotificationViewModel {
    var notifications = [Notification]()
    var gotReleases = false
    var unseenCount = 0
    
    func getNotificationsNew(lastSeen: Timestamp?, calledFromHome: Bool, completion: @escaping(Timestamp?) -> Void) {
        if !calledFromHome {
            self.unseenCount = 0
        }
        
        if self.notifications.isEmpty {
            let dispatchGroup = DispatchGroup()
            var notifications: [Notification] = []
            var devNotifications: [Notification] = []

            dispatchGroup.enter()
            NotifService().getNotificationsNew(newest: newestUserNotif()) { notifs in
                notifications = notifs
                dispatchGroup.leave()
            }

            dispatchGroup.enter()
            NotifService().getDevNotifs { devNotifs in
                devNotifications = devNotifs
                dispatchGroup.leave()
            }

            dispatchGroup.notify(queue: .main) {
                self.gotReleases = true
                let combinedNotifications = notifications + devNotifications
                
                let sortedNotifications = combinedNotifications.sorted { notif1, notif2 in
                    notif1.timestamp.dateValue() > notif2.timestamp.dateValue()
                }
                
                withAnimation(.easeInOut(duration: 0.3)){
                    self.notifications = sortedNotifications
                }
                
                self.setUnseen(calledFromHome: calledFromHome, lastSeen: lastSeen) { date in
                    completion(date)
                }
            }
        } else {
            NotifService().getNotificationsNew(newest: newestUserNotif()) { notifs in
                self.gotReleases = true
                
                withAnimation(.easeInOut(duration: 0.3)){
                    self.notifications.insert(contentsOf: notifs, at: 0)
                }
                
                self.setUnseen(calledFromHome: calledFromHome, lastSeen: lastSeen) { date in
                    completion(date)
                }
            }
        }
    }
    func getNotificationsOld() {
        if let oldest = oldestUserNotif() {
            NotifService().getNotificationsOld(oldest: oldest) { notifs in
                notifs.forEach { element in
                    if !self.notifications.contains(where: { $0.id == element.id }) {
                        self.notifications.append(element)
                    }
                }
            }
        }
    }
    func setUnseen(calledFromHome: Bool, lastSeen: Timestamp?, completion: @escaping(Timestamp?) -> Void) {
        if calledFromHome {
            if let lastSeen {
                
                let countNewerThanX = self.notifications.filter { notification in
                    notification.timestamp.dateValue() > lastSeen.dateValue()
                }.count
                
                self.unseenCount = countNewerThanX
                
            } else {
                self.unseenCount = self.notifications.count
            }
            completion(nil)
        } else if let newest = self.notifications.first?.timestamp {
            if let lastSeen {
                if lastSeen.dateValue() < newest.dateValue() {
                    completion(newest)
                } else {
                    completion(nil)
                }
            } else {
                completion(newest)
            }
        }
    }
    func newestUserNotif() -> Timestamp? {
        let newest = self.notifications
            .filter { notification in
                notification.type != NotificationTypes.developer.rawValue &&
                notification.type != NotificationTypes.staff.rawValue
            }
            .max(by: { hustle1, hustle2 in
                hustle1.timestamp.dateValue() < hustle2.timestamp.dateValue()
            })?.timestamp

        return newest
    }
    func oldestUserNotif() -> Timestamp? {
        let newest = self.notifications
            .filter { notification in
                notification.type != NotificationTypes.developer.rawValue &&
                notification.type != NotificationTypes.staff.rawValue
            }
            .min(by: { hustle1, hustle2 in
                hustle1.timestamp.dateValue() < hustle2.timestamp.dateValue()
            })?.timestamp

        return newest
    }
}
