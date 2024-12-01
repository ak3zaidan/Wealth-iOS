import SwiftUI
import Kingfisher

struct QueueOverlay: View {
    @Environment(TaskViewModel.self) private var viewModel
    @EnvironmentObject var popRoot: PopToRoot
    @EnvironmentObject var auth: AuthViewModel
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.colorScheme) var colorScheme
    @State var minimizedBeingDragged: Bool = false
    @State var minimizedPosition: CGPoint = .zero
    @State var lastMinimizedPosition: CGPoint = .zero
    @State var showFull: Bool = false
    @State var showSitePicker: Bool = false
    @State var restart = false
    @State var presentedViaMenu = false
    @Namespace private var animation
    @State private var timer: Timer? = nil
    @State var toggleId = UUID()
    
    var body: some View {
        ZStack {
            if showFull || viewModel.queueChecker.isEmpty {
                FullView()
            } else {
                bubble()
                    .scaleEffect(minimizedBeingDragged ? 1.2 : 1.0)
                    .offset(x: minimizedPosition.x + lastMinimizedPosition.x, y: minimizedPosition.y + lastMinimizedPosition.y)
                    .simultaneousGesture(createDragGesture())
                    .gesture(TapGesture(count: 2).onEnded {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation(.easeInOut(duration: 0.2)){
                            showFull = true
                        }
                    })
            }
        }
        .background(content: {
            Color.clear.id(toggleId)
        })
        .sheet(isPresented: $showSitePicker, content: {
            SelectSiteSheet(onlyShopify: true, maxSelect: 1) { result in
                if let first = result.first {
                    if viewModel.queueChecker.contains(where: { $0.url == first.1 }) {
                        UINotificationFeedbackGenerator().notificationOccurred(.error)
                        popRoot.presentAlert(image: "xmark",
                                             text: "Queue already open")
                    } else {
                        let new = QueueItems(url: first.1,
                                             name: first.0,
                                             exit: "NA",
                                             lastUpdate: nil)
                        
                        DispatchQueue.main.async {
                            withAnimation(.easeInOut(duration: 0.3)){
                                let status = (viewModel.showQueue && viewModel.queueChecker.isEmpty)

                                viewModel.queueChecker.append(new)
                                
                                if status {
                                    showFull = true
                                    viewModel.showQueue = false
                                }
                            }
                        }
                        
                        let threads: Int = viewModel.queueSpeed == 3 ? 5 : viewModel.queueSpeed == 2 ? 2 : 1
                        
                        if let username = popRoot.userResiLogin,
                            let pass = popRoot.userResiPassword, !username.isEmpty && !pass.isEmpty {
                            
                            for _ in 0..<threads {
                                viewModel.queueEntry(baseUrl: first.1, resiUsername: username, resiPassword: pass)
                            }
                        } else if let dUID = auth.currentUser?.discordUID, !dUID.isEmpty {
                            fetchUserCredentials(dUID: dUID) { username, pass in
                                if let username, let pass {
                                    DispatchQueue.main.async {
                                        popRoot.userResiLogin = username
                                        popRoot.userResiPassword = pass
                                    }
                                    
                                    for _ in 0..<threads {
                                        viewModel.queueEntry(baseUrl: first.1, resiUsername: username, resiPassword: pass)
                                    }
                                } else {
                                    viewModel.queueEntry(baseUrl: first.1, resiUsername: "", resiPassword: "")
                                }
                            }
                        } else {
                            viewModel.queueEntry(baseUrl: first.1, resiUsername: "", resiPassword: "")
                        }
                    }
                }
            }
        })
        .onDisappear {
            if timer != nil {
                timer?.invalidate()
                timer = nil
            }
        }
        .onAppear(perform: {
            let totalWidth = widthOrHeight(width: true)
            let totalHeight = widthOrHeight(width: false) / 2.0
            let viewWidth = 115.0
            let padding = 12.0
            let xPos = (totalWidth / 2.0) - (viewWidth / 2.0) - padding
            
            withAnimation(.easeInOut(duration: 0.3)){
                minimizedPosition = CGPoint(x: xPos, y: -totalHeight + 210)
            }
            
            if !viewModel.showQueue && !showFull {
                popRoot.presentAlert(image: "hand.raised.fingers.spread.fill", text: "Double tap to expand Queue")
            }
            
            if viewModel.showQueue && viewModel.queueChecker.isEmpty {
                presentedViaMenu = true
            }
            
            timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
                toggleId = UUID()
            }
        })
        .onChange(of: scenePhase) { prevPhase, newPhase in
            if prevPhase == .background && newPhase == .inactive {
                restart = true
            }
            
            if newPhase == .active && prevPhase == .inactive && restart {
                restart = false
                                
                DispatchQueue.main.async {
                    viewModel.appeared = true
                    
                    if !viewModel.queueChecker.isEmpty {
                        viewModel.restartAllQueues(resiUsername: popRoot.userResiLogin ?? "",
                                              resiPassword: popRoot.userResiPassword ?? "")
                    }
                }
            } else if newPhase == .background {
                DispatchQueue.main.async {
                    viewModel.appeared = false
                }
            }
        }
    }
    @ViewBuilder
    func FullView() -> some View {
        ZStack {
            GeometryReader { geo in
                Image("WealthBlur")
                    .resizable()
                    .frame(width: geo.size.width, height: geo.size.height)
            }
            .ignoresSafeArea()
            .matchedGeometryEffect(id: "Shape", in: animation)
            
            VStack {
                ZStack {
                    Text("All Queues").font(.title).bold()
                    
                    HStack {
                        Spacer()
                        Button {
                            if viewModel.queueChecker.isEmpty {
                                withAnimation(.easeInOut(duration: 0.2)){
                                    viewModel.showQueue = false
                                }
                            } else {
                                withAnimation(.easeInOut(duration: 0.2)){
                                    showFull = false
                                }
                            }
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        } label: {
                            Image(systemName: viewModel.queueChecker.isEmpty ? "xmark" : "arrow.down.right.and.arrow.up.left")
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
                    
                    HStack {
                        Button {
                            let owned = (auth.currentUser?.unlockedTools ?? []).contains("In-App Queue")
                            
                            if viewModel.queueChecker.count > 19 {
                                UINotificationFeedbackGenerator().notificationOccurred(.error)
                                popRoot.presentAlert(image: "xmark",
                                                     text: "Max of 20 queues!")
                            } else if !owned && viewModel.queueChecker.count >= 2 {
                                UINotificationFeedbackGenerator().notificationOccurred(.error)
                                popRoot.presentAlert(image: "dollar",
                                                     text: "Purchase In App Queue to track more than 2 at a time!")
                            } else {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                showSitePicker = true
                            }
                        } label: {
                            Image(systemName: "arrow.down.right.and.arrow.up.left")
                                .font(.subheadline).opacity(0.001)
                                .padding(12)
                                .background(content: {
                                    TransparentBlurView(removeAllFilters: true)
                                        .blur(radius: 14, opaque: true)
                                        .background(colorScheme == .dark ? .black.opacity(0.4) : .white.opacity(0.4))
                                })
                                .clipShape(Circle())
                                .shadow(color: .gray, radius: 2)
                                .overlay {
                                    Image(systemName: "plus").font(.subheadline)
                                }
                        }.buttonStyle(.plain)
                        
                        Spacer()
                    }.padding(.leading, 14)
                }
                
                ScrollView {
                    LazyVStack(spacing: 12){
                        ForEach(viewModel.queueChecker) { item in
                            HStack {
                                VStack(alignment: .leading, spacing: 3){
                                    Text(item.name).font(.headline).bold().lineLimit(1).shimmering()
                                    Text(formatLastQueue(date: item.lastUpdate)).font(.caption).lineLimit(1)
                                }
                                
                                Spacer()
                                
                                Text(item.exit)
                                    .font(.subheadline).bold()
                                    .foregroundStyle(item.exit == "Error" ? Color.red : Color.blue)
                                    .lineLimit(2).minimumScaleFactor(0.8)
                                
                                Spacer()
                                
                                Button {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    
                                    if viewModel.queueChecker.count == 1 {
                                        
                                        if presentedViaMenu {
                                            viewModel.showQueue = true
                                        } else {
                                            withAnimation(.easeInOut(duration: 0.2)){
                                                showFull = false
                                            }
                                        }
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                            withAnimation(.easeInOut(duration: 0.3)){
                                                viewModel.queueChecker.removeAll(where: { $0.id == item.id })
                                            }
                                        }
                                    } else {
                                        DispatchQueue.main.async {
                                            withAnimation(.easeInOut(duration: 0.3)){
                                                viewModel.queueChecker.removeAll(where: { $0.id == item.id })
                                            }
                                        }
                                    }
                                } label: {
                                    Image(systemName: "trash").font(.body).padding(10).foregroundStyle(.red)
                                }
                            }
                            if item.id != viewModel.queueChecker.last?.id {
                                Divider()
                            }
                        }
                        
                        if viewModel.queueChecker.isEmpty && viewModel.showQueue {
                            HStack {
                                Spacer()
                                VStack {
                                    Text("Nothing yet...").font(.title).bold()
                                    Text("Add a Site to Start Tracking").font(.caption)
                                }
                                Spacer()
                            }.padding(.vertical, 20)
                        }
                    }
                    .padding(10)
                    .background(content: {
                        TransparentBlurView(removeAllFilters: true)
                            .blur(radius: 14, opaque: true)
                            .background(colorScheme == .dark ? .black.opacity(0.6) : .white.opacity(0.6))
                    })
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    Color.clear.frame(height: 100)
                    
                }.scrollIndicators(.hidden).padding(.horizontal, 10)
            }
        }
    }
    func formatLastQueue(date: Date?) -> String {
        if let date = date {
            let now = Date()
            let calendar = Calendar.current
            
            let difference = calendar.dateComponents([.minute, .second], from: date, to: now)
            
            if let minute = difference.minute, minute < 60 {
                if minute < 1 {
                    let seconds = difference.second ?? 0
                    return "Last \(seconds) seconds ago"
                }
                return "Last \(minute) min ago"
            }
        }
        
        return "Last update NA"
    }
    @ViewBuilder
    func bubble() -> some View {
        ZStack {
            Image("WealthBlur")
                .resizable().scaledToFill()
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .contentShape(RoundedRectangle(cornerRadius: 16))
                .matchedGeometryEffect(id: "Shape", in: animation)
                .frame(width: 115.0, height: 115.0)
            
            if viewModel.queueChecker.count == 1 {
                
                let item = viewModel.queueChecker[0]
                
                VStack(spacing: 5){
                    Text(item.name).font(.subheadline).bold().lineLimit(1).minimumScaleFactor(0.9)
                        .shimmering()
                    
                    Text(item.exit)
                        .font(.title3).fontWeight(.heavy)
                        .lineLimit(2).minimumScaleFactor(0.7)
                    
                    Text("Exit At").font(.subheadline).lineLimit(1)
                }.frame(width: 110.0, height: 115.0)
                
            } else if viewModel.queueChecker.count > 1 {
                let items = getNewestTwoItems(viewModel.queueChecker)
                let first = items[0]
                let second = items[1]
                
                VStack(spacing: 5){
                    Text(first.name).font(.caption).bold().lineLimit(1).minimumScaleFactor(0.9)
                    
                    Text(first.exit).font(.subheadline).bold().lineLimit(1).minimumScaleFactor(0.9)
                    
                    Divider().overlay(colorScheme == .dark ? Color.black : Color.white)
                    
                    Text(second.name).font(.caption).bold().lineLimit(1).minimumScaleFactor(0.9)
                    
                    Text(second.exit).font(.subheadline).bold().lineLimit(1).minimumScaleFactor(0.9)
                    
                }.frame(width: 110.0, height: 115.0)
            }
        }.shadow(color: .gray, radius: 4)
    }
    func createDragGesture() -> some Gesture {
        DragGesture()
            .onChanged { value in
                if !minimizedBeingDragged {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    withAnimation(.easeInOut(duration: 0.3)) {
                        minimizedBeingDragged = true
                    }
                }

                lastMinimizedPosition = CGPoint(x: value.translation.width, y: value.translation.height)
            }
            .onEnded { value in
                minimizedPosition = CGPoint(
                    x: minimizedPosition.x + lastMinimizedPosition.x,
                    y: minimizedPosition.y + lastMinimizedPosition.y
                )
                lastMinimizedPosition = .zero

                let totalW = widthOrHeight(width: true)
                let totalH = widthOrHeight(width: false)
                let viewW = 115.0
                let viewH = 115.0
                let padding = 12.0

                let maxX = (totalW / 2.0) - (viewW / 2.0) - padding
                let maxY = (totalH / 2.0) - (viewH / 2.0) - padding

                let clampedX = min(max(minimizedPosition.x, -maxX), maxX)
                let clampedY = min(max(minimizedPosition.y, -maxY), maxY)

                if (minimizedPosition.x + 90.0) < -maxX ||
                    (minimizedPosition.x - 90.0) > maxX ||
                    (minimizedPosition.y + 90.0) < -maxY ||
                    (minimizedPosition.y - 90.0) > maxY {
                    
                    DispatchQueue.main.async {
                        withAnimation(.easeInOut(duration: 0.3)){
                            viewModel.queueChecker = []
                        }
                        viewModel.showQueue = false
                    }
                } else {
                    withAnimation {
                        minimizedPosition = CGPoint(x: clampedX, y: clampedY)
                        minimizedBeingDragged = false
                    }
                }
                withAnimation {
                    minimizedBeingDragged = false
                }
            }
    }
}

func getNewestTwoItems(_ items: [QueueItems]) -> [QueueItems] {
    let sortedItems = items.sorted {
        switch ($0.lastUpdate, $1.lastUpdate) {
        case let (date1?, date2?):
            return date1 > date2
        case (nil, _):
            return false
        case (_, nil):
            return true
        }
    }

    return Array(sortedItems.prefix(2))
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))

        return path
    }
}
