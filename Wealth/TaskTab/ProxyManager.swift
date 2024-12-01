import SwiftUI

struct ProxyManager: View {
    @Environment(TaskViewModel.self) private var viewModel
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var popRoot: PopToRoot
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @State var measuringSpeed = [String]()
    @State var highlight: String? = nil
    @State var showDiscordSheet = false
    @State var isLoggedIn = false
    @State var discordUsername = ""
    @State var ScrollOrClose = false
    @State var canRefresh = true
    @State var discordUID = ""
    @State var appeared = true
    @State var isSoftSession = true
    
    // Create sheet
    @State var showNewProxyFile = false
    @State var newProxyFileName: String = ""
    @State var createCount: Int = 100
    @State var newProxyCountry: String = "United States"
    @State var newProxyState: String = "No Selection"
    @State var newProxyAddTo: String = ""
    @State var showExportShareSheet = false
    @State var fileURL: URL? = nil
    
    let openGen: Bool
    var instances: [Instance]?
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 10){
                    Color.clear.frame(height: 1).id("scrolltop")

                    wealthProxiesView()
                    
                    if let proxies = viewModel.proxies {
                        if proxies.isEmpty {
                            VStack(spacing: 12){
                                Text("Nothing yet...").font(.largeTitle).bold()
                                Text("Proxy files will appear here.").font(.caption).foregroundStyle(.gray)
                            }.padding(.top, 150)
                        } else {
                            HStack {
                                Text("Proxy Files").font(.headline).bold()
                                Spacer()
                            }.padding(.leading, 12).padding(.top)
                            ForEach(proxies) { file in
                                proxyRowView(file: file)
                                    .scrollTransition { content, phase in
                                        content
                                            .scaleEffect(phase == .identity ? 1 : 0.65)
                                            .blur(radius: phase == .identity ? 0 : 10)
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
                        }.shimmering().transition(.scale.combined(with: .opacity)).padding(.top)
                    }
                    
                    Color.clear.frame(height: 120)
                }
            }
            .safeAreaPadding(.top, 75 + top_Inset())
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
        }
        .ignoresSafeArea()
        .onAppear(perform: {
            appeared = true
            refreshDate()
            getResiLogin()
            showNewProxyFile = openGen
            
            if (self.instances ?? []).isEmpty {
                if (auth.currentUser?.ownedInstances ?? 0) > 0 && auth.possibleInstances.isEmpty {
                    Task {
                        CheckoutService().getPossibleInstances { instances in
                            DispatchQueue.main.async {
                                auth.possibleInstances = instances
                            }
                        }
                    }
                }
            }
        })
        .onDisappear {
            appeared = false
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showNewProxyFile, content: {
            createProxies()
        })
        .sheet(isPresented: $showExportShareSheet) {
            if let fileURL = fileURL {
                ShareSheet(activityItems: [fileURL])
            }
        }
        .onChange(of: discordUsername, { _, _ in
            if !discordUsername.isEmpty && !discordUID.isEmpty {
                UserService().updateDiscordInfo(username: discordUsername, discordUid: discordUID)
                if auth.currentUser?.discordUsername != discordUsername {
                    refreshDate()
                }
                withAnimation(.easeInOut(duration: 0.3)){
                    auth.currentUser?.discordUsername = discordUsername
                    auth.currentUser?.discordUID = discordUID
                }
                popRoot.presentAlert(image: "checkmark", text: "Discord Linked!")
                showDiscordSheet = false
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
    @ViewBuilder
    func createProxies() -> some View {
        VStack {
            ScrollView {
                ZStack {
                    Text("Residential Proxies").font(.title).bold()
                    
                    HStack {
                        Spacer()
                        Button {
                            showNewProxyFile = false
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
                
                if newProxyAddTo.isEmpty {
                    TextField("", text: $newProxyFileName)
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
                        .padding(.horizontal, 12)
                } else {
                    HStack {
                        VStack(alignment: .leading, spacing: 4){
                            Text("Adding to file").font(.headline).fontWeight(.heavy)
                            Text("Proxies will append to \(newProxyAddTo)")
                                .font(.caption).foregroundStyle(.gray).lineLimit(1).minimumScaleFactor(0.8)
                        }
                        
                        Spacer()
                        
                        Button {
                            withAnimation(.easeInOut(duration: 0.15)){
                                newProxyAddTo = ""
                            }
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                        } label: {
                            Text("Cancel").font(.subheadline).bold()
                                .padding(.horizontal, 12).padding(.vertical, 6)
                                .background(Color.babyBlue).clipShape(Capsule()).shadow(color: .gray, radius: 3)
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
                    .padding(.horizontal, 12).transition(.scale.combined(with: .opacity))
                }
                
                ZStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 4){
                            Text(isSoftSession ? "Soft Session" : "Hard Session").font(.headline).fontWeight(.heavy)
                            Text(isSoftSession ?
                                 "May rotate IP addresses" :
                                    "Sticks to the same IP address").font(.caption).foregroundStyle(.gray)
                        }
                        
                        Spacer()
                    }
                    
                    HStack {
                        Spacer()
                        
                        Toggle("", isOn: $isSoftSession)
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
                .padding(.horizontal, 12).padding(.top, 12)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4){
                        Text("Country").font(.headline).fontWeight(.heavy)
                        Text("Required field").font(.caption).foregroundStyle(.gray)
                    }
                    
                    Spacer()
                    
                    Picker("Country", selection: $newProxyCountry) {
                        ForEach(countriesResi, id: \.name) { country in
                            Text(country.name)
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
                .padding(.horizontal, 12).padding(.top, 12)
                
                if newProxyCountry == "United States" {
                    HStack {
                        VStack(alignment: .leading, spacing: 4){
                            Text("State").font(.headline).fontWeight(.heavy)
                            Text("Optional field").font(.caption).foregroundStyle(.gray)
                        }
                        
                        Spacer()
                        
                        Picker("State", selection: $newProxyState) {
                            ForEach((["No Selection"] + stateNames), id: \.self) {
                                Text($0)
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
                    .padding(.horizontal, 12).padding(.top, 12)
                }
                
                let options = [10, 50, 100, 250, 500, 750, 1000, 2500, 5000]
                
                TagLayout(alignment: .center, spacing: 10) {
                    ForEach(options, id: \.self) { val in
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            createCount = val
                        } label: {
                            Text("\(val)")
                                .font(.subheadline).bold()
                                .foregroundStyle(colorScheme == .dark ? .black : .white)
                                .padding(.horizontal, 14).padding(.vertical, 6)
                                .background((createCount == val ? Color.blue : Color.gray).gradient)
                                .clipShape(Capsule())
                        }.buttonStyle(.plain)
                    }
                }.padding(.horizontal, 20).padding(.top, 20)
            }
            .scrollIndicators(.hidden)
            
            if newProxyAddTo.isEmpty {
                Button {
                    if !newProxyFileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                        var countryId = "US"
                        
                        if let first = countriesResi.first(where: { $0.name == newProxyCountry })?.id {
                            countryId = first
                        }
                        
                        let state: String? = (newProxyState == "No Selection") ? nil : newProxyState
                        
                        let proxies = genProxies(userLogin: popRoot.userResiLogin ?? "", userPassword: popRoot.userResiPassword ?? "", countryId: countryId, state: state, genCount: createCount, SoftSession: isSoftSession)
                        
                        showNewProxyFile = false
                        
                        if let url = saveToFile(content: proxies, isCSV: false, fileName: newProxyFileName) {
                            fileURL = url
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                                showExportShareSheet = true
                            }
                        }
                    } else {
                        UINotificationFeedbackGenerator().notificationOccurred(.error)
                    }
                } label: {
                    HStack(spacing: 5){
                        Spacer()
                        Image(systemName: "arrowshape.turn.up.right.fill").font(.body).foregroundStyle(.blue).bold()
                        
                        Text("Share").font(.body)
                        Spacer()
                    }
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial).clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: .green, radius: 2.5)
                }
                .buttonStyle(.plain).padding(.bottom).padding(.horizontal, 12)
                .transition(.scale.combined(with: .opacity))
            }
            
            let instanceString = getInstances()
            let addStatus = !newProxyAddTo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            let nameStatus = !newProxyFileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            
            if instanceString.isEmpty || addStatus || !nameStatus {
                Button {
                    if nameStatus || addStatus {
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                        var countryId = "US"
                        
                        if let first = countriesResi.first(where: { $0.name == newProxyCountry })?.id {
                            countryId = first
                        }
                        
                        let state: String? = (newProxyState == "No Selection") ? nil : newProxyState
                        
                        TaskService().postProxyRequest(
                            request: ProxyRequest(
                                fileName: addStatus ? newProxyAddTo : newProxyFileName,
                                userLogin: popRoot.userResiLogin ?? "",
                                userPassword: popRoot.userResiPassword ?? "",
                                countryId: countryId,
                                stateName: state,
                                genCount: createCount,
                                append: addStatus ? viewModel.proxies?.first(where: { $0.name == newProxyAddTo })?.id : nil)
                            , instance: 1
                        )
                        
                        showNewProxyFile = false
                        
                        popRoot.presentAlert(image: "checkmark",
                                             text: "Proxy request sent to server!")
                    } else {
                        UINotificationFeedbackGenerator().notificationOccurred(.error)
                    }
                } label: {
                    HStack(spacing: 5){
                        Spacer()
                        Image(systemName: "square.and.arrow.up.fill").font(.body).foregroundStyle(.blue).bold()
                        
                        Text("Export to AIO").font(.body)
                        Spacer()
                    }
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial).clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: .blue, radius: 2.5)
                }.buttonStyle(.plain).padding(.bottom, 50).padding(.horizontal, 12)
            } else {
                Menu {
                    ForEach(Array(instanceString.enumerated()), id: \.element) { index, instance in
                        Button {
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                            var countryId = "US"
                            
                            if let first = countriesResi.first(where: { $0.name == newProxyCountry })?.id {
                                countryId = first
                            }
                            
                            let state: String? = (newProxyState == "No Selection") ? nil : newProxyState
                            
                            TaskService().postProxyRequest(
                                request: ProxyRequest(
                                    fileName: newProxyFileName,
                                    userLogin: popRoot.userResiLogin ?? "",
                                    userPassword: popRoot.userResiPassword ?? "",
                                    countryId: countryId,
                                    stateName: state,
                                    genCount: createCount,
                                    append: nil)
                                , instance: index + 1
                            )
                            
                            showNewProxyFile = false
                            
                            popRoot.presentAlert(image: "checkmark",
                                                 text: "Proxy request sent to \(instance)!")
                        } label: {
                            Label("\(index + 1). \(instance)", systemImage: "square.and.arrow.up")
                        }
                    }
                    
                    Divider()
                    
                    Button {
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                        var countryId = "US"
                        
                        if let first = countriesResi.first(where: { $0.name == newProxyCountry })?.id {
                            countryId = first
                        }
                        
                        let state: String? = (newProxyState == "No Selection") ? nil : newProxyState
                        
                        for i in 0..<(instanceString.count) {
                            TaskService().postProxyRequest(
                                request: ProxyRequest(
                                    fileName: newProxyFileName,
                                    userLogin: popRoot.userResiLogin ?? "",
                                    userPassword: popRoot.userResiPassword ?? "",
                                    countryId: countryId,
                                    stateName: state,
                                    genCount: createCount,
                                    append: nil)
                                , instance: i + 1
                            )
                        }
                        
                        showNewProxyFile = false
                        
                        popRoot.presentAlert(image: "checkmark",
                                             text: "Proxy request sent to instances!")
                    } label: {
                        Label("Export to All", systemImage: "square.and.arrow.up.fill")
                    }
                } label: {
                    HStack(spacing: 5){
                        Spacer()
                        Image(systemName: "square.and.arrow.up.fill").font(.body).foregroundStyle(.blue).bold()
                        
                        Text("Export to AIO").font(.body)
                        Spacer()
                    }
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial).clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: .blue, radius: 2.5)
                }.buttonStyle(.plain).padding(.bottom, 50).padding(.horizontal, 12)
            }
        }
        .presentationDetents([.large])
        .background { backColor() }
        .presentationCornerRadius(30).presentationDragIndicator(.visible)
        .ignoresSafeArea()
    }
    func getInstances() -> [String] {
        if let instances = self.instances, !instances.isEmpty {
            return instances.compactMap({ $0.nickName })
        }
        return auth.possibleInstances
    }
    func getResiLogin(withOpen: Bool = false) {
        if let dUID = auth.currentUser?.discordUID, popRoot.userResiPassword == nil {
            fetchUserCredentials(dUID: dUID) { username, password in
                if let username, let password {
                    DispatchQueue.main.async {
                        popRoot.userResiLogin = username
                        popRoot.userResiPassword = password
                    }
                    if withOpen {
                        showNewProxyFile = true
                    }
                } else if withOpen {
                    popRoot.presentAlert(image: "exclamationmark.bubble",
                                         text: "Failed to fetch credentials! Ensure you have purchased data")
                }
            }
        }
    }
    @ViewBuilder
    func wealthProxiesView() -> some View {
        VStack(spacing: 10){
            Image("Proxies")
                .resizable()
                .scaledToFill()
                .frame(width: 90, height: 90)
                .clipShape(Circle()).contentShape(Circle())
                .shadow(color: .gray, radius: 3).padding(.top)
            
            Text("Wealth Proxies").font(.title).bold()
            
            if let username = auth.currentUser?.discordUsername, let duid = auth.currentUser?.discordUID {
                
                HStack(spacing: 4){
                    Text("Left:").font(.subheadline).fontWeight(.light).foregroundStyle(.gray)
                    Text(popRoot.resisData?.trafficBalanceString ?? "-- GB").font(.subheadline).fontWeight(.heavy)
                        .padding(.trailing, 10)
                    
                    Text("Used:").font(.subheadline).fontWeight(.light).foregroundStyle(.gray)
                    Text(popRoot.resisData?.trafficConsumed ?? "-- GB").font(.subheadline).fontWeight(.heavy)
                }.lineLimit(1).minimumScaleFactor(0.8)
                
                HStack(spacing: 20){
                    Spacer()
                    
                    Button {
                        if popRoot.userResiPassword != nil && !(popRoot.userResiPassword ?? "").isEmpty {
                            showNewProxyFile = true
                        } else {
                            getResiLogin(withOpen: true)
                            popRoot.presentAlert(image: "hand.raised",
                                                 text: "Please wait as we fetch your credentials.")
                        }
                        
                        newProxyAddTo = ""
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    } label: {
                        HStack(spacing: 5){
                            Image(systemName: "plus")
                                .font(.body).foregroundStyle(.blue).bold()
                                .frame(width: 25, height: 25)
                                .background(colorScheme == .dark ? .white : .black)
                                .clipShape(Circle())
                            
                            Text("Gen Proxies").font(.body)
                        }
                        .padding(.horizontal, 10).padding(.vertical, 6)
                        .background(.ultraThinMaterial).clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: .green, radius: 1.5)
                    }.buttonStyle(.plain)
                    
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        fetchPurchaseLink(dUID: duid, dUsername: username) { urlStr in
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
                        HStack(spacing: 5){
                            Image(systemName: "dollarsign")
                                .font(.body).foregroundStyle(.blue).bold()
                                .frame(width: 25, height: 25)
                                .background(colorScheme == .dark ? .white : .black)
                                .clipShape(Circle())
                            
                            Text("Buy Data").font(.body)
                        }
                        .padding(.horizontal, 10).padding(.vertical, 6)
                        .background(.ultraThinMaterial).clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: .blue, radius: 1.5)
                    }.buttonStyle(.plain)
                    
                    Spacer()
                }
            } else {
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    discordUsername = ""
                    discordUID = ""
                    showDiscordSheet = true
                } label: {
                    HStack(spacing: 5){
                        Text("Link Discord").font(.body)
                    }
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .background(.ultraThinMaterial).clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: .indigo, radius: 1.5)
                }.buttonStyle(.plain)
            }
        }
    }
    @ViewBuilder
    func proxyRowView(file: ProxyFile) -> some View {
        VStack {
            HStack {
                if (file.first25.first ?? "").contains("wealthproxies") {
                    Image("Proxies")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 35, height: 35)
                        .clipShape(Circle()).contentShape(Circle())
                        .shadow(color: .gray, radius: 3)
                }
                Text(file.name).font(.headline).bold()
                
                Spacer()
                
                if (auth.currentUser?.ownedInstances ?? 0) > 0 {
                    Text("Instance \(file.instance)")
                        .font(.subheadline)
                        .padding(.horizontal, 11).padding(.vertical, 4)
                        .background(content: {
                            TransparentBlurView(removeAllFilters: true)
                                .blur(radius: 14, opaque: true)
                                .background(colorScheme == .dark ? .black.opacity(0.4) : .white.opacity(0.4))
                        })
                        .clipShape(Capsule())
                        .shadow(color: .gray, radius: 2)
                }
                
                Menu {
                    if let id = file.id {
                        Button(role: .destructive){
                            let data = [
                                "name": file.name,
                                "docId": id,
                            ] as [String : Any]
                            
                            TaskService().newRequest(type: "\(file.instance)deleteProxy", data: data)
                            
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                            
                            popRoot.presentAlert(image: "hand.raised", text: "Running Task Groups will continue using this proxy list.")
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        Divider()
                    }
                    if file.count > 0 {
                        Button {
                            let data = [
                                "name": file.name
                            ] as [String : Any]
                            
                            TaskService().newRequest(type: "\(file.instance)proxyCache", data: data)
                            
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                            
                            popRoot.presentAlert(image: "checkmark",
                                                 text: "Request sent to server")
                        } label: {
                            Label("Cache Proxy IP's", systemImage: "square.and.arrow.down")
                        }
                    }
                    if let id = file.id, !measuringSpeed.contains(id) && !file.first25.isEmpty {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)){
                                measuringSpeed.append(id)
                            }
                            Task {
                                averageProxyGroupSpeed(proxies: file.first25) { msSpeed, err in
                                    if let idx = viewModel.proxies?.firstIndex(where: { $0.id == id }) {
                                        DispatchQueue.main.async {
                                            withAnimation(.easeInOut(duration: 0.2)){
                                                measuringSpeed.remove(id)
                                                
                                                if err.isEmpty {
                                                    viewModel.proxies?[idx].speed = msSpeed
                                                    viewModel.proxies?[idx].speedErr = nil
                                                } else {
                                                    viewModel.proxies?[idx].speedErr = err
                                                }
                                                
                                                highlight = id
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                    highlight = nil
                                                }
                                            }
                                        }
                                    } else {
                                        withAnimation(.easeInOut(duration: 0.2)){
                                            _ = measuringSpeed.remove(id)
                                        }
                                    }
                                }
                            }
                        } label: {
                            Label("Test Speed", systemImage: "figure.roll.runningpace")
                        }
                    }
                    Button {
                        newProxyAddTo = file.name
                        if popRoot.userResiPassword != nil && !(popRoot.userResiPassword ?? "").isEmpty {
                            showNewProxyFile = true
                        } else {
                            getResiLogin(withOpen: true)
                            popRoot.presentAlert(image: "hand.raised",
                                                 text: "Please hold while we retrieve your credentials.")
                        }
                    } label: {
                        Label("Add Proxies", systemImage: "plus")
                    }
                    if !file.first25.isEmpty {
                        Button {
                            let stringToCopy = file.first25.joined(separator: "\n")
                            UIPasteboard.general.string = stringToCopy
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                        } label: {
                            Label("Copy first \(file.first25.count)", systemImage: "document.on.document")
                        }
                    }
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
            
            if !file.first25.isEmpty {
                VStack(alignment: .leading){
                    if let first = file.first25.first {
                        HStack {
                            Text(first).font(.subheadline).lineLimit(1).fontWeight(.light)
                            Spacer()
                        }
                    }
                    if file.first25.count > 1 {
                        Text(file.first25[1]).font(.subheadline).lineLimit(1).fontWeight(.light)
                    }
                    if file.first25.count > 2 {
                        Text(file.first25[2]).font(.subheadline).lineLimit(1).fontWeight(.light)
                    }
                    
                    if file.first25.count > 3 {
                        let left = file.count - 3
                        let word = left == 1 ? "Proxy" : "Proxies"
                        
                        HStack {
                            Text("... \(left) More \(word)")
                            Spacer()
                        }
                    }
                }
                .padding(10)
                .background(Color.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .contentShape(RoundedRectangle(cornerRadius: 12))
            } else if file.count > 0 {
                VStack {
                    Spacer()
                    
                    Text("This file has \(file.count) \(file.count == 1 ? "Proxy" : "Proxies")")
                        .padding(.vertical).foregroundStyle(.gray)
                    
                    Spacer()
                }
                .padding(10).padding(.horizontal)
                .background(Color.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .contentShape(RoundedRectangle(cornerRadius: 12))
            } else {
                VStack {
                    Spacer()
                    
                    if auth.currentUser?.discordUsername != nil && auth.currentUser?.discordUID != nil {
                        Text("This file is empty, click to add Wealth Proxies.")
                            .padding(.vertical).foregroundStyle(.gray).bold()
                    } else {
                        Text("This file is empty, Link your discord to add Wealth Proxies.")
                            .padding(.vertical).foregroundStyle(.gray)
                    }
                    
                    Spacer()
                }
                .padding(10).padding(.horizontal)
                .background(Color.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .contentShape(RoundedRectangle(cornerRadius: 12))
                .onTapGesture {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    
                    if auth.currentUser?.discordUsername != nil && auth.currentUser?.discordUID != nil {
                        newProxyAddTo = file.name
                        if popRoot.userResiPassword != nil && !(popRoot.userResiPassword ?? "").isEmpty {
                            showNewProxyFile = true
                        } else {
                            getResiLogin(withOpen: true)
                            popRoot.presentAlert(image: "hand.raised",
                                                 text: "Please hold while we retrieve your credentials.")
                        }
                    } else {
                        discordUsername = ""
                        discordUID = ""
                        showDiscordSheet = true
                    }
                }
            }
            
            if measuringSpeed.contains(file.id ?? "") {
                HStack {
                    ProgressView()
                    Text("Measuring speed...").font(.subheadline)
                    Spacer()
                    if let speed = file.speed {
                        Text("Last speed: \(speed) ms").foregroundStyle(.blue).font(.subheadline)
                    }
                }
            } else if let speed = file.speed {
                HStack {
                    Text("Average RTT: \(speed) ms").foregroundStyle(.blue).font(.subheadline)
                    Spacer()
                }
            } else if let err = file.speedErr {
                HStack {
                    Text(err).foregroundStyle(.red).font(.subheadline)
                    Spacer()
                }
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
        .brightness((highlight ?? "NA") == (file.id ?? "") ? 0.4 : 0.0)
        .padding(.horizontal, 12)
    }
    func refreshDate() {
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
                    Text("Proxy Manager").font(.caption).fontWeight(.semibold)
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
                
                Menu {
                    if let username = auth.currentUser?.discordUsername, auth.currentUser?.discordUID != nil {
                        Text("Signed in as @\(username)")
                        Divider()
                        Button {
                            discordUsername = ""
                            discordUID = ""
                            showDiscordSheet = true
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        } label: {
                            Label("Switch Discord", systemImage: "arrow.2.squarepath")
                        }
                        Button {
                            refreshDate()
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        } label: {
                            Label("Refresh page", systemImage: "arrow.clockwise")
                        }
                    } else {
                        Button {
                            discordUsername = ""
                            discordUID = ""
                            showDiscordSheet = true
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        } label: {
                            Label("Link Discord", systemImage: "link")
                        }
                    }
                } label: {
                    Image(systemName: "gear")
                        .font(.headline).scaleEffect(1.1)
                        .padding(10)
                        .background(content: {
                            TransparentBlurView(removeAllFilters: true)
                                .blur(radius: 14, opaque: true)
                                .background(colorScheme == .dark ? .black.opacity(0.4) : .white.opacity(0.4))
                        })
                        .clipShape(Circle())
                        .shadow(color: .gray, radius: 2)
                }.buttonStyle(.plain)
            }
        }
        .padding(.top, top_Inset()).padding(.horizontal).padding(.bottom, 10)
        .background {
            TransparentBlurView(removeAllFilters: true).blur(radius: 14, opaque: true)
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
