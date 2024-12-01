import SwiftUI
import AuthenticationServices
import Kingfisher
import Firebase

struct MainTaskView: View {
    @Environment(TaskViewModel.self) private var viewModel
    @Environment(FeedViewModel.self) private var feedModel
    @EnvironmentObject var subManager: SubscriptionsManager
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var popRoot: PopToRoot
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.scenePhase) var scenePhase
    
    // Text fields
    @State var newUrl = ""
    @FocusState var isEditingUrl
    @State var newPass = ""
    @FocusState var isEditingPass
    @State var successHook = ""
    @FocusState var isEditingSuccess
    @State var failureHook = ""
    @FocusState var isEditingFailure
    @State var capKey = ""
    @FocusState var isEditingCap
    @State var newImapEmail = ""
    @State var newImapPass = ""
    
    // Misc vars
    @State var hideOrderNums: Bool? = false
    @State var showServerSheet = false
    @State var showPasswordSheet = false
    @State var showAccountManager = false
    @State var showProfileManager = false
    @State var showUpdateAlert = false
    @State var showSitePicker = false
    @State var showCapSolver = false
    @State var showQueueConfig = false
    @State var toggleGlitch = false
    @State var showNewGroup = false
    @State var newGroupToggleId = UUID()
    @State var showPassword = false
    @State var showWebhooks = false
    @State var showSettings = false
    @State var showIMAPSheet = false
    @State var showIMAPEdit = false
    @State var imapEditing = 0
    @State var showCreateInstance = false
    @State var createInstanceIndices = [Int]()
    @State var createInstanceData: [String : Any] = [:]
    @State var maxRetryCount = 0
    @State var showBuyPro = false
    @State var appearHit = false
    @State var restart = false
    @State var appeared = true
    @Namespace var hero
        
    // Discord Auth
    @State var showDiscordAlert = false
    @State var showDiscordSheet = false
    @State var isLoggedIn = false
    @State var discordUsername = ""
    @State var discordUID = ""
    
    // Create
    @State var previousSetup = BotTask(profileGroup: "", profileName: "", proxyGroup: "", accountGroup: "", input: "", size: "", color: "", site: "", mode: "", cartQuantity: 1, delay: 3500, discountCode: "", maxBuyPrice: 99999, maxBuyQuantity: 99999)
    @State var lock = false
    @State var action = TaskAction.Create
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                Color.clear.frame(height: 14)
                
                StatusBarView(maxRetryCount: $maxRetryCount, uid: auth.currentUser?.id ?? "", instanceCount: auth.currentUser?.ownedInstances ?? 0)
                
                LazyVStack(spacing: 10, pinnedViews: [.sectionHeaders]){
                    Color.clear.frame(height: 1).id("scrolltop")
                    
                    if let user = auth.currentUser {
                        headerStats(user: user)
                    }
                    
                    quickTasks()
                    
                    if let tasks = viewModel.tasks {
                        if tasks.isEmpty {
                            VStack(spacing: 6){
                                Text("No Tasks yet...").font(.largeTitle).bold()
                                    .scrollTransition { content, phase in
                                        content
                                            .scaleEffect(phase == .identity ? 1 : 0.65)
                                            .blur(radius: phase == .identity ? 0 : 10)
                                    }
                                Text("Click here to make a group.").font(.subheadline).fontWeight(.light)
                                    .scrollTransition { content, phase in
                                        content
                                            .scaleEffect(phase == .identity ? 1 : 0.65)
                                            .blur(radius: phase == .identity ? 0 : 10)
                                    }
                                
                                LottieView(loopMode: .loop, name: "noTask")
                                    .scaleEffect(0.25).frame(width: 100, height: 100).padding(.top)
                                    .scrollTransition { content, phase in
                                        content
                                            .scaleEffect(phase == .identity ? 1 : 0.65)
                                            .blur(radius: phase == .identity ? 0 : 10)
                                    }
                            }
                            .onTapGesture(perform: {
                                showNewGroup = true
                            })
                            .padding(.top, 80)
                        } else {
                            LazyVStack(spacing: 6){
                                HStack {
                                    Text("Task Groups").font(.headline).bold()
                                    Spacer()
                                }.padding(.leading, 12).padding(.top, 10)
                                
                                ForEach(tasks) { task in
                                    
                                    let isOnline: Bool = isOnlineInstance(id: task.instance)
                                    
                                    NavigationLink {
                                        SingleTaskview(task: task, isOnline: isOnline)
                                            .navigationTransition(.zoom(sourceID: task.id, in: hero))
                                    } label: {
                                        TaskRowView(task: task, isOnline: isOnline) { baseUrl in
                                            newUrl = baseUrl
                                            withAnimation(.easeInOut(duration: 0.25)){
                                                showPassword = true
                                            }
                                        } moveTop: {
                                            if let idx = viewModel.tasks?.firstIndex(where: { ($0.id ?? "") == (task.id ?? "") }) {
                                                withAnimation(.easeInOut(duration: 0.3)){
                                                    if let element = viewModel.tasks?.remove(at: idx) {
                                                        if idx == 0 {
                                                            viewModel.tasks = (viewModel.tasks ?? []) + [element]
                                                        } else {
                                                            viewModel.tasks = [element] + (viewModel.tasks ?? [])
                                                        }
                                                    }
                                                    proxy.scrollTo("scrolltop", anchor: .bottom)
                                                }
                                            }
                                        }
                                    }
                                    .disabled(viewModel.disabledTasks.contains(task.id ?? "NA"))
                                    .buttonStyle(.plain)
                                    .matchedTransitionSource(id: task.id, in: hero)
                                    .overlay(content: {
                                        let status = task.isRunning ? 3 : (viewModel.startTaskQueue[task.name] != nil
                                                                           || viewModel.stopTaskQueue[task.name] != nil) ? 2 : 1
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(status == 3 ? .green : .blue, lineWidth: 1).opacity(0.8)
                                    })
                                    .scrollTransition { content, phase in
                                        content
                                            .scaleEffect(phase == .identity ? 1 : 0.65)
                                            .blur(radius: phase == .identity ? 0 : 10)
                                    }
                                    .padding(.bottom, 6).padding(.horizontal, 12)
                                }
                            }
                        }
                    } else {
                        VStack(spacing: 10){
                            ForEach(0..<5) { _ in
                                FeedLoadingView()
                                    .scrollTransition { content, phase in
                                        content
                                            .scaleEffect(phase == .identity ? 1 : 0.65)
                                            .blur(radius: phase == .identity ? 0 : 10)
                                    }
                            }
                        }.shimmering().transition(.scale.combined(with: .opacity)).padding(.top, 10)
                    }
                                        
                    Color.clear.frame(height: 150)
                }
            }
            .safeAreaPadding(.top, top_Inset() + 65)
            .scrollIndicators(.hidden)
            .onChange(of: popRoot.tap) { _, _ in
                if appeared {
                    withAnimation {
                        proxy.scrollTo("scrolltop", anchor: .bottom)
                    }
                    popRoot.tap = 0
                }
            }
        }
        .onChange(of: auth.currentUser?.id, { _, _ in
            if !appearHit {
                if let user = auth.currentUser, let uid = user.id, user.connectedMobileIP.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || user.connectedMobileIP == currentDeviceID() {
                    appearHit = true
                    
                    updateStats()
                    
                    getResiLogin()
                    
                    if user.connectedMobileIP.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        UserService().setPhoneIP(id: currentDeviceID())
                    }
                    if !viewModel.isConnected {
                        viewModel.connect(currentUID: uid)
                    }
                    
                    updateStatus()
                }
            }
        })
        .onAppear(perform: {
            appeared = true
            
            if viewModel.tasks == nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    if viewModel.tasks == nil {
                        withAnimation(.easeInOut(duration: 0.3)){
                            viewModel.tasks = []
                        }
                    }
                }
            }
            if !viewModel.glitchRunning {
                DispatchQueue.main.async {
                    viewModel.glitchRunning = true
                }
                glitchTogg()
            }

            if let user = auth.currentUser, let uid = user.id, user.connectedMobileIP.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || user.connectedMobileIP == currentDeviceID() {
                appearHit = true
                
                updateStats()
                
                getResiLogin()
                
                if user.connectedMobileIP.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    UserService().setPhoneIP(id: currentDeviceID())
                }
                if !viewModel.isConnected {
                    viewModel.connect(currentUID: uid)
                }
                
                updateStatus()
            }
        })
        .onChange(of: scenePhase) { prevPhase, newPhase in
            if prevPhase == .background && newPhase == .inactive {
                restart = true
            }
            
            if newPhase == .active && prevPhase == .inactive && restart {
                restart = false
                appeared = true
                
                if !viewModel.glitchRunning {
                    DispatchQueue.main.async {
                        viewModel.glitchRunning = true
                    }
                    glitchTogg()
                }
                
                if let user = auth.currentUser, let uid = user.id, user.connectedMobileIP.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || user.connectedMobileIP == currentDeviceID() {
                    
                    updateStats()
                    
                    if user.connectedMobileIP.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        UserService().setPhoneIP(id: currentDeviceID())
                    }
                    if !viewModel.isConnected {
                        viewModel.connect(currentUID: uid)
                    }
                    
                    updateStatus()
                }
            } else if newPhase == .background {
                appeared = false
                
                DispatchQueue.main.async {
                    viewModel.disconnect()
                }
            }
        }
        .onDisappear(perform: {
            appeared = false
            maxRetryCount = 0
        })
        .overlay(alignment: .top) {
            headerView().overlay(alignment: .bottom) {
                Divider()
            }
        }
        .overlay(content: {
            if showPassword || showBuyPro || showWebhooks || showCapSolver {
                TransparentBlurView(removeAllFilters: true).blur(radius: 14, opaque: true)
                    .background(colorScheme == .dark ? .black.opacity(0.7) : .white.opacity(0.7))
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)){
                            showPassword = false
                            showBuyPro = false
                            showWebhooks = false
                            showCapSolver = false
                        }
                    }
            }
        })
        .overlay(content: {
            if showPassword {
                passwordAdd().transition(.move(edge: .bottom).combined(with: .scale).combined(with: .opacity))
            }
        })
        .overlay(content: {
            if showBuyPro {
                buyProView().transition(.move(edge: .bottom).combined(with: .scale).combined(with: .opacity))
            }
        })
        .overlay(content: {
            if showWebhooks {
                webHooksView().transition(.move(edge: .bottom).combined(with: .scale).combined(with: .opacity))
            }
        })
        .overlay(content: {
            if showCapSolver {
                CapSolverView().transition(.move(edge: .bottom).combined(with: .scale).combined(with: .opacity))
            }
        })
        .overlay(content: {
            if !(auth.currentUser?.hasBotAccess ?? false) {
                TransparentBlurView(removeAllFilters: true).blur(radius: 14, opaque: true)
                    .background(colorScheme == .dark ? .black.opacity(0.7) : .white.opacity(0.7))
                    .ignoresSafeArea()
                    .overlay {
                        VStack{
                            Text("Task page locked!").font(.largeTitle).bold()
                            Text("Create a Wealth AIO plan to view this page.")
                                .font(.subheadline).fontWeight(.light).padding(.bottom)
                            LottieView(loopMode: .loop, name: "taskLock")
                                .scaleEffect(1.4).frame(width: 100, height: 100)
                        }
                    }
            } else if let user = auth.currentUser, !user.connectedMobileIP.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && user.connectedMobileIP != currentDeviceID() {
                TransparentBlurView(removeAllFilters: true).blur(radius: 14, opaque: true)
                    .background(colorScheme == .dark ? .black.opacity(0.7) : .white.opacity(0.7))
                    .ignoresSafeArea()
                    .overlay {
                        VStack{
                            Text("Task page locked!").font(.largeTitle).bold()
                            Text("Another device is connected.")
                                .font(.subheadline).fontWeight(.light).padding(.bottom, 25)
                            
                            Button {
                                UINotificationFeedbackGenerator().notificationOccurred(.success)
                                let currentId = currentDeviceID()
                                auth.currentUser?.connectedMobileIP = currentId
                                UserService().setPhoneIP(id: currentId)
                                ServerSend().alertMobileChange(id: currentId)
                                if let id = user.id {
                                    viewModel.connect(currentUID: id)
                                }
                                
                                updateStatus()
                            } label: {
                                VStack {
                                    Text("Reset Wealth AIO Mobile Remote.").font(.headline).bold()
                                    Text("This will reset connected mobile devices.").font(.caption)
                                }
                                .padding(12).background(.indigo.gradient).clipShape(RoundedRectangle(cornerRadius: 12))
                            }.buttonStyle(.plain)
                        }
                    }
            }
        })
        .ignoresSafeArea()
        .sheet(isPresented: $showCreateInstance) {
            createPicker()
        }
        .sheet(isPresented: $showNewGroup) {
            TaskBuilder(presetName: nil, setup: previousSetup, lock: $lock, action: $action, setShippingLock: .constant(false)) { result in
                let createCount = result.2
                let fileName = result.1
                let config = result.0
                
                let data = [
                    "name": fileName,
                    "count": createCount,
                    "config": convertTaskToString(task: config)
                ] as [String : Any]
                
                if (auth.currentUser?.ownedInstances ?? 0) > 0 {
                    createInstanceIndices = []
                    createInstanceData = data
                    showCreateInstance = true
                } else {
                    TaskService().newRequest(type: "1createTask", data: data)
                    
                    popRoot.presentAlert(image: "checkmark", text: "Request sent please wait")
                }
                
                self.previousSetup.input = config.input
                self.previousSetup.color = config.color
                self.previousSetup.size = config.size
                self.previousSetup.profileGroup = config.profileGroup
                self.previousSetup.profileName = config.profileName
                self.previousSetup.proxyGroup = config.proxyGroup
                self.previousSetup.accountGroup = config.accountGroup
            }
            .id(newGroupToggleId)
            .onAppear {
                appeared = false
            }
            .onDisappear {
                appeared = true
                
                if !viewModel.glitchRunning {
                    DispatchQueue.main.async {
                        viewModel.glitchRunning = true
                    }
                    glitchTogg()
                }
            }
        }
        .sheet(isPresented: $showPasswordSheet, content: {
            mainPassSheet()
        })
        .sheet(isPresented: $showSettings, content: {
            SettingsSheetView(hideOrderNums: $hideOrderNums)
        })
        .sheet(isPresented: $showProfileManager, content: {
            ProfileManager()
        })
        .sheet(isPresented: $showAccountManager, content: {
            AccountManager(showInstance: (auth.currentUser?.ownedInstances ?? 0) > 0)
        })
        .sheet(isPresented: $showQueueConfig, content: {
            queueConfigView()
        })
        .sheet(isPresented: $showServerSheet, content: {
            serverInfo()
        })
        .sheet(isPresented: $showIMAPSheet, content: {
            imapView()
                .overlay(content: {
                    if showIMAPEdit {
                        TransparentBlurView(removeAllFilters: true).blur(radius: 14, opaque: true)
                            .background(colorScheme == .dark ? .black.opacity(0.7) : .white.opacity(0.7))
                            .ignoresSafeArea()
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.3)){
                                    showIMAPEdit = false
                                }
                            }
                    }
                })
                .overlay {
                    if showIMAPEdit {
                        editImapView().transition(.move(edge: .bottom).combined(with: .scale).combined(with: .opacity))
                    }
                }
        })
        .sheet(isPresented: $showSitePicker, content: {
            SelectSiteSheet(maxSelect: 1) { result in
                if let first = result.first?.1 {
                    newUrl = first
                }
            }
        })
        .alert("Confirm Update. This will restart Wealth AIO.", isPresented: $showUpdateAlert, actions: {
            Button("Update", role: .destructive) {
                ServerSend().updateServer(instance: 1)
                withAnimation(.easeInOut(duration: 0.25)){
                    viewModel.lastServerUpdate = nil
                    viewModel.checkingConnection = nil
                }
            }
            Button("Cancel", role: .cancel) { }
        })
        .alert("To use Wealth Proxies you must authenticate with Discord.", isPresented: $showDiscordAlert, actions: {
            Button("Continue", role: .destructive) {
                showDiscordSheet = true
            }
            Button("Cancel", role: .cancel) { }
        })
        .onChange(of: viewModel.flagMobile) { _, _ in
            auth.currentUser?.connectedMobileIP = UUID().uuidString
            popRoot.presentAlert(image: "exclamationmark.shield.fill", text: "A new mobile device has connected!")
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
        .onChange(of: discordUsername, { _, _ in
            if !discordUsername.isEmpty && !discordUID.isEmpty {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                UserService().updateDiscordInfo(username: discordUsername, discordUid: discordUID)
                withAnimation(.easeInOut(duration: 0.3)){
                    auth.currentUser?.discordUsername = discordUsername
                    auth.currentUser?.discordUID = discordUID
                }
                popRoot.presentAlert(image: "checkmark", text: "Discord Linked!")
                showDiscordSheet = false
                
                Task {
                    checkBandwidth(dUID: discordUID) { details in
                        if let details {
                            DispatchQueue.main.async {
                                popRoot.resisData = details
                            }
                        }
                    }
                }
            }
        })
        .sheet(isPresented: $showDiscordSheet, content: {
            DiscordWebView(username: $discordUsername, id: $discordUID, isLoggedIn: $isLoggedIn)
                .overlay(content: {
                    if isLoggedIn {
                        Color.gray.opacity(0.2).ignoresSafeArea()
                    }
                })
                .overlay {
                    if isLoggedIn {
                        VStack(spacing: 25){
                            Text("Authenticating...").font(.headline)
                            
                            LottieView(loopMode: .loop, name: "aiLoad")
                                .scaleEffect(0.7).frame(width: 100, height: 100)
                        }
                        .padding().background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .transition(.move(edge: .bottom).combined(with: .scale))
                    }
                }
                .overlay(alignment: .top, content: {
                    HStack {
                        Spacer()
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            showDiscordSheet = false
                        } label: {
                            Text("Cancel").font(.subheadline).bold()
                                .padding(.horizontal, 9).padding(.vertical, 5)
                                .background(Color.babyBlue).clipShape(Capsule())
                        }.buttonStyle(.plain).padding(.trailing).frame(height: 60)
                    }.ignoresSafeArea(edges: .top)
                })
        })
    }
    func isOnlineInstance(id: Int) -> Bool {
        if id == 1 {
            return (viewModel.lastServerUpdate != nil && isWithinXmin(from: viewModel.lastServerUpdate ?? Date(), min: 5) && (viewModel.checkingConnection == nil || viewModel.lastServerUpdate ?? Date() > viewModel.checkingConnection ?? Date()))
        }
        
        if id == 2 {
            return (viewModel.lastServer2Update != nil && isWithinXmin(from: viewModel.lastServer2Update ?? Date(), min: 5) && (viewModel.checking2Connection == nil || viewModel.lastServer2Update ?? Date() > viewModel.checking2Connection ?? Date()))
        }
        
        if id == 3 {
            return (viewModel.lastServer3Update != nil && isWithinXmin(from: viewModel.lastServer3Update ?? Date(), min: 5) && (viewModel.checking3Connection == nil || viewModel.lastServer3Update ?? Date() > viewModel.checking3Connection ?? Date()))
        }
        
        if id == 4 {
            return (viewModel.lastServer4Update != nil && isWithinXmin(from: viewModel.lastServer4Update ?? Date(), min: 5) && (viewModel.checking4Connection == nil || viewModel.lastServer4Update ?? Date() > viewModel.checking4Connection ?? Date()))
        }
        
        if id == 5 {
            return (viewModel.lastServer5Update != nil && isWithinXmin(from: viewModel.lastServer5Update ?? Date(), min: 5) && (viewModel.checking5Connection == nil || viewModel.lastServer5Update ?? Date() > viewModel.checking5Connection ?? Date()))
        }
        
        if id == 6 {
            return (viewModel.lastServer6Update != nil && isWithinXmin(from: viewModel.lastServer6Update ?? Date(), min: 5) && (viewModel.checking6Connection == nil || viewModel.lastServer6Update ?? Date() > viewModel.checking6Connection ?? Date()))
        }
        
        return false
    }
    func updateStatus() {
        let instanceCount = auth.currentUser?.ownedInstances ?? 0
        
        if viewModel.lastServerUpdate == nil || isAtLeastOneMinuteOld(from: viewModel.lastServerUpdate ?? Date()) {
            let sessionId = UUID().uuidString
            viewModel.checkingConnectionIds[sessionId] = Date()
            ServerSend().checkServerOnline(id: sessionId, instance: 1)
            withAnimation(.easeInOut(duration: 0.3)){
                viewModel.checkingConnection = Date()
            }
        }
        
        if instanceCount > 0 {
            if viewModel.lastServer2Update == nil || isAtLeastOneMinuteOld(from: viewModel.lastServer2Update ?? Date()) {
                let sessionId = UUID().uuidString
                viewModel.checking2ConnectionIds[sessionId] = Date()
                ServerSend().checkServerOnline(id: sessionId, instance: 2)
                withAnimation(.easeInOut(duration: 0.3)){
                    viewModel.checking2Connection = Date()
                }
            }
        }
        
        if instanceCount > 1 {
            if viewModel.lastServer3Update == nil || isAtLeastOneMinuteOld(from: viewModel.lastServer3Update ?? Date()) {
                let sessionId = UUID().uuidString
                viewModel.checking3ConnectionIds[sessionId] = Date()
                ServerSend().checkServerOnline(id: sessionId, instance: 3)
                withAnimation(.easeInOut(duration: 0.3)){
                    viewModel.checking3Connection = Date()
                }
            }
        }
        
        if instanceCount > 2 {
            if viewModel.lastServer4Update == nil || isAtLeastOneMinuteOld(from: viewModel.lastServer4Update ?? Date()) {
                let sessionId = UUID().uuidString
                viewModel.checking4ConnectionIds[sessionId] = Date()
                ServerSend().checkServerOnline(id: sessionId, instance: 4)
                withAnimation(.easeInOut(duration: 0.3)){
                    viewModel.checking4Connection = Date()
                }
            }
        }
        
        if instanceCount > 3 {
            if viewModel.lastServer5Update == nil || isAtLeastOneMinuteOld(from: viewModel.lastServer5Update ?? Date()) {
                let sessionId = UUID().uuidString
                viewModel.checking5ConnectionIds[sessionId] = Date()
                ServerSend().checkServerOnline(id: sessionId, instance: 5)
                withAnimation(.easeInOut(duration: 0.3)){
                    viewModel.checking5Connection = Date()
                }
            }
        }
        
        if instanceCount > 4 {
            if viewModel.lastServer6Update == nil || isAtLeastOneMinuteOld(from: viewModel.lastServer6Update ?? Date()) {
                let sessionId = UUID().uuidString
                viewModel.checking6ConnectionIds[sessionId] = Date()
                ServerSend().checkServerOnline(id: sessionId, instance: 6)
                withAnimation(.easeInOut(duration: 0.3)){
                    viewModel.checking6Connection = Date()
                }
            }
        }
    }
    @ViewBuilder
    func createPicker() -> some View {
        VStack(spacing: 6){
            HStack {
                Text("Create Group").font(.title3).fontWeight(.heavy)
                Spacer()
                Button {
                    showCreateInstance = false
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    Text("Cancel")
                        .font(.subheadline)
                        .padding(.horizontal, 11).padding(.vertical, 4)
                        .background(content: {
                            TransparentBlurView(removeAllFilters: true)
                                .blur(radius: 14, opaque: true)
                                .background(colorScheme == .dark ? .black.opacity(0.4) : .white.opacity(0.4))
                        })
                        .clipShape(Capsule())
                        .shadow(color: .gray, radius: 2)
                }.buttonStyle(.plain)
            }.padding(.top, 15).padding(.bottom, 15)
            
            HStack {
                VStack(alignment: .leading, spacing: 5){
                    if let instance = viewModel.instances?.first(where: { $0.instanceId == 1 }) {
                        HStack {
                            Text(instance.nickName).font(.headline).fontWeight(.heavy).foregroundStyle(.blue)
                            Spacer()
                            Text(instance.ip).font(.subheadline).foregroundStyle(.gray)
                        }
                        Text("Instance 1").font(.subheadline)
                    } else {
                        Text("Instance 1").font(.headline).fontWeight(.heavy).foregroundStyle(.blue)
                        
                        Text("Server offline").font(.subheadline)
                    }
                }
                Spacer()
                ZStack(alignment: .trailing){
                    Rectangle()
                        .foregroundStyle(.gray).opacity(0.001)
                        .frame(width: 30, height: 50)
 
                    if createInstanceIndices.contains(1) {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable().scaledToFill().frame(width: 21, height: 21)
                            .foregroundStyle(Color.babyBlue)
                    } else {
                        Circle()
                            .stroke(Color.babyBlue, lineWidth: 2)
                            .frame(width: 20, height: 20)
                    }
                }.scaleEffect(1.25)
            }
            .padding(10)
            .background(Color.gray.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .onTapGesture {
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                if createInstanceIndices.contains(1) {
                    createInstanceIndices.removeAll(where: { $0 == 1 })
                } else {
                    createInstanceIndices.append(1)
                }
            }
            
            ForEach(0..<(auth.currentUser?.ownedInstances ?? 0), id: \.self) { index in
                
                let instanceId = index + 2
                
                HStack {
                    VStack(alignment: .leading, spacing: 5){
                        if let instance = viewModel.instances?.first(where: { $0.instanceId == instanceId }) {
                            HStack {
                                Text(instance.nickName).font(.headline).fontWeight(.heavy).foregroundStyle(.blue)
                                Spacer()
                                Text(instance.ip).font(.subheadline).foregroundStyle(.gray)
                            }
                            Text("Instance \(instanceId)").font(.subheadline)
                        } else {
                            Text("Instance \(instanceId)").font(.headline).fontWeight(.heavy).foregroundStyle(.blue)
                            
                            Text("Server offline").font(.subheadline)
                        }
                    }
                    Spacer()
                    ZStack(alignment: .trailing){
                        Rectangle()
                            .foregroundStyle(.gray).opacity(0.001)
                            .frame(width: 30, height: 50)
     
                        if createInstanceIndices.contains(instanceId) {
                            Image(systemName: "checkmark.circle.fill")
                                .resizable().scaledToFill().frame(width: 21, height: 21)
                                .foregroundStyle(Color.babyBlue)
                        } else {
                            Circle()
                                .stroke(Color.babyBlue, lineWidth: 2)
                                .frame(width: 20, height: 20)
                        }
                    }.scaleEffect(1.25)
                }
                .padding(10)
                .background(Color.gray.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .onTapGesture {
                    UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                    if createInstanceIndices.contains(instanceId) {
                        createInstanceIndices.removeAll(where: { $0 == instanceId })
                    } else {
                        createInstanceIndices.append(instanceId)
                    }
                }
            }
            
            Spacer()
            
            Button {
                if !createInstanceIndices.isEmpty {
                    showCreateInstance = false
                    
                    createInstanceIndices.forEach { index in
                        TaskService().newRequest(type: "\(index)createTask", data: createInstanceData)
                    }
                    
                    if createInstanceIndices.count > 1 {
                        popRoot.presentAlert(image: "exclamationmark.shield", text: "Manual fixes may be needed if instances lack shared files")
                    } else {
                        popRoot.presentAlert(image: "checkmark", text: "Request sent please wait")
                    }
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 12).foregroundStyle(Color.babyBlue).frame(height: 45)
                    Text(!createInstanceIndices.isEmpty ? "Create" : "Select")
                        .font(.headline).bold()
                }
            }.buttonStyle(.plain).padding(.horizontal).padding(.bottom, 30)
        }
        .padding(.horizontal, 14)
        .background(content: { backColor() })
        .presentationDetents([.fraction(0.75)])
        .presentationCornerRadius(30).presentationDragIndicator(.visible)
        .ignoresSafeArea()
    }
    @ViewBuilder
    func editImapView() -> some View {
        VStack(spacing: 6){
            HStack {
                Text("Email").font(.subheadline).foregroundStyle(.green)
                Spacer()
            }
            TextField("", text: $newImapEmail)
                .lineLimit(1)
                .frame(height: 57)
                .padding(.top, 8).padding(.trailing, 30)
                .overlay(alignment: .leading, content: {
                    Text("IMAP Email").font(.system(size: 18)).fontWeight(.light)
                        .lineLimit(1).minimumScaleFactor(0.8)
                        .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
                        .opacity(0.7)
                        .offset(y: -21.0)
                        .scaleEffect(0.8, anchor: .leading)
                })
                .padding(.horizontal)
                .background {
                    TransparentBlurView(removeAllFilters: true)
                        .blur(radius: 10, opaque: true)
                        .background(colorScheme == .dark ? .black.opacity(0.5) : .white.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .overlay(content: {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: 1)
                        .opacity(0.5)
                })
                .overlay(alignment: .trailing) {
                    if !newImapEmail.isEmpty {
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            newImapEmail = ""
                        } label: {
                            ZStack {
                                Rectangle().frame(width: 35, height: 45).foregroundStyle(.gray).opacity(0.001)
                                Image(systemName: "xmark")
                            }
                        }.padding(.trailing, 5)
                    }
                }
            
            HStack {
                Text("Password").font(.subheadline).foregroundStyle(.red)
                Spacer()
            }.padding(.top, 10)
            TextField("", text: $newImapPass)
                .lineLimit(1)
                .frame(height: 57)
                .padding(.top, 8).padding(.trailing, 30)
                .overlay(alignment: .leading, content: {
                    Text("IMAP Password").font(.system(size: 18)).fontWeight(.light)
                        .lineLimit(1).minimumScaleFactor(0.8)
                        .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
                        .opacity(0.7)
                        .offset(y: -21.0)
                        .scaleEffect(0.8, anchor: .leading)
                })
                .padding(.horizontal)
                .background {
                    TransparentBlurView(removeAllFilters: true)
                        .blur(radius: 10, opaque: true)
                        .background(colorScheme == .dark ? .black.opacity(0.5) : .white.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .overlay(content: {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: 1)
                        .opacity(0.5)
                })
                .overlay(alignment: .trailing) {
                    if !newImapPass.isEmpty {
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            newImapPass = ""
                        } label: {
                            ZStack {
                                Rectangle().frame(width: 35, height: 45).foregroundStyle(.gray).opacity(0.001)
                                Image(systemName: "xmark")
                            }
                        }.padding(.trailing, 5)
                    }
                }
                  
            let current = getImapForIndex(index: imapEditing)
            let status = (newImapEmail != (current?.0 ?? "") && !newImapEmail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) || (newImapPass != (current?.1 ?? "") && !newImapPass.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            
            Button {
                if status {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    popRoot.presentAlert(image: "checkmark", text: "IMAP credentials updated!")
                    withAnimation(.easeInOut(duration: 0.25)){
                        showIMAPEdit = false
                    }
                    
                    let newInfo = newImapEmail + "," + newImapPass
                    
                    let field = imapEditing == 1 ? "one" : imapEditing == 2 ? "two" : imapEditing == 3 ? "three" : imapEditing == 4 ? "four" : imapEditing == 5 ? "five" : "six"
                    
                    TaskService().updateEvent(docId: "IMAP", updates: [field : newInfo])
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 12).frame(height: 40).foregroundStyle(Color.babyBlue)
                        .shadow(color: .gray, radius: 3)
                    Text(status ? "Save" : "Edit IMAP").font(.subheadline).bold()
                }
            }.buttonStyle(.plain).padding(.top, 10)
        }
        .padding(12)
        .background { backColor() }
        .clipShape(RoundedRectangle(cornerRadius: 12.0))
        .overlay(content: {
            RoundedRectangle(cornerRadius: 12.0).stroke(Color.gray, lineWidth: 1)
        })
        .padding(.horizontal, 12)
    }
    @ViewBuilder
    func imapView() -> some View {
        VStack(spacing: 20){
            ZStack {
                Text("IMAP").font(.title).bold()
                
                HStack {
                    Spacer()
                    Button {
                        showIMAPSheet = false
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.subheadline)
                            .padding(12)
                            .background(content: {
                                TransparentBlurView(removeAllFilters: true)
                                    .blur(radius: 14, opaque: true)
                                    .background(colorScheme == .dark ? .black.opacity(0.4) : .white.opacity(0.4))
                            })
                            .clipShape(Circle())
                            .shadow(color: .gray, radius: 2)
                    }.buttonStyle(.plain)
                }.padding(.trailing, 14)
            }.padding(.top, 20)
                        
            ScrollView {
                LazyVStack {
                    VStack {
                        HStack {
                            Text("Instance 1").font(.title3).bold()
                            
                            Spacer()
                                                            
                            Button {
                                imapEditing = 1
                                if let credentials = getImapForIndex(index: 1) {
                                    newImapEmail = credentials.0
                                    newImapPass = credentials.1
                                }
                                withAnimation(.easeInOut(duration: 0.3)){
                                    showIMAPEdit = true
                                }
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            } label: {
                                Text("Edit")
                                    .font(.subheadline)
                                    .padding(.horizontal, 11)
                                    .padding(.vertical, 4)
                                    .background(content: {
                                        TransparentBlurView(removeAllFilters: true)
                                            .blur(radius: 14, opaque: true)
                                            .background(colorScheme == .dark ? .black.opacity(0.4) : .white.opacity(0.4))
                                    })
                                    .clipShape(Capsule())
                                    .shadow(color: .gray, radius: 2)
                            }.buttonStyle(.plain)
                        }
                        
                        if let credentials = getImapForIndex(index: 1) {
                            VStack {
                                HStack(spacing: 2){
                                    Text("Email:").bold().foregroundStyle(.gray)
                                    Text(credentials.0)
                                    Spacer()
                                    Button {
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        UIPasteboard.general.string = credentials.0
                                    } label: {
                                        Image(systemName: "link").font(.body)
                                    }
                                }.font(.subheadline).lineLimit(1)
                                HStack(spacing: 2){
                                    Text("Password:").bold().foregroundStyle(.gray)
                                    Text(credentials.1)
                                    Spacer()
                                    Button {
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        UIPasteboard.general.string = credentials.1
                                    } label: {
                                        Image(systemName: "link").font(.body)
                                    }
                                }.font(.subheadline).lineLimit(1)
                            }
                            .padding(10)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .contentShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            HStack {
                                Spacer()
                                
                                Text("This file is empty")
                                    .padding(.vertical).foregroundStyle(.gray).bold()
                                
                                Spacer()
                            }
                            .padding(10).padding(.horizontal)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .contentShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(13)
                    .background(content: {
                        TransparentBlurView(removeAllFilters: true)
                            .blur(radius: 14, opaque: true)
                            .background(colorScheme == .dark ? .black.opacity(0.4) : .white.opacity(0.4))
                    })
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .contentShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(content: {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.blue, lineWidth: 1).opacity(0.4)
                    })
                    .padding(.horizontal, 12)
                    
                    ForEach(0..<(auth.currentUser?.ownedInstances ?? 0), id: \.self) { indice in
                        
                        VStack {
                            HStack {
                                Text("Instance \(indice + 2)").font(.title3).bold()
                                
                                Spacer()
                                                                
                                Button {
                                    imapEditing = indice + 2
                                    if let credentials = getImapForIndex(index: indice + 2) {
                                        newImapEmail = credentials.0
                                        newImapPass = credentials.1
                                    }
                                    withAnimation(.easeInOut(duration: 0.3)){
                                        showIMAPEdit = true
                                    }
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                } label: {
                                    Text("Edit")
                                        .font(.subheadline)
                                        .padding(.horizontal, 11)
                                        .padding(.vertical, 4)
                                        .background(content: {
                                            TransparentBlurView(removeAllFilters: true)
                                                .blur(radius: 14, opaque: true)
                                                .background(colorScheme == .dark ? .black.opacity(0.4) : .white.opacity(0.4))
                                        })
                                        .clipShape(Capsule())
                                        .shadow(color: .gray, radius: 2)
                                }.buttonStyle(.plain)
                            }
                            
                            if let credentials = getImapForIndex(index: indice + 2) {
                                VStack {
                                    HStack(spacing: 2){
                                        Text("Email:").bold().foregroundStyle(.gray)
                                        Text(credentials.0)
                                        Spacer()
                                        Button {
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                            UIPasteboard.general.string = credentials.0
                                        } label: {
                                            Image(systemName: "link").font(.body)
                                        }
                                    }.font(.subheadline).lineLimit(1)
                                    HStack(spacing: 2){
                                        Text("Password:").bold().foregroundStyle(.gray)
                                        Text(credentials.1)
                                        Spacer()
                                        Button {
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                            UIPasteboard.general.string = credentials.1
                                        } label: {
                                            Image(systemName: "link").font(.body)
                                        }
                                    }.font(.subheadline).lineLimit(1)
                                }
                                .padding(10)
                                .background(Color.gray.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .contentShape(RoundedRectangle(cornerRadius: 12))
                            } else {
                                HStack {
                                    Spacer()
                                    
                                    Text("This file is empty")
                                        .padding(.vertical).foregroundStyle(.gray).bold()
                                    
                                    Spacer()
                                }
                                .padding(10).padding(.horizontal)
                                .background(Color.gray.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .contentShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .padding(13)
                        .background(content: {
                            TransparentBlurView(removeAllFilters: true)
                                .blur(radius: 14, opaque: true)
                                .background(colorScheme == .dark ? .black.opacity(0.4) : .white.opacity(0.4))
                        })
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .contentShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(content: {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.blue, lineWidth: 1).opacity(0.4)
                        })
                        .padding(.horizontal, 12)
                    }
                }.padding(.vertical, 2)
            }
            .scrollIndicators(.hidden)
        }
        .background(content: { backColor() })
        .presentationDetents([.large])
        .presentationCornerRadius(30).presentationDragIndicator(.visible)
        .ignoresSafeArea()
    }
    func getImapForIndex(index: Int) -> (String, String)? {
        if let imap = viewModel.imap {
            if index == 1 {
                if let item = imap.one {
                    let parts = item.split(separator: ",")
                    if parts.count == 2 {
                        return (String(parts[0]), String(parts[1]))
                    }
                }
                return nil
            } else if index == 2 {
                if let item = imap.two {
                    let parts = item.split(separator: ",")
                    if parts.count == 2 {
                        return (String(parts[0]), String(parts[1]))
                    }
                }
                return nil
            } else if index == 3 {
                if let item = imap.three {
                    let parts = item.split(separator: ",")
                    if parts.count == 2 {
                        return (String(parts[0]), String(parts[1]))
                    }
                }
                return nil
            } else if index == 4 {
                if let item = imap.four {
                    let parts = item.split(separator: ",")
                    if parts.count == 2 {
                        return (String(parts[0]), String(parts[1]))
                    }
                }
                return nil
            } else if index == 5 {
                if let item = imap.five {
                    let parts = item.split(separator: ",")
                    if parts.count == 2 {
                        return (String(parts[0]), String(parts[1]))
                    }
                }
                return nil
            } else {
                if let item = imap.six {
                    let parts = item.split(separator: ",")
                    if parts.count == 2 {
                        return (String(parts[0]), String(parts[1]))
                    }
                }
                return nil
            }
        }
        return nil
    }
    @ViewBuilder
    func queueConfigView() -> some View {
        VStack(spacing: 20){
            ZStack {
                Text("Queue Refresh").font(.title).bold()
                
                HStack {
                    Spacer()
                    Button {
                        showQueueConfig = false
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.subheadline)
                            .padding(12)
                            .background(content: {
                                TransparentBlurView(removeAllFilters: true)
                                    .blur(radius: 14, opaque: true)
                                    .background(colorScheme == .dark ? .black.opacity(0.4) : .white.opacity(0.4))
                            })
                            .clipShape(Circle())
                            .shadow(color: .gray, radius: 2)
                    }.buttonStyle(.plain)
                }.padding(.trailing, 14)
            }.padding(.top, 20)
            
            HStack {
                VStack(alignment: .leading, spacing: 5){
                    Text("Slow").font(.headline).fontWeight(.heavy).foregroundStyle(.blue)
                    Text("Local host (not recommended)").font(.subheadline)
                }
                
                Spacer()
                
                ZStack(alignment: .trailing){
                    Rectangle()
                        .foregroundStyle(.gray).opacity(0.001)
                        .frame(width: 30, height: 50)
                    
                    if viewModel.queueSpeed == 1 {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable().scaledToFill().frame(width: 21, height: 21)
                            .foregroundStyle(Color.babyBlue)
                    } else {
                        Circle()
                            .stroke(Color.babyBlue, lineWidth: 2)
                            .frame(width: 20, height: 20)
                    }
                }.scaleEffect(1.25)
            }
            .padding(10)
            .background(Color.gray.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .onTapGesture {
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                viewModel.queueSpeed = 1
                showQueueConfig = false
            }
            .padding(.horizontal, 14)
            
            HStack {
                VStack(alignment: .leading, spacing: 2){
                    Text("Normal").font(.headline).fontWeight(.heavy).foregroundStyle(.blue)
                    Text("- Uses Wealth Proxies!").font(.subheadline).padding(.top, 3)
                    Text("- Quick refresh (recommended)").font(.subheadline).padding(.top, 3)
                }
                
                Spacer()
                
                ZStack(alignment: .trailing){
                    Rectangle()
                        .foregroundStyle(.gray).opacity(0.001)
                        .frame(width: 30, height: 50)
                    
                    if viewModel.queueSpeed == 2 {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable().scaledToFill().frame(width: 21, height: 21)
                            .foregroundStyle(Color.babyBlue)
                    } else {
                        Circle()
                            .stroke(Color.babyBlue, lineWidth: 2)
                            .frame(width: 20, height: 20)
                    }
                }.scaleEffect(1.25)
            }
            .padding(10)
            .background(Color.gray.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .onTapGesture {
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                if (auth.currentUser?.discordUID ?? "").isEmpty {
                    showQueueConfig = false
                    showDiscordAlert = true
                } else {
                    viewModel.queueSpeed = 2
                    showQueueConfig = false
                }
            }
            .padding(.horizontal, 14)
            
            HStack {
                VStack(alignment: .leading, spacing: 2){
                    Text("Fast").font(.headline).fontWeight(.heavy).foregroundStyle(.blue)
                    Text("- Uses Wealth Proxies!").font(.subheadline).padding(.top, 3)
                    Text("- Fast refresh").font(.subheadline).padding(.top, 3)
                }
                
                Spacer()
                
                ZStack(alignment: .trailing){
                    Rectangle()
                        .foregroundStyle(.gray).opacity(0.001)
                        .frame(width: 30, height: 50)
                    
                    if viewModel.queueSpeed == 3 {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable().scaledToFill().frame(width: 21, height: 21)
                            .foregroundStyle(Color.babyBlue)
                    } else {
                        Circle()
                            .stroke(Color.babyBlue, lineWidth: 2)
                            .frame(width: 20, height: 20)
                    }
                }.scaleEffect(1.25)
            }
            .padding(10)
            .background(Color.gray.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .onTapGesture {
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                if (auth.currentUser?.discordUID ?? "").isEmpty {
                    showQueueConfig = false
                    showDiscordAlert = true
                } else {
                    viewModel.queueSpeed = 3
                    showQueueConfig = false
                }
            }
            .padding(.horizontal, 14)
            
            Spacer()
        }
        .background(content: { backColor() })
        .presentationDetents([.medium])
        .presentationCornerRadius(30).presentationDragIndicator(.visible)
        .ignoresSafeArea()
    }
    @ViewBuilder
    func serverInfo() -> some View {
        VStack {
            ZStack {
                Text("Server Info").font(.title).bold()
                
                HStack {
                    Image("Proxies")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 41, height: 41)
                        .clipShape(Circle()).contentShape(Circle())
                        .shadow(color: .gray, radius: 3)
                        .onTapGesture {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            if let url = URL(string: "https://discord.gg/wealthproxies") {
                                
                                DispatchQueue.main.async {
                                    UIApplication.shared.open(url)
                                }
                            }
                        }
                    Spacer()
                    Button {
                        showServerSheet = false
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.subheadline)
                            .padding(12)
                            .background(content: {
                                TransparentBlurView(removeAllFilters: true)
                                    .blur(radius: 14, opaque: true)
                                    .background(colorScheme == .dark ? .black.opacity(0.4) : .white.opacity(0.4))
                            })
                            .clipShape(Circle())
                            .shadow(color: .gray, radius: 2)
                    }.buttonStyle(.plain)
                }.padding(.trailing, 14).padding(.leading, 14)
            }.padding(.top, 20)
            
            Text("Recommended Wealth AIO Config").font(.subheadline).foregroundStyle(.gray)
            
            VStack(spacing: 25){
                HStack {
                    Text("Virtual 16 Core 16 RAM").fontWeight(.light)
                    Spacer()
                    Text("~2500 Tasks").fontWeight(.heavy)
                }
                
                HStack {
                    Text("Virtual 32 Core 32 RAM").fontWeight(.light)
                    Spacer()
                    Text("~5500 Tasks").fontWeight(.heavy)
                }
                
                HStack {
                    Text("Virtual 64 Core 64 RAM").fontWeight(.light)
                    Spacer()
                    Text("~15,000 Tasks").fontWeight(.heavy)
                }
                
                HStack {
                    Text("Baremetal 12 Core 24 RAM").fontWeight(.light)
                    Spacer()
                    Text("~7500 Tasks").fontWeight(.heavy)
                }
                
                HStack {
                    Text("Baremetal 24 Core 64 RAM").fontWeight(.light).lineLimit(1).minimumScaleFactor(0.9)
                    Spacer()
                    Text("~20,000 Tasks").fontWeight(.heavy)
                }
            }
            .padding(10)
            .background(Color.gray.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .padding(.horizontal, 12).padding(.top, 25)
            
            Spacer()
        }
        .presentationDetents([.medium])
        .presentationCornerRadius(30).presentationDragIndicator(.visible)
        .ignoresSafeArea()
    }
    @ViewBuilder
    func headerStats(user: User) -> some View {
        HStack(spacing: 6){
            VStack {
                HStack(spacing: 2){
                    Image("capsolver")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 25, height: 25)
                        .clipShape(Circle()).contentShape(Circle())
                        .shadow(radius: 3)
                    Text("CapSolver").font(.body).bold().lineLimit(1).minimumScaleFactor(0.8)
                }
                
                Spacer()
                
                if viewModel.capsolver == "" {
                    Text("Setup Now").font(.body)
                } else {
                    VStack(spacing: 2){
                        
                        if let balance = viewModel.capSolverBalance {
                            
                            let color = balance > 1.0 ? Color.green : Color.red
                            
                            Text(String(format: "$%.2f", balance))
                                .font(.title3).fontWeight(.bold).foregroundStyle(color)
                            
                        } else {
                            Text("$ --").font(.title3).fontWeight(.bold)
                        }
                        
                        Text("Balance").font(.subheadline).fontWeight(.light).foregroundStyle(.gray)
                    }
                }
            }
            .padding(6).frame(height: 90)
            .background(Color.green.opacity(0.15))
            .overlay {
                RoundedRectangle(cornerRadius: 12).stroke(.green, lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .onTapGesture {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                capKey = viewModel.capsolver
                withAnimation(.easeInOut(duration: 0.3)){
                    showCapSolver = true
                }
            }
            
            if let uid = auth.currentUser?.discordUID, let username = auth.currentUser?.discordUsername, !uid.isEmpty && !username.isEmpty {
                Menu {
                    Button {
                        if let url = URL(string: "https://discord.gg/wealthproxies") {
                            
                            DispatchQueue.main.async {
                                UIApplication.shared.open(url)
                            }
                        }
                    } label: {
                        Label("Visit Wealth Proxies", systemImage: "square.and.arrow.up")
                    }

                    NavigationLink {
                        ProxyManager(openGen: true, instances: viewModel.instances)
                            .navigationTransition(.zoom(sourceID: "mainMenuProxy", in: hero))
                    } label: {
                        Label("Gen Proxies", systemImage: "hammer.fill")
                    }.matchedTransitionSource(id: "mainMenuProxy", in: hero)

                    Button {
                        fetchPurchaseLink(dUID: uid, dUsername: username) { urlStr in
                            if let urlStr, let url = URL(string: urlStr) {
                                DispatchQueue.main.async {
                                    UIApplication.shared.open(url)
                                }
                            } else {
                                popRoot.presentAlert(image: "exclamationmark.shield",
                                                     text: "Failed to create buy link.")
                            }
                        }
                    } label: {
                        Label("Buy data", systemImage: "dollarsign")
                    }
                    
                    Button {
                        updateStats()
                    } label: {
                        Label("Refresh", systemImage: "arrow.counterclockwise")
                    }
                } label: {
                    resiView()
                }.buttonStyle(.plain)
            } else {
                resiView()
                    .onTapGesture {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        showDiscordAlert = true
                    }
            }
  
            VStack(alignment: .leading){
                HStack(spacing: 2){
                    Image("builder")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 25, height: 25)
                        .clipShape(Circle()).contentShape(Circle())
                        .shadow(radius: 3)
                    Text("Server").font(.body).bold()
                }
                
                Spacer()
                
                if auth.currentUser?.serverCPU == nil {
                    Text("Get a server").font(.body)
                } else {
                    HStack(spacing: 4){
                        Text(auth.currentUser?.serverCPU ?? "---").font(.subheadline).fontWeight(.heavy)
                        
                        Text("Cores").font(.subheadline).fontWeight(.light).foregroundStyle(.gray)
                    }

                    HStack(spacing: 4){
                        Text(auth.currentUser?.serverRAM ?? "---").font(.subheadline).fontWeight(.heavy)
                        
                        Text("GB RAM").font(.subheadline).fontWeight(.light).foregroundStyle(.gray)
                    }
                }
            }
            .padding(6).frame(height: 90)
            .background(Color.orange.opacity(0.15))
            .overlay {
                RoundedRectangle(cornerRadius: 12).stroke(.orange, lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .onTapGesture {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                if auth.currentUser?.serverCPU == nil {
                    if let url = URL(string: "https://discord.gg/wealthproxies") {
                        DispatchQueue.main.async {
                            UIApplication.shared.open(url)
                        }
                    }
                } else {
                    showServerSheet = true
                }
            }
        }.padding(.top, 5).padding(.horizontal, 12)
    }
    @ViewBuilder
    func resiView() -> some View {
        VStack(alignment: .leading){
            HStack(spacing: 2){
                Image("Proxies")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 25, height: 25)
                    .clipShape(Circle()).contentShape(Circle())
                    .shadow(color: .gray, radius: 2)
                Text("Proxies").font(.body).bold()
                Spacer()
            }
            
            Spacer()
            
            if auth.currentUser?.discordUID == nil {
                Text("Link Discord").font(.body)
            } else {
                HStack(spacing: 4){
                    Text(popRoot.resisData?.trafficBalanceString ?? "---").font(.subheadline).fontWeight(.heavy)
                    
                    Text("Left").font(.subheadline).fontWeight(.light).foregroundStyle(.gray)
                }.lineLimit(1).minimumScaleFactor(0.8)
                
                HStack(spacing: 4){
                    Text(popRoot.resisData?.trafficConsumed ?? "---").font(.subheadline).fontWeight(.heavy)
                    
                    Text("Used").font(.subheadline).fontWeight(.light).foregroundStyle(.gray)
                }.lineLimit(1).minimumScaleFactor(0.8)
            }
        }
        .padding(6).frame(height: 90)
        .background(Color.blue.opacity(0.15))
        .overlay {
            RoundedRectangle(cornerRadius: 12).stroke(.blue, lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    func getResiLogin() {
        if let dUID = auth.currentUser?.discordUID, popRoot.userResiPassword == nil {
            fetchUserCredentials(dUID: dUID) { username, password in
                if let username, let password {
                    DispatchQueue.main.async {
                        popRoot.userResiLogin = username
                        popRoot.userResiPassword = password
                    }
                }
            }
        }
    }
    func updateStats() {
        if viewModel.lastUpdatedStats == nil || !isWithinXsec(from: viewModel.lastUpdatedStats ?? Date(), sec: 5) {
            DispatchQueue.main.async {
                viewModel.lastUpdatedStats = Date()
            }
            
            if viewModel.capsolver != "" {
                Task {
                    getCapSolverBalance(apiKey: viewModel.capsolver) { balance in
                        if let balance {
                            DispatchQueue.main.async {
                                viewModel.capSolverBalance = balance
                            }
                        }
                    }
                }
            }
            
            if let discordUID = auth.currentUser?.discordUID {
                Task {
                    checkBandwidth(dUID: discordUID) { details in
                        if let details {
                            DispatchQueue.main.async {
                                popRoot.resisData = details
                            }
                        }
                    }
                }
            }
        }
    }
    @ViewBuilder
    func CapSolverView() -> some View {
        VStack(spacing: 20){
            Text("CapSolver Key").font(.title3).bold()
            
            TextField("", text: $capKey)
                .lineLimit(1)
                .focused($isEditingCap)
                .frame(height: 57)
                .padding(.top, 8)
                .overlay(alignment: .leading, content: {
                    Text("Key").font(.system(size: 18)).fontWeight(.light)
                        .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
                        .opacity(isEditingCap ? 0.8 : 0.5)
                        .offset(y: capKey.isEmpty && !isEditingCap ? 0.0 : -21.0)
                        .scaleEffect(capKey.isEmpty && !isEditingCap ? 1.0 : 0.8, anchor: .leading)
                        .animation(.easeInOut(duration: 0.2), value: isEditingCap)
                        .onTapGesture {
                            isEditingCap = true
                        }
                })
                .padding(.horizontal)
                .background {
                    TransparentBlurView(removeAllFilters: true)
                        .blur(radius: 10, opaque: true)
                        .background(colorScheme == .dark ? .black.opacity(0.5) : .white.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .overlay(content: {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(colorScheme == .dark ? Color.white : Color.black ,lineWidth: 1)
                        .opacity(isEditingCap ? 0.8 : 0.5)
                })
                        
            let status = (capKey != viewModel.capsolver && !capKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            
            Button {
                if status {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    popRoot.presentAlert(image: "checkmark", text: "Key synced with Wealth AIO")
                    withAnimation(.easeInOut(duration: 0.25)){
                        showCapSolver = false
                    }
                    viewModel.capsolver = capKey
                    TaskService().updateCapSolver(capsolver: capKey)
                    
                    Task {
                        getCapSolverBalance(apiKey: capKey) { balance in
                            if let balance {
                                DispatchQueue.main.async {
                                    viewModel.capSolverBalance = balance
                                }
                            }
                        }
                    }
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 12).frame(height: 40).foregroundStyle(Color.babyBlue)
                        .shadow(color: .gray, radius: 3)
                    Text(status ? "Save" : "Edit Key").font(.subheadline).bold()
                }
            }.buttonStyle(.plain)
        }
        .padding(12)
        .background { backColor() }
        .clipShape(RoundedRectangle(cornerRadius: 12.0))
        .overlay(content: {
            RoundedRectangle(cornerRadius: 12.0).stroke(Color.gray, lineWidth: 1)
        })
        .padding(.horizontal, 12)
        .offset(y: -80)
    }
    @ViewBuilder
    func webHooksView() -> some View {
        VStack(spacing: 6){
            Text("Webhooks").font(.title3).bold().padding(.bottom, 10)
            
            HStack {
                Text("Success").font(.subheadline).foregroundStyle(.green)
                Spacer()
            }
            TextField("", text: $successHook)
                .lineLimit(1)
                .focused($isEditingSuccess)
                .frame(height: 57)
                .padding(.top, 8)
                .overlay(alignment: .leading, content: {
                    Text("Webhook URL").font(.system(size: 18)).fontWeight(.light)
                        .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
                        .opacity(isEditingSuccess ? 0.8 : 0.5)
                        .offset(y: successHook.isEmpty && !isEditingSuccess ? 0.0 : -21.0)
                        .scaleEffect(successHook.isEmpty && !isEditingSuccess ? 1.0 : 0.8, anchor: .leading)
                        .animation(.easeInOut(duration: 0.2), value: isEditingSuccess)
                        .onTapGesture {
                            isEditingSuccess = true
                        }
                })
                .padding(.horizontal)
                .background {
                    TransparentBlurView(removeAllFilters: true)
                        .blur(radius: 10, opaque: true)
                        .background(colorScheme == .dark ? .black.opacity(0.5) : .white.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .overlay(content: {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(colorScheme == .dark ? Color.white : Color.black ,lineWidth: 1)
                        .opacity(isEditingSuccess ? 0.8 : 0.5)
                })
            
            HStack {
                Text("Failure").font(.subheadline).foregroundStyle(.red)
                Spacer()
            }.padding(.top, 10)
            TextField("", text: $failureHook)
                .lineLimit(1)
                .focused($isEditingFailure)
                .frame(height: 57)
                .padding(.top, 8)
                .overlay(alignment: .leading, content: {
                    Text("Webhook URL").font(.system(size: 18)).fontWeight(.light)
                        .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
                        .opacity(isEditingFailure ? 0.8 : 0.5)
                        .offset(y: failureHook.isEmpty && !isEditingFailure ? 0.0 : -21.0)
                        .scaleEffect(failureHook.isEmpty && !isEditingFailure ? 1.0 : 0.8, anchor: .leading)
                        .animation(.easeInOut(duration: 0.2), value: isEditingFailure)
                        .onTapGesture {
                            isEditingFailure = true
                        }
                })
                .padding(.horizontal)
                .background {
                    TransparentBlurView(removeAllFilters: true)
                        .blur(radius: 10, opaque: true)
                        .background(colorScheme == .dark ? .black.opacity(0.5) : .white.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .overlay(content: {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(colorScheme == .dark ? Color.white : Color.black ,lineWidth: 1)
                        .opacity(isEditingFailure ? 0.8 : 0.5)
                })
                        
            let status = (successHook != viewModel.success && !successHook.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) || (failureHook != viewModel.failure && !failureHook.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            
            Button {
                if status {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    popRoot.presentAlert(image: "checkmark", text: "Webhooks synced with Wealth AIO")
                    withAnimation(.easeInOut(duration: 0.25)){
                        showWebhooks = false
                    }
                    if (successHook != viewModel.success) && (failureHook != viewModel.failure) {
                        TaskService().updateWebHooks(success: successHook, failure: failureHook)
                        viewModel.success = successHook
                        viewModel.failure = failureHook
                    } else if successHook != viewModel.success {
                        TaskService().updateWebHook(field: "success", newValue: successHook)
                        viewModel.success = successHook
                    } else {
                        TaskService().updateWebHook(field: "failure", newValue: failureHook)
                        viewModel.failure = failureHook
                    }
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 12).frame(height: 40).foregroundStyle(Color.babyBlue)
                        .shadow(color: .gray, radius: 3)
                    Text(status ? "Save" : "Edit Webhooks").font(.subheadline).bold()
                }
            }.buttonStyle(.plain).padding(.top, 10)
        }
        .padding(12)
        .background { backColor() }
        .clipShape(RoundedRectangle(cornerRadius: 12.0))
        .overlay(content: {
            RoundedRectangle(cornerRadius: 12.0).stroke(Color.gray, lineWidth: 1)
        })
        .padding(.horizontal, 12)
        .offset(y: -100)
    }
    @ViewBuilder
    func mainPassSheet() -> some View {
        VStack {
            ZStack {
                Text("Passwords").font(.title).bold()
                
                HStack {
                    Spacer()
                    Button {
                        showPasswordSheet = false
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation(.easeInOut(duration: 0.25)){
                            showPassword = true
                        }
                    } label: {
                        Image(systemName: "plus")
                            .font(.subheadline)
                            .padding(12)
                            .background(content: {
                                TransparentBlurView(removeAllFilters: true)
                                    .blur(radius: 14, opaque: true)
                                    .background(colorScheme == .dark ? .black.opacity(0.4) : .white.opacity(0.4))
                            })
                            .clipShape(Circle())
                            .shadow(color: .gray, radius: 2)
                    }.buttonStyle(.plain)
                }.padding(.trailing, 14)
            }.padding(.top, 20)
            
            ScrollView {
                passwordGrid()
            }
            .scrollIndicators(.hidden)
        }
        .background(content: { backColor() })
        .presentationDetents([.medium])
        .presentationCornerRadius(30).presentationDragIndicator(.visible)
        .ignoresSafeArea()
    }
    @ViewBuilder
    func passwordGrid() -> some View {
        VStack(spacing: 10){
            if viewModel.passwords.isEmpty {
                HStack {
                    Spacer()
                    Text("Enter site passwords here, or wait for staff/members to enter the correct site password")
                        .font(.caption).multilineTextAlignment(.center).padding(10)
                    Spacer()
                }
            } else {
                ForEach(Array(viewModel.passwords.enumerated()), id: \.element.key) { index, element in
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 2){
                            Text(getSiteNameFromUrl(url: element.key))
                                .font(.body).bold().foregroundStyle(.blue).lineLimit(1)
                            Text(element.value).font(.caption).foregroundStyle(.gray)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            withAnimation(.easeInOut(duration: 0.25)){
                                _ = viewModel.passwords.removeValue(forKey: element.key)
                            }
                            TaskService().updatePasswords(passwords: viewModel.passwords)
                        } label: {
                            Image(systemName: "trash")
                                .font(.subheadline)
                                .padding(10)
                                .background(Color.red)
                                .clipShape(Circle())
                                .shadow(color: .gray, radius: 2)
                        }.buttonStyle(.plain)
                        Button {
                            showPasswordSheet = false
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            newUrl = element.key
                            newPass = element.value
                            withAnimation(.easeInOut(duration: 0.25)){
                                showPassword = true
                            }
                        } label: {
                            Image(systemName: "pencil")
                                .font(.subheadline)
                                .padding(10)
                                .background(Color.green)
                                .clipShape(Circle())
                                .shadow(color: .gray, radius: 2)
                        }.buttonStyle(.plain)
                    }
                    
                    if (index + 1) < viewModel.passwords.count {
                        Divider()
                    }
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
                .stroke(lineWidth: 1).opacity(0.4)
        })
        .padding(.horizontal, 12).padding(.top, 10)
    }
    @ViewBuilder
    func passwordAdd() -> some View {
        VStack {
            Text("Site Password").font(.headline).bold()
            
            Text("Not sure? Enter multiple passwords comma seperated. Or wait for a Wealth member to enter the right password.").font(.caption).multilineTextAlignment(.center).padding(.bottom, 10)
            
            HStack {
                TextField("", text: $newUrl)
                    .lineLimit(1)
                    .focused($isEditingUrl)
                    .frame(height: 57)
                    .padding(.top, 8)
                    .overlay(alignment: .leading, content: {
                        Text("Base URL").font(.system(size: 18)).fontWeight(.light)
                            .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
                            .opacity(isEditingUrl ? 0.8 : 0.5)
                            .offset(y: newUrl.isEmpty && !isEditingUrl ? 0.0 : -21.0)
                            .scaleEffect(newUrl.isEmpty && !isEditingUrl ? 1.0 : 0.8, anchor: .leading)
                            .animation(.easeInOut(duration: 0.2), value: isEditingUrl)
                            .onTapGesture {
                                isEditingUrl = true
                            }
                    })
                    .padding(.horizontal)
                    .background {
                        TransparentBlurView(removeAllFilters: true)
                            .blur(radius: 10, opaque: true)
                            .background(colorScheme == .dark ? .black.opacity(0.5) : .white.opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .overlay(content: {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(colorScheme == .dark ? Color.white : Color.black ,lineWidth: 1)
                            .opacity(isEditingUrl ? 0.8 : 0.5)
                    })
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    showSitePicker = true
                } label: {
                    Image(systemName: "plus")
                        .font(.subheadline)
                        .padding(10)
                        .background(Color.babyBlue)
                        .clipShape(Circle())
                        .shadow(color: .gray, radius: 2)
                }.buttonStyle(.plain)
            }
            
            TextField("", text: $newPass)
                .lineLimit(1)
                .focused($isEditingPass)
                .frame(height: 57)
                .padding(.top, 8)
                .overlay(alignment: .leading, content: {
                    Text("Password").font(.system(size: 18)).fontWeight(.light)
                        .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
                        .opacity(isEditingPass ? 0.8 : 0.5)
                        .offset(y: newPass.isEmpty && !isEditingPass ? 0.0 : -21.0)
                        .scaleEffect(newPass.isEmpty && !isEditingPass ? 1.0 : 0.8, anchor: .leading)
                        .animation(.easeInOut(duration: 0.2), value: isEditingPass)
                        .onTapGesture {
                            isEditingPass = true
                        }
                })
                .padding(.horizontal)
                .background {
                    TransparentBlurView(removeAllFilters: true)
                        .blur(radius: 10, opaque: true)
                        .background(colorScheme == .dark ? .black.opacity(0.5) : .white.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .overlay(content: {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(colorScheme == .dark ? Color.white : Color.black ,lineWidth: 1)
                        .opacity(isEditingPass ? 0.8 : 0.5)
                })
            
            let status = !newUrl.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !newPass.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            
            Button {
                if status {
                    UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                    
                    viewModel.passwords[newUrl] = newPass
                    
                    newUrl = ""
                    newPass = ""
                    
                    TaskService().updatePasswords(passwords: viewModel.passwords)
                    
                    withAnimation(.easeInOut(duration: 0.2)){
                        showPassword = false
                    }
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 12).frame(height: 40).foregroundStyle(Color.babyBlue)
                        .shadow(color: .gray, radius: 3)
                    Text(status ? "Save" : "Enter password").font(.subheadline).bold()
                }
            }.buttonStyle(.plain).padding(.top, 10)
        }
        .padding(12)
        .background { backColor() }
        .clipShape(RoundedRectangle(cornerRadius: 12.0))
        .overlay(content: {
            RoundedRectangle(cornerRadius: 12.0).stroke(Color.gray, lineWidth: 1)
        })
        .padding(.horizontal, 12)
        .offset(y: -100)
    }
    @ViewBuilder
    func buyProView() -> some View {
        VStack(spacing: 8){
            HStack {
                Text("Wealth Pro")
                    .font(.title).bold()
                Spacer()
                Text("$9.99 Monthly")
                    .fontWeight(.semibold)
            }
            Text("With Pro you unlock:").italic().fontWeight(.light).padding(.bottom, 6)
            
            Text("- One-click task setup for all Sites").bold()
            
            Text("- Discord server with Live Alerts/Info.")
            Text("- Bot setup (Delays, Modes, Keywords).")
            Text("- Wealth AIO staff analysis on drops.")
            Text("- Push notifications for shock drops.")
            Text("- Live Stock Count (if available).")
            Text("- Stock count push notifications.")
            Text("- Important release information.")
            Text("- Links to all releasing sites.")
            Text("- Links to all raffles.")
            Text("- Release variants.")
            Text("- Ebay sale data.")
            
            Button {
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                if let product = subManager.products.first {
                    Task {
                        do {
                            try await subManager.buyProduct(product)
                            popRoot.presentAlert(image: "checkmark", text: "Purchase successful!")
                            self.subManager.hasInfoAccess = true
                            withAnimation(.easeInOut(duration: 0.2)){
                                showBuyPro = false
                            }
                            
                            try await Messaging.messaging().subscribe(toTopic: "info")
                            print("Subscribed to 'info' topic successfully!")
                            
                        } catch PurchaseError.verificationFailed(_) {
                            popRoot.presentAlert(image: "xmark", text: "Verification failed")
                        } catch PurchaseError.transactionPending {
                            popRoot.presentAlert(image: "xmark", text: "Transaction is pending approval.")
                        } catch PurchaseError.userCancelled {
                            popRoot.presentAlert(image: "xmark", text: "Please reattempt purchase.")
                        } catch PurchaseError.unknownState {
                            popRoot.presentAlert(image: "xmark", text: "Unknown error occurred during the purchase.")
                        } catch {
                            popRoot.presentAlert(image: "xmark", text: "Error making purchase.")
                        }
                    }
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 12.0).foregroundStyle(Color.babyBlue).frame(height: 40)
                    Text("Purchase")
                        .font(.headline)
                }
            }.padding(.top, 10).buttonStyle(.plain)
        }
        .padding(12)
        .background { backColor() }
        .clipShape(RoundedRectangle(cornerRadius: 12.0))
        .overlay(content: {
            RoundedRectangle(cornerRadius: 12.0).stroke(Color.gray, lineWidth: 1)
        })
        .padding(.horizontal, 12)
        .onAppear {
            if subManager.products.isEmpty {
                Task {
                    await subManager.loadProducts()
                }
            }
        }
    }
    @ViewBuilder
    func quickTasks() -> some View {
        
        let data = getQuickTasks()
        
        if !data.isEmpty {
            VStack(alignment: .leading, spacing: 6){
                Text("Quick Tasks").font(.headline).bold().padding(.leading, 12)
                
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 10){
                        Color.clear.frame(width: 2)
                        
                        ForEach(Array(data.enumerated()), id: \.offset) { index, element in
                            Button {
                                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                                
                                if subManager.hasInfoAccess {
                                    previousSetup.input = element.input
                                    previousSetup.size = element.size.joined(separator: " ")
                                    previousSetup.color = element.color
                                    previousSetup.site = element.site
                                    previousSetup.mode = element.mode.rawValue
                                    previousSetup.delay = Int(element.delay) ?? 3500
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        newGroupToggleId = UUID()
                                    }
                                    showNewGroup = true
                                } else {
                                    withAnimation(.easeInOut(duration: 0.25)){
                                        showBuyPro = true
                                    }
                                }
                            } label: {
                                let colorIndex = Color.colorIndex(for: index)
                                
                                VStack(alignment: .leading){
                                    HStack(alignment: .top){
                                        VStack(alignment: .leading){
                                            Text(element.site).font(.title3).bold().foregroundStyle(.blue)
                                                .lineLimit(1).minimumScaleFactor(0.8)
                                                                                    
                                            Text(getTaskDate(date: element.releaseDate, time: element.releaseTime))
                                                .font(.subheadline).foregroundStyle(.gray)
                                                .lineLimit(1).minimumScaleFactor(0.6)
                                        }
                                        
                                        Spacer()
                                        
                                        KFImage(URL(string: element.image))
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 60, height: 60)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                            .contentShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                    
                                    Spacer()
                                    
                                    Text(element.product)
                                        .font(.subheadline).lineLimit(2)
                                        .multilineTextAlignment(.leading).fontWeight(.semibold)
                                }
                                .padding(8).frame(width: 270)
                                .background(colorIndex.opacity(colorScheme == .dark ? 0.15 : 0.4))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 12).stroke(colorIndex, lineWidth: 1)
                                }
                            }.buttonStyle(.plain)
                        }
                        
                        Color.clear.frame(width: 2)
                    }.padding(.vertical, 2)
                }.frame(height: 130)
            }.padding(.top, 10)
        }
    }
    func GetMode(type: String) -> Modes {
        let scope = type.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        if scope == "normal" {
            return Modes.Normal
        } else if scope == "fast" {
            return Modes.Fast
        } else if scope == "wait" {
            return Modes.Wait
        } else if scope == "preload" {
            return Modes.Preload
        } else if scope == "flow" {
            return Modes.Flow
        } else if scope == "raffle" {
            return Modes.Raffle
        } else if scope == "normalmanual" {
            return Modes.NormalManual
        } else {
            return Modes.FastManual
        }
    }
    func getQuickTasks() -> [TaskSetUp] {
        var quick = [TaskSetUp]()
        
        feedModel.releases.forEach { holder in
            holder.releases.forEach { release in
                if let pre = release.premadeTasks {
                    pre.forEach { data in
                        if let setup = extractSetup(from: data) {
                            
                            let type = GetMode(type: setup.mode)
                            
                            quick.append(
                                TaskSetUp(input: setup.input, size: splitAndTrim(input: setup.size), color: setup.color, site: setup.site, mode: type, delay: setup.delay, releaseDate: setup.date, releaseTime: setup.time, product: release.title, image: release.images.first ?? "")
                            )
                        }
                    }
                }
            }
        }
        
        return quick
    }
    @ViewBuilder
    func headerView() -> some View {
        ZStack {
            HStack {
                Spacer()
                VStack(spacing: 0){
                    GlitchEffect(trigger: $toggleGlitch, text: "Wealth").font(.title).bold()
                    
                    TimeView()
                }
                Spacer()
            }.frame(height: 55)
            HStack(spacing: 15){
                ZStack(alignment: .bottomTrailing){
                    NavigationLink {
                        ProfileView().navigationTransition(.zoom(sourceID: "mainProfile", in: hero))
                    } label: {
                        ZStack {
                            Image("WealthIcon")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 42, height: 42)
                                .clipShape(Circle())
                                .contentShape(Circle())
                            
                            if let image = auth.currentUser?.profileImageUrl {
                                KFImage(URL(string: image))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 42, height: 42)
                                    .clipShape(Circle())
                                    .contentShape(Circle())
                            }
                        }
                    }
                    .matchedTransitionSource(id: "mainProfile", in: hero)
                    .contextMenu {
                        Button {
                            showSettings = true
                        } label: {
                            Label("Settings", systemImage: "gear")
                        }
                    }
                    .shadow(color: .gray, radius: 3)
        
                    if popRoot.unSeenProfileCheckouts > 0 {
                        Text("\(popRoot.unSeenProfileCheckouts)")
                            .font(.caption2).bold().padding(6).background(.red).clipShape(Circle())
                            .offset(x: 4, y: 4)
                    }
                }
                
                NavigationLink {
                    ProxyManager(openGen: false, instances: viewModel.instances)
                        .navigationTransition(.zoom(sourceID: "mainProxy", in: hero))
                } label: {
                    ZStack {
                        Circle().foregroundStyle(LinearGradient(colors: [.green, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)).frame(width: 42, height: 42)
                        Image(systemName: "wifi").font(.title3)
                    }
                }
                .buttonStyle(.plain)
                .matchedTransitionSource(id: "mainProxy", in: hero)
                .shadow(color: .gray, radius: 3)
                
                Spacer()
                
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    showNewGroup = true
                } label: {
                    ZStack {
                        Circle().foregroundStyle(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)).frame(width: 42, height: 42)
                            .shadow(color: .gray, radius: 3)
                        Image(systemName: "plus").font(.title3)
                    }
                }.buttonStyle(.plain)
                
                Menu {
                    if (auth.currentUser?.ownedInstances ?? 0) == 0 {
                        Button(role: .destructive){
                            TaskService().newRequest(type: "1reloadFiles", data: [:])
                            
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                            
                            popRoot.presentAlert(image: "checkmark",
                                                 text: "Reload request sent!")
                        } label: {
                            Label("Reload Files", systemImage: "arrow.counterclockwise")
                        }
                        Button(role: .destructive){
                            showUpdateAlert = true
                        } label: {
                            Label("Update Server", systemImage: "document.badge.arrow.up")
                        }
                        Divider()
                    }
                    Button {
                        showIMAPSheet = true
                    } label: {
                        Label("IMAP", systemImage: "paperplane")
                    }
                    Button {
                        showPasswordSheet = true
                    } label: {
                        Label("Site Passwords", systemImage: "key")
                    }
                    Button {
                        successHook = viewModel.success
                        failureHook = viewModel.failure
                        withAnimation(.easeInOut(duration: 0.25)){
                            showWebhooks = true
                        }
                    } label: {
                        Label("Webhooks", systemImage: "link")
                    }
                    Button {
                        capKey = viewModel.capsolver
                        withAnimation(.easeInOut(duration: 0.25)){
                            showCapSolver = true
                        }
                    } label: {
                        Label("Capsolver", systemImage: "link")
                    }
                    Button {
                        showProfileManager = true
                    } label: {
                        Label("Manage Profiles", systemImage: "person.icloud.fill")
                    }
                    Button {
                        showAccountManager = true
                    } label: {
                        Label("Manage Accounts", systemImage: "person.text.rectangle")
                    }
                    Button {
                        showQueueConfig = true
                    } label: {
                        Label("Queue Config", systemImage: "line.3.horizontal")
                    }
                    if viewModel.queueChecker.isEmpty {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)){
                                viewModel.showQueue = true
                            }
                        } label: {
                            Label("Show Queue", systemImage: "eye")
                        }
                    }
                } label: {
                    ZStack {
                        Circle().foregroundStyle(.gray).frame(width: 42, height: 42)
                            .shadow(color: .gray, radius: 3)
                        Image(systemName: "gear").font(.title3).scaleEffect(1.1)
                    }
                }.buttonStyle(.plain)
            }
        }
        .padding(.top, top_Inset()).padding(.horizontal).padding(.bottom, 10)
        .background {
            TransparentBlurView(removeAllFilters: true).blur(radius: 14, opaque: true)
        }
    }
    func glitchTogg() {
        Task { toggleGlitch.toggle() }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            if appeared {
                glitchTogg()
            } else {
                viewModel.glitchRunning = false
            }
        }
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
}

struct TimeView: View {
    @State private var timeNow = ""
    @State private var timer: Timer? = nil

    let dateFormatter = DateFormatter()

    var body: some View {
        Text(timeNow)
            .font(.caption)
            .onAppear {
                dateFormatter.dateFormat = "h:mm:ss"
                
                timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                    timeNow = dateFormatter.string(from: Date())
                }
            }
            .onDisappear {
                if timer != nil {
                    timer?.invalidate()
                    timer = nil
                }
            }
    }
}

func getSiteNameFromUrl(url: String) -> String {
    let query = url.lowercased()
    
    if query.contains("nike") {
        return "Nike"
    } else if query.contains("popmart") {
        return "Popmart"
    } else if query.contains("pokemon") {
        return "Pokemon Center"
    }
    
    if let element = allSites.first(where: { $0.value == query }) {
        return element.key
    }
    
    return url
}

func currentDeviceID() -> String {
    if let id = UIDevice.current.identifierForVendor?.uuidString {
        return id
    }
    
    return "\(UIDevice.current.name)\(UIDevice.current.model)\(UIDevice.current.localizedModel)\(UIDevice.current.systemName)\(UIDevice.current.systemVersion)"
}

func formatDateString(from date: Date) -> String {
    let calendar = Calendar.current
    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    
    timeFormatter.dateFormat = "h:mm a"
    let formattedTime = timeFormatter.string(from: date)
    
    if calendar.isDateInToday(date) {
        return "As of \(formattedTime) today"
    } else {
        dateFormatter.dateFormat = "M/d/yy"
        let formattedDate = dateFormatter.string(from: date)
        return "As of \(formattedTime) on \(formattedDate)"
    }
}

func extractSetup(from input: String) -> (input: String, size: String, color: String, site: String, mode: String, delay: String, date: String, time: String)? {
    let components = input.split(separator: ",").map { String($0) }
    guard components.count == 8 else {
        return nil
    }
    
    return (
        input: components[0],
        size: components[1],
        color: components[2],
        site: components[3],
        mode: components[4],
        delay: components[5],
        date: components[6],
        time: components[7]
    )
}

struct TaskSetUp: Identifiable {
    let id: UUID = UUID()
    let input: String
    let size: [String]
    let color: String
    let site: String
    let mode: Modes
    let delay: String
    let releaseDate: String
    let releaseTime: String
    let product: String
    let image: String
}

func getTaskDate(date: String, time: String) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM/dd/yy h:mm a"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    
    guard let taskDate = formatter.date(from: "\(date) \(time)") else {
        return "Releasing soon"
    }
    
    let now = Date()
    let calendar = Calendar.current
    
    if taskDate < now {
        return "Already Released"
    }
    
    if calendar.isDate(taskDate, equalTo: now, toGranularity: .minute) {
        return "Now"
    }
    
    if calendar.isDate(taskDate, equalTo: now, toGranularity: .hour) {
        let minutesLeft = calendar.dateComponents([.minute], from: now, to: taskDate).minute ?? 0
        return "In \(minutesLeft)min"
    }
    
    if calendar.isDate(taskDate, equalTo: now, toGranularity: .day) {
        let components = calendar.dateComponents([.hour, .minute], from: now, to: taskDate)
        let hoursLeft = components.hour ?? 0
        let minutesLeft = components.minute ?? 0
        return "In \(hoursLeft)h and \(minutesLeft)min"
    }
    
    if let tomorrow = calendar.date(byAdding: .day, value: 1, to: now),
       calendar.isDate(taskDate, inSameDayAs: tomorrow) {
        formatter.dateFormat = "h:mm a"
        let timeString = formatter.string(from: taskDate)
        return "Tomorrow at \(timeString)"
    }
    
    formatter.dateFormat = "M/d/yy h:mm a"
    let formattedDate = formatter.string(from: taskDate)
    return "Releasing \(formattedDate)"
}

extension Color {
    static let lightBlue = Color(red: 173/255, green: 216/255, blue: 230/255) // Light Blue
    static let lightGreen = Color(red: 144/255, green: 238/255, blue: 144/255) // Light Green
    static let lightPurple = Color(red: 216/255, green: 191/255, blue: 216/255) // Light Purple
    static let lightTurquoise = Color(red: 175/255, green: 238/255, blue: 238/255) // Light Turquoise
    static let lightPink = Color(red: 255/255, green: 182/255, blue: 193/255) // Light Pink
    static let lightOrange = Color(red: 255/255, green: 218/255, blue: 185/255) // Light Orange
    static let lightRuby = Color(red: 229/255, green: 115/255, blue: 115/255) // Light Ruby
    static let lightMagenta = Color(red: 255/255, green: 119/255, blue: 255/255) // Light Magenta
    static let lightCoral = Color(red: 240/255, green: 128/255, blue: 128/255) // Light Coral
    static let lightSalmon = Color(red: 255/255, green: 160/255, blue: 122/255) // Light Salmon
    static let lightSeaGreen = Color(red: 32/255, green: 178/255, blue: 170/255) // Light Sea Green
    static let lightSteelBlue = Color(red: 176/255, green: 196/255, blue: 222/255) // Light Steel Blue

    static var randomLightColor: Color {
        let colors: [Color] = [
            .lightBlue,
            .lightGreen,
            .lightPurple,
            .lightTurquoise,
            .lightPink,
            .lightOrange,
            .lightRuby,
            .lightMagenta,
            .lightCoral,
            .lightSalmon,
            .lightSeaGreen,
            .lightSteelBlue
        ]
        let randomIndex = Int(arc4random_uniform(UInt32(colors.count)))
        return colors[randomIndex]
    }
    
    static var allColors: [Color] {
        return [
            .lightBlue,
            .lightGreen,
            .lightPurple,
            .lightTurquoise,
            .lightPink,
            .lightOrange,
            .lightRuby,
            .lightMagenta,
            .lightCoral,
            .lightSalmon,
            .lightSeaGreen,
            .lightSteelBlue
        ]
    }
        
    static func colorIndex(for number: Int) -> Color {
        let colors = allColors
        return colors[number % colors.count]
    }
}

func splitAndTrim(input: String) -> [String] {
    return input
        .split(separator: " ")
        .map { $0.trimmingCharacters(in: .whitespaces) }
}
