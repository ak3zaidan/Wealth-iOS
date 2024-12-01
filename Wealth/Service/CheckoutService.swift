import Firebase
import FirebaseAuth
import FirebaseFirestore

struct CheckoutService {
    let db = Firestore.firestore()
    
    func getPossibleInstances(completion: @escaping ([String]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion([])
            return
        }
        
        db.collection("users").document(uid).collection("events").whereField("instanceId", isNotEqualTo: "")
            .limit(to: 6)
            .getDocuments { snapshot, _ in
                if let documents = snapshot?.documents {
                    var instances = documents.compactMap { try? $0.data(as: Instance.self) }
                    
                    instances = instances.sorted { instance1, instance2 in
                        return instance1.instanceId < instance2.instanceId
                    }
                    
                    completion(instances.compactMap({ $0.nickName }))
                } else {
                    completion([])
                }
            }
    }
    func getCheckoutsFilter(filter: CheckoutFilter, completion: @escaping ([Checkout]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion([])
            return
        }
        
        if var tokensSubset = filter.containsText, !tokensSubset.isEmpty {
            
            tokensSubset.sort { $0.count > $1.count }
            tokensSubset = Array(tokensSubset.prefix(4))
            
            var matchedDocuments: [Checkout] = []
            let group = DispatchGroup()

            for token in tokensSubset {
                group.enter()

                db.collection("users").document(uid).collection("checkouts")
                    .whereField("titleTokens", arrayContains: token.lowercased())
                    .limit(to: 15)
                    .getDocuments { snapshot, _ in
                        if let documents = snapshot?.documents {
                            let checkouts = documents.compactMap { try? $0.data(as: Checkout.self) }
                            matchedDocuments.append(contentsOf: checkouts)
                        }
                        group.leave()
                    }
            }

            group.notify(queue: .main, execute: {
                let uniqueDocuments = Dictionary(
                    matchedDocuments.map { ($0.id, $0) },
                    uniquingKeysWith: { (first, _) in first }
                ).values

                let filteredDocuments = uniqueDocuments.filter { document in
                    let tokens = document.titleTokens.map { $0.lowercased() }
                    return tokensSubset.allSatisfy { token in
                        tokens.contains(token.lowercased())
                    }
                }
                
                completion(Array(filteredDocuments))
            })
        } else {
            
            let db = Firestore.firestore()
            var query: Query = db.collectionGroup("checkouts").whereField("uid", isEqualTo: uid)
            
            if let startDate = filter.startDate {
                query = query.whereField("orderPlaced", isGreaterThanOrEqualTo: Timestamp(date: startDate))
            }
            
            if let endDate = filter.endDate {
                query = query.whereField("orderPlaced", isLessThanOrEqualTo: Timestamp(date: endDate))
            }
            
            if let fromSite = filter.fromSite {
                query = query.whereField("site", isEqualTo: fromSite)
            }
            
            if let forProfile = filter.forProfile {
                query = query.whereField("profile", isEqualTo: forProfile)
            }
            
            if let forEmail = filter.forEmail {
                query = query.whereField("email", isEqualTo: forEmail)
            }
            
            if let forPrice = filter.forPrice {
                query = query
                            .whereField("cost", isGreaterThan: (forPrice - 2.0) )
                            .whereField("cost", isLessThan: (forPrice + 2.0) )
            }
            
            if let forOrderNumber = filter.forOrderNumber {
                let endRange = forOrderNumber + "\u{f8ff}"
                
                query = db.collection("users").document(uid).collection("checkouts")
                            .whereField("orderNumber", isGreaterThanOrEqualTo: forOrderNumber)
                            .whereField("orderNumber", isLessThan: endRange)
                            .limit(to: 10)
            } else {
                query = query.limit(to: 250)
            }
            
            query.getDocuments { snapshot, _ in
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                let checkouts = documents.compactMap({ try? $0.data(as: Checkout.self)} )
                completion(checkouts)
            }
        }
    }
    func getCheckoutsNew(newest: Timestamp?, completion: @escaping ([Checkout]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion([])
            return
        }
        
        var query = db.collection("users").document(uid).collection("checkouts")
                        .order(by: "orderPlaced", descending: true)
                        .limit(to: 45)
        
        if let newest {
            query = db.collection("users").document(uid).collection("checkouts")
                        .whereField("orderPlaced", isGreaterThan: newest)
                        .order(by: "orderPlaced", descending: true)
                        .limit(to: 65)
        }
        
        query.getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents else {
                completion([])
                return
            }            
            let checkouts = documents.compactMap({ try? $0.data(as: Checkout.self)} )
            completion(checkouts)
        }
    }
    func getCheckoutsOld(oldest: Timestamp, completion: @escaping ([Checkout]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion([])
            return
        }
        
        let query = db.collection("users").document(uid).collection("checkouts")
                        .whereField("orderPlaced", isLessThan: oldest)
                        .order(by: "orderPlaced", descending: true)
                        .limit(to: 45)
        
        query.getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents else {
                completion([])
                return
            }
            let checkouts = documents.compactMap({ try? $0.data(as: Checkout.self)} )
            completion(checkouts)
        }
    }
    func getDayIncrease(completion: @escaping ((Int, Double)) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion((0, 0.0))
            return
        }
        
        let userCheckoutsRef = db.collection("users").document(uid).collection("checkouts")
        
        let now = Date()
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: now)
        let startOfYesterday = calendar.date(byAdding: .day, value: -1, to: startOfToday)!
        let startOfTodayTimestamp = Timestamp(date: startOfToday)
        let startOfYesterdayTimestamp = Timestamp(date: startOfYesterday)
        
        let todayQuery = userCheckoutsRef.whereField("orderPlaced", isGreaterThanOrEqualTo: startOfTodayTimestamp)
        let yesterdayQuery = userCheckoutsRef
            .whereField("orderPlaced", isGreaterThanOrEqualTo: startOfYesterdayTimestamp)
            .whereField("orderPlaced", isLessThan: startOfTodayTimestamp)

        var todayCount = 0
        var yesterdayCount = 0

        let group = DispatchGroup()
        group.enter()
        todayQuery.getDocuments { snapshot, error in
            if error != nil {
                group.leave()
                return
            }
            todayCount = snapshot?.documents.count ?? 0
            group.leave()
        }

        group.enter()
        yesterdayQuery.getDocuments { snapshot, error in
            if error != nil {
                group.leave()
                return
            }
            yesterdayCount = snapshot?.documents.count ?? 0
            group.leave()
        }

        group.notify(queue: .main) {
            let percentageIncrease: Double
            if yesterdayCount == 0 {
                percentageIncrease = todayCount > 0 ? 100.0 : 0.0
            } else {
                percentageIncrease = (Double(todayCount - yesterdayCount) / Double(yesterdayCount)) * 100.0
            }
            
            completion((todayCount, percentageIncrease))
        }
    }
    func getMonthIncrease(completion: @escaping ((Int, Double)) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion((0, 0.0))
            return
        }
        
        let userCheckoutsRef = db.collection("users").document(uid).collection("checkouts")
        
        let now = Date()
        let calendar = Calendar.current
        let startOfCurrentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        let startOfLastMonth = calendar.date(byAdding: .month, value: -1, to: startOfCurrentMonth)!
        let startOfCurrentMonthTimestamp = Timestamp(date: startOfCurrentMonth)
        let startOfLastMonthTimestamp = Timestamp(date: startOfLastMonth)
        
        let currentMonthQuery = userCheckoutsRef.whereField("orderPlaced", isGreaterThanOrEqualTo: startOfCurrentMonthTimestamp)
        let lastMonthQuery = userCheckoutsRef
            .whereField("orderPlaced", isGreaterThanOrEqualTo: startOfLastMonthTimestamp)
            .whereField("orderPlaced", isLessThan: startOfCurrentMonthTimestamp)

        var currentMonthCount = 0
        var lastMonthCount = 0

        let group = DispatchGroup()
        group.enter()
        currentMonthQuery.getDocuments { snapshot, error in
            if error != nil {
                group.leave()
                return
            }
            currentMonthCount = snapshot?.documents.count ?? 0
            group.leave()
        }

        group.enter()
        lastMonthQuery.getDocuments { snapshot, error in
            if error != nil {
                group.leave()
                return
            }
            lastMonthCount = snapshot?.documents.count ?? 0
            group.leave()
        }

        group.notify(queue: .main) {
            let percentageIncrease: Double
            if lastMonthCount == 0 {
                percentageIncrease = currentMonthCount > 0 ? 100.0 : 0.0
            } else {
                percentageIncrease = (Double(currentMonthCount - lastMonthCount) / Double(lastMonthCount)) * 100.0
            }
            
            completion((currentMonthCount, percentageIncrease))
        }
    }
    func getYearIncrease(completion: @escaping ([Int]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion([])
            return
        }
        
        let userCheckoutsRef = db.collection("users").document(uid).collection("checkouts")
        
        let calendar = Calendar.current
        let now = Date()
        var monthStartDates: [Date] = []
        var monthCounts: [Int] = Array(repeating: 0, count: 12)
        
        for i in 0..<12 {
            if let monthStart = calendar.date(byAdding: .month, value: -i, to: now) {
                let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: monthStart))!
                monthStartDates.append(startOfMonth)
            }
        }
        monthStartDates.reverse()
        
        let group = DispatchGroup()
        
        for i in 0..<monthStartDates.count {
            let startOfMonthTimestamp = Timestamp(date: monthStartDates[i])
            let endOfMonthTimestamp = i < monthStartDates.count - 1 ? Timestamp(date: monthStartDates[i + 1]) : Timestamp(date: now)
            
            group.enter()
            userCheckoutsRef
                .whereField("orderPlaced", isGreaterThanOrEqualTo: startOfMonthTimestamp)
                .whereField("orderPlaced", isLessThan: endOfMonthTimestamp)
                .getDocuments { snapshot, _ in
                    monthCounts[i] = snapshot?.documents.count ?? 0
                    group.leave()
                }
        }
        
        group.notify(queue: .main) {
            completion(monthCounts)
        }
    }
    func getLeaderboardPositionWithRefresh(completion: @escaping ((User?, Int?)) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion((nil, nil))
            return
        }
        
        UserService().fetchSafeUser(withUid: uid) { user in
            if let user {
                let query = db.collection("users").whereField("checkoutTotal", isGreaterThan: user.checkoutTotal)
                let countQuery = query.count

                Task {
                    do {
                        let snapshot = try await countQuery.getAggregation(source: .server)
                        completion((user, Int(truncating: snapshot.count) + 1))
                    } catch {
                        completion((user, nil))
                    }
                }
            } else {
                completion((nil, nil))
            }
        }
    }
    func getLeaderboardPosition(checkoutTotal: Double, completion: @escaping (Int) -> Void) {
        let query = db.collection("users").whereField("checkoutTotal", isGreaterThan: checkoutTotal)
        let countQuery = query.count

        Task {
            do {
                let snapshot = try await countQuery.getAggregation(source: .server)
                completion(Int(truncating: snapshot.count) + 1)
            } catch {
                completion(0)
            }
        }
    }
    func deleteCheckouts(checkouts: [String]) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        checkouts.forEach { id in
            if !id.isEmpty {
                db.collection("users").document(uid).collection("checkouts").document(id).delete()
            }
        }
    }
    func setStatus(id: String?, field: String, timestamp: Timestamp? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        if let id, !id.isEmpty {
            db.collection("users").document(uid).collection("checkouts").document(id)
                .updateData([field: timestamp ?? Timestamp()]) { _ in }
        }
    }
    func setEstimate(id: String?, dateStr: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        if let id, !id.isEmpty && !dateStr.isEmpty {
            db.collection("users").document(uid).collection("checkouts").document(id)
                .updateData(["estimatedDelivery": dateStr]) { _ in }
        }
    }
    func setDelivered(id: String?, dateStr: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        if let id, !id.isEmpty && !dateStr.isEmpty {
            db.collection("users").document(uid).collection("checkouts").document(id)
                .updateData(["deliveredDate": dateStr]) { _ in }
        }
    }
}
