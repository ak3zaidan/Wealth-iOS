import FirebaseFirestore

enum NotificationTypes: String, CaseIterable {
    case staff = "Wealth"
    case developer = "Developer"
    case checkout = "Checkout"
    case failure = "Failure"
    case status = "Order Update"
}

struct Notification: Identifiable, Decodable, Hashable {
    @DocumentID var id: String?
    let title: String
    var type: String
    let body: String
    let image: String?
    let timestamp: Timestamp
}
