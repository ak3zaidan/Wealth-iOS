import Firebase
import FirebaseAuth

struct NotifService {
    let db = Firestore.firestore()
    
    func getNotificationsNew(newest: Timestamp?, completion: @escaping([Notification]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion([])
            return
        }
        
        var query = db.collection("users").document(uid).collection("notifs")
                        .order(by: "timestamp", descending: true)
                        .limit(to: 45)
        
        if let newest {
            query = db.collection("users").document(uid).collection("notifs")
                        .whereField("timestamp", isGreaterThan: newest)
                        .order(by: "timestamp", descending: true)
                        .limit(to: 65)
        }
        
        query.getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents else {
                completion([])
                return
            }
            let notifs = documents.compactMap({ try? $0.data(as: Notification.self)} )
            completion(notifs)
        }
    }
    func getNotificationsOld(oldest: Timestamp, completion: @escaping([Notification]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion([])
            return
        }
        
        let query = db.collection("users").document(uid).collection("notifs")
                        .whereField("timestamp", isLessThan: oldest)
                        .order(by: "timestamp", descending: true)
                        .limit(to: 45)
        
        query.getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents else {
                completion([])
                return
            }
            let notifs = documents.compactMap({ try? $0.data(as: Notification.self)} )
            completion(notifs)
        }
    }
    func getDevNotifs(completion: @escaping([Notification]) -> Void) {
        db.collection("devAlerts")
            .order(by: "timestamp", descending: true).limit(to: 30)
            .getDocuments { snapshot, _ in
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                let notifs = documents.compactMap({ try? $0.data(as: Notification.self)} )
                completion(notifs)
            }
    }
}
