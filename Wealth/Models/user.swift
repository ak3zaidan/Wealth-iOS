import FirebaseFirestore

struct User: Identifiable, Decodable, Hashable {
    @DocumentID var id: String?
    var username: String
    var profileImageUrl: String
    let email: String
    var checkoutCount: Int
    var checkoutTotal: Double
    var botKey: String
    var connectedServerIP: String
    var connectedMobileIP: String
    var hasBotAccess: Bool
    var hasInfoAccess: Bool
    var unlockedTools: [String]
    let userSince: Timestamp
    let registerWithCode: String?
    var notificationToken: String?
    var newestAlert: Timestamp?
    var newestCheckout: Timestamp?
    var billingCycle: Timestamp?
    var disableAutoPush: Bool?
    var shoeSize: String?
    var clothingSize: String?
    var discordUsername: String?
    var discordUID: String?
    var serverRAM: String?
    var serverCPU: String?
    var useResiToUpdate: Bool?
    var subscriptionId: String?
    
    var isSuspended: Bool?
    var isVerified: Bool?
    var hasLifeTime: Bool?
    
    var instanceSubscriptionId: String?
    let instanceRegisterWithCode: String?
    var ownedInstances: Int?
    var instanceBillingCycle: Timestamp?
    var connectedServerIPExtra: [String]?
}
