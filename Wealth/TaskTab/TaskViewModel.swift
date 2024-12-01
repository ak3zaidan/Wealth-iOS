import Foundation
import Network
import Firebase
import SwiftUI

struct QueueItems: Identifiable, Hashable {
    var id: UUID = UUID()
    var url: String
    var name: String
    var exit: String
    var lastUpdate: Date?
}

@Observable
class TaskViewModel {
    var capSolverBalance: Double? = nil
    var lastUpdatedStats: Date? = nil
    
    var imap: IMAP? = nil
    var instances: [Instance]? = nil
    var profiles: [ProfileFile]? = nil
    var accounts: [AccountFile]? = nil
    var proxies: [ProxyFile]? = nil
    var tasks: [TaskFile]? = nil
    
    var ignoreDeletions = [String]()
    
    var startTaskQueue: [String : String] = [:]
    var stopTaskQueue: [String : String] = [:]
    var startTaskQueue2: [String : String] = [:]
    var stopTaskQueue2: [String : String] = [:]
    var startTaskQueue3: [String : String] = [:]
    var stopTaskQueue3: [String : String] = [:]
    var startTaskQueue4: [String : String] = [:]
    var stopTaskQueue4: [String : String] = [:]
    var startTaskQueue5: [String : String] = [:]
    var stopTaskQueue5: [String : String] = [:]
    var startTaskQueue6: [String : String] = [:]
    var stopTaskQueue6: [String : String] = [:]
    
    var disabledTasks = [String]()
    
    var passwords: [String : String] = [:]
    var success: String = ""
    var failure: String = ""
    var capsolver: String = ""
    
    var checkingConnectionIds: [String : Date] = [:]
    var checkingConnection: Date? = nil
    var lastServerUpdate: Date? = nil
    
    var checking2ConnectionIds: [String : Date] = [:]
    var checking2Connection: Date? = nil
    var lastServer2Update: Date? = nil
    var checking3ConnectionIds: [String : Date] = [:]
    var checking3Connection: Date? = nil
    var lastServer3Update: Date? = nil
    var checking4ConnectionIds: [String : Date] = [:]
    var checking4Connection: Date? = nil
    var lastServer4Update: Date? = nil
    var checking5ConnectionIds: [String : Date] = [:]
    var checking5Connection: Date? = nil
    var lastServer5Update: Date? = nil
    var checking6ConnectionIds: [String : Date] = [:]
    var checking6Connection: Date? = nil
    var lastServer6Update: Date? = nil
    
    var isConnected: Bool { return listener != nil }
    private var listener: ListenerRegistration?
    
    var clockRunning = false
    var glitchRunning = false
    
    // Flags
    var flagMobile = false
    var didJig = false
    var exitView = [String]()
    
    // Queue
    var appeared = true
    var showQueue = false
    var queueChecker = [QueueItems]()
    var queueSpeed = 2
    var queuePreloads: [String : [String]]? = nil
    
    func queueEntry(baseUrl: String, resiUsername: String, resiPassword: String) {
        self.getPreload(site: baseUrl, resiUsername: resiUsername, resiPassword: resiPassword) { variant in
            
            if !self.appeared {
                return
            }
            
            if !variant.isEmpty && Int(variant) != nil {
                let current = self.queuePreloads?[baseUrl] ?? []
                self.queuePreloads?[baseUrl] = [variant] + current
                
                var username = resiUsername
                var password = resiPassword
                
                if username.isEmpty || password.isEmpty {
                    username = "akzaidan"
                    password = "x0if46jo"
                }
                
                Task {
                    await self.queueExecuter(username: username, password: password,
                                             variant: variant, baseUrl: baseUrl)
                }
            } else if let idx = self.queueChecker.firstIndex(where: { $0.url == baseUrl }){
                DispatchQueue.main.async {
                    self.queueChecker[idx].exit = "Error"
                }
            }
        }
    }
    func queueExecuter(username: String, password: String, variant: String, baseUrl: String) async {
        let proxy = genProxies(userLogin: username,
                               userPassword: password,
                               countryId: "US",
                               state: nil,
                               genCount: 1,
                               SoftSession: true)
        
        let client = Client(proxy: proxy)
                
        if let queueEta = await trackQueue(client: client, baseUrl: baseUrl, variantStr: variant, appeared: &appeared) {
            if let idx = self.queueChecker.firstIndex(where: { $0.url == baseUrl }){
                DispatchQueue.main.async {
                    self.queueChecker[idx].exit = queueEta
                    self.queueChecker[idx].lastUpdate = Date()
                }
            } else {
                return
            }
        } else if let idx = self.queueChecker.firstIndex(where: { $0.url == baseUrl }){
            if let last = self.queueChecker[idx].lastUpdate {
                if !isWithinXmin(from: last, min: 1) {
                    DispatchQueue.main.async {
                        self.queueChecker[idx].exit = "Error"
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.queueChecker[idx].exit = "Error"
                }
            }
        } else {
            return
        }
        
        if !self.appeared {
            return
        }
                
        await queueExecuter(username: username, password: password, variant: variant, baseUrl: baseUrl)
    }
    func restartAllQueues(resiUsername: String, resiPassword: String) {
        let threads: Int = self.queueSpeed == 3 ? 5 : self.queueSpeed == 2 ? 2 : 1
        
        for i in 0..<queueChecker.count {
            for _ in 0..<threads {
                self.queueEntry(baseUrl: queueChecker[i].url,
                                resiUsername: resiUsername,
                                resiPassword: resiPassword)
            }
        }
    }
    func getPreload(site: String, resiUsername: String, resiPassword: String, completion: @escaping (String) -> Void) {
        if let preloads = self.queuePreloads {
            if let variant = preloads[site]?.first {
                completion(variant)
            } else {
                var username = resiUsername
                var password = resiPassword
                
                if username.isEmpty || password.isEmpty {
                    username = "akzaidan"
                    password = "x0if46jo"
                }
                
                let proxy = genProxies(userLogin: resiUsername,
                                       userPassword: resiPassword,
                                       countryId: "US",
                                       state: nil,
                                       genCount: 1,
                                       SoftSession: true)
                
                Task {
                    let client = Client(proxy: proxy)
                    let variant = await getVariant(client: client, site: site)
                    completion(variant)
                }
            }
        } else {
            TaskService().getPreloadVariants { data in
                if let data {
                    self.queuePreloads = data
                    self.getPreload(site: site, resiUsername: resiUsername, resiPassword: resiPassword, completion: completion)
                } else {
                    self.queuePreloads = [:]
                    self.getPreload(site: site, resiUsername: resiUsername, resiPassword: resiPassword, completion: completion)
                }
            }
        }
    }
    func connect(currentUID: String) {
        self.disconnect()
        
        let listenerStartTime = Date()
        
        let db = Firestore.firestore()
        
        listener = db.collection("users")
            .document(currentUID)
            .collection("events")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if error != nil {
                    disconnect()
                    self.connect(currentUID: currentUID)
                }
                
                if let snapshot = snapshot {
                    for change in snapshot.documentChanges {
                        let document = change.document
                        let documentData = change.document.data()
                                                
                        if document.documentID == "passwords" {
                            if let urlToPassword = documentData["urlToPassword"] as? [String: String] {
                                DispatchQueue.main.async {
                                    self.passwords = urlToPassword
                                }
                            }
                            continue
                        } else if document.documentID == "webhooks" {
                            if let successHook = documentData["success"] as? String {
                                DispatchQueue.main.async {
                                    self.success = successHook
                                }
                            }
                            if let failureHook = documentData["failure"] as? String {
                                DispatchQueue.main.async {
                                    self.failure = failureHook
                                }
                            }
                            continue
                        } else if document.documentID == "capsolver" {
                            if let capKey = documentData["capsolver"] as? String, !capKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                DispatchQueue.main.async {
                                    self.capsolver = capKey
                                }
                                Task {
                                    getCapSolverBalance(apiKey: capKey) { balance in
                                        if let balance {
                                            DispatchQueue.main.async {
                                                self.capSolverBalance = balance
                                            }
                                        }
                                    }
                                }
                            }
                            continue
                        }
                        
                        if change.type == .added || change.type == .modified {
                            if document.documentID == "IMAP" {
                                do {
                                    self.imap = try document.data(as: IMAP.self)
                                } catch {
                                    print("Error decoding IMAPFile: \(error)")
                                }
                                
                                continue
                            } else if document.documentID.hasPrefix("instance") {
                                do {
                                    let instanceFile = try document.data(as: Instance.self)

                                    if let idx = self.instances?.firstIndex(where: { $0.id == instanceFile.id }) {
                                        self.instances?[idx] = instanceFile
                                    } else {
                                        if self.instances == nil {
                                            self.instances = []
                                        }
                                        self.instances?.append(instanceFile)
                                        
                                        self.instances?.sort { $0.instanceId < $1.instanceId }
                                    }
                                } catch {
                                    print("Error decoding InstanceFile: \(error)")
                                }
                                
                                continue
                            } else if document.documentID.hasPrefix("proxy") {
                                do {
                                    var proxyFile = try document.data(as: ProxyFile.self)

                                    if let idx = self.proxies?.firstIndex(where: { $0.id == proxyFile.id }) {
                                        let speed = self.proxies?[idx].speed
                                        proxyFile.speed = speed
                                        self.proxies?[idx] = proxyFile
                                    } else {
                                        if self.proxies == nil {
                                            self.proxies = []
                                        }
                                        self.proxies?.append(proxyFile)
                                        
                                        self.proxies?.sort { $0.instance < $1.instance }
                                    }
                                } catch {
                                    print("Error decoding ProxyFile: \(error)")
                                }
                                
                                continue
                            } else if document.documentID.hasPrefix("profile") {
                                do {
                                    let profileFile = try document.data(as: ProfileFile.self)

                                    if let idx = self.profiles?.firstIndex(where: { $0.id == profileFile.id }) {
                                        self.profiles?[idx] = profileFile
                                    } else {
                                        if self.profiles == nil {
                                            self.profiles = []
                                        }
                                        self.profiles?.append(profileFile)
                                        
                                        self.profiles?.sort { $0.instance < $1.instance }
                                    }
                                } catch {
                                    print("Error decoding ProfileFile: \(error)")
                                }
                                
                                continue
                            } else if document.documentID.hasPrefix("account") {
                                do {
                                    let accountFile = try document.data(as: AccountFile.self)

                                    if let idx = self.accounts?.firstIndex(where: { $0.id == accountFile.id }) {
                                        self.accounts?[idx] = accountFile
                                    } else {
                                        if self.accounts == nil {
                                            self.accounts = []
                                        }
                                        self.accounts?.append(accountFile)
                                        
                                        self.accounts?.sort { $0.instance < $1.instance }
                                    }
                                } catch {
                                    print("Error decoding AccountFile: \(error)")
                                }
                                
                                continue
                            } else if document.documentID.hasPrefix("task") {
                                do {
                                    let taskFile = try document.data(as: TaskFile.self)

                                    if let idx = self.tasks?.firstIndex(where: { $0.id == taskFile.id }) {
                                        withAnimation(.easeInOut(duration: 0.2)){
                                            self.tasks?[idx] = taskFile
                                        }
                                    } else {
                                        withAnimation(.easeInOut(duration: 0.2)){
                                            if self.tasks == nil {
                                                self.tasks = []
                                            }
                                            self.tasks?.insert(taskFile, at: 0)
                                        }
                                    }
                                } catch {
                                    print("Error decoding TaskFile: \(error)")
                                }
                                
                                continue
                            } else if document.documentID.contains("serverOff") {
                                ServerSend().deleteEvent(id: document.documentID)
                                
                                if let time = documentData["time"] as? Timestamp {
                                    if isWithinXsec(from: time.dateValue(), sec: 5) {
                                        DispatchQueue.main.async {
                                            if let iID = firstCharToInt(document.documentID) {
                                                if iID == 1 {
                                                    self.lastServerUpdate = nil
                                                    withAnimation(.easeInOut(duration: 0.3)){
                                                        self.checkingConnection = Date()
                                                    }
                                                } else if iID == 2 {
                                                    self.lastServer2Update = nil
                                                    withAnimation(.easeInOut(duration: 0.3)){
                                                        self.checking2Connection = Date()
                                                    }
                                                } else if iID == 3 {
                                                    self.lastServer3Update = nil
                                                    withAnimation(.easeInOut(duration: 0.3)){
                                                        self.checking3Connection = Date()
                                                    }
                                                } else if iID == 4 {
                                                    self.lastServer4Update = nil
                                                    withAnimation(.easeInOut(duration: 0.3)){
                                                        self.checking4Connection = Date()
                                                    }
                                                } else if iID == 5 {
                                                    self.lastServer5Update = nil
                                                    withAnimation(.easeInOut(duration: 0.3)){
                                                        self.checking5Connection = Date()
                                                    }
                                                } else {
                                                    self.lastServer6Update = nil
                                                    withAnimation(.easeInOut(duration: 0.3)){
                                                        self.checking6Connection = Date()
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                continue
                            }
                        }

                        switch change.type {
                        case .added:
                            if isWithinXsec(from: listenerStartTime, sec: 5) {
                                if document.documentID.hasPrefix("mobile") {
                                    ServerSend().deleteEvent(id: document.documentID)
                                } else if document.documentID.contains("testonline") {
                                    
                                    let testId = String(document.documentID.dropFirst(11))
                                    
                                    if self.checkingConnectionIds[testId] == nil &&
                                        self.checking2ConnectionIds[testId] == nil &&
                                        self.checking3ConnectionIds[testId] == nil &&
                                        self.checking4ConnectionIds[testId] == nil &&
                                        self.checking5ConnectionIds[testId] == nil &&
                                        self.checking6ConnectionIds[testId] == nil {
                                        
                                        self.ignoreDeletions.append(testId)
                                        ServerSend().deleteEvent(id: document.documentID)
                                    }
                                }
                            } else {
                                if document.documentID.hasPrefix("mobile") {
                                    if let new = documentData["new"] as? String, new != currentDeviceID() {
                                        flagMobile.toggle()
                                    }
                                }
                            }
                        case .modified:
                            print("Document Modified: ID: \(document.documentID), Data: \(document.data())")
                        case .removed:
                            if document.documentID.contains("testonline") {
                                
                                if let iID = firstCharToInt(document.documentID) {
                                    let testId = String(document.documentID.dropFirst(11))
                                    
                                    if self.ignoreDeletions.contains(testId) {
                                        // Do nothing
                                    } else if iID == 1 {
                                        let cachedDate = self.checkingConnectionIds[testId]
                                        
                                        if !isWithinXsec(from: listenerStartTime, sec: 5) ||
                                            (cachedDate != nil && isWithinXsec(from: cachedDate ?? Date(), sec: 6)) {
                                            
                                            lastServerUpdate = Date()
                                            withAnimation(.easeInOut(duration: 0.3)){
                                                self.checkingConnection = nil
                                            }
                                            self.checkingConnectionIds = [:]
                                        }
                                    } else if iID == 2 {
                                        let cachedDate = self.checking2ConnectionIds[testId]
                                        
                                        if !isWithinXsec(from: listenerStartTime, sec: 5) ||
                                            (cachedDate != nil && isWithinXsec(from: cachedDate ?? Date(), sec: 6)) {
                                            
                                            lastServer2Update = Date()
                                            withAnimation(.easeInOut(duration: 0.3)){
                                                self.checking2Connection = nil
                                            }
                                            self.checking2ConnectionIds = [:]
                                        }
                                    } else if iID == 3 {
                                        let cachedDate = self.checking3ConnectionIds[testId]
                                        
                                        if !isWithinXsec(from: listenerStartTime, sec: 5) ||
                                            (cachedDate != nil && isWithinXsec(from: cachedDate ?? Date(), sec: 6)) {
                                            
                                            lastServer3Update = Date()
                                            withAnimation(.easeInOut(duration: 0.3)){
                                                self.checking3Connection = nil
                                            }
                                            self.checking3ConnectionIds = [:]
                                        }
                                    } else if iID == 4 {
                                        let cachedDate = self.checking4ConnectionIds[testId]
                                        
                                        if !isWithinXsec(from: listenerStartTime, sec: 5) ||
                                            (cachedDate != nil && isWithinXsec(from: cachedDate ?? Date(), sec: 6)) {
                                            
                                            lastServer4Update = Date()
                                            withAnimation(.easeInOut(duration: 0.3)){
                                                self.checking4Connection = nil
                                            }
                                            self.checking4ConnectionIds = [:]
                                        }
                                    } else if iID == 5 {
                                        let cachedDate = self.checking5ConnectionIds[testId]
                                        
                                        if !isWithinXsec(from: listenerStartTime, sec: 5) ||
                                            (cachedDate != nil && isWithinXsec(from: cachedDate ?? Date(), sec: 6)) {
                                            
                                            lastServer5Update = Date()
                                            withAnimation(.easeInOut(duration: 0.3)){
                                                self.checking5Connection = nil
                                            }
                                            self.checking5ConnectionIds = [:]
                                        }
                                    } else {
                                        let cachedDate = self.checking6ConnectionIds[testId]
                                        
                                        if !isWithinXsec(from: listenerStartTime, sec: 5) ||
                                            (cachedDate != nil && isWithinXsec(from: cachedDate ?? Date(), sec: 6)) {
                                            
                                            lastServer6Update = Date()
                                            withAnimation(.easeInOut(duration: 0.3)){
                                                self.checking6Connection = nil
                                            }
                                            self.checking6ConnectionIds = [:]
                                        }
                                    }
                                }
                            } else if document.documentID.contains("startTask") {
                                let name = String(document.documentID.dropFirst(10))
                                
                                if let iID = firstCharToInt(document.documentID) {
                                    if iID == 1 {
                                        DispatchQueue.main.async {
                                            self.lastServerUpdate = Date()
                                            withAnimation(Animation.spring(response: 0.2, dampingFraction: 0.5, blendDuration: 0.75)) {
                                                _ = self.startTaskQueue.removeValue(forKey: name)
                                            }
                                        }
                                    } else if iID == 2 {
                                        DispatchQueue.main.async {
                                            self.lastServer2Update = Date()
                                            withAnimation(Animation.spring(response: 0.2, dampingFraction: 0.5, blendDuration: 0.75)) {
                                                _ = self.startTaskQueue2.removeValue(forKey: name)
                                            }
                                        }
                                    } else if iID == 3 {
                                        DispatchQueue.main.async {
                                            self.lastServer3Update = Date()
                                            withAnimation(Animation.spring(response: 0.2, dampingFraction: 0.5, blendDuration: 0.75)) {
                                                _ = self.startTaskQueue3.removeValue(forKey: name)
                                            }
                                        }
                                    } else if iID == 4 {
                                        DispatchQueue.main.async {
                                            self.lastServer4Update = Date()
                                            withAnimation(Animation.spring(response: 0.2, dampingFraction: 0.5, blendDuration: 0.75)) {
                                                _ = self.startTaskQueue4.removeValue(forKey: name)
                                            }
                                        }
                                    } else if iID == 5 {
                                        DispatchQueue.main.async {
                                            self.lastServer5Update = Date()
                                            withAnimation(Animation.spring(response: 0.2, dampingFraction: 0.5, blendDuration: 0.75)) {
                                                _ = self.startTaskQueue5.removeValue(forKey: name)
                                            }
                                        }
                                    } else {
                                        DispatchQueue.main.async {
                                            self.lastServer6Update = Date()
                                            withAnimation(Animation.spring(response: 0.2, dampingFraction: 0.5, blendDuration: 0.75)) {
                                                _ = self.startTaskQueue6.removeValue(forKey: name)
                                            }
                                        }
                                    }
                                }
                            } else if document.documentID.contains("stopTask") {
                                let name = String(document.documentID.dropFirst(9))
                                
                                if let iID = firstCharToInt(document.documentID) {
                                    if iID == 1 {
                                        DispatchQueue.main.async {
                                            self.lastServerUpdate = Date()
                                            withAnimation(Animation.spring(response: 0.2, dampingFraction: 0.5, blendDuration: 0.75)) {
                                                _ = self.stopTaskQueue.removeValue(forKey: name)
                                            }
                                        }
                                    } else if iID == 2 {
                                        DispatchQueue.main.async {
                                            self.lastServer2Update = Date()
                                            withAnimation(Animation.spring(response: 0.2, dampingFraction: 0.5, blendDuration: 0.75)) {
                                                _ = self.stopTaskQueue2.removeValue(forKey: name)
                                            }
                                        }
                                    } else if iID == 3 {
                                        DispatchQueue.main.async {
                                            self.lastServer3Update = Date()
                                            withAnimation(Animation.spring(response: 0.2, dampingFraction: 0.5, blendDuration: 0.75)) {
                                                _ = self.stopTaskQueue3.removeValue(forKey: name)
                                            }
                                        }
                                    } else if iID == 4 {
                                        DispatchQueue.main.async {
                                            self.lastServer4Update = Date()
                                            withAnimation(Animation.spring(response: 0.2, dampingFraction: 0.5, blendDuration: 0.75)) {
                                                _ = self.stopTaskQueue4.removeValue(forKey: name)
                                            }
                                        }
                                    } else if iID == 5 {
                                        DispatchQueue.main.async {
                                            self.lastServer5Update = Date()
                                            withAnimation(Animation.spring(response: 0.2, dampingFraction: 0.5, blendDuration: 0.75)) {
                                                _ = self.stopTaskQueue5.removeValue(forKey: name)
                                            }
                                        }
                                    } else {
                                        DispatchQueue.main.async {
                                            self.lastServer6Update = Date()
                                            withAnimation(Animation.spring(response: 0.2, dampingFraction: 0.5, blendDuration: 0.75)) {
                                                _ = self.stopTaskQueue6.removeValue(forKey: name)
                                            }
                                        }
                                    }
                                }
                            } else if document.documentID.hasPrefix("proxy") {
                                if let idx = self.proxies?.firstIndex(where: { $0.id == document.documentID }) {
                                    withAnimation(.easeInOut(duration: 0.3)){
                                        _ = self.proxies?.remove(at: idx)
                                    }
                                }
                            } else if document.documentID.hasPrefix("profile") {
                                if let idx = self.profiles?.firstIndex(where: { $0.id == document.documentID }) {
                                    withAnimation(.easeInOut(duration: 0.3)){
                                        _ = self.profiles?.remove(at: idx)
                                    }
                                }
                            } else if document.documentID.hasPrefix("account") {
                                if let idx = self.accounts?.firstIndex(where: { $0.id == document.documentID }) {
                                    withAnimation(.easeInOut(duration: 0.3)){
                                        _ = self.accounts?.remove(at: idx)
                                    }
                                }
                            } else if document.documentID.hasPrefix("task") {
                                DispatchQueue.main.async {
                                    self.exitView.append(document.documentID)
                                    self.disabledTasks.append(document.documentID)
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                    if let idx = self.tasks?.firstIndex(where: { $0.id == document.documentID }) {
                                        withAnimation(.easeInOut(duration: 0.3)){
                                            _ = self.tasks?.remove(at: idx)
                                        }
                                    }
                                }
                            } else if document.documentID.hasPrefix("jigProfile") {
                                didJig.toggle()
                            }
                        }
                    }
                }
            }
    }
    func disconnect() {
        if self.listener != nil {
            self.listener?.remove()
        }
        self.listener = nil
    }
}

func firstCharToInt(_ input: String) -> Int? {
    guard let firstChar = input.first else {
        return nil
    }

    let firstCharStr = String(firstChar)
    return Int(firstCharStr)
}
