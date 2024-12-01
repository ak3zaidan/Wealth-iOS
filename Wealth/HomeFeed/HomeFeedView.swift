import SwiftUI
import Kingfisher

struct HomeFeedView: View {
    @Environment(FeedViewModel.self) private var viewModel
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var popRoot: PopToRoot
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.scenePhase) var scenePhase
    @State var showSettings = false
    @State var filter = "No filter"
    @State var filterImage = "shoe"
    @State var canRefresh = true
    @State var appeared = false
    @State var restart = false
    @State var hideOrderNums: Bool? = false
    
    @Namespace var hero
   
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 10, pinnedViews: [.sectionHeaders]){
                    Color.clear.frame(height: 1).id("scrolltop")
                    
                    let data = getData()
                    
                    if data.isEmpty {
                        if filter == "Past Drops" && !viewModel.gotPastReleases {
                            VStack(spacing: 10){
                                ForEach(0..<12) { _ in
                                    FeedLoadingView()
                                        .scrollTransition { content, phase in
                                            content
                                                .scaleEffect(phase == .identity ? 1 : 0.65)
                                                .blur(radius: phase == .identity ? 0 : 10)
                                        }
                                }
                            }.shimmering()
                        } else if !viewModel.gotReleases {
                            VStack(spacing: 10){
                                ForEach(0..<12) { _ in
                                    FeedLoadingView()
                                        .scrollTransition { content, phase in
                                            content
                                                .scaleEffect(phase == .identity ? 1 : 0.65)
                                                .blur(radius: phase == .identity ? 0 : 10)
                                        }
                                }
                            }.shimmering()
                        } else {
                            VStack(spacing: 12){
                                Text("Nothing yet...").font(.largeTitle).bold()
                                Text("Releases will appear here.").font(.caption).foregroundStyle(.gray)
                            }.padding(.top, 150)
                        }
                    } else {
                        ForEach(data) { holder in
                            Section {
                                ForEach(holder.releases) { release in
                                    NavigationLink {
                                        ReleaseView(release: release)
                                            .navigationTransition(.zoom(sourceID: "\(holder.id)\(release.id ?? "")", in: hero))
                                    } label: {
                                        let isUpVoted = release.likers.contains(where: { $0 == auth.currentUser?.id ?? "" }) || viewModel.upvotes.contains(where: { $0 == release.id ?? "" })
                                        let isDownVoted = release.unLikers.contains(where: { $0 == auth.currentUser?.id ?? "" }) || viewModel.downvotes.contains(where: { $0 == release.id ?? "" })
                                        
                                        FeedRowView(release: release, upVoted: isUpVoted, downVoted: isDownVoted, releaseImage: release.images.first) { bool in
                                            if bool {
                                                viewModel.upVote(releaseId: release.id)
                                                viewModel.upvotes.append(release.id ?? "")
                                                viewModel.downvotes.removeAll(where: { $0 == release.id ?? "" })
                                            } else {
                                                viewModel.removeUpVote(releaseId: release.id)
                                                viewModel.upvotes.removeAll(where: { $0 == release.id ?? "" })
                                            }
                                        } downVote: { bool in
                                            if bool {
                                                viewModel.downVote(releaseId: release.id)
                                                viewModel.downvotes.append(release.id ?? "")
                                                viewModel.upvotes.removeAll(where: { $0 == release.id ?? "" })
                                            } else {
                                                viewModel.removeDownVote(releaseId: release.id)
                                                viewModel.downvotes.removeAll(where: { $0 == release.id ?? "" })
                                            }
                                        } alert: { (reason, image) in
                                            popRoot.presentAlert(image: image, text: reason)
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .matchedTransitionSource(id: "\(holder.id)\(release.id ?? "")", in: hero)
                                }
                            } header: {
                                HStack(spacing: 6){
                                    Text(holder.dateString).font(.headline).bold()
                                    Spacer()
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.subheadline).foregroundStyle(.blue).offset(y: -1)
                                }
                                .padding(.horizontal, 12).padding(.vertical, 12)
                                .background {
                                    TransparentBlurView(removeAllFilters: true).blur(radius: 14, opaque: true)
                                }
                                .onTapGesture {
                                    UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                                    
                                    let allUrls = holder.releases.compactMap { release -> URL? in
                                        if let id = release.id {
                                            return URL(string: "https://wealth.com/releases/\(id)")
                                        }
                                        return nil
                                    }
                                    
                                    showMultiShareSheet(urls: allUrls)
                                }
                            }
                        }
                    }
                    
                    Color.clear.frame(height: 120)
                }.id(viewModel.viewId)
            }
            .safeAreaPadding(.top, 60 + top_Inset())
            .scrollIndicators(.hidden)
            .refreshable {
                if canRefresh {
                    canRefresh = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                        canRefresh = true
                    }
                    viewModel.getReleases()
                }
            }
            .onChange(of: popRoot.tap) { _, _ in
                if popRoot.tap == 1 && appeared {
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
            if viewModel.releases.isEmpty || !isWithinXsec(from: viewModel.lastUpdatedReleases ?? Date(), sec: 15) {
                viewModel.getReleases()
            }
        })
        .onDisappear {
            appeared = false
        }
        .onChange(of: scenePhase) { prevPhase, newPhase in
            if prevPhase == .background && newPhase == .inactive {
                restart = true
            }
            
            if newPhase == .active && prevPhase == .inactive && restart {
                restart = false
                appeared = true
                
                if viewModel.releases.isEmpty || !isWithinXsec(from: viewModel.lastUpdatedReleases ?? Date(), sec: 15) {
                    viewModel.getReleases()
                }
            } else if newPhase == .background {
                appeared = false
            }
        }
    }
    func getData() -> [ReleaseHolder] {
        if filter == "Past Drops" {
            return viewModel.pastReleases
        }
        if filter == "No filter" {
            return viewModel.releases
        }
        
        var final = [ReleaseHolder]()
        
        viewModel.releases.forEach { element in
            var new = ReleaseHolder(dateString: element.dateString, releases: [])
            var newPosts = [Release]()
            
            element.releases.forEach { single in
                if (filter == "Sneakers" && single.type == 4) || (filter == "Apparel" && single.type == 3) || (filter == "Tickets" && single.type == 2) || (filter == "Collectibles" && single.type == 1) || (filter == "Electronics" && single.type == 5) {
                    newPosts.append(single)
                }
            }
            
            if !newPosts.isEmpty {
                new.releases = newPosts
                final.append(new)
            }
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
                    .shadow(color: .gray, radius: 4)
        
                    if popRoot.unSeenProfileCheckouts > 0 {
                        Text("\(popRoot.unSeenProfileCheckouts)")
                            .font(.caption2).bold().padding(6).background(.red).clipShape(Circle())
                            .offset(x: 4, y: 4)
                    }
                }
                
                Spacer()
                
                Menu {
                    Button {
                        filterImage = "shoe"
                        filter = "Sneakers"
                    } label: {
                        Label("Sneakers", systemImage: "shoe")
                    }
                    Button {
                        filterImage = "tshirt"
                        filter = "Apparel"
                    } label: {
                        Label("Apparel", systemImage: "tshirt")
                    }
                    Button {
                        filterImage = "ticket"
                        filter = "Tickets"
                    } label: {
                        Label("Tickets", systemImage: "ticket")
                    }
                    Button {
                        filterImage = "bolt.horizontal"
                        filter = "Collectibles"
                    } label: {
                        Label("Collectibles", systemImage: "bolt.horizontal")
                    }
                    Button {
                        filterImage = "iphone.gen1.radiowaves.left.and.right"
                        filter = "Electronics"
                    } label: {
                        Label("Electronics", systemImage: "iphone.gen1.radiowaves.left.and.right")
                    }
                    Divider()
                    Button {
                        viewModel.getOldReleases()
                        filterImage = "clock"
                        filter = "Past Drops"
                    } label: {
                        Label("Past Drops", systemImage: "clock")
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
