import SwiftUI
import Kingfisher

struct NotificationView: View {
    @Environment(NotificationViewModel.self) private var viewModel
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var popRoot: PopToRoot
    @Environment(\.colorScheme) var colorScheme
    @State var showSettings = false
    @State var filter = "No filter"
    @State var filterImage = "shoe"
    @State var canRefresh = true
    @State var canFetchMore = true
    @State var appeared = true
    @State var hideOrderNums: Bool? = false
    @Namespace var hero
   
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 10){
                    Color.clear.frame(height: 1).id("scrolltop")
                    
                    let data = getData()
                    
                    if data.isEmpty {
                        if !viewModel.gotReleases {
                            VStack(spacing: 10){
                                ForEach(0..<12) { _ in
                                    FeedLoadingView()
                                }
                            }.shimmering()
                        } else {
                            VStack(spacing: 12){
                                Text("Nothing yet...").font(.largeTitle).bold()
                                Text("Notifications will appear here.").font(.caption).foregroundStyle(.gray)
                            }.padding(.top, 150)
                        }
                    } else {
                        ForEach(data) { element in
                            NotificationRowView(notification: element)
                                .scrollTransition { content, phase in
                                    content
                                        .scaleEffect(phase == .identity ? 1 : 0.65)
                                        .blur(radius: phase == .identity ? 0 : 10)
                                }
                        }
                    }
                    
                    Color.clear.frame(height: 120)
                        .overlay {
                            if data.count > 20 {
                                ProgressView()
                                    .offset(y: -20)
                                    .onAppear {
                                        if canFetchMore {
                                            canFetchMore = false
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                                canFetchMore = true
                                            }
                                            viewModel.getNotificationsOld()
                                        }
                                    }
                            }
                        }
                }
            }
            .safeAreaPadding(.top, 60 + top_Inset())
            .scrollIndicators(.hidden)
            .refreshable {
                if canRefresh {
                    canRefresh = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                        canRefresh = true
                    }
                    viewModel.getNotificationsNew(lastSeen: auth.currentUser?.newestAlert, calledFromHome: false) { new in
                        if let new {
                            auth.currentUser?.newestAlert = new
                            UserService().newestAlertSeen(date: new)
                        }
                    }
                }
            }
            .onChange(of: popRoot.tap) { _, _ in
                if popRoot.tap == 5 && appeared {
                    withAnimation {
                        proxy.scrollTo("scrolltop", anchor: .bottom)
                    }
                    popRoot.tap = 0
                }
            }
        }
        .sheet(isPresented: $showSettings, content: {
            SettingsSheetView(hideOrderNums: $hideOrderNums)
        })
        .overlay(alignment: .top) {
            headerView()
        }
        .ignoresSafeArea()
        .onAppear(perform: {
            appeared = true
            viewModel.getNotificationsNew(lastSeen: auth.currentUser?.newestAlert, calledFromHome: false) { new in
                if let new {
                    auth.currentUser?.newestAlert = new
                    UserService().newestAlertSeen(date: new)
                }
            }
        })
        .onDisappear {
            appeared = false
        }
    }
    func getData() -> [Notification] {
        if filter == "No filter" {
            return viewModel.notifications
        }
        
        var final = [Notification]()
        
        viewModel.notifications.forEach { element in
            if filter == "Wealth Notifications" {
                if element.type == NotificationTypes.staff.rawValue || element.type == NotificationTypes.developer.rawValue {
                    final.append(element)
                }
            } else {
                if element.type == NotificationTypes.checkout.rawValue || element.type == NotificationTypes.failure.rawValue || element.type == NotificationTypes.status.rawValue {
                    final.append(element)
                }
            }
        }
        
        if let user = auth.currentUser, !user.hasBotAccess {
            final.removeAll(where: { $0.type == NotificationTypes.developer.rawValue })
        }
        
        return final
    }
    @ViewBuilder
    func headerView() -> some View {
        ZStack {
            HStack {
                Spacer()
                Image(colorScheme == .dark ? "wealthLogoWhite" : "wealthLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 55)
                Spacer()
            }
            HStack {
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
                .shadow(color: .gray, radius: 4)
                .overlay(alignment: .bottomTrailing){
                    if popRoot.unSeenProfileCheckouts > 0 {
                        Text("\(popRoot.unSeenProfileCheckouts)")
                            .font(.caption2).bold().padding(6).background(.red).clipShape(Circle())
                            .offset(x: 4, y: 4)
                    }
                }
                
                Spacer()
                
                Menu {
                    Button {
                        filterImage = "person"
                        filter = "My Notifications"
                    } label: {
                        Label("My Notifications", systemImage: "person")
                    }
                    Divider()
                    Button {
                        filterImage = "crown"
                        filter = "Wealth Notifications"
                    } label: {
                        Label("Wealth Notifications", systemImage: "crown")
                    }
                    Divider()
                    Button {
                        filterImage = "shoe"
                        filter = "No filter"
                    } label: {
                        Label("No filter", systemImage: "xmark")
                    }
                } label: {
                    ZStack {
                        Rectangle()
                            .foregroundStyle(.gray).opacity(0.001).frame(width: 40, height: 40)
                        HStack(spacing: 4){
                            Image(systemName: filter == "No filter" ? "line.3.horizontal.decrease" : filterImage)
                                .font(.title3)
                            Image(systemName: "chevron.down").font(.headline)
                        }
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                    }
                }
            }
        }
        .padding(.top, top_Inset()).padding(.horizontal).padding(.bottom, 10)
        .background {
            TransparentBlurView(removeAllFilters: true).blur(radius: 14, opaque: true)
        }
    }
}
