import Firebase
import FirebaseAuth

struct TaskService {
    let db = Firestore.firestore()
    
    func newRequest(type: String, data: [String : Any], addUUID: Bool = true) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        db.collection("users").document(uid).collection("events")
            .document("\(type)\(addUUID ? UUID().uuidString : "")").setData(data) { _ in }
    }
    func updateEvent(docId: String, updates: [String : Any]) {
        if docId.isEmpty {
            return
        }
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        db.collection("users").document(uid).collection("events").document(docId)
            .updateData(updates) { _ in  }
    }
    func deleteSchedule(docId: String) {
        if docId.isEmpty {
            return
        }
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }

        let documentRef = db.collection("users").document(uid).collection("events").document(docId)

        documentRef.updateData([ "schedule": FieldValue.delete() ]) { _ in }
    }
    func postProxyRequest(request: ProxyRequest, instance: Int) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        var data = [
            "fileName": request.fileName,
            "userLogin": request.userLogin,
            "userPassword": request.userPassword,
            "countryId": request.countryId,
            "genCount": request.genCount
        ] as [String : Any]
        
        if let stateName = request.stateName {
            data["state"] = stateName
        }
        if let append = request.append, !append.isEmpty {
            data["append"] = append
        }
        
        db.collection("users").document(uid).collection("events")
            .document("\(instance)requestproxy\(UUID().uuidString)").setData(data) { _ in }
    }
    func updatePasswords(passwords: [String : String]) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
                
        let data = ["urlToPassword": passwords] as [String : Any]
        
        db.collection("users").document(uid).collection("events").document("passwords").setData(data) { _ in }
    }
    func updateWebHook(field: String, newValue: String) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let data = [field: newValue] as [String : Any]
        
        db.collection("users").document(uid).collection("events").document("webhooks").updateData(data) { _ in  }
    }
    func updateWebHooks(success: String, failure: String) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let data = ["success": success,
                    "failure": failure] as [String : Any]
                
        db.collection("users").document(uid).collection("events").document("webhooks").setData(data) { _ in }
    }
    func updateCapSolver(capsolver: String) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let data = ["capsolver": capsolver] as [String : Any]
                
        db.collection("users").document(uid).collection("events").document("capsolver").setData(data) { _ in }
    }
    func getPreloadVariants(completion: @escaping ([String: [String]]?) -> Void) {
        db.collection("variants").document("variants").getDocument { document, error in
            if error != nil {
                completion(nil)
                return
            }

            guard let data = document?.data() else {
                completion(nil)
                return
            }

            var urlToVariant = [String: [String]]()

            for (domain, value) in data {
                if let variantList = value as? [String] {
                    urlToVariant[domain] = variantList
                }
            }
            
            completion(urlToVariant)
        }
    }
}
