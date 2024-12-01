import Foundation
import Network

func getCapSolverBalance(apiKey: String, completion: @escaping (Double?) -> Void) {
    let url = URL(string: "https://api.capsolver.com/getBalance")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let body: [String: Any] = ["clientKey": apiKey]
    request.httpBody = try? JSONSerialization.data(withJSONObject: body)
    
    let session = URLSession.shared
    session.dataTask(with: request) { data, response, error in
        guard let data = data, error == nil else {
            completion(nil)
            return
        }
        
        do {
            if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let errorId = jsonObject["errorId"] as? Int, errorId == 0,
               let balance = jsonObject["balance"] as? Double {
                completion(balance)
            } else {
                completion(nil)
            }
        } catch {
            completion(nil)
        }
    }.resume()
}

func genProxies(userLogin: String, userPassword: String, countryId: String, state: String?, genCount: Int, SoftSession: Bool) -> String {
    var proxies: [String] = []
    
    var sessionType = "session"
    
    if !SoftSession {
        sessionType = "hardsession"
    }

    for _ in 0..<genCount {
        let sessionSuffix = generateRandomString(length: 8)
        var baseLink = "resi.wealthproxies.com:8000:\(userLogin):\(userPassword)-country-\(countryId)-\(sessionType)-\(sessionSuffix)-duration-60"
        
        if let state = state {
            let lowerState = state.lowercased()
            baseLink = "resi.wealthproxies.com:8000:\(userLogin):\(userPassword)-country-\(countryId)-region-\(lowerState)-\(sessionType)-\(sessionSuffix)-duration-60"
        }
        
        proxies.append(baseLink)
    }

    return proxies.joined(separator: "\n")
}

func fetchUserCredentials(dUID: String, completion: @escaping (String?, String?) -> Void) {
    let urlString = "https://stripe.wealthproxies.com/user-credentials"
    guard let url = URL(string: urlString) else {
        completion(nil, nil)
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    let requestBody: [String: Any] = ["discordId": dUID]

    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
    } catch {
        completion(nil, nil)
        return
    }

    URLSession.shared.dataTask(with: request) { data, response, error in
        guard error == nil,
              let data = data,
              let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            completion(nil, nil)
            return
        }

        do {
            if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let login = jsonResponse["login"] as? String,
               let password = jsonResponse["password"] as? String {
                completion(login, password)
            } else {
                completion(nil, nil)
            }
        } catch {
            completion(nil, nil)
        }
    }.resume()
}

struct BandwidthDetails: Equatable {
    var trafficBalanceString: String
    var trafficConsumed: String
    var lastUpdated: String
}

func extractBandwidth(from string: String) -> Double? {
    let pattern = #"-?\d+(\.\d+)?"#
    
    guard let regex = try? NSRegularExpression(pattern: pattern) else {
        return nil
    }
    
    let range = NSRange(location: 0, length: string.utf16.count)
    if let match = regex.firstMatch(in: string, options: [], range: range) {
        let matchedSubstring = (string as NSString).substring(with: match.range)
        
        return Double(matchedSubstring)
    }
    
    return nil
}

func checkBandwidth(dUID: String, completion: @escaping (BandwidthDetails?) -> Void) {
    let urlString = "https://stripe.wealthproxies.com/check-bandwidth"
    guard let url = URL(string: urlString) else {
        completion(nil)
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    let requestBody: [String: Any] = ["discordId": dUID]

    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
    } catch {
        completion(nil)
        return
    }

    URLSession.shared.dataTask(with: request) { data, response, error in
        guard error == nil,
              let data = data,
              let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            completion(nil)
            return
        }

        do {
            if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                if let trafficBalanceString = jsonResponse["trafficBalanceString"] as? String,
                   let trafficConsumed = jsonResponse["trafficConsumed"] as? String,
                   let lastUpdated = jsonResponse["lastUpdated"] as? String {
                    completion(
                        BandwidthDetails(
                            trafficBalanceString: trafficBalanceString,
                            trafficConsumed: trafficConsumed,
                            lastUpdated: lastUpdated
                        )
                    )
                }
            } else {
                completion(nil)
            }
        } catch {
            completion(nil)
        }
    }.resume()
}

func fetchPurchaseLink(dUID: String, dUsername: String, completion: @escaping (String?) -> Void) {
    let urlString = "https://stripe.wealthproxies.com/create-checkout-session-resi"
    guard let url = URL(string: urlString) else {
        completion(nil)
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    let requestBody: [String: Any] = [
        "discordId": dUID,
        "discordUsername": dUsername,
        "serverName": "Wealth Proxies"
    ]

    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
    } catch {
        completion(nil)
        return
    }

    URLSession.shared.dataTask(with: request) { data, response, error in
        guard error == nil,
              let data = data,
              let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            completion(nil)
            return
        }

        do {
            if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let checkoutLink = jsonResponse["url"] as? String {
                completion(checkoutLink)
            } else {
                completion(nil)
            }
        } catch {
            completion(nil)
        }
    }.resume()
}

func averageProxyGroupSpeed(proxies: [String], completion: @escaping (Int, String) -> Void) {
    let numProxies = proxies.count
    if numProxies == 0 {
        completion(0, "No proxies")
        return
    }

    var totalTime: Int64 = 0
    var successCount = 0
    let group = DispatchGroup()
    let queue = DispatchQueue(label: "proxyQueue", attributes: .concurrent)
    let lock = NSLock()

    let shuffledProxies = proxies.shuffled()
    let selectedProxies = Array(shuffledProxies.prefix(25))

    for proxy in selectedProxies {
        group.enter()
        queue.async {
            let proxyDetails = proxy.split(separator: ":").map(String.init)
            guard proxyDetails.count == 4,
                  let port = UInt16(proxyDetails[1]) else {
                completion(0, "Invalid proxy format")
                group.leave()
                return
            }

            let proxyEndpoint = NWEndpoint.hostPort(host: .init(proxyDetails[0]), port: NWEndpoint.Port(integerLiteral: port))
            let proxyConfig = ProxyConfiguration(httpCONNECTProxy: proxyEndpoint, tlsOptions: nil)
            proxyConfig.applyCredential(username: proxyDetails[2], password: proxyDetails[3])

            let parameters = NWParameters.tls
            let privacyContext = NWParameters.PrivacyContext(description: "ProxyConfig")
            privacyContext.proxyConfigurations = [proxyConfig]
            parameters.setPrivacyContext(privacyContext)


            let connection = NWConnection(
                to: .hostPort(
                    host: .init("httpbin.org"),
                    port: .init(integerLiteral: UInt16(443))
                ),
                using: parameters
            )
            
            let start = Date()
            
            connection.stateUpdateHandler = { state in
                switch state {
                case .ready:
                                        
                    let httpRequest = "GET /get HTTP/1.1\r\nHost: httpbin.org\r\nConnection: close\r\nAccept: */*\r\nUser-Agent: MySwiftApp/1.0\r\n\r\n"
                    
                    connection.send(content: httpRequest.data(using: .utf8), completion: .contentProcessed({ error in
                        if let error = error {
                            print("Failed to send request: \(error)")
                            group.leave()
                        } else {
                            connection.receive(minimumIncompleteLength: 1, maximumLength: 4096) { data, _, isComplete, error in
                                defer { group.leave() }
                                
                                if let error = error {
                                    print("Failed to receive response: \(error)")
                                } else if isComplete || data != nil {
                                    let duration = Date().timeIntervalSince(start) * 1000
                                    
                                    lock.lock()
                                    totalTime += Int64(duration)
                                    successCount += 1
                                    lock.unlock()
                                }
                            }
                        }
                    }))
                case .failed:
                    group.leave()
                case .cancelled:
                    group.leave()
                case .waiting:
                    group.leave()
                default:
                    break
                }
            }

            connection.start(queue: queue)
        }
    }

    group.notify(queue: DispatchQueue.main) {
        if successCount == 0 {
            completion(0, "Proxies Failed")
        } else {
            let averageTime = Int(Double(totalTime) / Double(successCount))
            completion(averageTime, "")
        }
    }
}

func generateRandomString(length: Int) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyz0123456789"
    let randomString = String((0..<length).compactMap { _ in letters.randomElement() })
    return randomString
}

struct Country: Identifiable {
    let id: String
    let name: String
}

let countriesResi: [Country] = [
    Country(id: "AD", name: "Andorra"),
    Country(id: "AE", name: "United Arab Emirates"),
    Country(id: "AG", name: "Antigua and Barbuda"),
    Country(id: "AI", name: "Anguilla"),
    Country(id: "AL", name: "Albania"),
    Country(id: "AM", name: "Armenia"),
    Country(id: "AO", name: "Angola"),
    Country(id: "AR", name: "Argentina"),
    Country(id: "AT", name: "Austria"),
    Country(id: "AU", name: "Australia"),
    Country(id: "AW", name: "Aruba"),
    Country(id: "AZ", name: "Azerbaijan"),
    Country(id: "BA", name: "Bosnia and Herzegovina"),
    Country(id: "BD", name: "Bangladesh"),
    Country(id: "BE", name: "Belgium"),
    Country(id: "BF", name: "Burkina Faso"),
    Country(id: "BG", name: "Bulgaria"),
    Country(id: "BH", name: "Bahrain"),
    Country(id: "BJ", name: "Benin"),
    Country(id: "BL", name: "Saint Barthélemy"),
    Country(id: "BM", name: "Bermuda"),
    Country(id: "BN", name: "Brunei"),
    Country(id: "BO", name: "Bolivia"),
    Country(id: "BQ", name: "Bonaire"),
    Country(id: "BR", name: "Brazil"),
    Country(id: "BS", name: "Bahamas"),
    Country(id: "BT", name: "Bhutan"),
    Country(id: "BW", name: "Botswana"),
    Country(id: "BY", name: "Belarus"),
    Country(id: "BZ", name: "Belize"),
    Country(id: "CA", name: "Canada"),
    Country(id: "CG", name: "Congo Republic"),
    Country(id: "CH", name: "Switzerland"),
    Country(id: "CI", name: "Ivory Coast"),
    Country(id: "CL", name: "Chile"),
    Country(id: "CM", name: "Cameroon"),
    Country(id: "CN", name: "China"),
    Country(id: "CO", name: "Colombia"),
    Country(id: "CR", name: "Costa Rica"),
    Country(id: "CV", name: "Cabo Verde"),
    Country(id: "CW", name: "Curaçao"),
    Country(id: "CY", name: "Cyprus"),
    Country(id: "CZ", name: "Czechia"),
    Country(id: "DE", name: "Germany"),
    Country(id: "DJ", name: "Djibouti"),
    Country(id: "DK", name: "Denmark"),
    Country(id: "DM", name: "Dominica"),
    Country(id: "DO", name: "Dominican Republic"),
    Country(id: "DZ", name: "Algeria"),
    Country(id: "EC", name: "Ecuador"),
    Country(id: "EE", name: "Estonia"),
    Country(id: "EG", name: "Egypt"),
    Country(id: "ES", name: "Spain"),
    Country(id: "ET", name: "Ethiopia"),
    Country(id: "FI", name: "Finland"),
    Country(id: "FJ", name: "Fiji"),
    Country(id: "FR", name: "France"),
    Country(id: "GA", name: "Gabon"),
    Country(id: "GB", name: "United Kingdom"),
    Country(id: "GD", name: "Grenada"),
    Country(id: "GE", name: "Georgia"),
    Country(id: "GF", name: "French Guiana"),
    Country(id: "GH", name: "Ghana"),
    Country(id: "GI", name: "Gibraltar"),
    Country(id: "GL", name: "Greenland"),
    Country(id: "GM", name: "Gambia"),
    Country(id: "GP", name: "Guadeloupe"),
    Country(id: "GR", name: "Greece"),
    Country(id: "GT", name: "Guatemala"),
    Country(id: "GU", name: "Guam"),
    Country(id: "GY", name: "Guyana"),
    Country(id: "HK", name: "Hong Kong"),
    Country(id: "HN", name: "Honduras"),
    Country(id: "HR", name: "Croatia"),
    Country(id: "HT", name: "Haiti"),
    Country(id: "HU", name: "Hungary"),
    Country(id: "ID", name: "Indonesia"),
    Country(id: "IE", name: "Ireland"),
    Country(id: "IL", name: "Israel"),
    Country(id: "IM", name: "Isle of Man"),
    Country(id: "IN", name: "India"),
    Country(id: "IQ", name: "Iraq"),
    Country(id: "IS", name: "Iceland"),
    Country(id: "IT", name: "Italy"),
    Country(id: "JM", name: "Jamaica"),
    Country(id: "JO", name: "Jordan"),
    Country(id: "JP", name: "Japan"),
    Country(id: "KE", name: "Kenya"),
    Country(id: "KH", name: "Cambodia"),
    Country(id: "KN", name: "St Kitts and Nevis"),
    Country(id: "KR", name: "South Korea"),
    Country(id: "KW", name: "Kuwait"),
    Country(id: "KY", name: "Cayman Islands"),
    Country(id: "LB", name: "Lebanon"),
    Country(id: "LC", name: "Saint Lucia"),
    Country(id: "LK", name: "Sri Lanka"),
    Country(id: "LR", name: "Liberia"),
    Country(id: "LS", name: "Lesotho"),
    Country(id: "LT", name: "Lithuania"),
    Country(id: "LU", name: "Luxembourg"),
    Country(id: "LV", name: "Latvia"),
    Country(id: "MA", name: "Morocco"),
    Country(id: "MD", name: "Moldova"),
    Country(id: "ME", name: "Montenegro"),
    Country(id: "MF", name: "Saint Martin"),
    Country(id: "MG", name: "Madagascar"),
    Country(id: "MK", name: "North Macedonia"),
    Country(id: "ML", name: "Mali"),
    Country(id: "MM", name: "Myanmar"),
    Country(id: "MN", name: "Mongolia"),
    Country(id: "MO", name: "Macao"),
    Country(id: "MR", name: "Mauritania"),
    Country(id: "MT", name: "Malta"),
    Country(id: "MU", name: "Mauritius"),
    Country(id: "MW", name: "Malawi"),
    Country(id: "MX", name: "Mexico"),
    Country(id: "MZ", name: "Mozambique"),
    Country(id: "NA", name: "Namibia"),
    Country(id: "NC", name: "New Caledonia"),
    Country(id: "NG", name: "Nigeria"),
    Country(id: "NI", name: "Nicaragua"),
    Country(id: "NL", name: "The Netherlands"),
    Country(id: "NO", name: "Norway"),
    Country(id: "NP", name: "Nepal"),
    Country(id: "NZ", name: "New Zealand"),
    Country(id: "OM", name: "Oman"),
    Country(id: "PA", name: "Panama"),
    Country(id: "PE", name: "Peru"),
    Country(id: "PF", name: "French Polynesia"),
    Country(id: "PH", name: "Philippines"),
    Country(id: "PK", name: "Pakistan"),
    Country(id: "PL", name: "Poland"),
    Country(id: "PR", name: "Puerto Rico"),
    Country(id: "PT", name: "Portugal"),
    Country(id: "QA", name: "Qatar"),
    Country(id: "RE", name: "Réunion"),
    Country(id: "RO", name: "Romania"),
    Country(id: "RS", name: "Serbia"),
    Country(id: "RU", name: "Russia"),
    Country(id: "RW", name: "Rwanda"),
    Country(id: "SA", name: "Saudi Arabia"),
    Country(id: "SB", name: "Solomon Islands"),
    Country(id: "SC", name: "Seychelles"),
    Country(id: "SE", name: "Sweden"),
    Country(id: "SG", name: "Singapore"),
    Country(id: "SI", name: "Slovenia"),
    Country(id: "SK", name: "Slovakia"),
    Country(id: "SN", name: "Senegal"),
    Country(id: "SR", name: "Suriname"),
    Country(id: "ST", name: "São Tomé and Príncipe"),
    Country(id: "SV", name: "El Salvador"),
    Country(id: "SX", name: "Sint Maarten"),
    Country(id: "SZ", name: "Eswatini"),
    Country(id: "TC", name: "Turks and Caicos Islands"),
    Country(id: "TG", name: "Togo"),
    Country(id: "TH", name: "Thailand"),
    Country(id: "TN", name: "Tunisia"),
    Country(id: "TR", name: "Türkiye"),
    Country(id: "TT", name: "Trinidad and Tobago"),
    Country(id: "TZ", name: "Tanzania"),
    Country(id: "UA", name: "Ukraine"),
    Country(id: "UG", name: "Uganda"),
    Country(id: "US", name: "United States"),
    Country(id: "UY", name: "Uruguay"),
    Country(id: "UZ", name: "Uzbekistan"),
    Country(id: "VC", name: "St Vincent and Grenadines"),
    Country(id: "VG", name: "British Virgin Islands"),
    Country(id: "VI", name: "U.S. Virgin Islands"),
    Country(id: "VN", name: "Vietnam"),
    Country(id: "XK", name: "Kosovo"),
    Country(id: "ZA", name: "South Africa"),
    Country(id: "ZM", name: "Zambia")
]
