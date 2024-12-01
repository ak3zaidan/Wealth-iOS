import Firebase
import FirebaseAuth

struct ServerSend {
    let db = Firestore.firestore()
    
    func deleteEvent(id: String) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        if !id.isEmpty {
            db.collection("users").document(uid).collection("events").document(id).delete()
        }
    }
    func alertMobileChange(id: String) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
                
        let data = ["new": id] as [String : Any]
        
        db.collection("users").document(uid).collection("events")
            .document("mobile\(UUID().uuidString)").setData(data) { _ in }
    }
    func sendProfiles(name: String, profiles: String, instance: Int) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let lines = profiles.components(separatedBy: "\n")
        
        if lines.isEmpty {
            return
        }
        
        let data = ["name": name,
                    "profiles": lines] as [String : Any]
        
        db.collection("users").document(uid).collection("events")
            .document("\(instance)buildProfile\(UUID().uuidString)").setData(data) { _ in }
    }
    func updateServer(instance: Int) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }

        db.collection("users").document(uid).collection("events")
            .document("\(instance)update\(UUID().uuidString)").setData([:]) { _ in }
    }
    func checkServerOnline(id: String, instance: Int) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }

        db.collection("users").document(uid).collection("events")
            .document("\(instance)testonline\(id)").setData([:]) { _ in }
    }
}
