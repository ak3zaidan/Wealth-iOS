
struct InStock: Decodable {
    let InStock: Bool
}

struct RandomString: Decodable {
    let random: String
}

struct SoldQuantities: Decodable {
    var CsvLite: Int
    var CsvPro: Int
    var WealthIcon: Int
    var aiLogo: Int
    var forwardLite: Int
    var forwardPro: Int
    var builder: Int
    var stockChecker: Int
    var variantScraper: Int
    var qApp: Int
    var qDiscord: Int
    var pokemonBuilder: Int
    var nikeBuilder: Int
    var costcoBuilder: Int
    var uberBuilder: Int
}
