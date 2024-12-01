import FirebaseFirestore

struct CheckoutFilter: Equatable {
    var startDate: Date?
    var endDate: Date?
    var fromSite: String?
    var forProfile: String?
    var forEmail: String?
    var forPrice: Double?
    var containsText: [String]?
    var forOrderNumber: String?
    
    func nonNilCount() -> Int {
        let properties: [Any?] = [startDate, endDate, fromSite, forProfile, forEmail, forPrice]
        return properties.filter { $0 != nil }.count
    }
}

struct ExportFilter {
    var containsTitle: Bool = true
    var containsProfile: Bool = true
    var containsSite: Bool = true
    var containsEmail: Bool = true
    var containsColor: Bool = true
    var containsSize: Bool = true
    var containsOrder: Bool = true
    var containsOrderLink: Bool = true
    var containsCost: Bool = true
    var containsStatus: Bool = true
    var containsDatePlaced: Bool = true
    var fileType: FileType = .csv
    
    func hasAtLeastOneTrue() -> Bool {
        let boolProperties = [
            containsTitle,
            containsProfile,
            containsSite,
            containsEmail,
            containsColor,
            containsSize,
            containsOrder,
            containsOrderLink,
            containsCost,
            containsStatus
        ]
        return boolProperties.contains(true)
    }
}

enum FileType {
    case csv
    case text
}

enum CheckoutStatus: String, CaseIterable {
    case orderPlaced = "Order Placed"
    case orderCanceled = "Order Cancelled"
    case orderDelivered = "Order Delivered"
    case orderTransit = "Order In Transit"
    case orderReturned = "Order Returned"
    case orderPreparing = "Order Preparing Shipment"
}

struct CheckoutHolder: Identifiable, Hashable {
    let id: String = UUID().uuidString
    var dateString: String
    var checkouts: [Checkout]
}

struct Checkout: Identifiable, Decodable, Hashable {
    @DocumentID var id: String?
    let title: String
    let titleTokens: [String]
    let site: String
    let profile: String
    let email: String
    let color: String?
    let size: String?
    let image: String?
    let cost: Double?
    let orderNumber: String?
    let orderLink: String?
    var quantity: Int?
    var instanceName: String?
    
    let orderPlaced: Timestamp
    var orderCanceled: Timestamp?
    var orderDelivered: Timestamp?
    var orderTransit: Timestamp?
    var orderPreparing: Timestamp?
    var orderReturned: Timestamp?
    
    var estimatedDelivery: String?
    var deliveredDate: String?
}
