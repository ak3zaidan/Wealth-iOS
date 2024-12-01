import Foundation
import Network
import Firebase
import SwiftUI

@Observable class ProfileViewModel {
    var leaderboard: [User] = []
    var checkouts: [CheckoutHolder] = []
    var cachedFilters: [(String, CheckoutFilter, [CheckoutHolder]?)] = []
    var dayIncrease = (0, 0.0)
    var monthIncrease = (0, 0.0)
    var yearIncrease = [Int]()
    var leaderBoardPosition = 0
    var gotCheckouts = false
    var refreshingRowViews = [String]()
    var lastRefreshed: [String: Date] = [:]
    var showedResiAlert = false
    var showedResiBulkAlert = false
    
    func getCheckoutsFilter(filter: CheckoutFilter) {
        if let idx = self.cachedFilters.firstIndex(where: { $0.1 == filter }) {
            if idx != 0 {
                let element = self.cachedFilters.remove(at: idx)
                self.cachedFilters.insert(element, at: 0)
            }
        } else {
            let id = UUID().uuidString
            let newElement: (String, CheckoutFilter, [CheckoutHolder]?) = (id, filter, nil)
            self.cachedFilters.insert(newElement, at: 0)
            
            if let startDate = filter.startDate, let endDate = filter.endDate {
                if startDate > endDate {
                    withAnimation(.easeInOut(duration: 0.3)){
                        self.cachedFilters[0].2 = []
                    }
                    return
                }
            }
            
            CheckoutService().getCheckoutsFilter(filter: filter) { data in
                let calendar = Calendar.current
                let formatter = DateFormatter()
                
                formatter.dateFormat = "EEEE, MMMM d"
                
                let groupedCheckouts = Dictionary(grouping: data) { release -> String in
                    let date = release.orderPlaced.dateValue()
                    return formatter.string(from: date)
                }
                
                var checkoutHolders = groupedCheckouts.map { (dateString, releases) in
                    let firstReleaseDate = releases.first?.orderPlaced.dateValue() ?? Date()
                    
                    let adjustedDateString: String
                    if calendar.isDateInToday(firstReleaseDate) {
                        adjustedDateString = "Today"
                    } else if calendar.isDateInYesterday(firstReleaseDate) {
                        adjustedDateString = "Yesterday"
                    } else if calendar.isDate(firstReleaseDate, equalTo: Date(), toGranularity: .year) {
                        formatter.dateFormat = "EEEE, MMMM d"
                        adjustedDateString = formatter.string(from: firstReleaseDate)
                    } else {
                        formatter.dateFormat = "MMMM d, yyyy"
                        adjustedDateString = formatter.string(from: firstReleaseDate)
                    }
                    
                    let sortedCheckouts = releases.sorted {
                        $0.orderPlaced.dateValue() > $1.orderPlaced.dateValue()
                    }
                    
                    return CheckoutHolder(dateString: adjustedDateString, checkouts: sortedCheckouts)
                }
                
                checkoutHolders.sort {
                    let date1 = $0.checkouts.first?.orderPlaced.dateValue() ?? Date.distantFuture
                    let date2 = $1.checkouts.first?.orderPlaced.dateValue() ?? Date.distantFuture
                    return date1 > date2
                }
                
                if let idx = self.cachedFilters.firstIndex(where: { $0.0 == id }) {
                    self.cachedFilters[idx].2 = checkoutHolders
                }
            }
        }
    }
    func getCheckoutsNew(lastSeen: Timestamp?, calledFromHome: Bool, completion: @escaping ((Int?, Timestamp?, Bool)) -> Void) {
        let newest = self.checkouts.first?.checkouts.first?.orderPlaced
        
        CheckoutService().getCheckoutsNew(newest: newest) { data in
            let calendar = Calendar.current
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMMM d"
            
            let groupedCheckouts = Dictionary(grouping: data) { release -> String in
                let date = release.orderPlaced.dateValue()
                return formatter.string(from: date)
            }
            
            var checkoutHolders = groupedCheckouts.map { (dateString, releases) in
                let firstReleaseDate = releases.first?.orderPlaced.dateValue() ?? Date()
                
                let adjustedDateString: String
                if calendar.isDateInToday(firstReleaseDate) {
                    adjustedDateString = "Today"
                } else if calendar.isDateInYesterday(firstReleaseDate) {
                    adjustedDateString = "Yesterday"
                } else if calendar.isDate(firstReleaseDate, equalTo: Date(), toGranularity: .year) {
                    formatter.dateFormat = "EEEE, MMMM d"
                    adjustedDateString = formatter.string(from: firstReleaseDate)
                } else {
                    formatter.dateFormat = "MMMM d, yyyy"
                    adjustedDateString = formatter.string(from: firstReleaseDate)
                }
                
                let sortedCheckouts = releases.sorted {
                    $0.orderPlaced.dateValue() > $1.orderPlaced.dateValue()
                }
                
                return CheckoutHolder(dateString: adjustedDateString, checkouts: sortedCheckouts)
            }
            
            checkoutHolders.sort {
                let date1 = $0.checkouts.first?.orderPlaced.dateValue() ?? Date.distantFuture
                let date2 = $1.checkouts.first?.orderPlaced.dateValue() ?? Date.distantFuture
                return date1 < date2
            }
            
            DispatchQueue.main.async {
                checkoutHolders.forEach { element in
                    if let idx = self.checkouts.firstIndex(where: { $0.dateString == element.dateString }) {
                        var setElements = [Checkout]()
                        
                        element.checkouts.forEach { check in
                            if !self.checkouts[idx].checkouts.contains(where: { $0.id == check.id }) {
                                setElements.append(check)
                            }
                        }
                        
                        if calledFromHome {
                            self.checkouts[idx].checkouts.insert(contentsOf: setElements, at: 0)
                        } else {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                self.checkouts[idx].checkouts.insert(contentsOf: setElements, at: 0)
                            }
                        }
                    } else if calledFromHome {
                        self.checkouts.insert(element, at: 0)
                    } else {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            self.checkouts.insert(element, at: 0)
                        }
                    }
                }
                
                self.gotCheckouts = true
                
                self.setUnseen(calledFromHome: calledFromHome, lastSeen: lastSeen) { result in
                    completion((result.0, result.1, !data.isEmpty))
                }
            }
        }
    }
    func getCheckoutsOld() {
        Task {
            if let oldest = self.checkouts.last?.checkouts.last?.orderPlaced {
                CheckoutService().getCheckoutsOld(oldest: oldest) { data in
                    let calendar = Calendar.current
                    let formatter = DateFormatter()
                    
                    formatter.dateFormat = "EEEE, MMMM d"
                    
                    let groupedCheckouts = Dictionary(grouping: data) { release -> String in
                        let date = release.orderPlaced.dateValue()
                        return formatter.string(from: date)
                    }
                    
                    var checkoutHolders = groupedCheckouts.map { (dateString, releases) in
                        let firstReleaseDate = releases.first?.orderPlaced.dateValue() ?? Date()
                        
                        let adjustedDateString: String
                        if calendar.isDateInToday(firstReleaseDate) {
                            adjustedDateString = "Today"
                        } else if calendar.isDateInYesterday(firstReleaseDate) {
                            adjustedDateString = "Yesterday"
                        } else if calendar.isDate(firstReleaseDate, equalTo: Date(), toGranularity: .year) {
                            formatter.dateFormat = "EEEE, MMMM d"
                            adjustedDateString = formatter.string(from: firstReleaseDate)
                        } else {
                            formatter.dateFormat = "MMMM d, yyyy"
                            adjustedDateString = formatter.string(from: firstReleaseDate)
                        }
                        
                        let sortedCheckouts = releases.sorted {
                            $0.orderPlaced.dateValue() > $1.orderPlaced.dateValue()
                        }
                        
                        return CheckoutHolder(dateString: adjustedDateString, checkouts: sortedCheckouts)
                    }
                    
                    checkoutHolders.sort {
                        let date1 = $0.checkouts.first?.orderPlaced.dateValue() ?? Date.distantFuture
                        let date2 = $1.checkouts.first?.orderPlaced.dateValue() ?? Date.distantFuture
                        return date1 < date2
                    }
                    
                    DispatchQueue.main.async {
                        checkoutHolders.forEach { element in
                            if let idx = self.checkouts.firstIndex(where: { $0.dateString == element.dateString }) {
                                var setElements = [Checkout]()
                                
                                element.checkouts.forEach { check in
                                    if !self.checkouts[idx].checkouts.contains(where: { $0.id == check.id }) {
                                        setElements.append(check)
                                    }
                                }
                                
                                self.checkouts[idx].checkouts.append(contentsOf: setElements)
                                
                            } else {
                                self.checkouts.append(element)
                            }
                        }
                    }
                }
            }
        }
    }
    func setUnseen(calledFromHome: Bool, lastSeen: Timestamp?, completion: @escaping((Int?, Timestamp?)) -> Void) {
        let temp = self.checkouts.compactMap { $0.checkouts }
        let all = temp.compactMap { $0 }.flatMap { $0 }
        
        if calledFromHome {
            if let lastSeen {
                let countNewerThanX = all.filter { checkout in
                    checkout.orderPlaced.dateValue() > lastSeen.dateValue()
                }.count
                
                completion((countNewerThanX, nil))
            } else {
                completion((all.count, nil))
            }
        } else if let newest = all.first?.orderPlaced {
            if let lastSeen {
                if lastSeen.dateValue() < newest.dateValue() {
                    completion((nil, newest))
                } else {
                    completion((nil, nil))
                }
            } else {
                completion((nil, newest))
            }
        }
    }
    func getDayIncrease() {
        CheckoutService().getDayIncrease { result in
            self.dayIncrease = result
        }
    }
    func getMonthIncrease() {
        CheckoutService().getMonthIncrease { result in
            self.monthIncrease = result
        }
    }
    func getLeaderboardPosition(checkoutTotal: Double) {
        CheckoutService().getLeaderboardPosition(checkoutTotal: checkoutTotal) { pos in
            self.leaderBoardPosition = pos
        }
    }
    func getLeaderboardUsers() {
        let lowest = leaderboard.last?.checkoutTotal
        
        if let lowest, lowest == 0.0 {
            sortLeaderboard()
            return
        }
        
        UserService().getLeaderboardUsers(lowest: lowest) { users in
            users.forEach { element in
                if !self.leaderboard.contains(where: { $0.id == element.id }) {
                    self.leaderboard.append(element)
                }
            }
            self.sortLeaderboard()
        }
    }
    func sortLeaderboard() {
        withAnimation(.easeInOut(duration: 0.3)){
            self.leaderboard.sort(by: { $0.checkoutTotal > $1.checkoutTotal })
        }
    }
    func updateOrderStatusProxy(checkout: Checkout, proxy: String, completion: @escaping (Bool) -> Void) {
        let checkoutID = checkout.id ?? ""
        let orderLink = checkout.orderLink ?? ""

        if checkoutID.isEmpty || orderLink.isEmpty {
            completion(true)
            return
        }

        guard let url = URL(string: orderLink) else {
            completion(true)
            return
        }

        DispatchQueue.main.async {
            self.refreshingRowViews.append(checkoutID)
            self.lastRefreshed[checkoutID] = Date()
        }
        
        let proxyDetails = proxy.split(separator: ":").map(String.init)
        guard proxyDetails.count == 4, let port = UInt16(proxyDetails[1]) else {
            completion(false)
            print("Invalid proxy format")
            return
        }

        let proxyEndpoint = NWEndpoint.hostPort(host: .init(proxyDetails[0]),
                                                port: NWEndpoint.Port(integerLiteral: port))
        let proxyConfig = ProxyConfiguration(httpCONNECTProxy: proxyEndpoint, tlsOptions: nil)
        proxyConfig.applyCredential(username: proxyDetails[2], password: proxyDetails[3])

        let parameters = NWParameters.tls
        let privacyContext = NWParameters.PrivacyContext(description: "ProxyConfig")
        privacyContext.proxyConfigurations = [proxyConfig]
        parameters.setPrivacyContext(privacyContext)
    
        let host = url.host ?? ""
        let path = url.path.isEmpty ? "/" : url.path
        let query = url.query ?? ""
        let fullPath = query.isEmpty ? path : "\(path)?\(query)"

        let connection = NWConnection(
            to: .hostPort(
                host: .init(host),
                port: .init(integerLiteral: UInt16(url.port ?? 443))
            ),
            using: parameters
        )

        connection.stateUpdateHandler = { state in
            switch state {
            case .ready:

                let httpRequest = "GET \(fullPath) HTTP/1.1\r\nHost: \(host)\r\nConnection: close\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\nUser-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0.1 Safari/605.1.15\r\nAccept-Language: en-US,en;q=0.9\r\nSec-Fetch-Dest: document\r\nSec-Fetch-Mode: navigate\r\nSec-Fetch-Site: none\r\nPriority: u=0, i\r\n\r\n"
                
                connection.send(content: httpRequest.data(using: .utf8), completion: .contentProcessed({ error in
                    if let error = error {
                        print("Failed to send request: \(error)")
                        completion(false)
                        return
                    }
                    
                    readAllData(connection: connection, maxReadBytes: 500000) { finalData, readError in
                        DispatchQueue.main.async {
                            self.refreshingRowViews.removeAll(where: { $0 == checkoutID })
                        }

                        if let readError = readError {
                            print("Failed to receive response: \(readError)")
                            completion(false)
                            return
                        }

                        guard let data = finalData else {
                            print("No data received or unable to read data.")
                            completion(false)
                            return
                        }

                        if let body = String(data: data, encoding: .utf8) {
                            completion(true)

                            if body.contains("Your order is on its way") {
                                if checkout.orderTransit == nil {
                                    let deliveryEstimate = extractDeliveryEstimate(from: body)?.trimmingCharacters(in: .whitespacesAndNewlines)
                                    CheckoutService().setStatus(id: checkoutID, field: "orderTransit")
                                    self.updateArrays(checkoutID: checkoutID, newStatus: "orderTransit", deliveryEstimate: deliveryEstimate)
                                    
                                    if convertToDate(from: deliveryEstimate) != nil {
                                        CheckoutService().setEstimate(id: checkoutID, dateStr: deliveryEstimate ?? "")
                                    }
                                }
                            } else if body.contains("Your order has been delivered") || body.contains("This shipment has been delivered") {
                                if checkout.orderDelivered == nil {
                                    let deliveredDate = extractDeliveredDate(from: body)
                                    let dateObject = convertToDate(from: deliveredDate)
                                    
                                    if let dateObject {
                                        CheckoutService().setStatus(id: checkoutID, field: "orderDelivered", timestamp: Timestamp(date: dateObject))
                                        CheckoutService().setDelivered(id: checkoutID, dateStr: deliveredDate ?? "")
                                    } else {
                                        CheckoutService().setStatus(id: checkoutID, field: "orderDelivered")
                                    }
                                    self.updateArrays(checkoutID: checkoutID, newStatus: "orderDelivered", deliveredDate: deliveredDate)
                                }
                            } else if body.contains("Your order has been canceled") || body.contains("Order not found") {
                                if checkout.orderCanceled == nil {
                                    CheckoutService().setStatus(id: checkoutID, field: "orderCanceled")
                                    self.updateArrays(checkoutID: checkoutID, newStatus: "orderCanceled")
                                }
                            } else if body.contains("We've received your order") {
                                return
                            } else if body.contains("Returned") {
                                if checkout.orderCanceled == nil {
                                    CheckoutService().setStatus(id: checkoutID, field: "orderReturned")
                                    self.updateArrays(checkoutID: checkoutID, newStatus: "orderReturned")
                                }
                            } else if body.contains("Preparing") {
                                if checkout.orderCanceled == nil {
                                    CheckoutService().setStatus(id: checkoutID, field: "orderPreparing")
                                    self.updateArrays(checkoutID: checkoutID, newStatus: "orderPreparing")
                                }
                            }
                        } else {
                            print("Unable to decode response body.")
                            completion(false)
                        }
                    }
                }))

            case .failed(let error):
                print("Connection failed for proxy \(proxyDetails[0]): \(error)")
                completion(false)

            case .cancelled:
                print("Connection cancelled for proxy \(proxyDetails[0])")
                completion(false)

            case .waiting(let error):
                print("Connection waiting for proxy \(proxyDetails[0]): \(error)")
                completion(false)

            default:
                break
            }
        }

        connection.start(queue: .global())
    }
    func updateOrderStatus(checkout: Checkout, completion: @escaping (Bool) -> Void) {
        let checkoutID = checkout.id ?? ""
        let orderLink = checkout.orderLink ?? ""

        if checkoutID.isEmpty || orderLink.isEmpty {
            completion(true)
            return
        }

        guard let url = URL(string: orderLink) else {
            completion(true)
            return
        }

        DispatchQueue.main.async {
            self.refreshingRowViews.append(checkoutID)
            self.lastRefreshed[checkoutID] = Date()
        }

        let cookieStorage = HTTPCookieStorage.shared
        let config = URLSessionConfiguration.default
        config.httpCookieStorage = cookieStorage
        config.httpCookieAcceptPolicy = .always
        let session = URLSession(configuration: config)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.setValue("none", forHTTPHeaderField: "Sec-Fetch-Site")
        request.setValue("navigate", forHTTPHeaderField: "Sec-Fetch-Mode")
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0.1 Safari/605.1.15", forHTTPHeaderField: "User-Agent")
        request.setValue("en-US,en;q=0.9", forHTTPHeaderField: "Accept-Language")
        request.setValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        request.setValue("document", forHTTPHeaderField: "Sec-Fetch-Dest")
        request.setValue("u=0, i", forHTTPHeaderField: "Priority")
        
        let task = session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.refreshingRowViews.removeAll(where: { $0 == checkoutID })
            }

            if let error = error {
                print("Request error: \(error.localizedDescription)")
                completion(false)
                return
            }

            guard let data = data else {
                completion(false)
                print("No data received")
                return
            }

            if let body = String(data: data, encoding: .utf8) {
                completion(true)
                if body.contains("Your order is on its way") {
                    if checkout.orderTransit == nil {
                        let deliveryEstimate = extractDeliveryEstimate(from: body)?.trimmingCharacters(in: .whitespacesAndNewlines)
                        CheckoutService().setStatus(id: checkoutID, field: "orderTransit")
                        self.updateArrays(checkoutID: checkoutID, newStatus: "orderTransit", deliveryEstimate: deliveryEstimate)
                        
                        if convertToDate(from: deliveryEstimate) != nil {
                            CheckoutService().setEstimate(id: checkoutID, dateStr: deliveryEstimate ?? "")
                        }
                    }
                } else if body.contains("Your order has been delivered") || body.contains("This shipment has been delivered") {
                    if checkout.orderDelivered == nil {
                        let deliveredDate = extractDeliveredDate(from: body)
                        let dateObject = convertToDate(from: deliveredDate)
                        
                        if let dateObject {
                            CheckoutService().setStatus(id: checkoutID, field: "orderDelivered", timestamp: Timestamp(date: dateObject))
                            CheckoutService().setDelivered(id: checkoutID, dateStr: deliveredDate ?? "")
                        } else {
                            CheckoutService().setStatus(id: checkoutID, field: "orderDelivered")
                        }
                        self.updateArrays(checkoutID: checkoutID, newStatus: "orderDelivered", deliveredDate: deliveredDate)
                    }
                } else if body.contains("Your order has been canceled") || body.contains("Order not found") {
                    if checkout.orderCanceled == nil {
                        CheckoutService().setStatus(id: checkoutID, field: "orderCanceled")
                        self.updateArrays(checkoutID: checkoutID, newStatus: "orderCanceled")
                    }
                } else if body.contains("We've received your order") {
                    return
                } else if body.contains("Returned") {
                    if checkout.orderCanceled == nil {
                        CheckoutService().setStatus(id: checkoutID, field: "orderReturned")
                        self.updateArrays(checkoutID: checkoutID, newStatus: "orderReturned")
                    }
                } else if body.contains("Preparing") {
                    if checkout.orderCanceled == nil {
                        CheckoutService().setStatus(id: checkoutID, field: "orderPreparing")
                        self.updateArrays(checkoutID: checkoutID, newStatus: "orderPreparing")
                    }
                }
            } else {
                completion(false)
                print("Unable to decode response body")
            }
        }

        task.resume()
    }
    func updateArrays(checkoutID: String, newStatus: String, deliveredDate: String? = nil, deliveryEstimate: String? = nil) {
        for j in 0..<self.checkouts.count {
            var shouldBreak = false
            
            for i in 0..<self.checkouts[j].checkouts.count {
                if self.checkouts[j].checkouts[i].id == checkoutID {
                    DispatchQueue.main.async {
                        if newStatus == "orderPreparing" {
                            self.checkouts[j].checkouts[i].orderPreparing = Timestamp()
                        } else if newStatus == "orderReturned" {
                            self.checkouts[j].checkouts[i].orderReturned = Timestamp()
                        } else if newStatus == "orderCanceled" {
                            self.checkouts[j].checkouts[i].orderCanceled = Timestamp()
                        } else if newStatus == "orderDelivered" {
                            
                            if let deliveredDate, let dateObject = convertToDate(from: deliveredDate) {
                                self.checkouts[j].checkouts[i].deliveredDate = deliveredDate
                                self.checkouts[j].checkouts[i].orderDelivered = Timestamp(date: dateObject)
                            } else {
                                self.checkouts[j].checkouts[i].orderDelivered = Timestamp()
                            }
                            
                        } else if newStatus == "orderTransit" {
                            self.checkouts[j].checkouts[i].orderTransit = Timestamp()
                            if let deliveryEstimate, !deliveryEstimate.isEmpty {
                                self.checkouts[j].checkouts[i].estimatedDelivery = deliveryEstimate
                            }
                        }
                    }
                    shouldBreak = true
                    break
                }
            }
            
            if shouldBreak {
                break
            }
        }
        
        if !self.cachedFilters.isEmpty {
            for i in 0..<(self.cachedFilters[0].2?.count ?? 0) {
                var shouldBreak = false
                
                for j in 0..<(self.cachedFilters[0].2?[i].checkouts.count ?? 0) {
                    if self.cachedFilters[0].2?[i].checkouts[j].id == checkoutID {
                        
                        DispatchQueue.main.async {
                            if newStatus == "orderPreparing" {
                                self.cachedFilters[0].2?[i].checkouts[j].orderPreparing = Timestamp()
                            } else if newStatus == "orderReturned" {
                                self.cachedFilters[0].2?[i].checkouts[j].orderReturned = Timestamp()
                            } else if newStatus == "orderCanceled" {
                                self.cachedFilters[0].2?[i].checkouts[j].orderCanceled = Timestamp()
                            } else if newStatus == "orderDelivered" {
                                
                                if let deliveredDate, let dateObject = convertToDate(from: deliveredDate) {
                                    self.cachedFilters[0].2?[i].checkouts[j].deliveredDate = deliveredDate
                                    self.cachedFilters[0].2?[i].checkouts[j].orderDelivered = Timestamp(date: dateObject)
                                } else {
                                    self.cachedFilters[0].2?[i].checkouts[j].orderDelivered = Timestamp()
                                }
                                
                            } else if newStatus == "orderTransit" {
                                self.cachedFilters[0].2?[i].checkouts[j].orderTransit = Timestamp()
                                if let deliveryEstimate, !deliveryEstimate.isEmpty {
                                    self.cachedFilters[0].2?[i].checkouts[j].estimatedDelivery = deliveryEstimate
                                }
                            }
                        }
                        
                        shouldBreak = true
                        break
                    }
                }
                
                if shouldBreak {
                    break
                }
            }
        }
    }
    func shouldReload(checkout: Checkout) -> Bool {
        if checkout.orderDelivered != nil || checkout.orderCanceled != nil || checkout.orderReturned != nil {
            return false
        }
        
        if (checkout.orderLink ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return false
        }
        if checkout.site.lowercased().contains("pokemon") {
            return false
        }
        
        if let lastRefreshed = self.lastRefreshed[checkout.id ?? ""] {
            if !isAtLeastFiveMinutesOld(from: lastRefreshed) {
                return false
            }
        }
        
        return true
    }
}

func decodeHTMLEntities(_ string: String) -> String {
    var decodedString = string
    let htmlEntities = [
        "&nbsp;": " ", // Non-breaking space
        "&lt;": "<",   // Less than
        "&gt;": ">",   // Greater than
        "&amp;": "&",  // Ampersand
        "&quot;": "\"", // Double quote
        "&apos;": "'"  // Single quote
    ]
    for (entity, replacement) in htmlEntities {
        decodedString = decodedString.replacingOccurrences(of: entity, with: replacement)
    }
    return decodedString
}

func extractDeliveryEstimate(from html: String) -> String? {
    let pattern = #"(?:Estimated delivery date:|Current delivery estimate:)\s*<strong[^>]*>\s*([^<]+)\s*</strong>"#
    
    do {
        let regex = try NSRegularExpression(pattern: pattern, options: [])
        if let match = regex.firstMatch(in: html, options: [], range: NSRange(html.startIndex..., in: html)) {
            if let range = Range(match.range(at: 1), in: html) {
                let capturedText = String(html[range]).trimmingCharacters(in: .whitespacesAndNewlines)
                return decodeHTMLEntities(capturedText)
            }
        }
    } catch {
        print("Invalid regex: \(error.localizedDescription)")
    }
    return nil
}

func extractDeliveredDate(from html: String) -> String? {
    let pattern = #"<span class="os-timeline-step__title">\s*Delivered\s*</span>\s*<span class="os-timeline-step__date">\s*([^<]+)\s*</span>"#
    
    do {
        let regex = try NSRegularExpression(pattern: pattern, options: [])
        if let match = regex.firstMatch(in: html, options: [], range: NSRange(html.startIndex..., in: html)) {
            if let range = Range(match.range(at: 1), in: html) {
                return String(html[range]).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
    } catch {
        print("Invalid regex: \(error.localizedDescription)")
    }
    return nil
}

func convertToDate(from input: String?) -> Date? {
    guard let input = input?.trimmingCharacters(in: .whitespacesAndNewlines), !input.isEmpty else {
        return nil
    }

    let formats = ["MMMM d", "MMMM dd", "MMM d", "MMM dd", "MMMM d, yyyy", "MMMM dd, yyyy", "MMM d, yyyy", "MMM dd, yyyy", "yyyy-MM-dd", "MM/dd/yyyy", "MM-dd-yyyy", "d MMMM yyyy", "d MMM yyyy", "d-MMM-yyyy", "d/MMM/yyyy"]
    
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.timeZone = TimeZone.current

    for format in formats {
        dateFormatter.dateFormat = format
        if let partialDate = dateFormatter.date(from: input) {
            var calendar = Calendar.current
            calendar.timeZone = TimeZone.current
            
            let components = calendar.dateComponents([.month, .day], from: partialDate)
            guard let month = components.month, let day = components.day else {
                return nil
            }
            
            let currentYear = calendar.component(.year, from: Date())
            let currentMonth = calendar.component(.month, from: Date())
            let year = (month <= currentMonth) ? currentYear : (currentYear - 1)
            
            var fullComponents = DateComponents()
            fullComponents.year = year
            fullComponents.month = month
            fullComponents.day = day
            return calendar.date(from: fullComponents)
        }
    }

    return nil
}

func isAtLeastFiveMinutesOld(from date: Date) -> Bool {
    let oneMinuteAgo = Date().addingTimeInterval(-300)
    return date <= oneMinuteAgo
}
