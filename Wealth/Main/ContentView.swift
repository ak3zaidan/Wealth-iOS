import SwiftUI
import FirebaseMessaging

struct ContentView: View {
    @Environment(TaskViewModel.self) private var taskModel
    @Environment(NotificationViewModel.self) private var notifModel
    @Environment(ProfileViewModel.self) private var profileModel
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var popRoot: PopToRoot
    @Environment(\.colorScheme) var colorScheme
    @State var gotNotifs: Date? = nil
    @State var showSettings = false
    @State var offset = 0.0
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        Group {
            if viewModel.userSession == nil {
                WelcomeView()
                    .transition(.move(edge: .bottom))
            } else {
                ZStack {
                    TabView(selection: $popRoot.tab) {
                        NavigationStack {
                            ZStack {
                                backColor()
                                HomeFeedView()
                            }
                        }.tag(1)
                        
                        NavigationStack {
                            ZStack {
                                backColor()
                                ToolsView()
                            }
                        }.tag(2)
                        
                        NavigationStack {
                            ZStack {
                                backColor()
                                MainTaskView()
                            }
                        }.tag(3)
                        
                        NavigationStack {
                            ZStack {
                                backColor()
                                BaseAIView()
                            }
                        }.tag(4)
                        
                        NavigationStack {
                            ZStack {
                                backColor()
                                NotificationView()
                            }
                        }.tag(5)
                    }
                    
                    VStack {
                        Spacer()
                        tabBar().ignoresSafeArea()
                    }.ignoresSafeArea()
                }
                .overlay(content: {
                    if !taskModel.queueChecker.isEmpty || taskModel.showQueue {
                        QueueOverlay()
                    }
                })
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10.0){
                        Messaging.messaging().token { token, _ in
                            if let token = token, !token.isEmpty {
                                if let user = viewModel.currentUser {
                                    if token != user.notificationToken || user.notificationToken == nil {
                                        UserService().editUserToken(token: token)
                                    }
                                }
                            }
                        }
                    }
                    getInitialNotifications()
                }
                .onChange(of: viewModel.currentUser?.id) { _, _ in
                    getInitialNotifications()
                }
                .onChange(of: popRoot.resisData) { _, _ in
                    if let data = popRoot.resisData?.trafficBalanceString {
                        if !data.contains("GB") {
                            popRoot.presentAlert(image: "exclamationmark.shield.fill",
                                                 text: "You are low on Wealth Resis! Please purchase more data.")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showSettings, content: {
            SettingsSheetView(hideOrderNums: .constant(nil))
        })
        .overlay(alignment: .top, content: {
            if popRoot.showAlert, !popRoot.alertReason.isEmpty {
                bannerView()
                    .padding(.top)
                    .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
                    .offset(y: offset * 0.7)
                    .gesture(DragGesture()
                        .onChanged({ value in
                            offset = value.translation.height
                        })
                        .onEnded({ value in
                            withAnimation(.easeInOut(duration: 0.2)){
                                offset = 0.0
                                popRoot.showAlert = false
                            }
                        })
                    )
            }
        })
    }
    func getInitialNotifications() {
        if isDateNilOrOld(date: gotNotifs) {
            if let user = viewModel.currentUser {
                gotNotifs = Date()
                notifModel.getNotificationsNew(lastSeen: user.newestAlert, calledFromHome: true) { _ in }
                
                profileModel.getCheckoutsNew(lastSeen: user.newestCheckout, calledFromHome: true) { result in
                    if let count = result.0 {
                        DispatchQueue.main.async {
                            popRoot.unSeenProfileCheckouts = count
                        }
                    }
                }
            }
        }
    }
    func isDateNilOrOld(date: Date?) -> Bool {
        guard let date = date else {
            return true
        }
        
        return Date().timeIntervalSince(date) >= 15
    }
    @ViewBuilder
    func tabBar() -> some View {
        HStack {
            tabButton(index: 1, imageActive: "house.fill", imageInactive: "house")
            Spacer()
            tabButton(index: 2, imageActive: "wrench.adjustable.fill", imageInactive: "wrench.adjustable")
            Spacer()
            tabButton(index: 3, imageActive: "", imageInactive: "")
            Spacer()
            tabButton(index: 4, imageActive: "bolt.fill", imageInactive: "bolt")
            Spacer()
            tabButton(index: 5, imageActive: "bell.fill", imageInactive: "bell")
                .overlay(alignment: .bottomTrailing){
                    if notifModel.unseenCount > 0 {
                        Text("\(notifModel.unseenCount)")
                            .font(.caption2).bold().padding(4).background(.red).clipShape(Circle())
                            .offset(x: notifModel.unseenCount > 9 ? -4 : -8)
                    }
                }
        }
        .padding(.horizontal, 10)
        .frame(height: 65)
        .background(.regularMaterial)
        .clipShape(Capsule())
        .shadow(color: .gray, radius: 2.5)
        .padding(.horizontal).padding(.bottom, 30)
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
    func tabButton(index: Int, imageActive: String, imageInactive: String) -> some View {
        Button {
            if popRoot.tab == index {
                if popRoot.tap == index {
                    popRoot.tap = 0
                }
                popRoot.tap = index
            } else {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                popRoot.tab = index
            }
        } label: {
            let status = popRoot.tab == index
            
            if index == 3 {
                ZStack {
                    Rectangle().frame(height: 52)
                        .foregroundStyle(.gray).opacity(0.001)
                    Image(colorScheme == .dark ? "wealthLogoWhite" : "wealthLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 36)
                        .contextMenu {
                            Button(role: .destructive){
                                logout()
                            } label: {
                                Label("Log out", systemImage: "arrow.down.circle.dotted")
                            }
                            Button {
                                showSettings = true
                            } label: {
                                Label("Settings", systemImage: "gear")
                            }
                        }
                        .overlay(alignment: .bottom){
                            if status {
                                Capsule()
                                    .frame(width: 30, height: 4)
                                    .foregroundStyle(.blue).offset(y: 15)
                            }
                        }
                }
            } else {
                ZStack {
                    Rectangle().frame(height: 52)
                        .foregroundStyle(.gray).opacity(0.001)
                    Image(systemName: status ? imageActive : imageInactive)
                        .foregroundStyle(status ? .blue : .gray).font(.title2)
                }
            }
        }
    }
    func logout() {
        viewModel.signOut()
        
        DispatchQueue.main.async {
            notifModel.gotReleases = false
            notifModel.notifications = []
            notifModel.unseenCount = 0
            
            profileModel.checkouts = []
            profileModel.cachedFilters = []
            profileModel.dayIncrease = (0, 0.0)
            profileModel.monthIncrease = (0, 0.0)
            profileModel.yearIncrease = []
            profileModel.leaderBoardPosition = 0
            profileModel.gotCheckouts = false
            
            popRoot.tap = 0
            popRoot.tab = 1
            popRoot.unSeenProfileCheckouts = 0
            popRoot.userResiLogin = nil
            popRoot.userResiPassword = nil
            
            taskModel.disconnect()
            taskModel.capSolverBalance = nil
            taskModel.lastUpdatedStats = nil
            taskModel.profiles = nil
            taskModel.accounts = nil
            taskModel.proxies = nil
            taskModel.tasks = nil
        }
    }
}
