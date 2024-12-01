import Firebase
import FirebaseAuth

struct ReleaseService {
    let db = Firestore.firestore()
    
    func GetNewReleases(completion: @escaping ([Release]) -> Void) {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let timestamp = Timestamp(date: startOfToday)
        
        db.collection("releases")
            .whereField("releaseTime", isGreaterThan: timestamp)
            .getDocuments { snapshot, _ in
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                let releases = documents.compactMap { try? $0.data(as: Release.self) }
                completion(releases)
            }
    }
    func GetOldReleases(completion: @escaping ([Release]) -> Void) {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let timestamp = Timestamp(date: startOfToday)
        
        db.collection("releases")
            .whereField("releaseTime", isLessThan: timestamp).limit(to: 75)
            .getDocuments { snapshot, _ in
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                let releases = documents.compactMap { try? $0.data(as: Release.self) }
                completion(releases)
            }
    }
    func upVote(releaseId: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("releases").document(releaseId).updateData(["likers": FieldValue.arrayUnion([uid])]) { _ in }
    }
    func removeUpVote(releaseId: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("releases").document(releaseId).updateData(["likers": FieldValue.arrayRemove([uid])]) { _ in }
    }
    func downVote(releaseId: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("releases").document(releaseId).updateData(["unLikers": FieldValue.arrayUnion([uid])]) { _ in }
    }
    func removeDownVote(releaseId: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("releases").document(releaseId).updateData(["unLikers": FieldValue.arrayRemove([uid])]) { _ in }
    }
}
