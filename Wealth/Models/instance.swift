import FirebaseFirestore

struct Instance: Identifiable, Decodable, Hashable {
    @DocumentID var id: String?
    var instanceId: Int
    var nickName: String
    var ip: String
}

struct IMAP: Identifiable, Decodable, Hashable {
    @DocumentID var id: String?
    var one: String?
    var two: String?
    var three: String?
    var four: String?
    var five: String?
    var six: String?
}
