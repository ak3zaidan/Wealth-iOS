import SwiftUI

struct InstanceManager: View {
    @Environment(TaskViewModel.self) private var viewModel
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var popRoot: PopToRoot
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @State private var timer: Timer? = nil
    @State var toggleId = UUID()
    @State var appeared = true
    @State var maxRetryCount1: Int = 0
    @State var maxRetryCount2: Int = 0
    @State var maxRetryCount3: Int = 0
    @State var maxRetryCount4: Int = 0
    @State var maxRetryCount5: Int = 0
    @State var maxRetryCount6: Int = 0
  
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 10){
                Color.clear.frame(height: 1).id("scrolltop")
                
                instance1()
                
                let instanceCount = auth.currentUser?.ownedInstances ?? 0
                
                if instanceCount > 0 {
                    instance2()
                }
                if instanceCount > 1 {
                    instance3()
                }
                if instanceCount > 2 {
                    instance4()
                }
                if instanceCount > 3 {
                    instance5()
                }
                if instanceCount > 4 {
                    instance6()
                }
                
                Color.clear.frame(height: 120)
            }
        }
        .safeAreaPadding(.top, 75 + top_Inset())
        .scrollIndicators(.hidden)
        .onChange(of: popRoot.tap) { _, _ in
            if appeared {
                dismiss()
                popRoot.tap = 0
            }
        }
        .background(content: {
            Color.clear.id(toggleId)
        })
        .background(content: {
            backColor()
        })
        .overlay(alignment: .top) {
            headerView()
        }
        .ignoresSafeArea()
        .onAppear(perform: {
            appeared = true
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                toggleId = UUID()
            }
        })
        .onDisappear {
            appeared = false
            if timer != nil {
                timer?.invalidate()
                timer = nil
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    @ViewBuilder
    func instance6() -> some View {
        let uid = auth.currentUser?.id ?? ""
        let instance = viewModel.instances?.first(where: { $0.instanceId == 6 })
        
        VStack(alignment: .leading, spacing: 6){
            if let name = instance?.nickName, !name.isEmpty {
                Text("6. \(name)").font(.headline).bold()
            } else {
                Text("Instance 6").font(.headline).bold()
            }
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 4){
                        if viewModel.checking6Connection != nil && isWithinXsec(from: viewModel.checking6Connection ?? Date(), sec: 6) {
                            Text("Server Status").font(.headline).fontWeight(.heavy)
                            Text("Refreshing connection...").font(.caption).foregroundStyle(.gray)
                        } else if viewModel.lastServer6Update != nil && isWithinXmin(from: viewModel.lastServer6Update ?? Date(), min: 1) && (viewModel.checking6Connection == nil || viewModel.lastServer6Update ?? Date() > viewModel.checking6Connection ?? Date()) {
                            Text("Server Online").font(.headline).fontWeight(.heavy).foregroundStyle(.green)
                            Text(formatDateString(from: viewModel.lastServer6Update ?? Date())).font(.caption).foregroundStyle(.gray)
                        } else if viewModel.checking6Connection != nil {
                            Text("Server Offline").font(.headline).fontWeight(.heavy).foregroundStyle(.red)
                            Text("Please turn on Wealth AIO.").font(.caption).foregroundStyle(.gray)
                        } else {
                            Text("Server Status").font(.headline).fontWeight(.heavy)
                            Text("Please refresh connection.").font(.caption).foregroundStyle(.gray)
                        }
                    }
                    Spacer()
                    if viewModel.checking6Connection != nil && isWithinXsec(from: viewModel.checking6Connection ?? Date(), sec: 6) {
                        ProgressView().transition(.scale)
                    } else if viewModel.lastServer6Update != nil && isWithinXmin(from: viewModel.lastServer6Update ?? Date(), min: 1) && (viewModel.checking6Connection == nil || viewModel.lastServer6Update ?? Date() > viewModel.checking6Connection ?? Date()) {
                        LottieView(loopMode: .loop, name: "greenAnim").frame(width: 35, height: 35).scaleEffect(0.7)
                            .transition(.scale)
                            .onDisappear {
                                if !(viewModel.lastServer6Update != nil && isWithinXmin(from: viewModel.lastServer6Update ?? Date(), min: 1) && (viewModel.checking6Connection == nil || viewModel.lastServer6Update ?? Date() > viewModel.checking6Connection ?? Date())) {
                                    
                                    if !viewModel.isConnected {
                                        viewModel.connect(currentUID: uid)
                                    }
                                    let sessionId = UUID().uuidString
                                    viewModel.checking6ConnectionIds[sessionId] = Date()
                                    ServerSend().checkServerOnline(id: sessionId, instance: 6)
                                    withAnimation(.easeInOut(duration: 0.3)){
                                        viewModel.checking6Connection = Date()
                                    }
                                }
                            }
                    } else {
                        Button {
                            if !viewModel.isConnected {
                                viewModel.connect(currentUID: uid)
                            }
                            let sessionId = UUID().uuidString
                            viewModel.checking6ConnectionIds[sessionId] = Date()
                            ServerSend().checkServerOnline(id: sessionId, instance: 6)
                            withAnimation(.easeInOut(duration: 0.3)){
                                viewModel.checking6Connection = Date()
                            }
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                        } label: {
                            Text("Refresh").font(.subheadline).bold()
                                .padding(.horizontal, 12).padding(.vertical, 6)
                                .background(Color.babyBlue).clipShape(Capsule()).shadow(color: .gray, radius: 3)
                        }
                        .transition(.scale).buttonStyle(.plain)
                        .onAppear {
                            if maxRetryCount6 < 3 {
                                maxRetryCount6 += 1
                                
                                if viewModel.lastServer6Update != nil &&
                                    isWithinXmin(from: viewModel.lastServer6Update ?? Date(), min: 2) {
                                    
                                    if !viewModel.isConnected {
                                        viewModel.connect(currentUID: uid)
                                    }
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
                
                HStack {
                    Button {
                        ServerSend().updateServer(instance: 6)
                        withAnimation(.easeInOut(duration: 0.25)){
                            viewModel.lastServer6Update = nil
                            viewModel.checking6Connection = nil
                        }
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    } label: {
                        Text("Update").font(.subheadline).bold()
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(Color.green).clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: .gray, radius: 3)
                    }.buttonStyle(.plain)
                    
                    Button {
                        TaskService().newRequest(type: "6reloadFiles", data: [:])
                        
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                        
                        popRoot.presentAlert(image: "checkmark",
                                             text: "Reload request sent!")
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Files").bold()
                        }
                        .font(.subheadline).padding(.horizontal, 12).padding(.vertical, 6)
                        .background(Color.indigo).clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .gray, radius: 3)
                    }.buttonStyle(.plain)
                    
                    Spacer()
                    
                    if let ip = instance?.ip {
                        Text(ip).font(.subheadline).foregroundStyle(.gray)
                    }
                }
            }
            .padding(10)
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
        }.padding(.horizontal, 12)
    }
    @ViewBuilder
    func instance5() -> some View {
        let uid = auth.currentUser?.id ?? ""
        let instance = viewModel.instances?.first(where: { $0.instanceId == 5 })
        
        VStack(alignment: .leading, spacing: 6){
            if let name = instance?.nickName, !name.isEmpty {
                Text("5. \(name)").font(.headline).bold()
            } else {
                Text("Instance 5").font(.headline).bold()
            }
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 4){
                        if viewModel.checking5Connection != nil && isWithinXsec(from: viewModel.checking5Connection ?? Date(), sec: 6) {
                            Text("Server Status").font(.headline).fontWeight(.heavy)
                            Text("Refreshing connection...").font(.caption).foregroundStyle(.gray)
                        } else if viewModel.lastServer5Update != nil && isWithinXmin(from: viewModel.lastServer5Update ?? Date(), min: 1) && (viewModel.checking5Connection == nil || viewModel.lastServer5Update ?? Date() > viewModel.checking5Connection ?? Date()) {
                            Text("Server Online").font(.headline).fontWeight(.heavy).foregroundStyle(.green)
                            Text(formatDateString(from: viewModel.lastServer5Update ?? Date())).font(.caption).foregroundStyle(.gray)
                        } else if viewModel.checking5Connection != nil {
                            Text("Server Offline").font(.headline).fontWeight(.heavy).foregroundStyle(.red)
                            Text("Please turn on Wealth AIO.").font(.caption).foregroundStyle(.gray)
                        } else {
                            Text("Server Status").font(.headline).fontWeight(.heavy)
                            Text("Please refresh connection.").font(.caption).foregroundStyle(.gray)
                        }
                    }
                    Spacer()
                    if viewModel.checking5Connection != nil && isWithinXsec(from: viewModel.checking5Connection ?? Date(), sec: 6) {
                        ProgressView().transition(.scale)
                    } else if viewModel.lastServer5Update != nil && isWithinXmin(from: viewModel.lastServer5Update ?? Date(), min: 1) && (viewModel.checking5Connection == nil || viewModel.lastServer5Update ?? Date() > viewModel.checking5Connection ?? Date()) {
                        LottieView(loopMode: .loop, name: "greenAnim").frame(width: 35, height: 35).scaleEffect(0.7)
                            .transition(.scale)
                            .onDisappear {
                                if !(viewModel.lastServer5Update != nil && isWithinXmin(from: viewModel.lastServer5Update ?? Date(), min: 1) && (viewModel.checking5Connection == nil || viewModel.lastServer5Update ?? Date() > viewModel.checking5Connection ?? Date())) {
                                    
                                    if !viewModel.isConnected {
                                        viewModel.connect(currentUID: uid)
                                    }
                                    let sessionId = UUID().uuidString
                                    viewModel.checking5ConnectionIds[sessionId] = Date()
                                    ServerSend().checkServerOnline(id: sessionId, instance: 5)
                                    withAnimation(.easeInOut(duration: 0.3)){
                                        viewModel.checking5Connection = Date()
                                    }
                                }
                            }
                    } else {
                        Button {
                            if !viewModel.isConnected {
                                viewModel.connect(currentUID: uid)
                            }
                            let sessionId = UUID().uuidString
                            viewModel.checking5ConnectionIds[sessionId] = Date()
                            ServerSend().checkServerOnline(id: sessionId, instance: 5)
                            withAnimation(.easeInOut(duration: 0.3)){
                                viewModel.checking5Connection = Date()
                            }
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                        } label: {
                            Text("Refresh").font(.subheadline).bold()
                                .padding(.horizontal, 12).padding(.vertical, 6)
                                .background(Color.babyBlue).clipShape(Capsule()).shadow(color: .gray, radius: 3)
                        }
                        .transition(.scale).buttonStyle(.plain)
                        .onAppear {
                            if maxRetryCount5 < 3 {
                                maxRetryCount5 += 1
                                
                                if viewModel.lastServer5Update != nil &&
                                    isWithinXmin(from: viewModel.lastServer5Update ?? Date(), min: 2) {
                                    
                                    if !viewModel.isConnected {
                                        viewModel.connect(currentUID: uid)
                                    }
                                    let sessionId = UUID().uuidString
                                    viewModel.checking5ConnectionIds[sessionId] = Date()
                                    ServerSend().checkServerOnline(id: sessionId, instance: 5)
                                    withAnimation(.easeInOut(duration: 0.3)){
                                        viewModel.checking5Connection = Date()
                                    }
                                }
                            }
                        }
                    }
                }
                
                HStack {
                    Button {
                        ServerSend().updateServer(instance: 5)
                        withAnimation(.easeInOut(duration: 0.25)){
                            viewModel.lastServer5Update = nil
                            viewModel.checking5Connection = nil
                        }
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    } label: {
                        Text("Update").font(.subheadline).bold()
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(Color.green).clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: .gray, radius: 3)
                    }.buttonStyle(.plain)
                    
                    Button {
                        TaskService().newRequest(type: "5reloadFiles", data: [:])
                        
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                        
                        popRoot.presentAlert(image: "checkmark",
                                             text: "Reload request sent!")
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Files").bold()
                        }
                        .font(.subheadline).padding(.horizontal, 12).padding(.vertical, 6)
                        .background(Color.indigo).clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .gray, radius: 3)
                    }.buttonStyle(.plain)
                    
                    Spacer()
                    
                    if let ip = instance?.ip {
                        Text(ip).font(.subheadline).foregroundStyle(.gray)
                    }
                }
            }
            .padding(10)
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
        }.padding(.horizontal, 12)
    }
    @ViewBuilder
    func instance4() -> some View {
        let uid = auth.currentUser?.id ?? ""
        let instance = viewModel.instances?.first(where: { $0.instanceId == 4 })
        
        VStack(alignment: .leading, spacing: 6){
            if let name = instance?.nickName, !name.isEmpty {
                Text("4. \(name)").font(.headline).bold()
            } else {
                Text("Instance 4").font(.headline).bold()
            }
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 4){
                        if viewModel.checking4Connection != nil && isWithinXsec(from: viewModel.checking4Connection ?? Date(), sec: 6) {
                            Text("Server Status").font(.headline).fontWeight(.heavy)
                            Text("Refreshing connection...").font(.caption).foregroundStyle(.gray)
                        } else if viewModel.lastServer4Update != nil && isWithinXmin(from: viewModel.lastServer4Update ?? Date(), min: 1) && (viewModel.checking4Connection == nil || viewModel.lastServer4Update ?? Date() > viewModel.checking4Connection ?? Date()) {
                            Text("Server Online").font(.headline).fontWeight(.heavy).foregroundStyle(.green)
                            Text(formatDateString(from: viewModel.lastServer4Update ?? Date())).font(.caption).foregroundStyle(.gray)
                        } else if viewModel.checking4Connection != nil {
                            Text("Server Offline").font(.headline).fontWeight(.heavy).foregroundStyle(.red)
                            Text("Please turn on Wealth AIO.").font(.caption).foregroundStyle(.gray)
                        } else {
                            Text("Server Status").font(.headline).fontWeight(.heavy)
                            Text("Please refresh connection.").font(.caption).foregroundStyle(.gray)
                        }
                    }
                    Spacer()
                    if viewModel.checking4Connection != nil && isWithinXsec(from: viewModel.checking4Connection ?? Date(), sec: 6) {
                        ProgressView().transition(.scale)
                    } else if viewModel.lastServer4Update != nil && isWithinXmin(from: viewModel.lastServer4Update ?? Date(), min: 1) && (viewModel.checking4Connection == nil || viewModel.lastServer4Update ?? Date() > viewModel.checking4Connection ?? Date()) {
                        LottieView(loopMode: .loop, name: "greenAnim").frame(width: 35, height: 35).scaleEffect(0.7)
                            .transition(.scale)
                            .onDisappear {
                                if !(viewModel.lastServer4Update != nil && isWithinXmin(from: viewModel.lastServer4Update ?? Date(), min: 1) && (viewModel.checking4Connection == nil || viewModel.lastServer4Update ?? Date() > viewModel.checking4Connection ?? Date())) {
                                    
                                    if !viewModel.isConnected {
                                        viewModel.connect(currentUID: uid)
                                    }
                                    let sessionId = UUID().uuidString
                                    viewModel.checking4ConnectionIds[sessionId] = Date()
                                    ServerSend().checkServerOnline(id: sessionId, instance: 4)
                                    withAnimation(.easeInOut(duration: 0.3)){
                                        viewModel.checking4Connection = Date()
                                    }
                                }
                            }
                    } else {
                        Button {
                            if !viewModel.isConnected {
                                viewModel.connect(currentUID: uid)
                            }
                            let sessionId = UUID().uuidString
                            viewModel.checking4ConnectionIds[sessionId] = Date()
                            ServerSend().checkServerOnline(id: sessionId, instance: 4)
                            withAnimation(.easeInOut(duration: 0.3)){
                                viewModel.checking4Connection = Date()
                            }
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                        } label: {
                            Text("Refresh").font(.subheadline).bold()
                                .padding(.horizontal, 12).padding(.vertical, 6)
                                .background(Color.babyBlue).clipShape(Capsule()).shadow(color: .gray, radius: 3)
                        }
                        .transition(.scale).buttonStyle(.plain)
                        .onAppear {
                            if maxRetryCount4 < 3 {
                                maxRetryCount4 += 1
                                
                                if viewModel.lastServer4Update != nil &&
                                    isWithinXmin(from: viewModel.lastServer4Update ?? Date(), min: 2) {
                                    
                                    if !viewModel.isConnected {
                                        viewModel.connect(currentUID: uid)
                                    }
                                    let sessionId = UUID().uuidString
                                    viewModel.checking4ConnectionIds[sessionId] = Date()
                                    ServerSend().checkServerOnline(id: sessionId, instance: 4)
                                    withAnimation(.easeInOut(duration: 0.3)){
                                        viewModel.checking4Connection = Date()
                                    }
                                }
                            }
                        }
                    }
                }
                
                HStack {
                    Button {
                        ServerSend().updateServer(instance: 4)
                        withAnimation(.easeInOut(duration: 0.25)){
                            viewModel.lastServer4Update = nil
                            viewModel.checking4Connection = nil
                        }
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    } label: {
                        Text("Update").font(.subheadline).bold()
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(Color.green).clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: .gray, radius: 3)
                    }.buttonStyle(.plain)
                    
                    Button {
                        TaskService().newRequest(type: "4reloadFiles", data: [:])
                        
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                        
                        popRoot.presentAlert(image: "checkmark",
                                             text: "Reload request sent!")
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Files").bold()
                        }
                        .font(.subheadline).padding(.horizontal, 12).padding(.vertical, 6)
                        .background(Color.indigo).clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .gray, radius: 3)
                    }.buttonStyle(.plain)
                    
                    Spacer()
                    
                    if let ip = instance?.ip {
                        Text(ip).font(.subheadline).foregroundStyle(.gray)
                    }
                }
            }
            .padding(10)
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
        }.padding(.horizontal, 12)
    }
    @ViewBuilder
    func instance3() -> some View {
        let uid = auth.currentUser?.id ?? ""
        let instance = viewModel.instances?.first(where: { $0.instanceId == 3 })
        
        VStack(alignment: .leading, spacing: 6){
            if let name = instance?.nickName, !name.isEmpty {
                Text("3. \(name)").font(.headline).bold()
            } else {
                Text("Instance 3").font(.headline).bold()
            }
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 4){
                        if viewModel.checking3Connection != nil && isWithinXsec(from: viewModel.checking3Connection ?? Date(), sec: 6) {
                            Text("Server Status").font(.headline).fontWeight(.heavy)
                            Text("Refreshing connection...").font(.caption).foregroundStyle(.gray)
                        } else if viewModel.lastServer3Update != nil && isWithinXmin(from: viewModel.lastServer3Update ?? Date(), min: 1) && (viewModel.checking3Connection == nil || viewModel.lastServer3Update ?? Date() > viewModel.checking3Connection ?? Date()) {
                            Text("Server Online").font(.headline).fontWeight(.heavy).foregroundStyle(.green)
                            Text(formatDateString(from: viewModel.lastServer3Update ?? Date())).font(.caption).foregroundStyle(.gray)
                        } else if viewModel.checking3Connection != nil {
                            Text("Server Offline").font(.headline).fontWeight(.heavy).foregroundStyle(.red)
                            Text("Please turn on Wealth AIO.").font(.caption).foregroundStyle(.gray)
                        } else {
                            Text("Server Status").font(.headline).fontWeight(.heavy)
                            Text("Please refresh connection.").font(.caption).foregroundStyle(.gray)
                        }
                    }
                    Spacer()
                    if viewModel.checking3Connection != nil && isWithinXsec(from: viewModel.checking3Connection ?? Date(), sec: 6) {
                        ProgressView().transition(.scale)
                    } else if viewModel.lastServer3Update != nil && isWithinXmin(from: viewModel.lastServer3Update ?? Date(), min: 1) && (viewModel.checking3Connection == nil || viewModel.lastServer3Update ?? Date() > viewModel.checking3Connection ?? Date()) {
                        LottieView(loopMode: .loop, name: "greenAnim").frame(width: 35, height: 35).scaleEffect(0.7)
                            .transition(.scale)
                            .onDisappear {
                                if !(viewModel.lastServer3Update != nil && isWithinXmin(from: viewModel.lastServer3Update ?? Date(), min: 1) && (viewModel.checking3Connection == nil || viewModel.lastServer3Update ?? Date() > viewModel.checking3Connection ?? Date())) {
                                    
                                    if !viewModel.isConnected {
                                        viewModel.connect(currentUID: uid)
                                    }
                                    let sessionId = UUID().uuidString
                                    viewModel.checking3ConnectionIds[sessionId] = Date()
                                    ServerSend().checkServerOnline(id: sessionId, instance: 3)
                                    withAnimation(.easeInOut(duration: 0.3)){
                                        viewModel.checking3Connection = Date()
                                    }
                                }
                            }
                    } else {
                        Button {
                            if !viewModel.isConnected {
                                viewModel.connect(currentUID: uid)
                            }
                            let sessionId = UUID().uuidString
                            viewModel.checking3ConnectionIds[sessionId] = Date()
                            ServerSend().checkServerOnline(id: sessionId, instance: 3)
                            withAnimation(.easeInOut(duration: 0.3)){
                                viewModel.checking3Connection = Date()
                            }
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                        } label: {
                            Text("Refresh").font(.subheadline).bold()
                                .padding(.horizontal, 12).padding(.vertical, 6)
                                .background(Color.babyBlue).clipShape(Capsule()).shadow(color: .gray, radius: 3)
                        }
                        .transition(.scale).buttonStyle(.plain)
                        .onAppear {
                            if maxRetryCount3 < 3 {
                                maxRetryCount3 += 1
                                
                                if viewModel.lastServer3Update != nil &&
                                    isWithinXmin(from: viewModel.lastServer3Update ?? Date(), min: 2) {
                                    
                                    if !viewModel.isConnected {
                                        viewModel.connect(currentUID: uid)
                                    }
                                    let sessionId = UUID().uuidString
                                    viewModel.checking3ConnectionIds[sessionId] = Date()
                                    ServerSend().checkServerOnline(id: sessionId, instance: 3)
                                    withAnimation(.easeInOut(duration: 0.3)){
                                        viewModel.checking3Connection = Date()
                                    }
                                }
                            }
                        }
                    }
                }
                
                HStack {
                    Button {
                        ServerSend().updateServer(instance: 3)
                        withAnimation(.easeInOut(duration: 0.25)){
                            viewModel.lastServer3Update = nil
                            viewModel.checking3Connection = nil
                        }
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    } label: {
                        Text("Update").font(.subheadline).bold()
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(Color.green).clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: .gray, radius: 3)
                    }.buttonStyle(.plain)
                    
                    Button {
                        TaskService().newRequest(type: "3reloadFiles", data: [:])
                        
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                        
                        popRoot.presentAlert(image: "checkmark",
                                             text: "Reload request sent!")
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Files").bold()
                        }
                        .font(.subheadline).padding(.horizontal, 12).padding(.vertical, 6)
                        .background(Color.indigo).clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .gray, radius: 3)
                    }.buttonStyle(.plain)
                    
                    Spacer()
                    
                    if let ip = instance?.ip {
                        Text(ip).font(.subheadline).foregroundStyle(.gray)
                    }
                }
            }
            .padding(10)
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
        }.padding(.horizontal, 12)
    }
    @ViewBuilder
    func instance2() -> some View {
        let uid = auth.currentUser?.id ?? ""
        let instance = viewModel.instances?.first(where: { $0.instanceId == 2 })
        
        VStack(alignment: .leading, spacing: 6){
            if let name = instance?.nickName, !name.isEmpty {
                Text("2. \(name)").font(.headline).bold()
            } else {
                Text("Instance 2").font(.headline).bold()
            }
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 4){
                        if viewModel.checking2Connection != nil && isWithinXsec(from: viewModel.checking2Connection ?? Date(), sec: 6) {
                            Text("Server Status").font(.headline).fontWeight(.heavy)
                            Text("Refreshing connection...").font(.caption).foregroundStyle(.gray)
                        } else if viewModel.lastServer2Update != nil && isWithinXmin(from: viewModel.lastServer2Update ?? Date(), min: 1) && (viewModel.checking2Connection == nil || viewModel.lastServer2Update ?? Date() > viewModel.checking2Connection ?? Date()) {
                            Text("Server Online").font(.headline).fontWeight(.heavy).foregroundStyle(.green)
                            Text(formatDateString(from: viewModel.lastServer2Update ?? Date())).font(.caption).foregroundStyle(.gray)
                        } else if viewModel.checking2Connection != nil {
                            Text("Server Offline").font(.headline).fontWeight(.heavy).foregroundStyle(.red)
                            Text("Please turn on Wealth AIO.").font(.caption).foregroundStyle(.gray)
                        } else {
                            Text("Server Status").font(.headline).fontWeight(.heavy)
                            Text("Please refresh connection.").font(.caption).foregroundStyle(.gray)
                        }
                    }
                    Spacer()
                    if viewModel.checking2Connection != nil && isWithinXsec(from: viewModel.checking2Connection ?? Date(), sec: 6) {
                        ProgressView().transition(.scale)
                    } else if viewModel.lastServer2Update != nil && isWithinXmin(from: viewModel.lastServer2Update ?? Date(), min: 1) && (viewModel.checking2Connection == nil || viewModel.lastServer2Update ?? Date() > viewModel.checking2Connection ?? Date()) {
                        LottieView(loopMode: .loop, name: "greenAnim").frame(width: 35, height: 35).scaleEffect(0.7)
                            .transition(.scale)
                            .onDisappear {
                                if !(viewModel.lastServer2Update != nil && isWithinXmin(from: viewModel.lastServer2Update ?? Date(), min: 1) && (viewModel.checking2Connection == nil || viewModel.lastServer2Update ?? Date() > viewModel.checking2Connection ?? Date())) {
                                    
                                    if !viewModel.isConnected {
                                        viewModel.connect(currentUID: uid)
                                    }
                                    let sessionId = UUID().uuidString
                                    viewModel.checking2ConnectionIds[sessionId] = Date()
                                    ServerSend().checkServerOnline(id: sessionId, instance: 2)
                                    withAnimation(.easeInOut(duration: 0.3)){
                                        viewModel.checking2Connection = Date()
                                    }
                                }
                            }
                    } else {
                        Button {
                            if !viewModel.isConnected {
                                viewModel.connect(currentUID: uid)
                            }
                            let sessionId = UUID().uuidString
                            viewModel.checking2ConnectionIds[sessionId] = Date()
                            ServerSend().checkServerOnline(id: sessionId, instance: 2)
                            withAnimation(.easeInOut(duration: 0.3)){
                                viewModel.checking2Connection = Date()
                            }
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                        } label: {
                            Text("Refresh").font(.subheadline).bold()
                                .padding(.horizontal, 12).padding(.vertical, 6)
                                .background(Color.babyBlue).clipShape(Capsule()).shadow(color: .gray, radius: 3)
                        }
                        .transition(.scale).buttonStyle(.plain)
                        .onAppear {
                            if maxRetryCount2 < 3 {
                                maxRetryCount2 += 1
                                
                                if viewModel.lastServer2Update != nil &&
                                    isWithinXmin(from: viewModel.lastServer2Update ?? Date(), min: 2) {
                                    
                                    if !viewModel.isConnected {
                                        viewModel.connect(currentUID: uid)
                                    }
                                    let sessionId = UUID().uuidString
                                    viewModel.checking2ConnectionIds[sessionId] = Date()
                                    ServerSend().checkServerOnline(id: sessionId, instance: 2)
                                    withAnimation(.easeInOut(duration: 0.3)){
                                        viewModel.checking2Connection = Date()
                                    }
                                }
                            }
                        }
                    }
                }
                
                HStack {
                    Button {
                        ServerSend().updateServer(instance: 2)
                        withAnimation(.easeInOut(duration: 0.25)){
                            viewModel.lastServer2Update = nil
                            viewModel.checking2Connection = nil
                        }
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    } label: {
                        Text("Update").font(.subheadline).bold()
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(Color.green).clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: .gray, radius: 3)
                    }.buttonStyle(.plain)
                    
                    Button {
                        TaskService().newRequest(type: "2reloadFiles", data: [:])
                        
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                        
                        popRoot.presentAlert(image: "checkmark",
                                             text: "Reload request sent!")
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Files").bold()
                        }
                        .font(.subheadline).padding(.horizontal, 12).padding(.vertical, 6)
                        .background(Color.indigo).clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .gray, radius: 3)
                    }.buttonStyle(.plain)
                    
                    Spacer()
                    
                    if let ip = instance?.ip {
                        Text(ip).font(.subheadline).foregroundStyle(.gray)
                    }
                }
            }
            .padding(10)
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
        }.padding(.horizontal, 12)
    }
    @ViewBuilder
    func instance1() -> some View {
        
        let uid = auth.currentUser?.id ?? ""
        let instance = viewModel.instances?.first(where: { $0.instanceId == 1 })
        
        VStack(alignment: .leading, spacing: 6){
            if let name = instance?.nickName, !name.isEmpty {
                Text("1. \(name)").font(.headline).bold()
            } else {
                Text("Instance 1").font(.headline).bold()
            }
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 4){
                        if viewModel.checkingConnection != nil && isWithinXsec(from: viewModel.checkingConnection ?? Date(), sec: 6) {
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
                    if viewModel.checkingConnection != nil && isWithinXsec(from: viewModel.checkingConnection ?? Date(), sec: 6) {
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
                            if maxRetryCount1 < 3 {
                                maxRetryCount1 += 1
                                
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
                
                HStack {
                    Button {
                        ServerSend().updateServer(instance: 1)
                        withAnimation(.easeInOut(duration: 0.25)){
                            viewModel.lastServerUpdate = nil
                            viewModel.checkingConnection = nil
                        }
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    } label: {
                        Text("Update").font(.subheadline).bold()
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(Color.green).clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: .gray, radius: 3)
                    }.buttonStyle(.plain)
                    
                    Button {
                        TaskService().newRequest(type: "1reloadFiles", data: [:])
                        
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                        
                        popRoot.presentAlert(image: "checkmark",
                                             text: "Reload request sent!")
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Files").bold()
                        }
                        .font(.subheadline).padding(.horizontal, 12).padding(.vertical, 6)
                        .background(Color.indigo).clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .gray, radius: 3)
                    }.buttonStyle(.plain)
                    
                    Spacer()
                    
                    if let ip = instance?.ip {
                        Text(ip).font(.subheadline).foregroundStyle(.gray)
                    }
                }
            }
            .padding(10)
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
        }.padding(.horizontal, 12)
    }
    @ViewBuilder
    func backColor() -> some View {
        GeometryReader { geo in
            Image("WealthBlur")
                .resizable()
                .frame(width: geo.size.width, height: geo.size.height)
            if colorScheme == .dark {
                Color.black.opacity(0.8)
            } else {
                Color.white.opacity(0.75)
            }
        }
        .ignoresSafeArea()
    }
    @ViewBuilder
    func headerView() -> some View {
        ZStack {
            HStack {
                Spacer()
                VStack(spacing: 3){
                    Image(colorScheme == .dark ? "wealthLogoWhite" : "wealthLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 45)
                    Text("Instance Manager").font(.caption).fontWeight(.semibold)
                }
                Spacer()
            }
            HStack {
                Button {
                    dismiss()
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    ZStack {
                        Rectangle().frame(width: 40, height: 50)
                            .foregroundStyle(.gray).opacity(0.001)
                        Image(systemName: "chevron.left").font(.title3).bold()
                    }
                }.buttonStyle(.plain)
                
                Spacer()
            }
        }
        .padding(.top, top_Inset()).padding(.horizontal).padding(.bottom, 10)
        .background {
            TransparentBlurView(removeAllFilters: true).blur(radius: 14, opaque: true)
        }
    }
}
