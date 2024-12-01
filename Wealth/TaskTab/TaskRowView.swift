import SwiftUI
import FirebaseCore

struct TaskRowView: View {
    @Environment(TaskViewModel.self) private var viewModel
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var popRoot: PopToRoot
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedSeconds: Int = 30
    @State var selectedDate: Date = Date()
    @State var minDate: Date = Date()
    @State var maxDate: Date = Date()
    @State var showSchedule = false
    @State var statusChanged = false
    @State var showExportShareSheet = false
    @State var showRenameSheet = false
    @State var newName = ""
    @State var fileURL: URL?
    
    let task: TaskFile
    let isOnline: Bool
    let openPassword: (String) -> Void
    let moveTop: () -> Void

    var body: some View {
        VStack {
            HStack {
                Image(getImageName())
                    .resizable()
                    .scaledToFill()
                    .frame(width: 35, height: 35)
                    .clipShape(Circle()).contentShape(Circle())
                    .shadow(color: .gray, radius: 2)
                
                if (auth.currentUser?.ownedInstances ?? 0) > 0 {
                    VStack(alignment: .leading, spacing: 0){
                        Text(task.name).font(.title3).bold()
                        
                        if let instance = viewModel.instances?.first(where: { $0.instanceId == task.instance })?.nickName, !instance.isEmpty {
                            Text(instance).font(.caption).lineLimit(1)
                                .foregroundStyle(isOnline ? Color.green : Color.red)
                        } else {
                            Text("Instance \(task.instance)").font(.caption)
                                .foregroundStyle(isOnline ? Color.green : Color.red)
                        }
                    }
                } else {
                    Text(task.name).font(.title3).bold()
                }
                
                Spacer()
                
                if isOnline && status() == 3 && hasPopmartWaitMode() {
                    Button {
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                        
                        TaskService().newRequest(type: "\(task.instance)unblock\(task.name)", data: [:], addUUID: false)
                        
                        popRoot.presentAlert(image: "checkmark", text: "Start request sent!")
                    } label: {
                        Image(systemName: "play.fill")
                            .font(.body)
                            .padding(10)
                            .background {
                                LinearGradient(colors: [.blue, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing)
                            }
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }.buttonStyle(.plain).padding(.trailing, 10).transition(.scale)
                }
                
                toggle().id(statusChanged)
            }
            
            HStack(spacing: 30){
                VStack(spacing: 4){
                    Text("\(task.count)").font(.title3).fontWeight(.heavy).lineLimit(1)
                    Text(task.count == 1 ? "Task" : "Tasks").font(.subheadline)
                }
                Divider().frame(height: 50).overlay(Color.gray)
                VStack(spacing: 4){
                    Text("\(task.success)").font(.title3).fontWeight(.heavy).lineLimit(1)
                        .foregroundStyle(task.success > 0 ? .green : colorScheme == .dark ? .white : .black)
                    Text("Success").font(.subheadline)
                }
                Divider().frame(height: 50).overlay(Color.gray)
                VStack(spacing: 4){
                    Text("\(task.failure)").font(.title3).fontWeight(.heavy).lineLimit(1)
                        .foregroundStyle(task.failure > 0 ? .red : colorScheme == .dark ? .white : .black)
                    Text("Failure").font(.subheadline)
                }
            }
            .padding(10).padding(.horizontal)
            .background(Color.gray.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .contentShape(RoundedRectangle(cornerRadius: 12))
            
            HStack(spacing: 4){
                let status = status()
                
                let showSchedule: Bool = task.schedule != nil && status == 1 && (task.schedule?.dateValue() ?? Date()) > Date()
                
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
            }
        }
        .padding(13).frame(height: 165)
        .background(content: {
            TransparentBlurView(removeAllFilters: true)
                .blur(radius: 14, opaque: true)
                .background(colorScheme == .dark ? .black.opacity(0.4) : .white.opacity(0.4))
        })
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .contextMenu {

            let status = status()
            
            if isOnline && status != 3 {
                Button(role: .destructive){
                    if let id = task.id {
                        viewModel.disabledTasks.append(id)
                    }
                    
                    let data = [
                        "name": task.name,
                    ] as [String : Any]
                    
                    TaskService().newRequest(type: "\(task.instance)deleteTask", data: data)
                    
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                Divider()
            }
            
            let scheduleStatus = task.schedule != nil && status == 1 && (task.schedule?.dateValue() ?? Date()) > Date()
            
            if scheduleStatus {
                Button(role: .destructive){
                    TaskService().deleteSchedule(docId: task.id ?? "")
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                } label: {
                    Label("Delete Schedule", systemImage: "trash")
                }
            }
            Button {
                let now = Date()
                selectedDate = Calendar.current.date(byAdding: .hour, value: 1, to: now) ?? now
                minDate = Calendar.current.date(byAdding: .minute, value: 5, to: now) ?? now
                maxDate = Calendar.current.date(byAdding: .day, value: 4, to: now) ?? now
                
                showSchedule = true
            } label: {
                Label(scheduleStatus ? "Edit Schedule" : "Schedule", systemImage: "calendar")
            }
            
            if let instances = auth.currentUser?.ownedInstances, instances > 0 && isOnline {
                Menu {
                    ForEach(1..<(instances + 2), id: \.self) { index in
                        if index == task.instance {
                            Button {
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
                    Label("Duplicate", systemImage: "document.on.document")
                }
            } else {
                Button {
                    if isOnline {
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
                    Label("Duplicate", systemImage: "document.on.document")
                }
            }
            
            Button {
                moveTop()
            } label: {
                Label("Move top", systemImage: "arrow.up")
            }
            
            Button {
                newName = task.name
                showRenameSheet = true
            } label: {
                Label("Rename", systemImage: "pencil")
            }
            
            Button {
                let csvContent = generateTaskCSV(from: task.tasks)
                
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
                openPassword(getSiteUrl())
            } label: {
                Label("Enter password", systemImage: "key")
            }
            if getImageName() == "pokemon" && status == 3 {
                Button {
                    popRoot.presentAlert(image: "checkmark", text: "Override request sent!")
                    
                    let data = [
                        "name": task.name,
                    ] as [String : Any]
                    
                    TaskService().newRequest(type: "\(task.instance)overrideMonitor", data: data)
                } label: {
                    Label("Override Monitor", systemImage: "play.circle")
                }
            }
            if getImageName() == "shopify" {
                Button {
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
                        let new = QueueItems(url: siteUrl,
                                             name: getQueueName(baseUrl: siteUrl),
                                             exit: "NA",
                                             lastUpdate: nil)
                        
                        DispatchQueue.main.async {
                            withAnimation(.easeInOut(duration: 0.3)){
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
                    Label("Open Queue", systemImage: "line.3.horizontal")
                }
            }
        }
        .sheet(isPresented: $showRenameSheet, content: {
            renameSheet()
        })
        .sheet(isPresented: $showSchedule) {
            scheduleSheet()
        }
        .sheet(isPresented: $showExportShareSheet) {
            if let fileURL = fileURL {
                ShareSheet(activityItems: [fileURL])
            }
        }
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
}

func generateTaskCSV(from elements: [String]) -> String {
    var rows: [String] = []

    let header = "profileGroup,profileName,proxyGroup,accountGroup,input,size,color,site,mode,cartQuantity,delay,discountCode,Max Buy Price,Max Buy Quantity"
    
    rows.append(header)

    rows.append(contentsOf: elements)

    return rows.joined(separator: "\n")
}

func formattedDateString(from date: Date) -> String {
    let calendar = Calendar.current
    
    let formatter = DateFormatter()
    formatter.dateFormat = "h:mm:ss a"
    
    let timeString = formatter.string(from: date)
    
    if calendar.isDateInToday(date) {
        return "Today at \(timeString)"
    } else if calendar.isDateInTomorrow(date) {
        return "Tomorrow at \(timeString)"
    } else {
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMM"
        
        let day = calendar.component(.day, from: date)
        let ordinalFormatter = NumberFormatter()
        ordinalFormatter.numberStyle = .ordinal
        let dayOrdinal = ordinalFormatter.string(from: NSNumber(value: day)) ?? String(day)
        
        return "\(monthFormatter.string(from: date)) \(dayOrdinal) at \(timeString)"
    }
}

func getQueueName(baseUrl: String) -> String {
    if let name = allSites.first(where: { $0.value == baseUrl })?.key {
        return name
    }
    
    var trimmedUrl = baseUrl.replacingOccurrences(of: "www.", with: "")
    
    if trimmedUrl.contains("shop.") {
        trimmedUrl = baseUrl.replacingOccurrences(of: "shop.", with: "")
    }
        
    if let dotIndex = trimmedUrl.lastIndex(of: ".") {
        trimmedUrl = String(trimmedUrl[..<dotIndex])
    }
    
    return trimmedUrl.prefix(1).capitalized + trimmedUrl.dropFirst()
}
