import SwiftUI
import Kingfisher
import Firebase

struct TabModel2: Identifiable {
    private(set) var id: String
    var size: CGSize = .zero
    var minX: CGFloat = .zero
}

struct ProfileView: View {
    @Environment(ProfileViewModel.self) private var viewModel
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var popRoot: PopToRoot
    @EnvironmentObject var subManager: SubscriptionsManager
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.dismiss) var dismiss
    @State var newestDate: Timestamp? = nil
    @State var showSettingsSheet = false
    @State var HideOrderNums: Bool? = false
    @State var ScrollOrClose = false
    @State var deleteAlert = false
    @State var canFetchMore = true
    @State var canRefresh = true
    @State var restart = false
    @State var appeared = true
    @State var sort = "No filter"
    @State var sortImage = ""
    @State var selectedInstance = ""
    @State var showInstanceBilling = false
    @State var degree = 0.0
    
    // Show Order
    @State var selectedOrder: Checkout? = nil
    @State var showOrderSheet = false
    
    // Filter
    @State var filter: CheckoutFilter? = nil
    @State var showFilterSheet = false
    @State var forOrderNumber = ""
    @State var forProfile = ""
    @State var containsText = ""
    @State var forEmail = ""
    @State var forPrice = ""
    @State var startDate: Date? = nil
    @State var endDate: Date? = nil
    @State var fromSite: String? = nil
    
    // Export
    @State var export: ExportFilter = ExportFilter()
    @State var showExportSheet = false
    @State var fileName = ""
    @State var showExportShareSheet = false
    @State var fileURL: URL?
    @State private var tabs: [TabModel2] = [
        .init(id: "Full list"),
        .init(id: "Size Run")
    ]
    @State private var activeTab: String = "Full list"
    @State var groupBy: Int = 0
    
    // Select
    @State var selectedCheckouts = [String]()
    @State var isSelecting = false
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 10, pinnedViews: [.sectionHeaders]){
                    Color.clear.frame(height: 15).id("scrolltop")
                    
                    profileData()
                        .onAppear { ScrollOrClose = false }
                        .onDisappear { ScrollOrClose = true }
                    
                    let data = getData()
                    
                    if data.isEmpty {
                        if filter != nil && !viewModel.cachedFilters.isEmpty {
                            if viewModel.cachedFilters[0].2 == nil {
                                VStack(spacing: 10){
                                    ForEach(0..<12) { _ in
                                        FeedLoadingView()
                                    }
                                }.shimmering()
                            } else {
                                VStack(spacing: 12){
                                    Text("Nothing yet...").font(.largeTitle).bold()
                                    Text("No checkouts match this filter.").font(.caption).foregroundStyle(.gray)
                                }.padding(.top, 70)
                            }
                        } else if !viewModel.gotCheckouts {
                            VStack(spacing: 10){
                                ForEach(0..<12) { _ in
                                    FeedLoadingView()
                                }
                            }.shimmering()
                        } else {
                            VStack(spacing: 12){
                                Text("Nothing yet...").font(.largeTitle).bold()
                                Text("Checkouts will appear here.").font(.caption).foregroundStyle(.gray)
                            }.padding(.top, 70)
                        }
                    } else {
                        ForEach(data) { holder in
                            Section {
                                ForEach(holder.checkouts) { checkout in
                                    CheckoutRowView(checkout: checkout, isRefreshing: viewModel.refreshingRowViews.contains(checkout.id ?? ""), isSelecting: $isSelecting, hideOrderNum: $HideOrderNums, isSelected: isSelecting ? selectedCheckouts.contains(checkout.id ?? "") : false) {
                                        
                                        popRoot.presentAlert(image: "arrow.counterclockwise", text: "Refreshing")
                                                                                
                                        viewModel.updateOrderStatus(checkout: checkout) { success in
                                            if !success {
                                                popRoot.presentAlert(image: "exclamationmark.triangle", text: "Error reloading status!")
                                            }
                                        }
                                    }
                                    .scrollTransition { content, phase in
                                        content
                                            .scaleEffect(phase == .identity ? 1 : 0.65)
                                            .blur(radius: phase == .identity ? 0 : 10)
                                            .opacity(phase == .identity ? 1.0 : 0.2)
                                    }
                                    .onTapGesture {
                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                        if isSelecting {
                                            if selectedCheckouts.contains(checkout.id ?? "") {
                                                selectedCheckouts.removeAll(where: { $0 == checkout.id ?? "" })
                                            } else {
                                                selectedCheckouts.append(checkout.id ?? "")
                                            }
                                        } else {
                                            selectedOrder = checkout
                                            showOrderSheet = true
                                        }
                                    }
                                    .contextMenu {
                                        if let name = checkout.instanceName, !name.isEmpty {
                                            Label(name, systemImage: "flame")
                                            Divider()
                                        }
                                        if let link = checkout.orderLink {
                                            Button {
                                                UIPasteboard.general.string = link
                                                popRoot.presentAlert(image: "link", text: "Link Copied")
                                            } label: {
                                                Label("Copy Order Link", systemImage: "link")
                                            }
                                        }
                                        if let link = checkout.orderLink, let url = URL(string: link) {
                                            Button {
                                                DispatchQueue.main.async {
                                                    UIApplication.shared.open(url)
                                                }
                                            } label: {
                                                Label("Open Order Link", systemImage: "square.and.arrow.up")
                                            }
                                            Button {
                                                showShareSheet(url: url)
                                            } label: {
                                                Label("Share Order Link", systemImage: "arrowshape.turn.up.right")
                                            }
                                        }
                                        if checkout.site != "Pokemon Center" {
                                            Button {
                                                viewModel.updateOrderStatus(checkout: checkout) { success in
                                                    if !success {
                                                        popRoot.presentAlert(image: "exclamationmark.triangle", text: "Error reloading status!")
                                                    }
                                                }
                                            } label: {
                                                Label("Refresh Status", systemImage: "arrow.counterclockwise")
                                            }
                                        } else if let oid = checkout.orderNumber, !oid.isEmpty {
                                            Button {
                                                UIPasteboard.general.string = oid
                                                popRoot.presentAlert(image: "link", text: "Order ID Copied!")
                                            } label: {
                                                Label("Copy Order ID", systemImage: "link")
                                            }
                                        }
                                        Button {
                                            selectedCheckouts = []
                                            self.selectedCheckouts.append(checkout.id ?? "")
                                            withAnimation(.easeInOut(duration: 0.3)){
                                                isSelecting = true
                                            }
                                        } label: {
                                            Label("Select", systemImage: "checkmark.circle")
                                        }
                                    }
                                }
                            } header: {
                                HStack {
                                    Text("(\(holder.checkouts.count)) \(holder.dateString)").font(.headline).bold()
                                    Spacer()
                                    if isSelecting {
                                        let elements = holder.checkouts.compactMap({ $0.id })
                                        let status = containsAllElements(array: selectedCheckouts, elements: elements)
                                        
                                        Button {
                                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                            if status {
                                                elements.forEach { singleID in
                                                    self.selectedCheckouts.removeAll(where: { $0 == singleID })
                                                }
                                            } else {
                                                selectedCheckouts += holder.checkouts.compactMap({ $0.id })
                                                selectedCheckouts = Array(Set(selectedCheckouts))
                                            }
                                        } label: {
                                            Text(status ? "Unselect" : "Select All")
                                                .font(.headline).fontWeight(.light)
                                                .foregroundStyle(.blue)
                                        }
                                    } else {
                                        Button {
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                            selectedCheckouts = []
                                            selectedCheckouts = holder.checkouts.compactMap({ $0.id })
                                            showExportSheet = true
                                        } label: {
                                            ZStack {
                                                Circle()
                                                    .frame(width: 40, height: 20)
                                                    .foregroundStyle(.gray).opacity(0.001)
                                                
                                                Image(systemName: "square.and.arrow.up").font(.headline).scaleEffect(1.1)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 12).padding(.vertical, 12)
                                .background {
                                    TransparentBlurView(removeAllFilters: true).blur(radius: 14, opaque: true)
                                }
                            }
                        }
                    }

                    Color.clear.frame(height: 150)
                        .overlay {
                            if ScrollOrClose && self.filter == nil {
                                ProgressView()
                                    .offset(y: -45)
                                    .onAppear {
                                        if canFetchMore {
                                            canFetchMore = false
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                                canFetchMore = true
                                            }
                                            viewModel.getCheckoutsOld()
                                        }
                                    }
                            }
                        }
                }
            }
            .safeAreaPadding(.top, top_Inset() + (filter != nil ? 84 : 50))
            .scrollIndicators(.hidden)
            .refreshable {
                if canRefresh {
                    canRefresh = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                        canRefresh = true
                    }
                    viewModel.getCheckoutsNew(lastSeen: auth.currentUser?.newestCheckout, calledFromHome: false) { result in
                        if let date = result.1 {
                            auth.currentUser?.newestCheckout = date
                            UserService().newestCheckoutSeen(date: date)
                        }
                    }
                }
            }
            .onChange(of: popRoot.tap) { _, _ in
                if appeared {
                    if ScrollOrClose {
                        withAnimation {
                            proxy.scrollTo("scrolltop", anchor: .bottom)
                        }
                    } else {
                        dismiss()
                    }
                    popRoot.tap = 0
                }
            }
        }
        .sheet(isPresented: $showExportShareSheet) {
            if let fileURL = fileURL {
                ShareSheet(activityItems: [fileURL])
            }
        }
        .alert("Confirm Deletion", isPresented: $deleteAlert, actions: {
            Button("Delete", role: .destructive) {
                selectedCheckouts.forEach { id in
                    var found = false
                    
                    for i in 0..<viewModel.checkouts.count {
                        if let idx = viewModel.checkouts[i].checkouts.firstIndex(where: { $0.id == id }) {
                            withAnimation {
                                _ = viewModel.checkouts[i].checkouts.remove(at: idx)
                            }
                            found = true
                            break
                        }
                    }

                    if !found && !viewModel.cachedFilters.isEmpty {
                        if let filters = viewModel.cachedFilters[0].2 {
                            for i in 0..<filters.count {
                                if let idx = filters[i].checkouts.firstIndex(where: { $0.id == id }) {
                                    withAnimation {
                                        _ = viewModel.cachedFilters[0].2?[i].checkouts.remove(at: idx)
                                    }
                                    break
                                }
                            }
                        }
                    }
                }
                
                CheckoutService().deleteCheckouts(checkouts: selectedCheckouts)
                selectedCheckouts = []
                withAnimation(.easeInOut(duration: 0.3)){
                    isSelecting = false
                }
            }
            Button("Cancel", role: .cancel) { }
        })
        .background(content: {
            backColor()
        })
        .overlay(alignment: .top) {
            VStack(spacing: 0){
                headerView()
                    .overlay {
                        if isSelecting {
                            selectHeader()
                        }
                    }
                
                if let filter = self.filter {
                    HStack {
                        if let query = filter.containsText, !query.isEmpty {
                            Text("'\(query.joined(separator: " "))'").lineLimit(1)
                        } else if let order = filter.forOrderNumber, !order.isEmpty {
                            (Text("Order ID: ").fontWeight(.light)
                            + Text(order).foregroundStyle(.blue)).lineLimit(1)
                        } else {
                            let count = filter.nonNilCount()
                            let message = count == 1 ? "Filter" : "Filters"
                            
                            Text("\(count) \(message)")
                        }
                        Spacer()
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            withAnimation(.easeInOut(duration: 0.1)){
                                self.filter = nil
                            }
                            forOrderNumber = ""
                            forProfile = ""
                            containsText = ""
                            forEmail = ""
                            forPrice = ""
                            startDate = nil
                            endDate = nil
                            fromSite = nil
                        } label: {
                            Image(systemName: "xmark")
                                .frame(width: 40, height: 20).contentShape(Rectangle())
                        }.buttonStyle(.plain)
                    }
                    .font(.title3)
                    .frame(height: 39).padding(.horizontal, 12)
                    .background {
                        TransparentBlurView(removeAllFilters: true).blur(radius: 14, opaque: true)
                    }
                    .overlay(alignment: .bottom) {
                        Divider()
                    }
                    .transition(.move(edge: .top))
                }
                
                Spacer()
            }
        }
        .ignoresSafeArea()
        .onAppear(perform: {
            appeared = true
            refreshData(initial: true)
            refreshStatus()
            popRoot.unSeenProfileCheckouts = 0
            
            if viewModel.dayIncrease.1 == 0.0 {
                viewModel.getDayIncrease()
            }
            if viewModel.monthIncrease.1 == 0.0 {
                viewModel.getMonthIncrease()
            }
            if viewModel.leaderBoardPosition == 0 {
                viewModel.getLeaderboardPosition(checkoutTotal: auth.currentUser?.checkoutTotal ?? 0.0)
            }
            
            if auth.currentUser?.instanceSubscriptionId != nil && auth.possibleInstances.isEmpty {
                Task {
                    CheckoutService().getPossibleInstances { instances in
                        DispatchQueue.main.async {
                            auth.possibleInstances = instances
                        }
                    }
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0){
                if !showInstanceBilling {
                    if (auth.currentUser?.ownedInstances ?? 0) > 0 && auth.currentUser?.instanceBillingCycle != nil {
                        withAnimation(.easeIn(duration: 0.5)){
                            degree += 360
                            showInstanceBilling.toggle()
                        }
                    }
                }
            }
        })
        .onDisappear {
            appeared = false
            
            if let newestDate {
                DispatchQueue.main.async {
                    self.auth.currentUser?.newestCheckout = newestDate
                }
                UserService().newestCheckoutSeen(date: newestDate)
            }
        }
        .onChange(of: scenePhase) { prevPhase, newPhase in
            if prevPhase == .background && newPhase == .inactive {
                restart = true
            }
            
            if newPhase == .active && prevPhase == .inactive && restart {
                restart = false
                appeared = true
                refreshData(initial: true)
            } else if newPhase == .background {
                appeared = false
                
                if let newestDate {
                    DispatchQueue.main.async {
                        self.auth.currentUser?.newestCheckout = newestDate
                    }
                    UserService().newestCheckoutSeen(date: newestDate)
                    self.newestDate = nil
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showOrderSheet) {
            OrderSheetView(checkout: $selectedOrder)
        }
        .sheet(isPresented: $showExportSheet) {
            exportSheet()
        }
        .sheet(isPresented: $showFilterSheet) {
            filterSheet()
        }
        .sheet(isPresented: $showSettingsSheet) {
            SettingsSheetView(hideOrderNums: $HideOrderNums)
        }
    }
    func refreshStatus() {
        var toRefresh = [Checkout]()
        
        for i in 0..<viewModel.checkouts.count {
            for j in 0..<viewModel.checkouts[i].checkouts.count {
                if viewModel.shouldReload(checkout: viewModel.checkouts[i].checkouts[j]) {
                    toRefresh.append(viewModel.checkouts[i].checkouts[j])
                    if toRefresh.count == 40 {
                        break
                    }
                }
            }
            if toRefresh.count == 40 {
                break
            }
        }
        
        if !toRefresh.isEmpty {
            if let username = auth.currentUser?.discordUsername, let duid = auth.currentUser?.discordUID, !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !duid.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                
                if let last = popRoot.resisData?.trafficBalanceString, !last.isEmpty {
                    if let val = extractBandwidth(from: last), val > 0.0 {
                        
                        if let login = popRoot.userResiLogin, let password = popRoot.userResiPassword, !login.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            
                            handleProxyRefreshes(checkouts: toRefresh, index: 0, login: login, password: password)
                        } else {
                            fetchUserCredentials(dUID: duid) { login, password in
                                if let login, let password, !login.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    
                                    DispatchQueue.main.async {
                                        popRoot.userResiLogin = login
                                        popRoot.userResiPassword = password
                                    }
                                    handleProxyRefreshes(checkouts: toRefresh, index: 0, login: login, password: password)
                                } else {
                                    handleRefreshes(checkouts: toRefresh, index: 0)
                                }
                            }
                        }
                    } else {
                        if !viewModel.showedResiAlert {
                            DispatchQueue.main.async {
                                viewModel.showedResiAlert = true
                            }
                            popRoot.presentAlert(image: "dollarsign",
                                                 text: "Please add data to your Wealth Proxies plan!")
                        }
                        
                        handleRefreshes(checkouts: toRefresh, index: 0)
                    }
                } else {
                    checkBandwidth(dUID: duid) { data in
                        if let data {
                            DispatchQueue.main.async {
                                popRoot.resisData = data
                            }
                            
                            if let val = extractBandwidth(from: data.trafficBalanceString), val > 0.0 {
                                if let login = popRoot.userResiLogin, let password = popRoot.userResiPassword, !login.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    
                                    handleProxyRefreshes(checkouts: toRefresh, index: 0, login: login, password: password)
                                } else {
                                    fetchUserCredentials(dUID: duid) { login, password in
                                        if let login, let password, !login.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                            
                                            DispatchQueue.main.async {
                                                popRoot.userResiLogin = login
                                                popRoot.userResiPassword = password
                                            }
                                            handleProxyRefreshes(checkouts: toRefresh, index: 0, login: login, password: password)
                                        } else {
                                            handleRefreshes(checkouts: toRefresh, index: 0)
                                        }
                                    }
                                }
                            } else {
                                if !viewModel.showedResiAlert {
                                    DispatchQueue.main.async {
                                        viewModel.showedResiAlert = true
                                    }
                                    popRoot.presentAlert(image: "dollarsign",
                                                         text: "Please add data to your Wealth Proxies plan!")
                                }
                                
                                handleRefreshes(checkouts: toRefresh, index: 0)
                            }
                            
                        } else {
                            handleRefreshes(checkouts: toRefresh, index: 0)
                        }
                    }
                }
            } else {
                if !viewModel.showedResiAlert && (auth.currentUser?.useResiToUpdate ?? true) {
                    DispatchQueue.main.async {
                        viewModel.showedResiAlert = true
                    }
                    popRoot.presentAlert(image: "link",
                                         text: "Link Discord in Settings to use Wealth Proxies for faster order updates!")
                }
                
                handleRefreshes(checkouts: toRefresh, index: 0)
            }
        }
    }
    func handleProxyRefreshes(checkouts: [Checkout], index: Int, login: String, password: String) {
        if !appeared {
            return
        }
        Task {
            let proxy = genProxies(userLogin: login, userPassword: password, countryId: "US", state: nil, genCount: 1, SoftSession: true)
            
            viewModel.updateOrderStatusProxy(checkout: checkouts[index], proxy: proxy) { _ in
                if (index + 1) < checkouts.count {
                    if appeared {
                        handleProxyRefreshes(checkouts: checkouts, index: index + 1, login: login, password: password)
                    }
                } else if !viewModel.showedResiBulkAlert {
                    DispatchQueue.main.async {
                        viewModel.showedResiBulkAlert = true
                    }
                    popRoot.presentAlert(image: "checkmark",
                                         text: "All order statuses upto date. Thanks for using Wealth Proxies.")
                }
            }
        }
    }
    func handleRefreshes(checkouts: [Checkout], index: Int) {
        if !appeared {
            return
        }
        Task {
            viewModel.updateOrderStatus(checkout: checkouts[index]) { success in
                if (index + 1) < checkouts.count && appeared {
                    let delay = success ? 1.5 : 2.5
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        handleRefreshes(checkouts: checkouts, index: index + 1)
                    }
                }
            }
        }
    }
    func refreshData(initial: Bool) {
        Task {
            self.viewModel.getCheckoutsNew(lastSeen: self.auth.currentUser?.newestCheckout, calledFromHome: false) { result in

                if let date = result.1 {
                    newestDate = date
                }
                
                if !initial && result.2 {
               
                    if self.ScrollOrClose {
                        DispatchQueue.main.async {
                            self.popRoot.presentAlert(image: "trophy", text: "New checkouts!")
                        }
                    }
                  
                    CheckoutService().getLeaderboardPositionWithRefresh { result in
                        DispatchQueue.main.async {
                            if let user = result.0 {
                                self.auth.currentUser = user
                            }
                            if let position = result.1 {
                                self.viewModel.leaderBoardPosition = position
                            }
                        }
                        if let idx = viewModel.leaderboard.firstIndex(where: { $0.id == result.0?.id }) {
                            DispatchQueue.main.async {
                                viewModel.leaderboard[idx].checkoutCount = result.0?.checkoutCount ?? 0
                                viewModel.leaderboard[idx].checkoutTotal = result.0?.checkoutTotal ?? 0.0
                            }
                        }
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    if self.appeared {
                        self.refreshData(initial: false)
                    }
                }
            }
        }
    }
    func getData() -> [CheckoutHolder] {
        var final = [CheckoutHolder]()
        
        if self.filter != nil && !viewModel.cachedFilters.isEmpty {
            return viewModel.cachedFilters[0].2 ?? []
        }
        
        if sort == "No filter" {
            return viewModel.checkouts
        }
        
        viewModel.checkouts.forEach { element in
            var new = CheckoutHolder(dateString: element.dateString, checkouts: [])
            var newCheckouts = [Checkout]()
            
            element.checkouts.forEach { single in
                if sortImage.contains(".circle") {
                    if (single.instanceName ?? "") == selectedInstance {
                        newCheckouts.append(single)
                    }
                } else if (sort == "Delivered" && single.orderDelivered != nil) || (sort == "Returned" && single.orderReturned != nil) || (sort == "Cancelled" && single.orderCanceled != nil) || (sort == "In Transit" && single.orderTransit != nil && single.orderDelivered == nil) {
                    newCheckouts.append(single)
                }
            }
            
            if !newCheckouts.isEmpty {
                new.checkouts = newCheckouts
                final.append(new)
            }
        }
        
        return final
    }
    @ViewBuilder
    func filterSheet() -> some View {
        ZStack {
            backColor()
            
            VStack(spacing: 10){
                ScrollView {
                    VStack(spacing: 15){
                        textFieldView(value: $containsText, name: "Search Title/Variant")
                        
                        textFieldView(value: $forOrderNumber, name: "Order Number")
                        
                        textFieldView(value: $forEmail, name: "Order Email")
                            .keyboardType(.emailAddress)
                        
                        textFieldView(value: $forProfile, name: "Profile Name")

                        textFieldView(value: $forPrice, name: "Order Price")
                            .keyboardType(.decimalPad)

                        datePickerView(value: $startDate, name: "Start Date")
                        
                        datePickerView(value: $endDate, name: "End Date")
                        
                        SelectSiteButton(fromSite: $fromSite)
                    }.padding(2)
                }.scrollIndicators(.hidden)
                
                let status = hasFilter()
                
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    self.filter = CheckoutFilter()
                    
                    if !containsText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        filter?.containsText = containsText
                            .trimmingCharacters(in: .whitespacesAndNewlines).split(separator: " ").map(String.init)
                    }
                    if !forOrderNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        filter?.forOrderNumber = forOrderNumber
                    }
                    if !forEmail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        filter?.forEmail = forEmail
                    }
                    if !forProfile.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        filter?.forProfile = forProfile
                    }
                    if !forPrice.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        filter?.forPrice = Double(forPrice)
                    }
                    filter?.fromSite = fromSite
                    filter?.startDate = startDate
                    filter?.endDate = endDate
                    
                    viewModel.getCheckoutsFilter(filter: self.filter!)
                    
                    showFilterSheet = false
                } label: {
                    ZStack {
                        Capsule().foregroundStyle(status ? Color.babyBlue : Color.gray).frame(height: 50)
                        Text("Search").font(.headline).bold()
                    }
                }.disabled(!status).ignoresSafeArea().buttonStyle(.plain)
            }.padding().padding(.top, 15)
        }
        .presentationDetents([.large]).presentationCornerRadius(30)
        .presentationDragIndicator(.visible)
    }
    func hasFilter() -> Bool {
        if !containsText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return true
        }
        if !forOrderNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return true
        }
        if !forEmail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return true
        }
        if !forProfile.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return true
        }
        if !forPrice.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return true
        }
        if !(fromSite ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return true
        }
        if endDate != nil || startDate != nil {
            return true
        }
        return false
    }
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        return formatter.string(from: date)
    }
    @ViewBuilder
    func datePickerView(value: Binding<Date?>, name: String) -> some View {
        HStack {
            Text(name).font(.headline).fontWeight(.semibold)
            Spacer()
            DatePicker(
                "",
                selection: Binding(
                    get: { value.wrappedValue ?? Date() },
                    set: { value.wrappedValue = $0 }
                ),
                in: ...Date(),
                displayedComponents: .date
            )
            if value.wrappedValue != nil {
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    withAnimation(.easeInOut(duration: 0.2)){
                        value.wrappedValue = nil
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.headline).bold()
                        .padding(10)
                        .background(.red).clipShape(Circle())
                }.buttonStyle(.plain)
            }
        }
        .padding(10)
        .background {
            TransparentBlurView(removeAllFilters: true)
                .blur(radius: 10, opaque: true)
                .background(colorScheme == .dark ? .black.opacity(0.5) : .white.opacity(0.5))
        }
        .overlay(content: {
            RoundedRectangle(cornerRadius: 12)
                .stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: 1)
                .opacity(0.5)
        })
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    @ViewBuilder
    func textFieldView(value: Binding<String>, name: String) -> some View {
        TextField("", text: value)
            .lineLimit(1)
            .frame(height: 57)
            .padding(.top, 8).padding(.trailing, 30)
            .overlay(alignment: .leading, content: {
                Text(name).font(.system(size: 18)).fontWeight(.light)
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
                if !value.wrappedValue.isEmpty {
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        value.wrappedValue = ""
                    } label: {
                        ZStack {
                            Rectangle().frame(width: 35, height: 45).foregroundStyle(.gray).opacity(0.001)
                            Image(systemName: "xmark")
                        }
                    }.padding(.trailing, 5)
                }
            }
    }
    @ViewBuilder
    func exportSheet() -> some View {
        ZStack {
            backColor()
            
            VStack(spacing: 10){
                TextField("", text: $fileName)
                    .lineLimit(1)
                    .frame(height: 57)
                    .padding(.top, 8)
                    .overlay(alignment: .leading, content: {
                        Text("File Name").font(.system(size: 18)).fontWeight(.light)
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
                    .padding(.horizontal)
                
                HStack {
                    Text("File Type").font(.title3).bold()
                    Spacer()
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        export.fileType = .csv
                    } label: {
                        Text("CSV").font(.headline).bold()
                            .padding(.horizontal, 10).padding(.vertical, 6)
                            .background(export.fileType == .csv ? Color.babyBlue : Color.gray)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                    }.buttonStyle(.plain)
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        export.fileType = .text
                    } label: {
                        Text("Text").font(.headline).bold()
                            .padding(.horizontal, 10).padding(.vertical, 6)
                            .background(export.fileType == .text ? Color.babyBlue : Color.gray)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                    }.buttonStyle(.plain)
                }
                .padding(10)
                .background {
                    TransparentBlurView(removeAllFilters: true)
                        .blur(radius: 10, opaque: true)
                        .background(colorScheme == .dark ? .black.opacity(0.5) : .white.opacity(0.5))
                }
                .clipShape(RoundedRectangle(cornerRadius: 15)).padding(.horizontal)
                
                CustomTabBar().padding(.top)
                
                GeometryReader {
                    let size = $0.size
                    
                    TabView(selection: $activeTab) {
                        ScrollView {
                            VStack(spacing: 10){
                                exportRowView(name: "Include Title", status: $export.containsTitle).padding(.top, 10)
                                exportRowView(name: "Include Profile", status: $export.containsProfile)
                                exportRowView(name: "Include Site", status: $export.containsSite)
                                exportRowView(name: "Include Email", status: $export.containsEmail)
                                exportRowView(name: "Include Color", status: $export.containsColor)
                                exportRowView(name: "Include Size", status: $export.containsSize)
                                exportRowView(name: "Include Order Number", status: $export.containsOrder)
                                exportRowView(name: "Include Order Link", status: $export.containsOrderLink)
                                exportRowView(name: "Include Cost", status: $export.containsCost)
                                exportRowView(name: "Include Status", status: $export.containsStatus)
                                exportRowView(name: "Include Order Date", status: $export.containsDatePlaced)
                                Color.clear.frame(height: 50)
                            }.padding(.horizontal)
                        }
                        .scrollIndicators(.hidden).tag("Full list")
                        .frame(width: size.width, height: size.height)
                        
                        ScrollView {
                            VStack(spacing: 10){
                                exportGroupView(name: "Group by Color", type: 1).padding(.top, 10)
                                exportGroupView(name: "Group by Status", type: 2)
                                exportGroupView(name: "Group by Profile", type: 3)
                                exportGroupView(name: "Group by Site", type: 4)
                                if auth.currentUser?.instanceSubscriptionId != nil && !auth.possibleInstances.isEmpty {
                                    exportGroupView(name: "Group by Instance", type: 5)
                                }
                                Color.clear.frame(height: 50)
                            }.padding(.horizontal)
                        }
                        .scrollIndicators(.hidden).tag("Size Run")
                        .frame(width: size.width, height: size.height)
                        
                    }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
                                           
                let status = (export.hasAtLeastOneTrue() || activeTab == "Size Run") && !fileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    
                    var exportCheckouts = [Checkout]()

                    selectedCheckouts.forEach { id in
                        var found = false
                        
                        for i in 0..<viewModel.checkouts.count {
                            if let got = viewModel.checkouts[i].checkouts.first(where: { $0.id == id }) {
                                exportCheckouts.append(got)
                                found = true
                                break
                            }
                        }

                        if !found && !viewModel.cachedFilters.isEmpty {
                            if let filters = viewModel.cachedFilters[0].2 {
                                for i in 0..<filters.count {
                                    if let got = filters[i].checkouts.first(where: { $0.id == id }) {
                                        exportCheckouts.append(got)
                                        break
                                    }
                                }
                            }
                        }
                    }
                    
                    var csvContent = ""
                    
                    if activeTab == "Full list" {
                        csvContent = generateCSV(from: exportCheckouts, with: export)
                    } else {
                        csvContent = generateSizeRunsCSV(from: exportCheckouts,
                                                         with: groupBy,
                                                         isCsv: export.fileType == .csv)
                    }
                    
                    if let url = saveToFile(content: csvContent, isCSV: export.fileType == .csv, fileName: fileName) {
                        fileURL = url
                        showExportSheet = false
                        withAnimation {
                            isSelecting = false
                        }
                        selectedCheckouts = []
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                            showExportShareSheet = true
                        }
                    }
                } label: {
                    ZStack {
                        Capsule().foregroundStyle(status ? Color.babyBlue : Color.gray).frame(height: 50)
                        Text(activeTab == "Full list" ? "Export" : "Create list").font(.headline).bold()
                    }
                }.disabled(!status).ignoresSafeArea().buttonStyle(.plain).padding(.horizontal).padding(.bottom, 8)
            }.padding(.top, 25)
        }
        .presentationDetents([.large])
        .presentationCornerRadius(30)
        .presentationDragIndicator(.visible)
    }
    @ViewBuilder
    func CustomTabBar() -> some View {
        HStack {
            ForEach($tabs, id: \.id) { $tab in
                Button(action: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    withAnimation(.easeInOut(duration: 0.12)) {
                        activeTab = tab.id
                    }
                }) {
                    HStack {
                        Spacer()
                        Text(tab.id)
                            .fontWeight(.bold)
                            .font(.subheadline)
                            .padding(.vertical, 12)
                            .foregroundStyle(activeTab == tab.id ? Color.primary : .gray)
                            .contentShape(.rect)
                        Spacer()
                    }
                }.buttonStyle(.plain)
            }
        }
        .overlay(alignment: .bottom) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle().fill(.gray.opacity(0.3)).frame(height: 1)

                    HStack {
                        if activeTab == "Size Run" {
                            Spacer()
                        }
                        
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.blue).frame(width: geo.size.width / 2.0, height: 3)
                        
                        if activeTab != "Size Run" {
                            Spacer()
                        }
                    }.animation(.easeInOut(duration: 0.12), value: activeTab)
                }
            }.offset(y: 35)
        }
    }
    @ViewBuilder
    func exportGroupView(name: String, type: Int) -> some View {
        HStack {
            Text(name).font(.headline).fontWeight(.semibold).lineLimit(1)
            Spacer()
            if type == groupBy {
                Image(systemName: "checkmark.circle.fill")
                    .resizable().scaledToFill().frame(width: 21, height: 21)
                    .foregroundStyle(Color.babyBlue)
            } else {
                Circle()
                    .stroke(Color.babyBlue, lineWidth: 2)
                    .frame(width: 20, height: 20)
            }
        }
        .padding(10)
        .background {
            TransparentBlurView(removeAllFilters: true)
                .blur(radius: 10, opaque: true)
                .background(colorScheme == .dark ? .black.opacity(0.5) : .white.opacity(0.5))
        }
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .onTapGesture {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            if type == groupBy {
                groupBy = 0
            } else {
                groupBy = type
            }
        }
    }
    @ViewBuilder
    func exportRowView(name: String, status: Binding<Bool>) -> some View {
        ZStack(alignment: .leading){
            Text(name).font(.headline).fontWeight(.semibold).lineLimit(1)
            HStack {
                Spacer()
                Toggle("", isOn: status)
            }
        }
        .padding(10)
        .background {
            TransparentBlurView(removeAllFilters: true)
                .blur(radius: 10, opaque: true)
                .background(colorScheme == .dark ? .black.opacity(0.5) : .white.opacity(0.5))
        }
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
    @ViewBuilder
    func profileData() -> some View {
        VStack(spacing: 15){
            
            HStack(spacing: 15){
                HStack(spacing: 4){
                    Circle().frame(width: 8, height: 8)
                        .foregroundStyle(.green)
                    Text("Live Feed").font(.subheadline).bold()
                }
                .padding(6)
                .background(Color.gray.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                if subManager.hasInfoAccess {
                    HStack(spacing: 4){
                        Circle().frame(width: 8, height: 8)
                            .foregroundStyle(.blue)
                        Text("Wealth Pro Member").font(.subheadline).bold()
                    }
                    .padding(6)
                    .background(Color.gray.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                } else if (auth.currentUser?.hasBotAccess ?? false) {
                    HStack(spacing: 4){
                        Circle().frame(width: 8, height: 8)
                            .foregroundStyle(.blue)
                        Text("Wealth AIO Member").font(.subheadline).bold()
                    }
                    .padding(6)
                    .background(Color.gray.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                } else if viewModel.leaderBoardPosition < 100 && viewModel.leaderBoardPosition > 0 {
                    HStack(spacing: 4){
                        Circle().frame(width: 8, height: 8)
                            .foregroundStyle(.blue)
                        Text("Top 100").font(.subheadline).bold()
                    }
                    .padding(6)
                    .background(Color.gray.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                Spacer()
            }
            
            NavigationLink {
                LeaderBoardView(currentUID: auth.currentUser?.id ?? "")
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4){
                        Text("Ranked \(viewModel.leaderBoardPosition == 0 ? "NA" : "\(viewModel.leaderBoardPosition)") Overall")
                            .font(.headline).fontWeight(.heavy)
                        HStack(spacing: 3){
                            Text("\(auth.currentUser?.checkoutCount ?? 0)").font(.body).fontWeight(.heavy)
                            Text("Checkouts").font(.body).fontWeight(.light).padding(.trailing, 10)
                            
                            Text(String(format: "$%.1f", auth.currentUser?.checkoutTotal ?? 0.0)).font(.body).fontWeight(.heavy)
                            Text("Spent").font(.body).fontWeight(.light)
                            Spacer()
                        }
                    }
                    Spacer()
                    Image(systemName: "chevron.right").font(.headline)
                }
                .padding(.horizontal, 10).padding(.vertical, 5)
                .background(Color.gray.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }.buttonStyle(.plain)
            
            HStack(spacing: 10){
                if let date = auth.currentUser?.billingCycle?.dateValue(), auth.currentUser?.hasBotAccess ?? false {
                    VStack(alignment: .leading){
                        HStack {
                            Text(showInstanceBilling ? "Scale" : "Wealth AIO").font(.headline).fontWeight(.heavy)
                                .lineLimit(1).minimumScaleFactor(0.8)
                            Spacer()
                        }
                        Text("Billing Cycle").font(.subheadline)
                        
                        Spacer()
                        
                        let date2 = (auth.currentUser?.instanceBillingCycle ?? Timestamp()).dateValue()
                        
                        HStack {
                            Spacer()
                            DonutChartView(color: $showInstanceBilling, daysLeft: Double(daysUntilNextBillingCycle(from: showInstanceBilling ? date2 : date)), totalDays: 30)
                            Spacer()
                        }
                        
                        Spacer()
                    }
                    .frame(height: 150).padding(10)
                    .background(showInstanceBilling ? Color.purple.opacity(0.2) : Color.blue.opacity(0.2))
                    .overlay {
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(showInstanceBilling ? Color.purple : Color.blue, lineWidth: 1)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 15)).contentShape(RoundedRectangle(cornerRadius: 15))
                    .rotation3DEffect(.degrees(degree), axis: (x: 0, y:  1, z:  0))
                    .onTapGesture {
                        if (auth.currentUser?.ownedInstances ?? 0) > 0 && auth.currentUser?.instanceBillingCycle != nil {
                            withAnimation(.easeIn(duration: 0.4)){
                                degree += 360
                                showInstanceBilling.toggle()
                            }
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                    }
                }
                
                let dayStatus = viewModel.dayIncrease.1 >= 0
                
                VStack(alignment: .leading){
                    HStack {
                        Text("Day").font(.title2).fontWeight(.heavy)
                        Spacer()
                    }
                    Text("Checkouts")
                        .font(.subheadline).lineLimit(1).minimumScaleFactor(0.7)
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        Text("\(viewModel.dayIncrease.0)").font(.largeTitle).bold()
                        Spacer()
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 4){
                        Spacer()
                        
                        Text(String(format: "\(dayStatus ? "+" : "")%.1f%%", viewModel.dayIncrease.1)).font(.headline)
                            .lineLimit(1).minimumScaleFactor(0.8)
                        
                        if (auth.currentUser?.hasBotAccess ?? true) == false {
                            Image(systemName: dayStatus ? "chart.line.uptrend.xyaxis" : "chart.line.downtrend.xyaxis").font(.subheadline)
                        }
                        Spacer()
                    }
                }
                .frame(height: 150).padding(10)
                .background(dayStatus ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                .overlay {
                    RoundedRectangle(cornerRadius: 15).stroke(dayStatus ? .green : .red, lineWidth: 2)
                }
                .clipShape(RoundedRectangle(cornerRadius: 15)).contentShape(RoundedRectangle(cornerRadius: 15))
            
                let monthStatus = viewModel.monthIncrease.1 >= 0
                
                VStack(alignment: .leading){
                    HStack {
                        Text("Month").font(.title2).fontWeight(.heavy)
                        Spacer()
                    }
                    Text("Checkouts")
                        .font(.subheadline).lineLimit(1).minimumScaleFactor(0.7)
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        Text("\(viewModel.monthIncrease.0)").font(.largeTitle).bold()
                        Spacer()
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 4){
                        Spacer()
                        Text(String(format: "\(monthStatus ? "+" : "")%.1f%%", viewModel.monthIncrease.1)).font(.headline)
                            .lineLimit(1).minimumScaleFactor(0.8)
                        
                        if (auth.currentUser?.hasBotAccess ?? true) == false {
                            Image(systemName: monthStatus ? "chart.line.uptrend.xyaxis" : "chart.line.downtrend.xyaxis").font(.subheadline)
                        }
                        Spacer()
                    }
                }
                .frame(height: 150).padding(10)
                .background(monthStatus ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                .overlay {
                    RoundedRectangle(cornerRadius: 15).stroke(monthStatus ? .green : .red, lineWidth: 2)
                }
                .clipShape(RoundedRectangle(cornerRadius: 15)).contentShape(RoundedRectangle(cornerRadius: 15))
            }
        }.padding(.horizontal, 12)
    }
    @ViewBuilder
    func selectHeader() -> some View {
        HStack(spacing: 10){
            Button {
                dismiss()
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            } label: {
                ZStack {
                    Rectangle().frame(width: 20, height: 30)
                        .foregroundStyle(.gray).opacity(0.001)
                    Image(systemName: "chevron.left").font(.title3).bold()
                }
            }.buttonStyle(.plain)
            
            Text("\(selectedCheckouts.count) Selected").font(.title3).bold()
            
            Spacer()
            
            if !selectedCheckouts.isEmpty {
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    deleteAlert = true
                } label: {
                    ZStack {
                        Circle().frame(width: 40, height: 40).foregroundStyle(.red).opacity(0.4)
                        Image(systemName: "trash").font(.headline)
                    }
                }
                .buttonStyle(.plain)
                .transition(.scale)
                .animation(.easeInOut(duration: 0.2), value: selectedCheckouts)
            }
            
            Button {
                if !selectedCheckouts.isEmpty {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    showExportSheet = true
                }
            } label: {
                ZStack {
                    Circle().frame(width: 40, height: 40).foregroundStyle(.blue).opacity(0.4)
                    
                    Image(systemName: "square.and.arrow.up")
                        .font(.headline).offset(y: -1.5).scaleEffect(1.1)
                }
            }.buttonStyle(.plain)
            
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                selectedCheckouts = []
                withAnimation(.easeInOut(duration: 0.2)){
                    isSelecting = false
                }
            } label: {
                ZStack {
                    Circle().frame(width: 40, height: 40).foregroundStyle(.gray).opacity(0.4)
                    
                    Image(systemName: "xmark").font(.title3)
                }
            }.buttonStyle(.plain)
        }
        .padding(.top, top_Inset()).padding(.horizontal, 10).padding(.bottom, 10)
        .background(.ultraThinMaterial)
        .transition(.move(edge: .top))
    }
    @ViewBuilder
    func headerView() -> some View {
        HStack(spacing: 10){
            Button {
                dismiss()
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            } label: {
                ZStack {
                    Rectangle().frame(width: 25, height: 30)
                        .foregroundStyle(.gray).opacity(0.001)
                    Image(systemName: "chevron.left").font(.title3).bold()
                }
            }.buttonStyle(.plain)

            HStack(spacing: 4){
                ZStack {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .foregroundStyle(.gray)
                        .frame(width: 38, height: 38)
                    if let image = auth.currentUser?.profileImageUrl {
                        KFImage(URL(string: image))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .scaledToFill()
                            .clipShape(Circle())
                            .contentShape(Circle())
                            .frame(width: 38, height: 38)
                            .shadow(color: .gray, radius: 2)
                    }
                }
                
                VStack(alignment: .leading, spacing: 0){
                    Text(auth.currentUser?.username ?? "@randomUser").font(.title3).bold()
                        .lineLimit(1).minimumScaleFactor(0.8)
                    
                    Text(formatSince()).font(.caption).foregroundStyle(.gray).fontWeight(.light)
                        .lineLimit(1).minimumScaleFactor(0.8)
                }
            }
            .onTapGesture {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                showSettingsSheet = true
            }
            
            Spacer()
            
            Menu {
                Button {
                    sortImage = "airplane"
                    sort = "In Transit"
                } label: {
                    Label("In Transit", systemImage: "airplane")
                }
                Button {
                    sortImage = "xmark"
                    sort = "Cancelled"
                } label: {
                    Label("Cancelled", systemImage: "xmark")
                }
                Button {
                    sortImage = "arrow.counterclockwise"
                    sort = "Returned"
                } label: {
                    Label("Returned", systemImage: "arrow.counterclockwise")
                }
                Button {
                    sortImage = "house"
                    sort = "Delivered"
                } label: {
                    Label("Delivered", systemImage: "house")
                }
                if auth.currentUser?.instanceSubscriptionId != nil && !auth.possibleInstances.isEmpty {
                    Divider()
                    Menu {
                        ForEach(Array(auth.possibleInstances.enumerated()), id: \.element) { index, instance in
                            Button {
                                sort = "Instance"
                                selectedInstance = instance
                                sortImage = "\(index + 1).circle"
                            } label: {
                                Label(instance, systemImage: "\(index + 1).circle")
                            }
                        }
                    } label: {
                        Label("Instance", systemImage: "flame")
                    }
                }
                Divider()
                Button {
                    selectedInstance = ""
                    sortImage = ""
                    sort = "No filter"
                } label: {
                    Label("No filter", systemImage: "xmark")
                }
            } label: {
                ZStack {
                    Rectangle()
                        .foregroundStyle(.gray).opacity(0.001).frame(width: 40, height: 40)
                    HStack(spacing: 4){
                        Image(systemName: sort == "No filter" ? "line.3.horizontal.decrease" : sortImage)
                            .font(.title3)
                        Image(systemName: "chevron.down").font(.headline)
                    }
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                }
            }
            
            Menu {
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    showFilterSheet = true
                } label: {
                    Label("Search Orders", systemImage: "magnifyingglass")
                }
                Button {
                    let all = getData()
                    let allHolders = all.compactMap({ $0.checkouts })
                    let allCheckouts = allHolders.compactMap { $0 }.flatMap { $0 }
                    self.selectedCheckouts = allCheckouts.compactMap({ $0.id })

                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    showExportSheet = true
                } label: {
                    Label("Export Orders", systemImage: "square.and.arrow.up")
                }
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    selectedCheckouts = []
                    withAnimation(.easeInOut(duration: 0.3)){
                        isSelecting = true
                    }
                } label: {
                    Label("Select Orders", systemImage: "checkmark.circle")
                }
            } label: {
                ZStack {
                    Circle().frame(width: 40, height: 40).foregroundStyle(.indigo).opacity(0.4)
                    Image(systemName: "slider.horizontal.3").font(.title3)
                }
            }.buttonStyle(.plain)

            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                showSettingsSheet = true
            } label: {
                ZStack {
                    Circle().frame(width: 40, height: 40).foregroundStyle(.gray).opacity(0.4)
                    
                    Image(systemName: "gear").font(.title3)
                }
            }.buttonStyle(.plain)
        }
        .padding(.top, top_Inset()).padding(.horizontal, 10).padding(.bottom, 10)
        .background {
            TransparentBlurView(removeAllFilters: true).blur(radius: 14, opaque: true)
        }
        .overlay(alignment: .bottom) {
            Divider()
        }
    }
    func formatSince() -> String {
        if let date = auth.currentUser?.userSince.dateValue() {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM, yyyy"
            let formattedDate = dateFormatter.string(from: date)
            return "User since \(formattedDate)"
        }
        
        return "User since 2024"
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

func daysUntilNextBillingCycle(from startDate: Date) -> Int {
    let calendar = Calendar.current
    let today = Date()
    
    let components = calendar.dateComponents([.day], from: startDate, to: today)
    guard let daysElapsed = components.day else { return 0 }
    
    let daysSinceLastCycle = daysElapsed % 30
    
    let daysUntilNextCycle = 30 - daysSinceLastCycle
    return daysUntilNextCycle
}

struct DonutChartView: View {
    @Binding var color: Bool
    let daysLeft: Double
    let totalDays: Double

    var percentageLeft: Double {
        return daysLeft / totalDays
    }

    var body: some View {
        ZStack {
            Circle().stroke(Color.gray.opacity(0.3), lineWidth: 10)
            
            Circle()
                .trim(from: 0.0, to: percentageLeft)
                .stroke(color ? Color.purple : Color.blue, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))
            
            VStack(spacing: 3){
                Text("\(Int(daysLeft))").font(.title3).bold()
                Text("Days Left").font(.caption)
            }
        }.frame(width: 90, height: 90)
    }
}

func containsAllElements(array: [String], elements: [String]) -> Bool {
    return Set(elements).isSubset(of: Set(array))
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

func saveToFile(content: String, isCSV: Bool, fileName: String) -> URL? {
    let fileName = "\(fileName).\(isCSV ? "csv" : "txt")"
    let tempDirectory = FileManager.default.temporaryDirectory
    let fileURL = tempDirectory.appendingPathComponent(fileName)

    do {
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    } catch {
        print("Error saving file: \(error)")
        return nil
    }
}

func generateSizeRunsCSV(from checkouts: [Checkout], with config: Int, isCsv: Bool) -> String {
    var rows: [String] = []
    var uniqueItems: [String : [Checkout]] = [:]
    
    checkouts.forEach { item in
        let items = uniqueItems[item.title] ?? []
        uniqueItems[item.title] = items + [item]
    }
    
    if config == 0 {
        if isCsv {
            rows.append(["Item", "Sizes", "Quantity"].joined(separator: ","))
            rows.append("")
        }
        
        uniqueItems.forEach { (name, items) in
            var sizeCounts: [(String, Int)] = []
            
            items.forEach { checkout in
                if let idx = sizeCounts.firstIndex(where: { $0.0 == checkout.size ?? "NA" }) {
                    sizeCounts[idx].1 += 1
                } else {
                    sizeCounts.append((checkout.size ?? "NA", 1))
                }
            }
            
            sizeCounts = orderSizes(sizeCounts: sizeCounts)
            
            rows.append(name)
            
            if isCsv {
                sizeCounts.forEach { (size, count) in
                    rows.append(",\(size),\(count)")
                }
            } else {
                sizeCounts.forEach { (size, count) in
                    rows.append("\(size) x \(count)")
                }
            }
            rows.append("")
        }
    } else if config == 1 {
        if isCsv {
            rows.append(["(Color) Item", "Sizes", "Quantity"].joined(separator: ","))
            rows.append("")
        }
        
        uniqueItems.forEach { (name, items) in
            var uniqueColors: [String : [Checkout]] = [:]
            
            items.forEach { item in
                let setItems = uniqueColors[item.color ?? "NA"] ?? []
                uniqueColors[item.color ?? "NA"] = setItems + [item]
            }
            
            uniqueColors.forEach { (color, uniqueItems) in
                var sizeCounts: [(String, Int)] = []
                
                uniqueItems.forEach { checkout in
                    if let idx = sizeCounts.firstIndex(where: { $0.0 == checkout.size ?? "NA" }) {
                        sizeCounts[idx].1 += 1
                    } else {
                        sizeCounts.append((checkout.size ?? "NA", 1))
                    }
                }
                
                sizeCounts = orderSizes(sizeCounts: sizeCounts)
                
                rows.append("(\(color)) \(name)")
                
                if isCsv {
                    sizeCounts.forEach { (size, count) in
                        rows.append(",\(size),\(count)")
                    }
                } else {
                    sizeCounts.forEach { (size, count) in
                        rows.append("\(size) x \(count)")
                    }
                }
                
                rows.append("")
            }
        }
    } else if config == 2 {
        if isCsv {
            rows.append(["(Status) Item", "Sizes", "Quantity"].joined(separator: ","))
            rows.append("")
        }
        
        uniqueItems.forEach { (name, items) in
            var uniqueColors: [String : [Checkout]] = [:]
            
            items.forEach { item in
                let status = getStatus(checkout: item)
                let setItems = uniqueColors[status] ?? []
                uniqueColors[status] = setItems + [item]
            }
            
            uniqueColors.forEach { (color, uniqueItems) in
                var sizeCounts: [(String, Int)] = []
                
                uniqueItems.forEach { checkout in
                    if let idx = sizeCounts.firstIndex(where: { $0.0 == checkout.size ?? "NA" }) {
                        sizeCounts[idx].1 += 1
                    } else {
                        sizeCounts.append((checkout.size ?? "NA", 1))
                    }
                }
                
                sizeCounts = orderSizes(sizeCounts: sizeCounts)
                
                rows.append("(\(color)) \(name)")
                
                if isCsv {
                    sizeCounts.forEach { (size, count) in
                        rows.append(",\(size),\(count)")
                    }
                } else {
                    sizeCounts.forEach { (size, count) in
                        rows.append("\(size) x \(count)")
                    }
                }
                
                rows.append("")
            }
        }
    } else if config == 3 {
        if isCsv {
            rows.append(["(Profile) Item", "Sizes", "Quantity"].joined(separator: ","))
            rows.append("")
        }
        
        uniqueItems.forEach { (name, items) in
            var uniqueColors: [String : [Checkout]] = [:]
            
            items.forEach { item in
                let setItems = uniqueColors[item.profile] ?? []
                uniqueColors[item.profile] = setItems + [item]
            }
            
            uniqueColors.forEach { (color, uniqueItems) in
                var sizeCounts: [(String, Int)] = []
                
                uniqueItems.forEach { checkout in
                    if let idx = sizeCounts.firstIndex(where: { $0.0 == checkout.size ?? "NA" }) {
                        sizeCounts[idx].1 += 1
                    } else {
                        sizeCounts.append((checkout.size ?? "NA", 1))
                    }
                }
                
                sizeCounts = orderSizes(sizeCounts: sizeCounts)
                
                rows.append("(\(color)) \(name)")
                
                if isCsv {
                    sizeCounts.forEach { (size, count) in
                        rows.append(",\(size),\(count)")
                    }
                } else {
                    sizeCounts.forEach { (size, count) in
                        rows.append("\(size) x \(count)")
                    }
                }
                
                rows.append("")
            }
        }
    } else if config == 4 {
        if isCsv {
            rows.append(["(Site) Item", "Sizes", "Quantity"].joined(separator: ","))
            rows.append("")
        }
        
        uniqueItems.forEach { (name, items) in
            var uniqueColors: [String : [Checkout]] = [:]
            
            items.forEach { item in
                let setItems = uniqueColors[item.site] ?? []
                uniqueColors[item.site] = setItems + [item]
            }
            
            uniqueColors.forEach { (color, uniqueItems) in
                var sizeCounts: [(String, Int)] = []
                
                uniqueItems.forEach { checkout in
                    if let idx = sizeCounts.firstIndex(where: { $0.0 == checkout.size ?? "NA" }) {
                        sizeCounts[idx].1 += 1
                    } else {
                        sizeCounts.append((checkout.size ?? "NA", 1))
                    }
                }
                
                sizeCounts = orderSizes(sizeCounts: sizeCounts)
                
                rows.append("(\(color)) \(name)")
                
                if isCsv {
                    sizeCounts.forEach { (size, count) in
                        rows.append(",\(size),\(count)")
                    }
                } else {
                    sizeCounts.forEach { (size, count) in
                        rows.append("\(size) x \(count)")
                    }
                }
                
                rows.append("")
            }
        }
    } else if config == 5 {
        if isCsv {
            rows.append(["(Instance) Item", "Sizes", "Quantity"].joined(separator: ","))
            rows.append("")
        }
        
        uniqueItems.forEach { (name, items) in
            var uniqueColors: [String : [Checkout]] = [:]
            
            items.forEach { item in
                let setItems = uniqueColors[item.instanceName ?? "NA"] ?? []
                uniqueColors[item.instanceName ?? "NA"] = setItems + [item]
            }
            
            uniqueColors.forEach { (color, uniqueItems) in
                var sizeCounts: [(String, Int)] = []
                
                uniqueItems.forEach { checkout in
                    if let idx = sizeCounts.firstIndex(where: { $0.0 == checkout.size ?? "NA" }) {
                        sizeCounts[idx].1 += 1
                    } else {
                        sizeCounts.append((checkout.size ?? "NA", 1))
                    }
                }
                
                sizeCounts = orderSizes(sizeCounts: sizeCounts)
                
                rows.append("(\(color)) \(name)")
                
                if isCsv {
                    sizeCounts.forEach { (size, count) in
                        rows.append(",\(size),\(count)")
                    }
                } else {
                    sizeCounts.forEach { (size, count) in
                        rows.append("\(size) x \(count)")
                    }
                }
                
                rows.append("")
            }
        }
    }
    
    return rows.joined(separator: "\n")
}

func generateCSV(from checkouts: [Checkout], with config: ExportFilter) -> String {
    var rows: [String] = []

    var header: [String] = []
    if config.containsTitle { header.append("Title") }
    if config.containsProfile { header.append("Profile") }
    if config.containsSite { header.append("Site") }
    if config.containsEmail { header.append("Email") }
    if config.containsColor { header.append("Color") }
    if config.containsSize { header.append("Size") }
    if config.containsOrder { header.append("Order Number") }
    if config.containsOrderLink { header.append("Order Link") }
    if config.containsCost { header.append("Cost") }
    if config.containsStatus { header.append("Order Status") }
    if config.containsDatePlaced { header.append("Date Placed") }
    rows.append(header.joined(separator: ","))

    for checkout in checkouts {
        var row: [String] = []
        if config.containsTitle { row.append(checkout.title) }
        if config.containsProfile { row.append(checkout.profile) }
        if config.containsSite { row.append(checkout.site) }
        if config.containsEmail { row.append(checkout.email) }
        if config.containsColor { row.append(checkout.color ?? "") }
        if config.containsSize { row.append(checkout.size ?? "") }
        if config.containsOrder { row.append(checkout.orderNumber ?? "") }
        if config.containsOrderLink { row.append(checkout.orderLink ?? "") }
        if config.containsCost { row.append(String(format: "%.2f", checkout.cost ?? 0.0)) }
        
        if config.containsStatus {
            let status = getStatus(checkout: checkout)
            
            if let eta = checkout.estimatedDelivery, status == "In Transit" && !eta.isEmpty {
                row.append("In Transit: \(eta)")
            } else {
                row.append(status)
            }
        }
        
        if config.containsDatePlaced { row.append(checkout.orderPlaced.dateValue().description) }
        rows.append(row.joined(separator: ","))
    }

    return rows.joined(separator: "\n")
}

func orderSizes(sizeCounts: [(String, Int)]) -> [(String, Int)] {
    let sizeOrder: [String: Int] = [
        "XS": 1, "Extra Small": 1,
        "S": 2, "Small": 2,
        "M": 3, "Medium": 3,
        "L": 4, "Large": 4,
        "XL": 5, "Extra Large": 5,
        "XXL": 6, "XLL": 6, "Extra Extra Large": 6
    ]

    return sizeCounts.sorted { a, b in
        let (keyA, _) = a
        let (keyB, _) = b

        let normKeyA = keyA.uppercased()
        let normKeyB = keyB.uppercased()
        
        if let numA = Int(normKeyA), let numB = Int(normKeyB) {
            return numA < numB
        } else if let numA = Double(normKeyA), let numB = Double(normKeyB) {
            return numA < numB
        }
        
        if let orderA = sizeOrder[normKeyA], let orderB = sizeOrder[normKeyB] {
            return orderA < orderB
        }
        
        if Int(normKeyA) != nil && sizeOrder[normKeyB] != nil {
            return true
        } else if sizeOrder[normKeyA] != nil && Int(normKeyB) != nil {
            return false
        }
        
        return normKeyA < normKeyB
    }
}

struct SelectSiteButton: View {
    @Environment(\.colorScheme) var colorScheme
    @State var showSheet = false
    @Binding var fromSite: String?
    
    var body: some View {
        HStack {
            Text("From Site:").font(.headline).fontWeight(.semibold)
            Spacer()
            if let site = fromSite {
                Text(site).font(.headline).lineLimit(1).minimumScaleFactor(0.8)
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    withAnimation(.easeInOut(duration: 0.2)){
                        self.fromSite = nil
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.headline).bold()
                        .padding(10)
                        .background(.red).clipShape(Circle())
                }.buttonStyle(.plain)
            } else {
                Text("Select")
                    .font(.headline).bold()
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(.blue).clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(10)
        .background {
            TransparentBlurView(removeAllFilters: true)
                .blur(radius: 10, opaque: true)
                .background(colorScheme == .dark ? .black.opacity(0.5) : .white.opacity(0.5))
        }
        .overlay(content: {
            RoundedRectangle(cornerRadius: 12)
                .stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: 1)
                .opacity(0.5)
        })
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onTapGesture {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            showSheet = true
        }
        .sheet(isPresented: $showSheet) {
            SelectSiteSheet(maxSelect: 1) { allSites in
                if let firstSite = allSites.first {
                    fromSite = firstSite.0
                }
            }
        }
    }
}
