import FirebaseFirestore

enum Modes: String {
    case Fast = "Fast"
    case Normal = "Normal"
    case Preload = "Preload"
    case Wait = "Wait"
    
    case Raffle = "Raffle"
    case Flow = "Flow"
    
    case FastManual = "FastManual"
    case NormalManual = "NormalManual"
    case WaitManual = "WaitManual"
    
    case SetShipping = "SetShipping"
}

enum TaskAction {
    case Create
    case Edit
    case Add
}

struct ProxyRequest: Identifiable, Decodable, Hashable {
    @DocumentID var id: String?
    var fileName: String
    var userLogin: String
    var userPassword: String
    var countryId: String
    var stateName: String?
    var genCount: Int
    var append: String?
}

struct ProxyFile: Identifiable, Decodable, Hashable {
    @DocumentID var id: String?
    var name: String
    var count: Int
    var first25: [String]
    var speed: Int?
    var speedErr: String?
    var instance: Int
}

struct ProfileFile: Identifiable, Decodable, Hashable {
    @DocumentID var id: String?
    var name: String
    var profiles: [String]
    var left: Int?
    var instance: Int
}

struct AccountFile: Identifiable, Decodable, Hashable {
    @DocumentID var id: String?
    var name: String
    var accounts: [String]
    var left: Int?
    var instance: Int
}

struct TaskFile: Identifiable, Decodable, Hashable {
    @DocumentID var id: String?
    var name: String
    var tasks: [String]
    var isRunning: Bool
    var success: Int
    var failure: Int
    var status: String
    var count: Int
    var left: Int?
    var schedule: Timestamp?
    var instance: Int
    var cartLinks: [String]?
}

struct CartLinks: Identifiable, Hashable {
    var id: UUID = UUID()
    var email: String
    var password: String
    var paypalLink: URL?
    var timeLeft: String
}

struct BotTask: Equatable {
    var profileGroup: String
    var profileName: String
    var proxyGroup: String
    var accountGroup: String
    var input: String
    var size: String
    var color: String
    var site: String
    var mode: String
    var cartQuantity: Int
    var delay: Int
    var discountCode: String
    var maxBuyPrice: Int
    var maxBuyQuantity: Int
}

func extractTask(from string: String) -> BotTask? {
    let components = string.split(separator: ",", omittingEmptySubsequences: false)
                                .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
        
    guard components.count == 14,
          let cartQuantity = Int(components[9]),
          let delay = Int(components[10]),
          let maxBuyPrice = Int(components[12]),
          let maxBuyQuantity = Int(components[13]) else {
        return nil
    }
            
    return BotTask(
        profileGroup: components[0],
        profileName: components[1],
        proxyGroup: components[2],
        accountGroup: components[3],
        input: components[4],
        size: String(components[5]).split(separator: " ").joined(separator: ", "),
        color: String(components[6]).split(separator: " ").joined(separator: ", "),
        site: components[7],
        mode: components[8],
        cartQuantity: cartQuantity,
        delay: delay,
        discountCode: components[11],
        maxBuyPrice: maxBuyPrice,
        maxBuyQuantity: maxBuyQuantity
    )
}

func convertTaskToString(task: BotTask) -> String {
    let components = [
        task.profileGroup,
        task.profileName,
        task.proxyGroup,
        task.accountGroup,
        task.input,
        task.size.replacingOccurrences(of: ",", with: ""),
        task.color.replacingOccurrences(of: ",", with: ""),
        task.site,
        task.mode,
        String(task.cartQuantity),
        String(task.delay),
        task.discountCode,
        String(task.maxBuyPrice),
        String(task.maxBuyQuantity)
    ]
    
    return components.joined(separator: ",")
}
