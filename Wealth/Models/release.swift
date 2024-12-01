import FirebaseFirestore

struct ReleaseHolder: Identifiable, Hashable {
    let id: String = UUID().uuidString
    var dateString: String
    var releases: [Release]
    
    static func == (lhs: ReleaseHolder, rhs: ReleaseHolder) -> Bool {
        lhs.dateString == rhs.dateString && lhs.releases.elementsEqual(rhs.releases) { $0 == $1 }
    }
}

struct Release: Identifiable, Decodable, Hashable {
    @DocumentID var id: String?
    
    let title: String
    let images: [String]
    let desc: String
    let type: Int
    let likers: [String]
    let unLikers: [String]
    let staffAnalysis: String?
    let stockCount: Int?
    let sizeRange: String?
    let retail: Int
    let resell: Int
    let tags: [String]?
    let releaseTime: Timestamp
    let sku: String?
    let variants: [String]?
    
    let raffles: [String]?
    let availableAtUrl: [String]?
    let availableCountries: [String]?
    let estimatedShipping: Int?
    
    let stockxUrl: String?
    let ebaySoldUrl: String?
    let ebaySoldCount: Int?
    
    let suggestedKeywords: String?
    let suggestedMode: String?
    let suggestedDelays: Int?
    
    let premadeTasks: [String]? // Each element: "input,size,color,site,mode,delay"
    
    static func == (lhs: Release, rhs: Release) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.images == rhs.images &&
        lhs.desc == rhs.desc &&
        lhs.type == rhs.type &&
        lhs.likers == rhs.likers &&
        lhs.unLikers == rhs.unLikers &&
        lhs.staffAnalysis == rhs.staffAnalysis &&
        lhs.stockCount == rhs.stockCount &&
        lhs.sizeRange == rhs.sizeRange &&
        lhs.retail == rhs.retail &&
        lhs.resell == rhs.resell &&
        lhs.tags == rhs.tags &&
        lhs.releaseTime == rhs.releaseTime &&
        lhs.sku == rhs.sku &&
        lhs.variants == rhs.variants &&
        lhs.raffles == rhs.raffles &&
        lhs.availableAtUrl == rhs.availableAtUrl &&
        lhs.availableCountries == rhs.availableCountries &&
        lhs.estimatedShipping == rhs.estimatedShipping &&
        lhs.stockxUrl == rhs.stockxUrl &&
        lhs.ebaySoldUrl == rhs.ebaySoldUrl &&
        lhs.ebaySoldCount == rhs.ebaySoldCount &&
        lhs.suggestedKeywords == rhs.suggestedKeywords &&
        lhs.suggestedMode == rhs.suggestedMode &&
        lhs.suggestedDelays == rhs.suggestedDelays &&
        lhs.premadeTasks == rhs.premadeTasks
    }
}

func areReleasesEqual(_ array1: [ReleaseHolder], _ array2: [ReleaseHolder]) -> Bool {
    guard array1.count == array2.count else {
        return false
    }
    
    for (index, element) in array1.enumerated() {
        if element != array2[index] {
            return false
        }
    }
    
    return true
}
