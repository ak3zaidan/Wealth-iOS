import Foundation

let UserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0.1 Safari/605.1.15"

func getVariant(client: Client, site: String) async -> String {
    if site.contains("denimtears.com") {
        return "44458776854697"
    } else if site.contains("supreme") {
        return "42713357091087"
    } else if site.contains("palaceskateboards") {
        return "44560485187711"
    } else if site.contains("ladygaga") {
        return "41551785295949"
    } else {
        return await checkBasicShopify(client: client, retry: true, baseUrl: site)
    }
}

func trackQueue(client: Client, baseUrl: String, variantStr: String, appeared: inout Bool) async -> String? {
    guard let variant = Int(variantStr) else {
        return nil
    }
    
    let (_, atcError) = await addToCart(client: client, variantId: variantStr, baseUrl: baseUrl)
    if !appeared {
        return nil
    }
    
    if !atcError.isEmpty {
        print("Failed to ATC")
        return nil
    } else {
        let (cartStatus, statusErr) = await getCartDetails(client: client, baseUrl: baseUrl)
        if !appeared {
            return nil
        }
                
        if !statusErr.isEmpty {
            print("Cart status: \(statusErr)")
            return nil
        } else if let token = cartStatus?["token"] as? String {
            
            let (bodyStr, checkoutErr) = await getCheckout(client: client, token: token, baseUrl: baseUrl)
            if !appeared {
                return nil
            }
            
            if let bodyStr {
                let checkoutId = getSubstring(body: bodyStr, begin: "checkout_url=%2Fcheckouts%2Fcn%2F", end: "%3F")
                let queueToken = getEndSubstring(body: bodyStr, begin: "queueToken&quot;:&quot;", end: "&quot")
                let queueDomain = getSubstring(body: bodyStr, begin: "myshopifyDomain&quot;:&quot;", end: "&quot")
                                
                if checkoutId == "-1" || queueToken == "-1" || queueDomain == "-1" {
                    print("\nError parsing checkout for \(baseUrl), potential proxy block or cp up")
                    return nil
                }
                
                let queuePoll = await pollQueue(client: client, queueDomain: queueDomain, variantId: variant, checkoutId: checkoutId, queueToken: queueToken, iteration: 0, appeared: &appeared)
                
                if !queuePoll.1.isEmpty {
                    print("\nError checking queue: \(queuePoll.1)")
                    return nil
                } else {
                    return queuePoll.0
                }
            } else {
                print("Failed to get checkout: \(checkoutErr)")
                return nil
            }
        }
    }
    
    return nil
}

func pollQueue(client: Client, queueDomain: String, variantId: Int, checkoutId: String, queueToken: String, iteration: Int, appeared: inout Bool) async -> (String, String) {
    let url = "https://\(queueDomain)/queue/poll?operationName=ThrottlePoll"
    
    var headers: [String: String] = [
        "Content-Type": "application/json",
        "Sec-Fetch-Dest": "empty",
        "Accept": "application/json",
        "Sec-Fetch-Site": "cross-site",
        "Accept-Language": "en-US",
        "Sec-Fetch-Mode": "cors",
        "Origin": "https://shop.app",
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0.1 Safari/605.1.15",
        "Connection": "close",
        "x-checkout-web-source-id": checkoutId,
        "x-checkout-web-server-handling": "fast",
        "x-queue-session-fallback": "true",
        "Priority": "u=3, i",
        "x-checkout-web-deploy-stage": "production",
        "shopify-checkout-client": "checkout-web/1.0",
        "x-checkout-web-build-id": "b4069174a959aa76ee06bcbdcf0037b011a98742"
    ]
    
    let data: [String: Any] = [
        "query": "query ThrottlePoll($token:String!,$variantIdsV2:[Int!]){poll(token:$token,variantIdsV2:$variantIdsV2){...on PollContinue{token pollAfter queueEtaSeconds productVariantAvailabilityV2{available id __typename}__typename}...on PollComplete{token __typename}__typename}}",
        "variables": [
            "token": queueToken,
            "variantIdsV2": [variantId]
        ],
        "operationName": "ThrottlePoll"
    ]
    
    guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: []) else {
        return ("", "Error: Unable to serialize data")
    }
    
    headers["Content-Length"] = "\(jsonData.count)"

    let response = await client.request(
        requestType: client.POST,
        endpoint: url,
        body: String(data: jsonData, encoding: .utf8),
        headers: headers,
        headerOrder: [
            "Content-Type", "Sec-Fetch-Dest", "Accept", "Sec-Fetch-Site", "Accept-Language",
            "Sec-Fetch-Mode", "Origin", "User-Agent", "Connection",
            "x-checkout-web-source-id", "x-checkout-web-server-handling", "x-queue-session-fallback", "Priority",
            "x-checkout-web-deploy-stage", "shopify-checkout-client", "x-checkout-web-build-id", "Content-Length"
        ],
        maxReadBytes: 500000,
        followRedirect: false,
        maxRedirectsToFollow: 5
    )
    if !appeared {
        return ("", "Appeared is false")
    }
    
    if let resp = response.0 {
        if resp.statusCode != 200 {
            return ("", "Error: Status code \(resp.statusCode)")
        }
        
        if let responseBody = resp.responseBody, let data = responseBody.data(using: .utf8) {
            do {
                if let queuePoll = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let data = queuePoll["data"] as? [String: Any],
                   let poll = data["poll"] as? [String: Any] {
                                                            
                    let queueStatus = poll["__typename"] as? String ?? ""
                    let newToken = poll["token"] as? String ?? ""
                    
                    if queueStatus == "PollComplete" {
                        return ("No queue", "")
                    } else if queueStatus == "PollContinue" {
                        if let queueSeconds = poll["queueEtaSeconds"] as? Int, queueSeconds == 0 {
                            if let pollAfter = poll["pollAfter"] as? String {
                                let secondsWait = secondsUntil(dateTimeString: pollAfter)

                                if iteration >= 7 {
                                    let nextPoll = convertPollToReadableTime(iso8601String: pollAfter) ?? "NA"
                                    
                                    return ("Poll Next: \(nextPoll)", "")
                                } else {
                                    try await Task.sleep(nanoseconds: UInt64(secondsWait / 2) * 1_000_000_000)

                                    return await pollQueue(client: client, queueDomain: queueDomain, variantId: variantId, checkoutId: checkoutId, queueToken: newToken, iteration: iteration + 1, appeared: &appeared)
                                }
                            } else {
                                return ("No queue", "")
                            }
                        } else if let queueEta = poll["queueEtaSeconds"] as? Int {
                            
                            let formattedEta = addSecondsAndFormat(seconds: queueEta)
                            
                            let pollAfter = poll["pollAfter"] as? String ?? ""
                            let nextPoll = convertPollToReadableTime(iso8601String: pollAfter) ?? "NA"
                            
                            return ("ETA: \(formattedEta)\nPoll Next: \(nextPoll)", "")
                        }
                    }
                }
            } catch {
                return ("", "Error parsing JSON: \(error.localizedDescription)")
            }
        }
    } else if let error = response.1 {
        return ("", "Error making request: \(error.localizedDescription)")
    }
    
    return ("", "Unknown error")
}

func getCheckout(client: Client, token: String, baseUrl: String) async -> (String?, String) {
    var baseUrl = baseUrl
    if !baseUrl.hasPrefix("https://") {
        baseUrl = "https://" + baseUrl
    }
    
    baseUrl = baseUrl.trimmingCharacters(in: .punctuationCharacters)
    
    let url = "\(baseUrl)/checkouts/cn/\(token)"
    
    let headers: [String: String] = [
        "Connection": "close",
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        "Sec-Fetch-Site": "same-origin",
        "Sec-Fetch-Dest": "document",
        "Sec-Fetch-Mode": "navigate",
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0.1 Safari/605.1.15",
        "Referer": "\(baseUrl)/cart",
        "Accept-Language": "en-US,en;q=0.9",
        "Priority": "u=0, i"
    ]

    let response = await client.request(
        requestType: client.GET,
        endpoint: url,
        body: nil,
        headers: headers,
        headerOrder: [
            "Connection", "Accept", "Sec-Fetch-Site", "Sec-Fetch-Dest", "Sec-Fetch-Mode",
            "User-Agent", "Referer", "Accept-Language", "Priority"
        ],
        maxReadBytes: 500000,
        followRedirect: true,
        maxRedirectsToFollow: 5
    )

    if let resp = response.0 {
        if resp.statusCode != 200 {
            return (nil, "Status error: \(resp.statusCode)")
        }
        if let responseBody = resp.responseBody {
            return (responseBody, "")
        } else {
            return (nil, "Error: No response body received.")
        }
    } else if let error = response.1 {
        return (nil, "Error making request: \(error.localizedDescription)")
    }
    
    return (nil, "Unknown error")
}

func getCartDetails(client: Client, baseUrl: String) async -> ([String: Any]?, String) {
    var baseUrl = baseUrl
    if !baseUrl.hasPrefix("https://") {
        baseUrl = "https://" + baseUrl
    }

    let url = "\(baseUrl.trimmingCharacters(in: .punctuationCharacters))/cart.js"
    
    let headers: [String: String] = [
        "Connection": "close",
        "Sec-Fetch-Site": "same-origin",
        "Sec-Fetch-Dest": "empty",
        "Accept-Language": "en-US,en;q=0.9",
        "Sec-Fetch-Mode": "cors",
        "User-Agent": UserAgent,
        "Referer": baseUrl.trimmingCharacters(in: .punctuationCharacters) + "/cart",
        "Priority": "u=3, I"
    ]

    let response = await client.request(
        requestType: client.GET,
        endpoint: url,
        body: nil,
        headers: headers,
        headerOrder: [
            "Connection", "Sec-Fetch-Site", "Sec-Fetch-Dest", "Accept-Language", "Sec-Fetch-Mode",
            "User-Agent", "Referer", "Priority"
        ],
        maxReadBytes: 500000,
        followRedirect: false,
        maxRedirectsToFollow: 5
    )

    if let resp = response.0 {
        if resp.statusCode != 200 {
            return (nil, "Status error: \(resp.statusCode)")
        }
        if let responseBody = resp.responseBody, let data = responseBody.data(using: .utf8) {
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                return (jsonResponse ?? [:], "")
            } catch {
                return (nil, "Error parsing JSON response.")
            }
        } else {
            return (nil, "Error: No response body received.")
        }
    } else if let error = response.1 {
        return (nil, "Error making request: \(error.localizedDescription)")
    }
    
    return (nil, "Unknown error")
}

func addToCart(client: Client, variantId: String, baseUrl: String) async -> (Any?, String) {
    var baseUrl = baseUrl
    if !baseUrl.hasPrefix("https://") {
        baseUrl = "https://" + baseUrl
    }

    let url = "\(baseUrl.trimmingCharacters(in: .punctuationCharacters))/cart/add.js"
    var headers: [String: String] = [
        "Connection": "close",
        "Content-Type": "application/json",
        "Accept": "*/*",
        "Sec-Fetch-Site": "same-origin",
        "Accept-Language": "en-US,en;q=0.9",
        "Sec-Fetch-Mode": "cors",
        "Origin": baseUrl,
        "User-Agent": UserAgent
    ]
    
    let formData: [String: Any] = [
        "items": [
            [
                "id": variantId,
                "quantity": 1,
                "properties": (baseUrl.contains("creations.mattel")) ? ["variant_inventorystatus": "Available"] : [:]
            ]
        ]
    ]
    
    guard let jsonData = try? JSONSerialization.data(withJSONObject: formData, options: []) else {
        return (nil, "Error serializing form data to JSON.")
    }
    
    headers["Content-Length"] = String(jsonData.count)

    let response = await client.request(
        requestType: client.POST,
        endpoint: url,
        body: String(data: jsonData, encoding: .utf8),
        headers: headers,
        headerOrder: [
            "Connection", "Content-Type", "Accept", "Sec-Fetch-Site", "Accept-Language",
            "Sec-Fetch-Mode", "Origin", "User-Agent", "Content-Length"
        ],
        maxReadBytes: 500000,
        followRedirect: false,
        maxRedirectsToFollow: 5
    )
    
    if let resp = response.0 {
        if resp.statusCode != 200 {
            return (nil, "Status error: \(resp.statusCode)")
        } else {
            return (nil, "")
        }
    } else if let error = response.1 {
        return (nil, "Error making request: \(error.localizedDescription)")
    }
    
    return (nil, "Unknown error")
}

func checkBasicShopify(client: Client, retry: Bool, baseUrl: String) async -> String {
    var site = baseUrl
    if !site.hasPrefix("https://") {
        site = "https://" + site
    }
    
    let endpoint = "\(site)/products.json?limit=70"
    
    let headers: [String: String] = [
        "Connection": "close",
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        "Sec-Fetch-Site": "none",
        "Sec-Fetch-Mode": "navigate",
        "User-Agent": UserAgent,
        "Accept-Language": "en-US,en;q=0.9",
        "Sec-Fetch-Dest": "document",
        "Priority": "u=0, i"
    ]
    
    let response = await client.request(
        requestType: client.GET,
        endpoint: endpoint,
        body: nil,
        headers: headers,
        headerOrder: [
            "Connection", "Accept", "Sec-Fetch-Site", "Sec-Fetch-Mode", "User-Agent", "Accept-Language",
            "Sec-Fetch-Dest", "Priority"
        ],
        maxReadBytes: 500000,
        followRedirect: false,
        maxRedirectsToFollow: 5
    )
    
    if let resp = response.0, let responseBody = resp.responseBody, resp.statusCode == 200 {
        do {
            if let data = responseBody.data(using: .utf8),
               let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let products = json["products"] as? [[String: Any]] {
                
                var productsList: [[String: [Int]]] = []
                
                for product in products {
                    if let variants = product["variants"] as? [[String: Any]] {
                        var variantList: [Int] = []
                        for variant in variants {
                            if let variantId = variant["id"] as? Int {
                                variantList.append(variantId)
                            }
                        }
                        productsList.append(["variants": variantList])
                    }
                }
                     
                for product in productsList.reversed() {
                    if let variants = product["variants"], !variants.isEmpty {
                        let testVar = variants.randomElement() ?? variants[0]

                        let (_, atcError) = await addToCart(client: client, variantId: String(testVar), baseUrl: site)
                        
                        if atcError.isEmpty {
                            return String(testVar)
                        }
                    }
                }
            }
        } catch {
            if retry {
                return await checkBasicShopify(client: client, retry: false, baseUrl: site)
            } else {
                return ""
            }
        }
    } else if retry {
        return await checkBasicShopify(client: client, retry: false, baseUrl: site)
    }
    
    return ""
}

func getEndSubstring(body: String, begin: String, end: String) -> String {
    guard let startIndex = body.range(of: begin, options: .backwards)?.upperBound else {
        return "-1"
    }
    
    guard let endIndex = body.range(of: end, options: [], range: startIndex..<body.endIndex)?.lowerBound else {
        return "-1"
    }
    
    return String(body[startIndex..<endIndex])
}

func getSubstring(body: String, begin: String, end: String) -> String {
    guard let startIndex = body.range(of: begin)?.upperBound else {
        return "-1"
    }
    
    guard let endIndex = body.range(of: end, options: [], range: startIndex..<body.endIndex)?.lowerBound else {
        return "-1"
    }
    
    return String(body[startIndex..<endIndex])
}

func secondsUntil(dateTimeString: String) -> Int {
    let formatter = ISO8601DateFormatter()
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    
    let formattedString = dateTimeString.replacingOccurrences(of: "Z", with: "+00:00")
    
    guard let date = formatter.date(from: formattedString) else {
        return 0
    }
    
    let currentDate = Date()

    if date <= currentDate {
        return 0
    } else {
        let timeInterval = date.timeIntervalSince(currentDate)
        return Int(timeInterval)
    }
}

func addSecondsAndFormat(seconds: Int) -> String {
    let currentTime = Date()
    
    let futureTime = currentTime.addingTimeInterval(TimeInterval(seconds))
    
    let formatter = DateFormatter()
    formatter.dateFormat = "h:mm:dd a"
    formatter.locale = Locale(identifier: "en_US_POSIX")

    let formattedTime = formatter.string(from: futureTime).lowercased()
    return formattedTime
}

func convertToLocalTime(timeStr: String) -> String? {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZZZ"
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    
    guard let utcTime = formatter.date(from: timeStr) else {
        return nil
    }
    
    let localTimeZone = TimeZone.current
    
    let localFormatter = DateFormatter()
    localFormatter.dateFormat = "hh:mm:ss a"
    localFormatter.timeZone = localTimeZone
    
    let localTime = localFormatter.string(from: utcTime)
    
    return localTime
}

func parseSupremeKeywordBody(body: String) -> ([[String: [String]]]?, String) {
    let regexPattern = #"<script type="application/json" id="products-json">(.*?)</script>"#
    
    do {
        let regex = try NSRegularExpression(pattern: regexPattern, options: .dotMatchesLineSeparators)
        
        let range = NSRange(location: 0, length: body.utf16.count)
        if let match = regex.firstMatch(in: body, options: [], range: range) {
            if let jsonRange = Range(match.range(at: 1), in: body) {
                let jsonPart = String(body[jsonRange])
                
                let data = jsonPart.data(using: .utf8)
                
                if let data = data {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            if let productsData = json["products"] as? [[String: Any]] {
                                var foundItems: [[String: [String]]] = []
                                
                                for product in productsData {
                                    if let variants = product["variants"] as? [[String: Any]] {
                                        var variantList: [String] = []
                                        
                                        for variant in variants {
                                            if let variantId = variant["id"] as? String {
                                                variantList.append(variantId)
                                            }
                                        }
                                        
                                        foundItems.append(["variants": variantList])
                                    }
                                }
                                
                                return (foundItems, "")
                            } else {
                                return (nil, "Error: Products array not found in JSON")
                            }
                        }
                    } catch {
                        return (nil, "Error parsing JSON: \(error.localizedDescription)")
                    }
                }
            }
        }
    } catch {
        return (nil, "Error: Regular expression matching failed")
    }
    
    return (nil, "Error: JSON script tag not found")
}

func convertPollToReadableTime(iso8601String: String) -> String? {
    let isoFormatter = ISO8601DateFormatter()
    isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

    guard let date = isoFormatter.date(from: iso8601String) else {
        return nil
    }

    let outputFormatter = DateFormatter()
    outputFormatter.dateFormat = "h:mm:ss a"
    outputFormatter.amSymbol = "am"
    outputFormatter.pmSymbol = "pm"
    
    outputFormatter.timeZone = TimeZone.current

    return outputFormatter.string(from: date)
}
