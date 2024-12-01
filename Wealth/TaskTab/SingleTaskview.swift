import SwiftUI
import FirebaseCore
import Kingfisher
import Firebase

struct SingleTaskview: View {
    @Environment(TaskViewModel.self) private var viewModel
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var popRoot: PopToRoot
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @State var selectedTasks = [Int]()
    @State var isSelecting = false
    @State var ScrollOrClose = false
    @State var deleteGroupAlert = false
    @State private var selectedSeconds: Int = 30
    @State var selectedDate: Date = Date()
    @State var minDate: Date = Date()
    @State var maxDate: Date = Date()
    @State var showSchedule = false
    @State var statusChanged = false
    @State var showExportShareSheet = false
    @State var fileURL: URL?
    @State var showSettingsSheet = false
    @State var showEditSheet = false
    @State var editId = UUID()
    @State var showAddSheet = false
    @State var addId = UUID()
    @State var appeared = false
    @State var newUrl = ""
    @FocusState var isEditingUrl
    @State var newPass = ""
    @State var copiedId = ""
    @FocusState var isEditingPass
    @State var showPassword = false
    @State var showSitePicker = false
    @State var showLinkSheet = false
    @State var showRenameSheet = false
    @State var newName = ""
    @State var previousSetup = BotTask(profileGroup: "", profileName: "", proxyGroup: "", accountGroup: "", input: "", size: "", color: "", site: "", mode: "", cartQuantity: 1, delay: 3500, discountCode: "", maxBuyPrice: 99999, maxBuyQuantity: 99999)
    @State var lock = false
    @State var setShippingLock = false
    
    let task: TaskFile
    let isOnline: Bool
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 10, pinnedViews: [.sectionHeaders]){
                    Color.clear.frame(height: 15).id("scrolltop")
                    
                    taskData()
                        .onAppear { ScrollOrClose = false }
                        .onDisappear { ScrollOrClose = true }
                    
                    if isShipMode() {
                        HStack {
                            VStack(alignment: .leading, spacing: 4){
                                Text("Set-Shipper Mode").font(.headline).fontWeight(.heavy)
                                Text("Saves shipping data for quicker checkouts!")
                                    .font(.caption).foregroundStyle(.gray)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "shippingbox")
                                .font(.subheadline).padding(.horizontal, 12).padding(.vertical, 6)
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
                        .padding(.horizontal, 12)
                    }
                    
                    if isManual() {
                        HStack {
                            let count = (task.cartLinks ?? []).count
                            
                            if count == 0 {
                                VStack(alignment: .leading, spacing: 4){
                                    Text("Reserved Carts").font(.headline).fontWeight(.heavy)
                                    Text("No reserved carts yet. They will appear here.")
                                        .font(.caption).foregroundStyle(.gray)
                                }
                            } else {
                                VStack(alignment: .leading, spacing: 4){
                                    
                                    let title = (count == 1) ? "1 Reserved Cart!" : "\(count) Reserved Carts!"
                                    
                                    Text(title).font(.headline).fontWeight(.heavy).foregroundStyle(.green)
                                    Text("Complete the checkout now.")
                                        .font(.caption).foregroundStyle(.gray)
                                }
                            }
                            
                            Spacer()
                            
                            if task.cartLinks != nil {
                                Text("Open").font(.subheadline).bold()
                                    .padding(.horizontal, 12).padding(.vertical, 6)
                                    .background(Color.blue).clipShape(Capsule()).shadow(color: .gray, radius: 3)
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
                        .onTapGesture(perform: {
                            if (task.cartLinks ?? []).count > 0 {
                                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                                showLinkSheet = true
                            }
                        })
                        .padding(.horizontal, 12)
                    }
                                        
                    if task.tasks.isEmpty {
                        VStack(spacing: 12){
                            Text("Nothing yet...").font(.largeTitle).bold()
                            Text("Tasks will appear here.").font(.caption).foregroundStyle(.gray)
                        }.padding(.top, 70)
                    } else {
                        Section {
                            ForEach(Array(task.tasks.enumerated()), id: \.offset) { index, entry in
                                lineRowView(index: index, entry: entry)
                                    .scrollTransition { content, phase in
                                        content
                                            .scaleEffect(phase == .identity ? 1 : 0.65)
                                            .blur(radius: phase == .identity ? 0 : 10)
                                            .opacity(phase == .identity ? 1.0 : 0.2)
                                    }
                                    .padding(.horizontal, 12)
                            }
                        } header: {
                            
                            let status = status()
                            
                            let showSchedule: Bool = task.schedule != nil && status == 1 && (task.schedule?.dateValue() ?? Date()) > Date()
                            
                            HStack(spacing: 4){
                                Text(showSchedule ? "Scheduled:" : "Status:")
                                    .foregroundStyle(.gray).fontWeight(.light).font(.body)
                                
                                if let date = task.schedule, showSchedule {
                                    Text(formattedDateString(from: date.dateValue())).fontWeight(.bold).font(.body)
                                        .foregroundStyle(.blue)
                                } else if task.status.isEmpty {
                                    if task.isRunning && isOnline {
                                        Text("Running").fontWeight(.bold).font(.body)
                                    } else if status == 2 {
                                        Text("Waiting for server").fontWeight(.bold).font(.body)
                                    } else {
                                        Text("Idle").fontWeight(.bold).font(.body)
                                    }
                                } else {
                                    if status == 3 && isOnline {
                                        Text(task.status).fontWeight(.bold).font(.body).lineLimit(1)
                                    } else if status == 2 {
                                        Text("Waiting for server").fontWeight(.bold).font(.body)
                                    } else {
                                        Text(task.status == "Idle" || task.status == "Stopped" ? task.status : "Idle")
                                            .fontWeight(.bold).font(.body)
                                    }
                                }
                                
                                Spacer()
                                
                                if isSelecting {
                                    
                                    let didSelectAll: Bool = (selectedTasks.count == self.task.tasks.count)
                                    
                                    Button {
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        if didSelectAll {
                                            self.selectedTasks = []
                                        } else {
                                            self.selectedTasks = createArray(upperBound: self.task.tasks.count)
                                        }
                                    } label: {
                                        Text(didSelectAll ? "UnSelect" : "Select All")
                                            .fontWeight(.light).foregroundStyle(.blue).font(.body)
                                    }.transition(.move(edge: .trailing))
                                }
                            }
                            .padding(.horizontal, 12).padding(.vertical, 12)
                            .background {
                                TransparentBlurView(removeAllFilters: true).blur(radius: 14, opaque: true)
                            }
                            .onTapGesture {
                                if showSchedule {
                                    self.showSchedule = true
                                }
                            }
                        }
                    }
                    
                    if let left = task.left {
                        if left == 1 {
                            Text("One more task entry remaining. Showing first 100 entries for better performance")
                                .font(.caption).foregroundStyle(.gray)
                                .multilineTextAlignment(.center)
                        } else {
                            Text("\(left) more task entries remaining. Showing first 100 entries for better performance")
                                .font(.caption).foregroundStyle(.gray)
                                .multilineTextAlignment(.center)
                        }
                    }

                    Color.clear.frame(height: 150)
                }
            }
            .safeAreaPadding(.top, top_Inset() + 50)
            .scrollIndicators(.hidden)
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
        .background(content: {
            backColor()
        })
        .overlay(alignment: .top) {
            headerView()
                .overlay {
                    if isSelecting {
                        selectHeader()
                    }
                }
        }
        .overlay(content: {
            if showPassword {
                TransparentBlurView(removeAllFilters: true).blur(radius: 14, opaque: true)
                    .background(colorScheme == .dark ? .black.opacity(0.7) : .white.opacity(0.7))
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)){
                            showPassword = false
                        }
                    }
            }
        })
        .overlay(content: {
            if showPassword {
                passwordAdd().transition(.move(edge: .bottom).combined(with: .scale).combined(with: .opacity))
            }
        })
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .onAppear(perform: {
            appeared = true
        })
        .onDisappear {
            appeared = false
        }
        .onChange(of: viewModel.exitView, { _, _ in
            if viewModel.exitView.contains(self.task.id ?? "NA") && appeared {
                dismiss()
                popRoot.presentAlert(image: "exclamationmark.shield",
                                     text: "Task group deleted from server!")
            }
        })
        .sheet(isPresented: $showLinkSheet) {
            cartLinksView()
        }
        .sheet(isPresented: $showSettingsSheet) {
            settingsView()
        }
        .sheet(isPresented: $showEditSheet) {
            editTaskSheet().id(editId)
        }
        .sheet(isPresented: $showAddSheet) {
            addTaskSheet().id(addId)
        }
        .sheet(isPresented: $showSchedule) {
            scheduleSheet()
        }
        .sheet(isPresented: $showRenameSheet, content: {
            renameSheet()
        })
        .sheet(isPresented: $showExportShareSheet) {
            if let fileURL = fileURL {
                ShareSheet(activityItems: [fileURL])
            }
        }
        .sheet(isPresented: $showSitePicker, content: {
            SelectSiteSheet(maxSelect: 1) { result in
                if let first = result.first?.1 {
                    newUrl = first
                }
            }
        })
        .alert("Confirm Group Deletion", isPresented: $deleteGroupAlert, actions: {
            Button("Delete", role: .destructive) {
                dismiss()
                
                if let id = task.id {
                    viewModel.disabledTasks.append(id)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    
                    let data = [
                        "name": task.name,
                    ] as [String : Any]
                    
                    TaskService().newRequest(type: "\(task.instance)deleteTask", data: data)

                    if let idx = viewModel.tasks?.firstIndex(where: { $0.id == task.id }) {
                        withAnimation(.easeInOut(duration: 0.3)){
                            _ = viewModel.tasks?.remove(at: idx)
                        }
                    }
                }
            }
            Button("Cancel", role: .cancel) { }
        })
    }
    @ViewBuilder
    func cartLinksView() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15){
                
                let links = getCartLinks()
                    
                if links.isEmpty {
                    HStack {
                        Spacer()
                        VStack {
                            Text("Nothing yet...").font(.title).bold()
                            Text("Accounts with reserved carts will appear here").font(.caption)
                        }
                        Spacer()
                    }.padding(.vertical, 20)
                } else {
                    LazyVStack(spacing: 15) {
                        ForEach(links) { element in
                            
                            HStack {
                                if let link = element.paypalLink {
                                    Link(destination: link) {
                                        Image("paypal")
                                            .resizable().scaleEffect(2.1)
                                            .scaledToFit()
                                            .frame(width: 20, height: 15)
                                            .padding(.horizontal, 8).padding(.vertical, 7)
                                            .background(Color.babyBlue.opacity(0.3))
                                            .clipShape(Capsule())
                                            .shadow(radius: 2)
                                    }
                                }
                                
                                Text(element.timeLeft)
                                    .foregroundStyle(element.timeLeft == "Expired" ? Color.red : Color.green)
                                    .font(.subheadline).fontWeight(.heavy)
                                
                                Spacer()
                                
                                Text(element.email)
                                    .font(.subheadline).fontWeight(.light).lineLimit(1).truncationMode(.tail)
                                
                                Button {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    UIPasteboard.general.string = element.email
                                    withAnimation(.easeInOut(duration: 0.1)){
                                        copiedId = element.email
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                        if copiedId == element.email {
                                            withAnimation(.easeInOut(duration: 0.1)){
                                                copiedId = ""
                                            }
                                        }
                                    }
                                } label: {
                                    ZStack {
                                        Image(systemName: "link")
                                            .padding(.horizontal, 8).padding(.vertical, 4)
                                            .background(Color.blue)
                                            .clipShape(Capsule())
                                            .shadow(radius: 2)
                                            .opacity(copiedId == element.email ? 0.0 : 1.0)
                                        
                                        Image(systemName: "checkmark")
                                            .padding(.horizontal, 8).padding(.vertical, 4)
                                            .background(Color.blue)
                                            .clipShape(Capsule())
                                            .shadow(radius: 2)
                                            .opacity(copiedId == element.email ? 1.0 : 0.0)
                                    }
                                }.buttonStyle(.plain)
                                
                                Spacer()
                                
                                Text(element.password)
                                    .font(.subheadline).fontWeight(.light).lineLimit(1).truncationMode(.tail)
                                
                                Button {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    UIPasteboard.general.string = element.password
                                    withAnimation(.easeInOut(duration: 0.1)){
                                        copiedId = (element.password + element.email)
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                        if copiedId == (element.password + element.email) {
                                            withAnimation(.easeInOut(duration: 0.1)){
                                                copiedId = ""
                                            }
                                        }
                                    }
                                } label: {
                                    ZStack {
                                        Image(systemName: "link")
                                            .padding(.horizontal, 8).padding(.vertical, 4)
                                            .background(Color.blue)
                                            .clipShape(Capsule())
                                            .shadow(radius: 2)
                                            .opacity(copiedId == (element.password + element.email) ? 0.0 : 1.0)
                                        
                                        Image(systemName: "checkmark")
                                            .padding(.horizontal, 8).padding(.vertical, 4)
                                            .background(Color.blue)
                                            .clipShape(Capsule())
                                            .shadow(radius: 2)
                                            .opacity(copiedId == (element.password + element.email) ? 1.0 : 0.0)
                                    }
                                }.buttonStyle(.plain)
                            }
                            
                            if element.id != links.last?.id {
                                Divider()
                            }
                        }
                    }
                    .padding(10)
                    .background(Color.gray.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Color.clear.frame(height: 100)
            }.padding(.horizontal).safeAreaPadding(.top, 90)
        }
        .scrollIndicators(.hidden)
        .background {
            backColor()
        }
        .overlay(alignment: .top) {
            VStack(spacing: 8){
                HStack {
                    Spacer()
                    VStack(spacing: 3){
                        Image(colorScheme == .dark ? "wealthLogoWhite" : "wealthLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 45)
                        Text("Reserved Carts").font(.caption).fontWeight(.semibold)
                    }
                    Spacer()
                }
            }
            .padding(.vertical, 10)
            .background {
                TransparentBlurView(removeAllFilters: true).blur(radius: 14, opaque: true)
            }
        }
        .presentationDetents([.large])
        .presentationCornerRadius(30)
        .presentationDragIndicator(.hidden)
    }
    func getCartLinks() -> [CartLinks] {
        var cartLinks = [CartLinks]()
        
        if let links = task.cartLinks {
            links.forEach { element in
                let parts = element.split(separator: ",")
                
                if parts.count >= 4 {
                    if let seconds = Int(String(parts.last ?? "")) {
                        let paypalLink: URL? = URL(string: String(parts[2]))
                        
                        let left = formatTime(date: Date(timeIntervalSince1970: TimeInterval(seconds)))
                        
                        if left == "Expired" {
                            cartLinks.append(CartLinks(email: String(parts[0]),
                                                       password: String(parts[1]),
                                                       paypalLink: paypalLink,
                                                       timeLeft: left))
                        } else {
                            cartLinks.insert(CartLinks(email: String(parts[0]),
                                                       password: String(parts[1]),
                                                       paypalLink: paypalLink,
                                                       timeLeft: left), at: 0)
                        }
                    }
                }
            }
        }
        
        return cartLinks
    }
    func formatTime(date: Date) -> String {
        let now = Date()
        let elapsed = now.timeIntervalSince(date)

        let expirationInterval: TimeInterval = 15 * 60

        if elapsed >= expirationInterval {
            return "Expired"
        } else {
            let remainingSeconds = expirationInterval - elapsed
            let remainingMinutes = Int(ceil(remainingSeconds / 60))
            return "\(remainingMinutes) min"
        }
    }
    func isManual() -> Bool {
        var found = false
        
        if !(task.cartLinks ?? []).isEmpty {
            return true
        }
        
        task.tasks.forEach { element in
            if let mode = extractTask(from: element)?.mode {
                if mode.lowercased().contains("manual") {
                    found = true
                }
            }
        }
        
        return found
    }
    func isShipMode() -> Bool {
        var found = false
        
        task.tasks.forEach { element in
            if let mode = extractTask(from: element)?.mode {
                if mode.lowercased().contains("ship") {
                    found = true
                }
            }
        }

        return found
    }
    func hasPopmartWaitMode() -> Bool {
        var found = false
        
        task.tasks.forEach { element in
            if let config = extractTask(from: element) {
                if config.site.lowercased().contains("popmart") {
                    if config.mode.lowercased().contains("wait") {
                        found = true
                    }
                }
            }
        }

        return found
    }
    @ViewBuilder
    func renameSheet() -> some View {
        VStack {
            Text("Rename Group").padding(.vertical, 20).font(.title2).bold()
            
            TextField("", text: $newName)
                .lineLimit(1)
                .frame(height: 57)
                .padding(.top, 8).padding(.trailing, 30)
                .overlay(alignment: .leading, content: {
                    Text("New name").font(.system(size: 18)).fontWeight(.light)
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
                    if !newName.isEmpty {
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            newName = ""
                        } label: {
                            ZStack {
                                Rectangle().frame(width: 35, height: 45).foregroundStyle(.gray).opacity(0.001)
                                Image(systemName: "xmark")
                            }
                        }.padding(.trailing, 5)
                    }
                }
                .padding(.horizontal)
            
            Spacer()
            
            Button {
                if let id = task.id, task.name != newName && !id.isEmpty {
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    
                    popRoot.presentAlert(image: "checkmark", text: "Rename request sent!")
                    
                    let data = [
                        "old": task.name,
                        "new": newName,
                        "id": id
                    ]
                    
                    TaskService().newRequest(type: "\(task.instance)editTaskName", data: data)
                } else {
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 12).foregroundStyle(Color.babyBlue).frame(height: 45)
                    Text(task.name == newName ? "Edit Name" : "Save")
                        .font(.headline).bold()
                }
            }.buttonStyle(.plain).padding(.horizontal).padding(.bottom, 10)
        }
        .presentationDetents([.fraction(0.3)])
        .presentationCornerRadius(30).presentationDragIndicator(.visible)
    }
    @ViewBuilder
    func editTaskSheet() -> some View {
        TaskBuilder(presetName: task.name, setup: previousSetup, lock: $lock, action: .constant(.Edit), setShippingLock: $setShippingLock) { result in
            let config = result.0
            
            var data = [
                "name": task.name,
                "docId": task.id ?? "",
                "config": convertTaskToString(task: config)
            ] as [String : Any]
            
            if selectedTasks.count != self.task.tasks.count {
                data["indices"] = selectedTasks
            }
            
            TaskService().newRequest(type: "\(task.instance)editTaskGroup", data: data)
                            
            popRoot.presentAlert(image: "checkmark", text: "Request sent please wait")
            
            self.previousSetup.input = config.input
            self.previousSetup.color = config.color
            self.previousSetup.size = config.size
            self.previousSetup.profileGroup = config.profileGroup
            self.previousSetup.profileName = config.profileName
            self.previousSetup.proxyGroup = config.proxyGroup
            self.previousSetup.accountGroup = config.accountGroup
        }
    }
    @ViewBuilder
    func addTaskSheet() -> some View {
        TaskBuilder(presetName: task.name, setup: previousSetup, lock: $lock, action: .constant(.Add), setShippingLock: $setShippingLock) { result in
            let createCount = result.2
            let config = result.0
            
            let data = [
                "name": task.name,
                "docId": task.id ?? "",
                "count": createCount,
                "config": convertTaskToString(task: config)
            ] as [String : Any]
            
            TaskService().newRequest(type: "\(task.instance)appendToTask", data: data)
                            
            popRoot.presentAlert(image: "checkmark", text: "Request sent please wait")
            
            self.previousSetup.input = config.input
            self.previousSetup.color = config.color
            self.previousSetup.size = config.size
            self.previousSetup.profileGroup = config.profileGroup
            self.previousSetup.profileName = config.profileName
            self.previousSetup.proxyGroup = config.proxyGroup
            self.previousSetup.accountGroup = config.accountGroup
        }
    }
    @ViewBuilder
    func settingsView() -> some View {
        ScrollView {
            
            let status = status()
            
            LazyVStack(spacing: 20){
                HStack(spacing: 12){
                    Button {
                        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                        showSettingsSheet = false
                        selectedTasks = []
                        withAnimation(.easeInOut(duration: 0.2)){
                            isSelecting = true
                        }
                    } label: {
                        VStack {
                            Text("Select").font(.title3).bold().bold()
                            HStack {
                                Spacer()
                                Image(systemName: "checkmark.circle").font(.title2)
                                Spacer()
                            }
                        }
                        .padding(12)
                        .background(Color.green.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .overlay {
                            RoundedRectangle(cornerRadius: 15).stroke(Color.green, lineWidth: 1)
                        }
                    }.buttonStyle(.plain)
                    Button {
                        if task.isRunning {
                            UINotificationFeedbackGenerator().notificationOccurred(.error)
                            popRoot.presentAlert(image: "exclamationmark.shield",
                                                 text: "Group must be off to add tasks")
                        } else if isOnline {
                            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()

                            lock = !task.tasks.isEmpty
                            
                            if let first = self.task.tasks.first {
                                if let setup = extractTask(from: first) {
                                    self.previousSetup = setup
                                }
                            }
                            
                            self.setShippingLock = false
                            if self.task.tasks.count > 1 {
                                self.task.tasks.forEach { element in
                                    if let setup = extractTask(from: element) {
                                        if formatMode(mode: setup.mode) == "SetShipping" {
                                            self.setShippingLock = true
                                        }
                                    }
                                }
                            }
                            
                            showSettingsSheet = false
                            showAddSheet = true
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                addId = UUID()
                            }
                        } else {
                            UINotificationFeedbackGenerator().notificationOccurred(.error)
                            popRoot.presentAlert(image: "exclamationmark.shield",
                                                 text: "Turn on Wealth AIO to add")
                        }
                    } label: {
                        VStack {
                            Text("Add").font(.title3).bold().bold()
                            HStack {
                                Spacer()
                                Image(systemName: "plus.circle").font(.title2)
                                Spacer()
                            }
                        }
                        .padding(12)
                        .background(Color.babyBlue.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .overlay {
                            RoundedRectangle(cornerRadius: 15).stroke(Color.babyBlue, lineWidth: 1)
                        }
                    }.buttonStyle(.plain)
                    
                    if !self.task.tasks.isEmpty {
                        Button {
                            if task.isRunning {
                                UINotificationFeedbackGenerator().notificationOccurred(.error)
                                popRoot.presentAlert(image: "exclamationmark.shield",
                                                     text: "Group must be off to edit")
                            } else if isOnline {
                                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                                
                                lock = false
                                selectedTasks = createArray(upperBound: self.task.tasks.count)
                                if let first = self.task.tasks.first {
                                    if let setup = extractTask(from: first) {
                                        self.previousSetup = setup
                                    }
                                }
                                
                                self.setShippingLock = false
                                
                                showSettingsSheet = false
                                showEditSheet = true
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    editId = UUID()
                                }
                            } else {
                                UINotificationFeedbackGenerator().notificationOccurred(.error)
                                popRoot.presentAlert(image: "exclamationmark.shield",
                                                     text: "Turn on Wealth AIO to edit")
                            }
                        } label: {
                            VStack {
                                Text("Edit").font(.title3).bold().bold()
                                HStack {
                                    Spacer()
                                    Image(systemName: "square.and.pencil").font(.title2)
                                    Spacer()
                                }
                            }
                            .padding(12)
                            .background(Color.indigo.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .overlay {
                                RoundedRectangle(cornerRadius: 15).stroke(Color.indigo, lineWidth: 1)
                            }
                        }.buttonStyle(.plain)
                    }
                }
                
                Button {
                    UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                    
                    let now = Date()
                    selectedDate = Calendar.current.date(byAdding: .hour, value: 1, to: now) ?? now
                    minDate = Calendar.current.date(byAdding: .minute, value: 5, to: now) ?? now
                    maxDate = Calendar.current.date(byAdding: .day, value: 4, to: now) ?? now
                    
                    showSettingsSheet = false
                    showSchedule = true
                } label: {
                    
                    let scheduleStatus = task.schedule != nil && status == 1 && (task.schedule?.dateValue() ?? Date()) > Date()
                    
                    HStack {
                        Text(scheduleStatus ? "Edit Schedule" : "Schedule").font(.title3).bold()
                        Spacer()
                        Image(systemName: "clock").font(.title3)
                    }
                    .padding(12)
                    .background(Color.gray.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                }.buttonStyle(.plain)
                
                if getImageName() == "shopify" {
                    Button {
                        showSettingsSheet = false
                        
                        let owned = (auth.currentUser?.unlockedTools ?? []).contains("In-App Queue")
                        let siteUrl = getSiteUrl()
                        
                        if viewModel.queueChecker.count > 19 {
                            UINotificationFeedbackGenerator().notificationOccurred(.error)
                            popRoot.presentAlert(image: "xmark",
                                                 text: "Max of 20 queues!")
                        } else if !owned && viewModel.queueChecker.count >= 2 {
                            UINotificationFeedbackGenerator().notificationOccurred(.error)
                            popRoot.presentAlert(image: "dollar",
                                                 text: "Purchase In App Queue to track more than 2 at a time!")
                        } else if viewModel.queueChecker.contains(where: { $0.url == getSiteUrl() }) {
                            UINotificationFeedbackGenerator().notificationOccurred(.error)
                            popRoot.presentAlert(image: "xmark",
                                                 text: "Queue already open")
                        } else {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            let new = QueueItems(url: siteUrl,
                                                 name: getQueueName(baseUrl: siteUrl),
                                                 exit: "NA",
                                                 lastUpdate: nil)
                            
                            DispatchQueue.main.async {
                                withAnimation(.easeInOut(duration: 0.2)){
                                    viewModel.queueChecker.append(new)
                                }
                            }
                            
                            let threads: Int = viewModel.queueSpeed == 3 ? 5 : viewModel.queueSpeed == 2 ? 2 : 1
                            
                            if let username = popRoot.userResiLogin,
                                let pass = popRoot.userResiPassword, !username.isEmpty && !pass.isEmpty {
                                
                                for _ in 0..<threads {
                                    viewModel.queueEntry(baseUrl: siteUrl, resiUsername: username, resiPassword: pass)
                                }
                            } else if let dUID = auth.currentUser?.discordUID, !dUID.isEmpty {
                                fetchUserCredentials(dUID: dUID) { username, pass in
                                    if let username, let pass {
                                        DispatchQueue.main.async {
                                            popRoot.userResiLogin = username
                                            popRoot.userResiPassword = pass
                                        }
                                        
                                        for _ in 0..<threads {
                                            viewModel.queueEntry(baseUrl: siteUrl, resiUsername: username, resiPassword: pass)
                                        }
                                    } else {
                                        viewModel.queueEntry(baseUrl: siteUrl, resiUsername: "", resiPassword: "")
                                    }
                                }
                            } else {
                                viewModel.queueEntry(baseUrl: siteUrl, resiUsername: "", resiPassword: "")
                            }
                        }
                    } label: {
                        HStack {
                            Text("Open Queue").font(.title3).bold()
                            Spacer()
                            Image(systemName: "line.3.horizontal").font(.title3)
                        }
                        .padding(12)
                        .background(Color.gray.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                    }.buttonStyle(.plain)
                }

                if getImageName() == "pokemon" && status == 3 {
                    Button {
                        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                        popRoot.presentAlert(image: "checkmark", text: "Override request sent!")
                        
                        let data = [
                            "name": task.name,
                        ] as [String : Any]
                        
                        TaskService().newRequest(type: "\(task.instance)overrideMonitor", data: data)
                    } label: {
                        HStack {
                            Text("Override Monitor").font(.title3).bold()
                            Spacer()
                            Image(systemName: "play.circle").font(.title3)
                        }
                        .padding(12)
                        .background(Color.gray.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                    }.buttonStyle(.plain)
                }
                
                Button {
                    UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                    showSettingsSheet = false
                    
                    let csvContent = generateTaskCSV(from: task.tasks)
                    
                    if let url = saveToFile(content: csvContent, isCSV: true, fileName: task.name) {
                        fileURL = url
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                            showExportShareSheet = true
                        }
                    }
                } label: {
                    HStack {
                        Text("Share Setup").font(.title3).bold()
                        Spacer()
                        Image(systemName: "arrowshape.turn.up.forward").font(.title3)
                    }
                    .padding(12)
                    .background(Color.gray.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                }.buttonStyle(.plain)
                                
                if let instances = auth.currentUser?.ownedInstances, instances > 0 && isOnline {
                    Menu {
                        ForEach(1..<(instances + 2), id: \.self) { index in
                            if index == task.instance {
                                Button {
                                    showSettingsSheet = false
                                    
                                    let data = [
                                        "name": task.name,
                                    ] as [String : Any]
                                    
                                    TaskService().newRequest(type: "\(task.instance)duplicateTask", data: data)
                                    
                                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                                } label: {
                                    Label("Same Instance", systemImage: "\(index).circle")
                                }
                            } else {
                                Button {
                                    showSettingsSheet = false
                                    
                                    let data = [
                                        "name": task.name,
                                        "tasks": task.tasks
                                    ] as [String : Any]
                                    
                                    TaskService().newRequest(type: "\(task.instance)duplicateNewTask", data: data)
                                    
                                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                                } label: {
                                    Label("On Instance \(index)", systemImage: "\(index).circle")
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text("Duplicate").font(.title3).bold()
                            Spacer()
                            Image(systemName: "document.on.document").font(.title3)
                        }
                        .padding(12)
                        .background(Color.gray.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                    }.buttonStyle(.plain)
                } else {
                    Button {
                        if isOnline {
                            showSettingsSheet = false
                            
                            let data = [
                                "name": task.name,
                            ] as [String : Any]
                            
                            TaskService().newRequest(type: "\(task.instance)duplicateTask", data: data)
                            
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                        } else {
                            UINotificationFeedbackGenerator().notificationOccurred(.error)
                            popRoot.presentAlert(image: "exclamationmark.shield", text: "Turn on Wealth AIO first")
                        }
                    } label: {
                        HStack {
                            Text("Duplicate").font(.title3).bold()
                            Spacer()
                            Image(systemName: "document.on.document").font(.title3)
                        }
                        .padding(12)
                        .background(Color.gray.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                    }.buttonStyle(.plain)
                }
                             
                Button {
                    UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                    showSettingsSheet = false
                    withAnimation(.easeInOut(duration: 0.25)){
                        showPassword = true
                    }
                } label: {
                    HStack {
                        Text("Enter Password").font(.title3).bold()
                        Spacer()
                        Image(systemName: "key").font(.title3)
                    }
                    .padding(12)
                    .background(Color.gray.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                }.buttonStyle(.plain)
                
                Button {
                    self.newName = task.name
                    UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                    showSettingsSheet = false
                    showRenameSheet = true
                } label: {
                    HStack {
                        Text("Rename Group").font(.title3).bold()
                        Spacer()
                        Image(systemName: "pencil").font(.title3)
                    }
                    .padding(12)
                    .background(Color.gray.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                }.buttonStyle(.plain)
                
                Button {
                    UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                    showSettingsSheet = false
                    
                    let updates: [String: Any] = [
                        "success": 0,
                        "failure": 0
                    ]
                    
                    TaskService().updateEvent(docId: task.id ?? "", updates: updates)
                } label: {
                    HStack {
                        Text("Reset Stats").font(.title3).bold()
                        Spacer()
                        Image(systemName: "eraser.fill").font(.title3)
                    }
                    .padding(12)
                    .background(Color.gray.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                }.buttonStyle(.plain)
                
                Button {
                    if task.isRunning {
                        UINotificationFeedbackGenerator().notificationOccurred(.error)
                        popRoot.presentAlert(image: "exclamationmark.shield",
                                             text: "Group must be off to delete")
                    } else if isOnline {
                        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                        showSettingsSheet = false
                        deleteGroupAlert = true
                    } else {
                        UINotificationFeedbackGenerator().notificationOccurred(.error)
                        popRoot.presentAlert(image: "exclamationmark.shield", text: "Turn on Wealth AIO first")
                    }
                } label: {
                    HStack {
                        Text("Delete").font(.title3).bold()
                        Spacer()
                        Image(systemName: "trash").font(.title3)
                    }
                    .padding(12)
                    .background(Color.red.opacity(0.85))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                }.buttonStyle(.plain)
                
            }.padding(.horizontal).padding(.top, 25)
        }
        .scrollIndicators(.hidden)
        .presentationDetents([.fraction(0.8)])
        .presentationCornerRadius(30).presentationDragIndicator(.visible)
        .background {
            ZStack {
                if colorScheme == .dark {
                    Color.white.ignoresSafeArea()
                }
                backColor().ignoresSafeArea().opacity(colorScheme == .dark ? 0.8 : 1.0)
            }
        }
    }
    @ViewBuilder
    func taskData() -> some View {
        HStack(spacing: 40){
            VStack(spacing: 4){
                Text("\(task.count)").font(.title2).fontWeight(.heavy).lineLimit(1)
                Text(task.count == 1 ? "Task" : "Tasks").font(.subheadline)
            }
            Divider().frame(height: 50).overlay(Color.gray)
            VStack(spacing: 4){
                Text("\(task.success)").font(.title2).fontWeight(.heavy).lineLimit(1)
                    .foregroundStyle(task.success > 0 ? .green : colorScheme == .dark ? .white : .black)
                Text("Success").font(.subheadline)
            }
            Divider().frame(height: 50).overlay(Color.gray)
            VStack(spacing: 4){
                Text("\(task.failure)").font(.title2).fontWeight(.heavy).lineLimit(1)
                    .foregroundStyle(task.failure > 0 ? .red : colorScheme == .dark ? .white : .black)
                Text("Failure").font(.subheadline)
            }
        }
        .padding(10).padding(.horizontal)
        .background(Color.gray.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .contentShape(RoundedRectangle(cornerRadius: 12))
    }
    @ViewBuilder
    func lineRowView(index: Int, entry: String) -> some View {
        
        let context = extractTask(from: entry)
        
        HStack {
            
            if isSelecting {
                ZStack(alignment: .trailing){
                    Rectangle()
                        .foregroundStyle(.gray).opacity(0.001)
                        .frame(width: 30, height: 50)
                    
                    if selectedTasks.contains(index) {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable().scaledToFill().frame(width: 21, height: 21)
                            .foregroundStyle(Color.babyBlue)
                    } else {
                        Circle()
                            .stroke(Color.babyBlue, lineWidth: 2)
                            .frame(width: 20, height: 20)
                    }
                }
            }
            
            VStack {
                if let context {
                    HStack(spacing: 10){
                        Text(formatSiteName(site: context.site)).font(.headline).bold()
                        
                        Spacer()
                        
                        Text(formatMode(mode: context.mode)).bold().foregroundStyle(.blue)
                        
                        Menu {
                            contextOptions(index: index)
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.subheadline)
                                .padding(11)
                                .background(content: {
                                    TransparentBlurView(removeAllFilters: true)
                                        .blur(radius: 14, opaque: true)
                                        .background(colorScheme == .dark ? .black.opacity(0.4) : .white.opacity(0.4))
                                })
                                .clipShape(Circle())
                                .shadow(color: .gray, radius: 2)
                        }.buttonStyle(.plain)
                    }
                    
                    HStack(spacing: 8){
                        Text("Input:").font(.body).bold()
                        
                        Text(context.input).font(.body).fontWeight(.light).lineLimit(1)
                        
                        Spacer()
                    }
                    .padding(10)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .contentShape(RoundedRectangle(cornerRadius: 12))
                    
                    HStack(spacing: 8){
                        Spacer()
                        VStack(spacing: 2){
                            let isEmpty = context.profileGroup.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            Text(isEmpty ? "---" : context.profileGroup)
                                .font(.body).bold().lineLimit(1)
                            Text("Profile Group").font(.caption)
                        }
                        Spacer()
                        VStack(spacing: 2){
                            let isEmpty = context.profileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            
                            if context.profileName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "all" {
                                Text("ALL")
                                    .font(.body).bold().lineLimit(1).italic()
                            } else {
                                Text(isEmpty ? "---" : context.profileName)
                                    .font(.body).bold().lineLimit(1)
                            }
                            
                            Text("Profile").font(.caption)
                        }
                        Spacer()
                        VStack(spacing: 2){
                            let isEmpty = context.proxyGroup.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            
                            if isEmpty || context.proxyGroup.lowercased() == "na" {
                                Text("Local Host").font(.body).bold().lineLimit(1).italic()
                            } else {
                                Text(context.proxyGroup).font(.body).bold().lineLimit(1)
                            }
                            
                            Text("Proxy Group").font(.caption)
                        }
                        Spacer()
                    }
                    .padding(10)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .contentShape(RoundedRectangle(cornerRadius: 12))
                    
                    TagLayout(alignment: .leading, spacing: 8) {
                        if context.cartQuantity > 1 {
                            HStack(spacing: 2){
                                Image(systemName: "cart")
                                Text("\(context.cartQuantity)").lineLimit(1)
                            }
                            .font(.caption)
                            .padding(.horizontal, 6).padding(.vertical, 4)
                            .background(Color.babyBlue.gradient.opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        if !context.accountGroup.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            HStack(spacing: 2){
                                Image(systemName: "person")
                                Text(context.accountGroup).lineLimit(1)
                            }
                            .font(.caption)
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background(Color.babyBlue.gradient.opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        if !context.size.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            HStack(spacing: 2){
                                Image(systemName: "shoe")
                                Text(context.size).lineLimit(1)
                            }
                            .font(.caption)
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background(Color.babyBlue.gradient.opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        if !context.color.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            HStack(spacing: 4){
                                ZStack {
                                    Circle().foregroundStyle(.blue).offset(y: 3).offset(x: 2)
                                    Circle().foregroundStyle(.red).offset(y: 3).offset(x: -2)
                                    Circle().foregroundStyle(.green).offset(y: -3)
                                }.frame(width: 12, height: 12).offset(x: -1)
                                
                                Text(context.color).lineLimit(1)
                            }
                            .font(.caption)
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background(Color.babyBlue.gradient.opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        if !context.discountCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            HStack(spacing: 2){
                                Image(systemName: "dollarsign.arrow.trianglehead.counterclockwise.rotate.90")
                                Text(context.discountCode).lineLimit(1)
                            }
                            .font(.caption)
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background(Color.babyBlue.gradient.opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        if context.maxBuyQuantity < 100 {
                            HStack(spacing: 2){
                                Image(systemName: "chart.pie.fill")
                                Text("\(context.maxBuyQuantity)").lineLimit(1)
                            }
                            .font(.caption)
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background(Color.babyBlue.gradient.opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                } else {
                    HStack {
                        Spacer()
                        Text("Could not parse file entry, fix format!")
                            .foregroundStyle(.red).font(.subheadline)
                        Spacer()
                    }.padding(.vertical)
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
        }
        .onTapGesture {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            
            if isSelecting {
                if selectedTasks.contains(index) {
                    selectedTasks.removeAll(where: { $0 == index })
                } else {
                    selectedTasks.append(index)
                }
            } else if task.isRunning {
                popRoot.presentAlert(image: "exclamationmark.shield",
                                     text: "Group must be off to edit")
            } else if isOnline {
                selectedTasks = [index]
                lock = (self.task.count != 1)
                if index < self.task.tasks.count {
                    if let setup = extractTask(from: self.task.tasks[index]) {
                        self.previousSetup = setup
                    }
                }
                
                self.setShippingLock = false
                if index < self.task.tasks.count && self.task.tasks.count > 1 {
                    self.task.tasks.forEach { element in
                        if let setup = extractTask(from: element) {
                            if formatMode(mode: setup.mode) == "SetShipping" {
                                self.setShippingLock = true
                            }
                        }
                    }
                }
                                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    editId = UUID()
                }
                showEditSheet = true
            } else {
                popRoot.presentAlert(image: "exclamationmark.shield",
                                     text: "Turn on Wealth AIO to edit")
            }
        }
    }
    func status() -> Int {
        if !isOnline {
            return 1
        }
        
        return task.isRunning ? 3 : (viewModel.startTaskQueue[task.name] != nil
                                     || viewModel.stopTaskQueue[task.name] != nil) ? 2 : 1
    }
    func getSiteUrl() -> String {
        if let site = extractTask(from: task.tasks.first ?? "")?.site {
            return site
        }
        return ""
    }
    func getImageName() -> String {
        if let site = extractTask(from: task.tasks.first ?? "")?.site {
            if site.contains("pokemon") {
                return "pokemon"
            } else if site.contains("nike") {
                return colorScheme == .dark ? "nikeW" : "nikeB"
            } else if site.contains("popmart") {
                return "popmart"
            } else {
                return "shopify"
            }
        } else {
            return "shopify"
        }
    }
    @ViewBuilder
    func scheduleSheet() -> some View {
        VStack {
            ZStack {
                Text("Schedule Task").font(.title).bold()
                
                HStack {
                    Spacer()
                    Button {
                        showSchedule = false
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
            }.padding(.top, 15)
            
            if let date = task.schedule, status() == 1 && date.dateValue() > Date() {
                HStack {
                    VStack(alignment: .leading, spacing: 4){
                        Text("Task Scheduled!").font(.headline).fontWeight(.heavy)
                        Text(formattedDateString(from: date.dateValue())).font(.caption).foregroundStyle(.gray)
                    }
                    
                    Spacer()
                    
                    Button {
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                        TaskService().deleteSchedule(docId: task.id ?? "")
                        showSchedule = false
                    } label: {
                        Text("Delete").font(.subheadline).bold()
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(Color.red).clipShape(Capsule()).shadow(color: .gray, radius: 3)
                    }.buttonStyle(.plain)
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
                .padding(.horizontal, 12)
            }
            
            VStack(spacing: 0){
                DatePicker(
                    "",
                    selection: $selectedDate,
                    in: minDate...maxDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.wheel).labelsHidden()
                
                Picker("Seconds", selection: $selectedSeconds) {
                    ForEach(0..<60, id: \.self) { second in
                        Text("\(second) sec").tag(second)
                    }
                }.pickerStyle(.wheel).offset(y: -10)
            }
            
            Spacer()
            
            Button {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                
                var baseDate = Calendar.current.date(bySetting: .second, value: 0, of: selectedDate) ?? selectedDate
                
                baseDate = Calendar.current.date(byAdding: .minute, value: -1, to: baseDate) ?? baseDate

                let updatedDate: Date
                if selectedSeconds > 0 {
                    updatedDate = Calendar.current.date(byAdding: .second, value: selectedSeconds, to: baseDate) ?? baseDate
                } else {
                    updatedDate = baseDate
                }

                let updates: [String: Any] = [
                    "schedule": Timestamp(date: updatedDate)
                ]
                
                TaskService().updateEvent(docId: task.id ?? "", updates: updates)
                
                showSchedule = false
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 12).foregroundStyle(Color.babyBlue).frame(height: 45)
                    Text(task.schedule != nil ? "Edit Schedule" : "Schedule Task")
                        .font(.headline).bold()
                }
            }.buttonStyle(.plain).padding(.horizontal).padding(.bottom, 40)
        }
        .presentationDetents([.fraction(0.7)])
        .presentationCornerRadius(30).presentationDragIndicator(.visible)
        .ignoresSafeArea()
    }
    @ViewBuilder
    func toggle() -> some View {
        HStack {
            let status = status()
            
            if status == 3 { Spacer() }
            
            ZStack {
                
                Circle()
                    .fill(colorScheme == .light ? .white : .black)
                    .padding(2)
                
                if status == 2 {
                    ProgressView()
                } else {
                    Text(status == 3 ? "ON" : "OFF")
                        .font(.system(size: 14, weight: .black, design: .monospaced))
                        .foregroundStyle(onColor.gradient)
                }
            }
            
            if status == 1 { Spacer() }
        }
        .frame(width: 32 * 1.95, height: 33)
        .background(onColor.gradient)
        .clipShape(Capsule())
        .onTapGesture {
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            if !isOnline {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                popRoot.presentAlert(image: "exclamationmark.shield", text: "Turn on Wealth AIO first")
            } else {
                if task.instance == 1 {
                    if viewModel.stopTaskQueue[task.name] != nil {
                        UINotificationFeedbackGenerator().notificationOccurred(.error)
                    } else if viewModel.stopTaskQueue[task.name] != nil {
                        UINotificationFeedbackGenerator().notificationOccurred(.error)
                    } else if task.isRunning {
                        let requestId = UUID().uuidString
                        
                        TaskService().newRequest(type: "\(task.instance)stopTask\(task.name)", data: [:], addUUID: false)
                        
                        DispatchQueue.main.async {
                            viewModel.stopTaskQueue[task.name] = requestId
                            statusChanged.toggle()
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                            if let checkRequestId = viewModel.stopTaskQueue[task.name] {
                                if checkRequestId == requestId {
                                    viewModel.stopTaskQueue.removeValue(forKey: task.name)
                                    statusChanged.toggle()
                                    popRoot.presentAlert(image: "exclamationmark.shield", text: "Failed to stop " + task.name + ", ensure server online.")
                                }
                            }
                        }
                    } else {
                        let requestId = UUID().uuidString
                        
                        TaskService().newRequest(type: "\(task.instance)startTask\(task.name)", data: [:], addUUID: false)
                        
                        DispatchQueue.main.async {
                            viewModel.startTaskQueue[task.name] = requestId
                            statusChanged.toggle()
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                            if let checkRequestId = viewModel.startTaskQueue[task.name] {
                                if checkRequestId == requestId {
                                    viewModel.startTaskQueue.removeValue(forKey: task.name)
                                    statusChanged.toggle()
                                    popRoot.presentAlert(image: "exclamationmark.shield", text: "Failed to start " + task.name + ", ensure server online.")
                                }
                            }
                        }
                    }
                } else if task.instance == 2 {
                    if viewModel.stopTaskQueue2[task.name] != nil {
                        UINotificationFeedbackGenerator().notificationOccurred(.error)
                    } else if viewModel.stopTaskQueue2[task.name] != nil {
                        UINotificationFeedbackGenerator().notificationOccurred(.error)
                    } else if task.isRunning {
                        let requestId = UUID().uuidString
                        
                        TaskService().newRequest(type: "\(task.instance)stopTask\(task.name)", data: [:], addUUID: false)
                        
                        DispatchQueue.main.async {
                            viewModel.stopTaskQueue2[task.name] = requestId
                            statusChanged.toggle()
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                            if let checkRequestId = viewModel.stopTaskQueue2[task.name] {
                                if checkRequestId == requestId {
                                    viewModel.stopTaskQueue2.removeValue(forKey: task.name)
                                    statusChanged.toggle()
                                    popRoot.presentAlert(image: "exclamationmark.shield", text: "Failed to stop " + task.name + ", ensure server online.")
                                }
                            }
                        }
                    } else {
                        let requestId = UUID().uuidString
                        
                        TaskService().newRequest(type: "\(task.instance)startTask\(task.name)", data: [:], addUUID: false)
                        
                        DispatchQueue.main.async {
                            viewModel.startTaskQueue2[task.name] = requestId
                            statusChanged.toggle()
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                            if let checkRequestId = viewModel.startTaskQueue2[task.name] {
                                if checkRequestId == requestId {
                                    viewModel.startTaskQueue2.removeValue(forKey: task.name)
                                    statusChanged.toggle()
                                    popRoot.presentAlert(image: "exclamationmark.shield", text: "Failed to start " + task.name + ", ensure server online.")
                                }
                            }
                        }
                    }
                } else if task.instance == 3 {
                    if viewModel.stopTaskQueue3[task.name] != nil {
                        UINotificationFeedbackGenerator().notificationOccurred(.error)
                    } else if viewModel.stopTaskQueue3[task.name] != nil {
                        UINotificationFeedbackGenerator().notificationOccurred(.error)
                    } else if task.isRunning {
                        let requestId = UUID().uuidString
                        
                        TaskService().newRequest(type: "\(task.instance)stopTask\(task.name)", data: [:], addUUID: false)
                        
                        DispatchQueue.main.async {
                            viewModel.stopTaskQueue3[task.name] = requestId
                            statusChanged.toggle()
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                            if let checkRequestId = viewModel.stopTaskQueue3[task.name] {
                                if checkRequestId == requestId {
                                    viewModel.stopTaskQueue3.removeValue(forKey: task.name)
                                    statusChanged.toggle()
                                    popRoot.presentAlert(image: "exclamationmark.shield", text: "Failed to stop " + task.name + ", ensure server online.")
                                }
                            }
                        }
                    } else {
                        let requestId = UUID().uuidString
                        
                        TaskService().newRequest(type: "\(task.instance)startTask\(task.name)", data: [:], addUUID: false)
                        
                        DispatchQueue.main.async {
                            viewModel.startTaskQueue3[task.name] = requestId
                            statusChanged.toggle()
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                            if let checkRequestId = viewModel.startTaskQueue3[task.name] {
                                if checkRequestId == requestId {
                                    viewModel.startTaskQueue3.removeValue(forKey: task.name)
                                    statusChanged.toggle()
                                    popRoot.presentAlert(image: "exclamationmark.shield", text: "Failed to start " + task.name + ", ensure server online.")
                                }
                            }
                        }
                    }
                } else if task.instance == 4 {
                    if viewModel.stopTaskQueue4[task.name] != nil {
                        UINotificationFeedbackGenerator().notificationOccurred(.error)
                    } else if viewModel.stopTaskQueue4[task.name] != nil {
                        UINotificationFeedbackGenerator().notificationOccurred(.error)
                    } else if task.isRunning {
                        let requestId = UUID().uuidString
                        
                        TaskService().newRequest(type: "\(task.instance)stopTask\(task.name)", data: [:], addUUID: false)
                        
                        DispatchQueue.main.async {
                            viewModel.stopTaskQueue4[task.name] = requestId
                            statusChanged.toggle()
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                            if let checkRequestId = viewModel.stopTaskQueue4[task.name] {
                                if checkRequestId == requestId {
                                    viewModel.stopTaskQueue4.removeValue(forKey: task.name)
                                    statusChanged.toggle()
                                    popRoot.presentAlert(image: "exclamationmark.shield", text: "Failed to stop " + task.name + ", ensure server online.")
                                }
                            }
                        }
                    } else {
                        let requestId = UUID().uuidString
                        
                        TaskService().newRequest(type: "\(task.instance)startTask\(task.name)", data: [:], addUUID: false)
                        
                        DispatchQueue.main.async {
                            viewModel.startTaskQueue4[task.name] = requestId
                            statusChanged.toggle()
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                            if let checkRequestId = viewModel.startTaskQueue4[task.name] {
                                if checkRequestId == requestId {
                                    viewModel.startTaskQueue4.removeValue(forKey: task.name)
                                    statusChanged.toggle()
                                    popRoot.presentAlert(image: "exclamationmark.shield", text: "Failed to start " + task.name + ", ensure server online.")
                                }
                            }
                        }
                    }
                } else if task.instance == 5 {
                    if viewModel.stopTaskQueue5[task.name] != nil {
                        UINotificationFeedbackGenerator().notificationOccurred(.error)
                    } else if viewModel.stopTaskQueue5[task.name] != nil {
                        UINotificationFeedbackGenerator().notificationOccurred(.error)
                    } else if task.isRunning {
                        let requestId = UUID().uuidString
                        
                        TaskService().newRequest(type: "\(task.instance)stopTask\(task.name)", data: [:], addUUID: false)
                        
                        DispatchQueue.main.async {
                            viewModel.stopTaskQueue5[task.name] = requestId
                            statusChanged.toggle()
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                            if let checkRequestId = viewModel.stopTaskQueue5[task.name] {
                                if checkRequestId == requestId {
                                    viewModel.stopTaskQueue5.removeValue(forKey: task.name)
                                    statusChanged.toggle()
                                    popRoot.presentAlert(image: "exclamationmark.shield", text: "Failed to stop " + task.name + ", ensure server online.")
                                }
                            }
                        }
                    } else {
                        let requestId = UUID().uuidString
                        
                        TaskService().newRequest(type: "\(task.instance)startTask\(task.name)", data: [:], addUUID: false)
                        
                        DispatchQueue.main.async {
                            viewModel.startTaskQueue5[task.name] = requestId
                            statusChanged.toggle()
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                            if let checkRequestId = viewModel.startTaskQueue5[task.name] {
                                if checkRequestId == requestId {
                                    viewModel.startTaskQueue5.removeValue(forKey: task.name)
                                    statusChanged.toggle()
                                    popRoot.presentAlert(image: "exclamationmark.shield", text: "Failed to start " + task.name + ", ensure server online.")
                                }
                            }
                        }
                    }
                } else if task.instance == 6 {
                    if viewModel.stopTaskQueue6[task.name] != nil {
                        UINotificationFeedbackGenerator().notificationOccurred(.error)
                    } else if viewModel.stopTaskQueue6[task.name] != nil {
                        UINotificationFeedbackGenerator().notificationOccurred(.error)
                    } else if task.isRunning {
                        let requestId = UUID().uuidString
                        
                        TaskService().newRequest(type: "\(task.instance)stopTask\(task.name)", data: [:], addUUID: false)
                        
                        DispatchQueue.main.async {
                            viewModel.stopTaskQueue6[task.name] = requestId
                            statusChanged.toggle()
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                            if let checkRequestId = viewModel.stopTaskQueue6[task.name] {
                                if checkRequestId == requestId {
                                    viewModel.stopTaskQueue6.removeValue(forKey: task.name)
                                    statusChanged.toggle()
                                    popRoot.presentAlert(image: "exclamationmark.shield", text: "Failed to stop " + task.name + ", ensure server online.")
                                }
                            }
                        }
                    } else {
                        let requestId = UUID().uuidString
                        
                        TaskService().newRequest(type: "\(task.instance)startTask\(task.name)", data: [:], addUUID: false)
                        
                        DispatchQueue.main.async {
                            viewModel.startTaskQueue6[task.name] = requestId
                            statusChanged.toggle()
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                            if let checkRequestId = viewModel.startTaskQueue6[task.name] {
                                if checkRequestId == requestId {
                                    viewModel.startTaskQueue6.removeValue(forKey: task.name)
                                    statusChanged.toggle()
                                    popRoot.presentAlert(image: "exclamationmark.shield", text: "Failed to start " + task.name + ", ensure server online.")
                                }
                            }
                        }
                    }
                } else {
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                    popRoot.presentAlert(image: "exclamationmark.shield", text: "Error instance ID! Fix Nickname.json file.")
                }
            }
        }
    }
    
    private var onColor: Color { status() == 2 ? .orange : status() == 3 ? .green : .red }
    
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
            
            Text("\(selectedTasks.count) Selected").font(.title3).bold()
            
            Spacer()
                        
            Menu {
                if !selectedTasks.isEmpty {
                    Button(role: .destructive){
                        if task.isRunning {
                            UINotificationFeedbackGenerator().notificationOccurred(.error)
                            popRoot.presentAlert(image: "exclamationmark.shield",
                                                 text: "Task must be off to delete")
                        } else if isOnline {
                            let data = [
                                "name": task.name,
                                "lines": selectedTasks
                            ] as [String : Any]
                            
                            TaskService().newRequest(type: "\(task.instance)deleteLines", data: data)
                            
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                            
                            popRoot.presentAlert(image: "checkmark", text: "Request sent please wait")
                            
                            self.selectedTasks = []
                        } else {
                            UINotificationFeedbackGenerator().notificationOccurred(.error)
                            popRoot.presentAlert(image: "exclamationmark.shield", text: "Turn on Wealth AIO first")
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    Divider()
                    Button {
                        if task.isRunning {
                            UINotificationFeedbackGenerator().notificationOccurred(.error)
                            popRoot.presentAlert(image: "exclamationmark.shield",
                                                 text: "Task must be off to edit")
                        } else if isOnline {
                            lock = (self.task.count != selectedTasks.count)
                            if let first = selectedTasks.first, first < self.task.tasks.count {
                                if let setup = extractTask(from: self.task.tasks[first]) {
                                    self.previousSetup = setup
                                }
                            }
                            
                            self.setShippingLock = false
                            if self.task.tasks.count > 1 && selectedTasks.count != self.task.tasks.count {
                                self.task.tasks.forEach { element in
                                    if let setup = extractTask(from: element) {
                                        if formatMode(mode: setup.mode) == "SetShipping" {
                                            self.setShippingLock = true
                                        }
                                    }
                                }
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                editId = UUID()
                            }
                            showEditSheet = true
                        } else {
                            UINotificationFeedbackGenerator().notificationOccurred(.error)
                            popRoot.presentAlert(image: "exclamationmark.shield", text: "Turn on Wealth AIO first")
                        }
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    Button {
                        var pickedTasks = [String]()
                        
                        selectedTasks.forEach { idx in
                            pickedTasks.append(task.tasks[idx])
                        }
                        
                        let csvContent = generateTaskCSV(from: pickedTasks)
                        
                        if let url = saveToFile(content: csvContent, isCSV: true, fileName: task.name) {
                            fileURL = url
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                                showExportShareSheet = true
                            }
                        }
                    } label: {
                        Label("Share setup", systemImage: "arrowshape.turn.up.forward.fill")
                    }
                    Button {
                        if task.isRunning {
                            UINotificationFeedbackGenerator().notificationOccurred(.error)
                            popRoot.presentAlert(image: "exclamationmark.shield",
                                                 text: "Group must be off to duplicate")
                        } else if isOnline {
                            let data = [
                                "name": task.name,
                                "lines": selectedTasks
                            ] as [String : Any]
                            
                            TaskService().newRequest(type: "\(task.instance)duplicateLines", data: data)
                            
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                            
                            popRoot.presentAlert(image: "checkmark", text: "Request sent please wait")
                        } else {
                            UINotificationFeedbackGenerator().notificationOccurred(.error)
                            popRoot.presentAlert(image: "exclamationmark.shield", text: "Turn on Wealth AIO first")
                        }
                    } label: {
                        Label("Duplicate", systemImage: "document.on.document")
                    }
                } else {
                    Text("Select entries to see options")
                }
            } label: {
                ZStack {
                    Circle().frame(width: 40, height: 40).foregroundStyle(.blue).opacity(0.4)
                    
                    Image(systemName: "gear").font(.title3)
                }
            }.buttonStyle(.plain)
            
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                selectedTasks = []
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

            HStack(spacing: 10){
                Image(getImageName())
                    .resizable()
                    .scaledToFill()
                    .frame(width: 38, height: 38)
                    .clipShape(Circle()).contentShape(Circle())
                    .shadow(color: .gray, radius: 2)
                
                VStack(alignment: .leading, spacing: 0){
                    Text(task.name).font(.title3).bold()
                        .lineLimit(1).minimumScaleFactor(0.8)
                    
                    if (auth.currentUser?.ownedInstances ?? 0) > 0 {
                        if let instance = viewModel.instances?.first(where: { $0.instanceId == task.instance })?.nickName, !instance.isEmpty {
                            Text(isOnline ? "\(instance) Online" : "\(instance) Offline")
                                .font(.caption).foregroundStyle(isOnline ? .green : .red).fontWeight(.light)
                                .lineLimit(1).minimumScaleFactor(0.8)
                        } else {
                            Text("Instance \(task.instance) \(isOnline ? "Online" : "Offline")").font(.caption)
                        }
                    } else {
                        Text(isOnline ? "Server Online" : "Server Offline")
                            .font(.caption).foregroundStyle(isOnline ? .green : .red).fontWeight(.light)
                            .lineLimit(1).minimumScaleFactor(0.8)
                    }
                }
            }
            .onTapGesture {
                if !task.tasks.isEmpty {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    showSettingsSheet = true
                }
            }
            
            Spacer()
            
            if isOnline && status() == 3 && hasPopmartWaitMode() {
                Button {
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    
                    TaskService().newRequest(type: "\(task.instance)unblock\(task.name)", data: [:], addUUID: false)
                    
                    popRoot.presentAlert(image: "checkmark", text: "Start request sent!")
                } label: {
                    ZStack {
                        LinearGradient(colors: [.blue, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing)
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())

                        Image(systemName: "play.fill").font(.title3)
                    }
                }.buttonStyle(.plain).transition(.scale)
            }
            
            if task.tasks.isEmpty {
                Menu {
                    Button(role: .destructive){
                        if task.isRunning {
                            UINotificationFeedbackGenerator().notificationOccurred(.error)
                            popRoot.presentAlert(image: "exclamationmark.shield",
                                                 text: "Group must be off to delete")
                        } else if isOnline {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            deleteGroupAlert = true
                        } else {
                            UINotificationFeedbackGenerator().notificationOccurred(.error)
                            popRoot.presentAlert(image: "exclamationmark.shield", text: "Turn on Wealth AIO first")
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    
                    Divider()
                    
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()

                        lock = false
                        self.setShippingLock = false
                        
                        self.previousSetup = BotTask(profileGroup: "", profileName: "", proxyGroup: "", accountGroup: "", input: "", size: "", color: "", site: "", mode: "", cartQuantity: 1, delay: 3500, discountCode: "", maxBuyPrice: 99999, maxBuyQuantity: 99999)
                        
                        showAddSheet = true
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            addId = UUID()
                        }
                    } label: {
                        Label("Add tasks", systemImage: "plus")
                    }
                } label: {
                    ZStack {
                        Circle().frame(width: 40, height: 40).foregroundStyle(.gray).opacity(0.4)
                        
                        Image(systemName: "gear").font(.title3)
                    }
                }.buttonStyle(.plain)
            } else {
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

            toggle().id(statusChanged)
        }
        .padding(.top, top_Inset()).padding(.horizontal, 10).padding(.bottom, 10)
        .background {
            TransparentBlurView(removeAllFilters: true).blur(radius: 14, opaque: true)
        }
        .overlay(alignment: .bottom) {
            Divider()
        }
    }
    @ViewBuilder
    func contextOptions(index: Int) -> some View {
        Button(role: .destructive){
            if task.isRunning {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                popRoot.presentAlert(image: "exclamationmark.shield",
                                     text: "Task must be off to delete")
            } else if isOnline {
                let data = [
                    "name": task.name,
                    "lines": [index]
                ] as [String : Any]
                
                TaskService().newRequest(type: "\(task.instance)deleteLines", data: data)
                
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                
                popRoot.presentAlert(image: "checkmark", text: "Request sent please wait")
            } else {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                popRoot.presentAlert(image: "exclamationmark.shield", text: "Turn on Wealth AIO first")
            }
        } label: {
            Label("Delete", systemImage: "trash")
        }
        Divider()
        Button {
            if task.isRunning {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                popRoot.presentAlert(image: "exclamationmark.shield",
                                     text: "Task must be off to edit")
            } else if isOnline {
                selectedTasks = [index]
                lock = (self.task.count != 1)
                if index < self.task.tasks.count {
                    if let setup = extractTask(from: self.task.tasks[index]) {
                        self.previousSetup = setup
                    }
                }
                
                self.setShippingLock = false
                if index < self.task.tasks.count && self.task.tasks.count > 1 {
                    self.task.tasks.forEach { element in
                        if let setup = extractTask(from: element) {
                            if formatMode(mode: setup.mode) == "SetShipping" {
                                self.setShippingLock = true
                            }
                        }
                    }
                }
                
                showEditSheet = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    editId = UUID()
                }
            } else {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                popRoot.presentAlert(image: "exclamationmark.shield", text: "Turn on Wealth AIO first")
            }
        } label: {
            Label("Edit", systemImage: "pencil")
        }
        Button {
            if task.isRunning {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                popRoot.presentAlert(image: "exclamationmark.shield",
                                     text: "Group must be off to duplicate")
            } else if isOnline {
                let data = [
                    "name": task.name,
                    "lines": [index]
                ] as [String : Any]
                
                TaskService().newRequest(type: "\(task.instance)duplicateLines", data: data)
                
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                
                popRoot.presentAlert(image: "checkmark", text: "Request sent please wait")
            } else {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                popRoot.presentAlert(image: "exclamationmark.shield", text: "Turn on Wealth AIO first")
            }
        } label: {
            Label("Duplicate", systemImage: "document.on.document")
        }
        if let input = extractTask(from: task.tasks[index])?.input {
            Button {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                UIPasteboard.general.string = input
            } label: {
                Label("Copy Input", systemImage: "link")
            }
        }
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

func formatMode(mode: String) -> String {
    let newMode = mode.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    
    if newMode.contains("ship") {
        return "SetShipping"
    } else if newMode == "wait" {
        return "Wait"
    } else if newMode == "preload" {
        return "Preload"
    } else if newMode == "fast" {
        return "Fast"
    } else if newMode == "raffle" {
        return "Raffle"
    } else if newMode == "flow" {
        return "Flow"
    } else if newMode == "normalmanual" {
        return "NormalManual"
    } else if newMode == "fastmanual" {
        return "FastManual"
    } else if newMode == "waitmanual" {
        return "WaitManual"
    }
    
    return "Normal"
}

func formatSiteName(site: String) -> String {
    if site.contains("pokemon") {
        return "Pokemon"
    } else if site.contains("nike") {
        return "Nike"
    } else if site.contains("popmart") {
        let region = site.suffix(2).uppercased()
        
        if region.count == 2 {
            return "Popmart \(region)"
        } else {
            return "Popmart"
        }
    } else {
        if let name = allSites.first(where: { $0.value == site }) {
            return name.key
        }
        return "shopify"
    }
}

func createArray(upperBound: Int) -> [Int] {
    return Array(0..<upperBound)
}
