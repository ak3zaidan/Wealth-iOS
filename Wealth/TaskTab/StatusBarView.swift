import SwiftUI

struct StatusBarView: View {
    @Environment(TaskViewModel.self) private var viewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var timer: Timer? = nil
    @State var toggleId = UUID()
    
    @Binding var maxRetryCount: Int
    let uid: String
    let instanceCount: Int
    
    var body: some View {
        HStack {
            
            if instanceCount > 0 {
                NavigationLink {
                    InstanceManager()
                } label: {
                    Image(systemName: "house.fill").font(.title2)
                }
            }
            
            VStack(alignment: .leading, spacing: 4){
                if instanceCount > 0 {
                    
                    let status = getStatus()
                    
                    Text(status.0).font(.headline).fontWeight(.heavy)
                        .foregroundStyle(status.0.contains("Online") ? Color.green :
                                            status.0.contains("Offline") ? Color.red :
                                                colorScheme == .dark ? Color.white : Color.black)
                    Text(status.1).font(.caption).foregroundStyle(.gray)
                    
                } else if viewModel.checkingConnection != nil && isWithinXsec(from: viewModel.checkingConnection ?? Date(), sec: 6) {
                    Text("Server Status").font(.headline).fontWeight(.heavy)
                    Text("Refreshing connection...").font(.caption).foregroundStyle(.gray)
                } else if viewModel.lastServerUpdate != nil && isWithinXmin(from: viewModel.lastServerUpdate ?? Date(), min: 1) && (viewModel.checkingConnection == nil || viewModel.lastServerUpdate ?? Date() > viewModel.checkingConnection ?? Date()) {
                    Text("Server Online").font(.headline).fontWeight(.heavy).foregroundStyle(.green)
                    Text(formatDateString(from: viewModel.lastServerUpdate ?? Date())).font(.caption).foregroundStyle(.gray)
                } else if viewModel.checkingConnection != nil {
                    Text("Server Offline").font(.headline).fontWeight(.heavy).foregroundStyle(.red)
                    Text("Please turn on Wealth AIO.").font(.caption).foregroundStyle(.gray)
                } else {
                    Text("Server Status").font(.headline).fontWeight(.heavy)
                    Text("Please refresh connection.").font(.caption).foregroundStyle(.gray)
                }
            }
            
            Spacer()
            
            if instanceCount > 0 {
                
                let status = getStatusDisplay()
                
                if status == 1 {
                    ProgressView().transition(.scale)
                } else if status == 2 {
                    LottieView(loopMode: .loop, name: "greenAnim")
                        .frame(width: 35, height: 35).scaleEffect(0.7).transition(.scale)
                        .onDisappear {
                            if !(viewModel.lastServerUpdate != nil && isWithinXmin(from: viewModel.lastServerUpdate ?? Date(), min: 1) && (viewModel.checkingConnection == nil || viewModel.lastServerUpdate ?? Date() > viewModel.checkingConnection ?? Date())) {
                                
                                if !viewModel.isConnected {
                                    viewModel.connect(currentUID: uid)
                                }
                                let sessionId = UUID().uuidString
                                viewModel.checkingConnectionIds[sessionId] = Date()
                                ServerSend().checkServerOnline(id: sessionId, instance: 1)
                                withAnimation(.easeInOut(duration: 0.3)){
                                    viewModel.checkingConnection = Date()
                                }
                            }
                            
                            if !(viewModel.lastServer2Update != nil && isWithinXmin(from: viewModel.lastServer2Update ?? Date(), min: 1) && (viewModel.checking2Connection == nil || viewModel.lastServer2Update ?? Date() > viewModel.checking2Connection ?? Date())) {
                                
                                let sessionId = UUID().uuidString
                                viewModel.checking2ConnectionIds[sessionId] = Date()
                                ServerSend().checkServerOnline(id: sessionId, instance: 2)
                                withAnimation(.easeInOut(duration: 0.3)){
                                    viewModel.checking2Connection = Date()
                                }
                            }
                            
                            if instanceCount > 1 {
                                if !(viewModel.lastServer3Update != nil && isWithinXmin(from: viewModel.lastServer3Update ?? Date(), min: 1) && (viewModel.checking3Connection == nil || viewModel.lastServer3Update ?? Date() > viewModel.checking3Connection ?? Date())) {
                                    
                                    let sessionId = UUID().uuidString
                                    viewModel.checking3ConnectionIds[sessionId] = Date()
                                    ServerSend().checkServerOnline(id: sessionId, instance: 3)
                                    withAnimation(.easeInOut(duration: 0.3)){
                                        viewModel.checking3Connection = Date()
                                    }
                                }
                            }
                            
                            if instanceCount > 2 {
                                if !(viewModel.lastServer4Update != nil && isWithinXmin(from: viewModel.lastServer4Update ?? Date(), min: 1) && (viewModel.checking4Connection == nil || viewModel.lastServer4Update ?? Date() > viewModel.checking4Connection ?? Date())) {
                                    
                                    let sessionId = UUID().uuidString
                                    viewModel.checking4ConnectionIds[sessionId] = Date()
                                    ServerSend().checkServerOnline(id: sessionId, instance: 4)
                                    withAnimation(.easeInOut(duration: 0.3)){
                                        viewModel.checking4Connection = Date()
                                    }
                                }
                            }
                            
                            if instanceCount > 3 {
                                if !(viewModel.lastServer5Update != nil && isWithinXmin(from: viewModel.lastServer5Update ?? Date(), min: 1) && (viewModel.checking5Connection == nil || viewModel.lastServer5Update ?? Date() > viewModel.checking5Connection ?? Date())) {
                                    
                                    let sessionId = UUID().uuidString
                                    viewModel.checking5ConnectionIds[sessionId] = Date()
                                    ServerSend().checkServerOnline(id: sessionId, instance: 5)
                                    withAnimation(.easeInOut(duration: 0.3)){
                                        viewModel.checking5Connection = Date()
                                    }
                                }
                            }
                            
                            if instanceCount > 4 {
                                if !(viewModel.lastServer6Update != nil && isWithinXmin(from: viewModel.lastServer6Update ?? Date(), min: 1) && (viewModel.checking6Connection == nil || viewModel.lastServer6Update ?? Date() > viewModel.checking6Connection ?? Date())) {
                                    
                                    let sessionId = UUID().uuidString
                                    viewModel.checking6ConnectionIds[sessionId] = Date()
                                    ServerSend().checkServerOnline(id: sessionId, instance: 6)
                                    withAnimation(.easeInOut(duration: 0.3)){
                                        viewModel.checking6Connection = Date()
                                    }
                                }
                            }
                        }
                } else {
                    Button {
                        if !viewModel.isConnected {
                            viewModel.connect(currentUID: uid)
                        }
                        
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                        
                        let sessionId = UUID().uuidString
                        viewModel.checkingConnectionIds[sessionId] = Date()
                        ServerSend().checkServerOnline(id: sessionId, instance: 1)
                        withAnimation(.easeInOut(duration: 0.3)){
                            viewModel.checkingConnection = Date()
                        }
                        
                        let session2Id = UUID().uuidString
                        viewModel.checking2ConnectionIds[sessionId] = Date()
                        ServerSend().checkServerOnline(id: session2Id, instance: 2)
                        withAnimation(.easeInOut(duration: 0.3)){
                            viewModel.checking2Connection = Date()
                        }
                        
                        if instanceCount > 1 {
                            let session3Id = UUID().uuidString
                            viewModel.checking3ConnectionIds[sessionId] = Date()
                            ServerSend().checkServerOnline(id: session3Id, instance: 3)
                            withAnimation(.easeInOut(duration: 0.3)){
                                viewModel.checking3Connection = Date()
                            }
                        }
                        
                        if instanceCount > 2 {
                            let session4Id = UUID().uuidString
                            viewModel.checking4ConnectionIds[sessionId] = Date()
                            ServerSend().checkServerOnline(id: session4Id, instance: 4)
                            withAnimation(.easeInOut(duration: 0.3)){
                                viewModel.checking4Connection = Date()
                            }
                        }
                        
                        if instanceCount > 3 {
                            let session5Id = UUID().uuidString
                            viewModel.checking5ConnectionIds[sessionId] = Date()
                            ServerSend().checkServerOnline(id: session5Id, instance: 5)
                            withAnimation(.easeInOut(duration: 0.3)){
                                viewModel.checking5Connection = Date()
                            }
                        }
                        
                        if instanceCount > 4 {
                            let session6Id = UUID().uuidString
                            viewModel.checking6ConnectionIds[sessionId] = Date()
                            ServerSend().checkServerOnline(id: session6Id, instance: 6)
                            withAnimation(.easeInOut(duration: 0.3)){
                                viewModel.checking6Connection = Date()
                            }
                        }
                    } label: {
                        Text("Refresh").font(.subheadline).bold()
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(Color.babyBlue).clipShape(Capsule()).shadow(color: .gray, radius: 3)
                    }
                    .transition(.scale).buttonStyle(.plain)
                    .onAppear {
                        if maxRetryCount < 3 {
                            maxRetryCount += 1
                            
                            if viewModel.lastServerUpdate != nil &&
                                isWithinXmin(from: viewModel.lastServerUpdate ?? Date(), min: 2) {
                                
                                if !viewModel.isConnected {
                                    viewModel.connect(currentUID: uid)
                                }
                                let sessionId = UUID().uuidString
                                viewModel.checkingConnectionIds[sessionId] = Date()
                                ServerSend().checkServerOnline(id: sessionId, instance: 1)
                                withAnimation(.easeInOut(duration: 0.3)){
                                    viewModel.checkingConnection = Date()
                                }
                            }
                            
                            if viewModel.lastServer2Update != nil &&
                                isWithinXmin(from: viewModel.lastServer2Update ?? Date(), min: 2) {
                                
                                let sessionId = UUID().uuidString
                                viewModel.checking2ConnectionIds[sessionId] = Date()
                                ServerSend().checkServerOnline(id: sessionId, instance: 2)
                                withAnimation(.easeInOut(duration: 0.3)){
                                    viewModel.checking2Connection = Date()
                                }
                            }
                            
                            if instanceCount > 1 {
                                if viewModel.lastServer3Update != nil &&
                                    isWithinXmin(from: viewModel.lastServer3Update ?? Date(), min: 2) {
                                    
                                    let sessionId = UUID().uuidString
                                    viewModel.checking3ConnectionIds[sessionId] = Date()
                                    ServerSend().checkServerOnline(id: sessionId, instance: 3)
                                    withAnimation(.easeInOut(duration: 0.3)){
                                        viewModel.checking3Connection = Date()
                                    }
                                }
                            }
                            
                            if instanceCount > 2 {
                                if viewModel.lastServer4Update != nil &&
                                    isWithinXmin(from: viewModel.lastServer4Update ?? Date(), min: 2) {
                                    
                                    let sessionId = UUID().uuidString
                                    viewModel.checking4ConnectionIds[sessionId] = Date()
                                    ServerSend().checkServerOnline(id: sessionId, instance: 4)
                                    withAnimation(.easeInOut(duration: 0.3)){
                                        viewModel.checking4Connection = Date()
                                    }
                                }
                            }
                            
                            if instanceCount > 3 {
                                if viewModel.lastServer5Update != nil &&
                                    isWithinXmin(from: viewModel.lastServer5Update ?? Date(), min: 2) {
                                    
                                    let sessionId = UUID().uuidString
                                    viewModel.checking5ConnectionIds[sessionId] = Date()
                                    ServerSend().checkServerOnline(id: sessionId, instance: 5)
                                    withAnimation(.easeInOut(duration: 0.3)){
                                        viewModel.checking5Connection = Date()
                                    }
                                }
                            }
                            
                            if instanceCount > 4 {
                                if viewModel.lastServer6Update != nil &&
                                    isWithinXmin(from: viewModel.lastServer6Update ?? Date(), min: 2) {
                                    
                                    let sessionId = UUID().uuidString
                                    viewModel.checking6ConnectionIds[sessionId] = Date()
                                    ServerSend().checkServerOnline(id: sessionId, instance: 6)
                                    withAnimation(.easeInOut(duration: 0.3)){
                                        viewModel.checking6Connection = Date()
                                    }
                                }
                            }
                        }
                    }
                }
                
            } else if viewModel.checkingConnection != nil && isWithinXsec(from: viewModel.checkingConnection ?? Date(), sec: 6) {
                ProgressView().transition(.scale)
            } else if viewModel.lastServerUpdate != nil && isWithinXmin(from: viewModel.lastServerUpdate ?? Date(), min: 1) && (viewModel.checkingConnection == nil || viewModel.lastServerUpdate ?? Date() > viewModel.checkingConnection ?? Date()) {
                LottieView(loopMode: .loop, name: "greenAnim").frame(width: 35, height: 35).scaleEffect(0.7)
                    .transition(.scale)
                    .onDisappear {
                        if !(viewModel.lastServerUpdate != nil && isWithinXmin(from: viewModel.lastServerUpdate ?? Date(), min: 1) && (viewModel.checkingConnection == nil || viewModel.lastServerUpdate ?? Date() > viewModel.checkingConnection ?? Date())) {
                            
                            if !viewModel.isConnected {
                                viewModel.connect(currentUID: uid)
                            }
                            let sessionId = UUID().uuidString
                            viewModel.checkingConnectionIds[sessionId] = Date()
                            ServerSend().checkServerOnline(id: sessionId, instance: 1)
                            withAnimation(.easeInOut(duration: 0.3)){
                                viewModel.checkingConnection = Date()
                            }
                        }
                    }
            } else {
                Button {
                    if !viewModel.isConnected {
                        viewModel.connect(currentUID: uid)
                    }
                    let sessionId = UUID().uuidString
                    viewModel.checkingConnectionIds[sessionId] = Date()
                    ServerSend().checkServerOnline(id: sessionId, instance: 1)
                    withAnimation(.easeInOut(duration: 0.3)){
                        viewModel.checkingConnection = Date()
                    }
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                } label: {
                    Text("Refresh").font(.subheadline).bold()
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(Color.babyBlue).clipShape(Capsule()).shadow(color: .gray, radius: 3)
                }
                .transition(.scale).buttonStyle(.plain)
                .onAppear {
                    if maxRetryCount < 3 {
                        maxRetryCount += 1
                        
                        if viewModel.lastServerUpdate != nil &&
                            isWithinXmin(from: viewModel.lastServerUpdate ?? Date(), min: 2) {
                            
                            if !viewModel.isConnected {
                                viewModel.connect(currentUID: uid)
                            }
                            let sessionId = UUID().uuidString
                            viewModel.checkingConnectionIds[sessionId] = Date()
                            ServerSend().checkServerOnline(id: sessionId, instance: 1)
                            withAnimation(.easeInOut(duration: 0.3)){
                                viewModel.checkingConnection = Date()
                            }
                        }
                    }
                }
            }
        }
        .padding(10)
        .background(content: {
            Color.clear.id(toggleId)
        })
        .background(content: {
            TransparentBlurView(removeAllFilters: true)
                .blur(radius: 14, opaque: true)
                .background(colorScheme == .dark ? .black.opacity(0.4) : .white.opacity(0.4))
        })
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .overlay(content: {
            RoundedRectangle(cornerRadius: 12)
                .stroke(lineWidth: 1).opacity(0.2)
        })
        .padding(.horizontal, 12)
        .onAppear {
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                toggleId = UUID()
            }
        }
        .onDisappear {
            if timer != nil {
                timer?.invalidate()
                timer = nil
            }
        }
    }
    func getStatus() -> (String, String) {
        var online = 0
        var offline = 0
        var refreshing = 0
        var noStatus = 0
        
        if viewModel.checkingConnection != nil && isWithinXsec(from: viewModel.checkingConnection ?? Date(), sec: 6) {
            refreshing += 1
        } else if viewModel.lastServerUpdate != nil && isWithinXmin(from: viewModel.lastServerUpdate ?? Date(), min: 1) && (viewModel.checkingConnection == nil || viewModel.lastServerUpdate ?? Date() > viewModel.checkingConnection ?? Date()) {
            online += 1
        } else if viewModel.checkingConnection != nil {
            offline += 1
        } else {
            noStatus += 1
        }
        
        if viewModel.checking2Connection != nil && isWithinXsec(from: viewModel.checking2Connection ?? Date(), sec: 6) {
            refreshing += 1
        } else if viewModel.lastServer2Update != nil && isWithinXmin(from: viewModel.lastServer2Update ?? Date(), min: 1) && (viewModel.checking2Connection == nil || viewModel.lastServer2Update ?? Date() > viewModel.checking2Connection ?? Date()) {
            online += 1
        } else if viewModel.checking2Connection != nil {
            offline += 1
        } else {
            noStatus += 1
        }
        
        if instanceCount > 1 {
            if viewModel.checking3Connection != nil && isWithinXsec(from: viewModel.checking3Connection ?? Date(), sec: 6) {
                refreshing += 1
            } else if viewModel.lastServer3Update != nil && isWithinXmin(from: viewModel.lastServer3Update ?? Date(), min: 1) && (viewModel.checking3Connection == nil || viewModel.lastServer3Update ?? Date() > viewModel.checking3Connection ?? Date()) {
                online += 1
            } else if viewModel.checking3Connection != nil {
                offline += 1
            } else {
                noStatus += 1
            }
        }
        
        if instanceCount > 2 {
            if viewModel.checking4Connection != nil && isWithinXsec(from: viewModel.checking4Connection ?? Date(), sec: 6) {
                refreshing += 1
            } else if viewModel.lastServer4Update != nil && isWithinXmin(from: viewModel.lastServer4Update ?? Date(), min: 1) && (viewModel.checking4Connection == nil || viewModel.lastServer4Update ?? Date() > viewModel.checking4Connection ?? Date()) {
                online += 1
            } else if viewModel.checking4Connection != nil {
                offline += 1
            } else {
                noStatus += 1
            }
        }
        
        if instanceCount > 3 {
            if viewModel.checking5Connection != nil && isWithinXsec(from: viewModel.checking5Connection ?? Date(), sec: 6) {
                refreshing += 1
            } else if viewModel.lastServer5Update != nil && isWithinXmin(from: viewModel.lastServer5Update ?? Date(), min: 1) && (viewModel.checking5Connection == nil || viewModel.lastServer5Update ?? Date() > viewModel.checking5Connection ?? Date()) {
                online += 1
            } else if viewModel.checking5Connection != nil {
                offline += 1
            } else {
                noStatus += 1
            }
        }
        
        if instanceCount > 4 {
            if viewModel.checking6Connection != nil && isWithinXsec(from: viewModel.checking6Connection ?? Date(), sec: 6) {
                refreshing += 1
            } else if viewModel.lastServer6Update != nil && isWithinXmin(from: viewModel.lastServer6Update ?? Date(), min: 1) && (viewModel.checking6Connection == nil || viewModel.lastServer6Update ?? Date() > viewModel.checking6Connection ?? Date()) {
                online += 1
            } else if viewModel.checking6Connection != nil {
                offline += 1
            } else {
                noStatus += 1
            }
        }

        let totalInstances = instanceCount + 1
        
        if online > 0 {
            if online == totalInstances {
                return ("All Servers Online", formatDateString(from: viewModel.lastServerUpdate ?? Date()))
            } else {
                return ("\(online)/\(totalInstances) Servers Online", formatDateString(from: viewModel.lastServerUpdate ?? Date()))
            }
        }
        if refreshing > 0 {
            if refreshing == totalInstances {
                return ("Servers Refreshing", "Pinging all servers")
            } else if refreshing == 1 {
                return ("Server Refreshing", "Pinging 1 server")
            } else {
                return ("Servers Refreshing", "Pinging \(refreshing) servers")
            }
        }
        if offline > 0 {
            if offline == totalInstances {
                return ("Servers Offline", "Please turn on Wealth AIO")
            } else if offline == 1 {
                return ("1 Server Offline", "Please turn on Wealth AIO")
            } else {
                return ("\(offline) Servers Offline", "Please turn on Wealth AIO")
            }
        }

        return ("Server Status", "Please refresh connection.")
    }
    func getStatusDisplay() -> Int {
        var online = 0
        var offline = 0
        var refreshing = 0
        var noStatus = 0
        
        if viewModel.checkingConnection != nil && isWithinXsec(from: viewModel.checkingConnection ?? Date(), sec: 6) {
            refreshing += 1
        } else if viewModel.lastServerUpdate != nil && isWithinXmin(from: viewModel.lastServerUpdate ?? Date(), min: 1) && (viewModel.checkingConnection == nil || viewModel.lastServerUpdate ?? Date() > viewModel.checkingConnection ?? Date()) {
            online += 1
        } else if viewModel.checkingConnection != nil {
            offline += 1
        } else {
            noStatus += 1
        }
        
        if viewModel.checking2Connection != nil && isWithinXsec(from: viewModel.checking2Connection ?? Date(), sec: 6) {
            refreshing += 1
        } else if viewModel.lastServer2Update != nil && isWithinXmin(from: viewModel.lastServer2Update ?? Date(), min: 1) && (viewModel.checking2Connection == nil || viewModel.lastServer2Update ?? Date() > viewModel.checking2Connection ?? Date()) {
            online += 1
        } else if viewModel.checking2Connection != nil {
            offline += 1
        } else {
            noStatus += 1
        }
        
        if instanceCount > 1 {
            if viewModel.checking3Connection != nil && isWithinXsec(from: viewModel.checking3Connection ?? Date(), sec: 6) {
                refreshing += 1
            } else if viewModel.lastServer3Update != nil && isWithinXmin(from: viewModel.lastServer3Update ?? Date(), min: 1) && (viewModel.checking3Connection == nil || viewModel.lastServer3Update ?? Date() > viewModel.checking3Connection ?? Date()) {
                online += 1
            } else if viewModel.checking3Connection != nil {
                offline += 1
            } else {
                noStatus += 1
            }
        }
        
        if instanceCount > 2 {
            if viewModel.checking4Connection != nil && isWithinXsec(from: viewModel.checking4Connection ?? Date(), sec: 6) {
                refreshing += 1
            } else if viewModel.lastServer4Update != nil && isWithinXmin(from: viewModel.lastServer4Update ?? Date(), min: 1) && (viewModel.checking4Connection == nil || viewModel.lastServer4Update ?? Date() > viewModel.checking4Connection ?? Date()) {
                online += 1
            } else if viewModel.checking4Connection != nil {
                offline += 1
            } else {
                noStatus += 1
            }
        }
        
        if instanceCount > 3 {
            if viewModel.checking5Connection != nil && isWithinXsec(from: viewModel.checking5Connection ?? Date(), sec: 6) {
                refreshing += 1
            } else if viewModel.lastServer5Update != nil && isWithinXmin(from: viewModel.lastServer5Update ?? Date(), min: 1) && (viewModel.checking5Connection == nil || viewModel.lastServer5Update ?? Date() > viewModel.checking5Connection ?? Date()) {
                online += 1
            } else if viewModel.checking5Connection != nil {
                offline += 1
            } else {
                noStatus += 1
            }
        }
        
        if instanceCount > 4 {
            if viewModel.checking6Connection != nil && isWithinXsec(from: viewModel.checking6Connection ?? Date(), sec: 6) {
                refreshing += 1
            } else if viewModel.lastServer6Update != nil && isWithinXmin(from: viewModel.lastServer6Update ?? Date(), min: 1) && (viewModel.checking6Connection == nil || viewModel.lastServer6Update ?? Date() > viewModel.checking6Connection ?? Date()) {
                online += 1
            } else if viewModel.checking6Connection != nil {
                offline += 1
            } else {
                noStatus += 1
            }
        }

        if online > 0 {
            return 2
        }
        if refreshing > 0 {
            return 1
        }

        return 3
    }
}
