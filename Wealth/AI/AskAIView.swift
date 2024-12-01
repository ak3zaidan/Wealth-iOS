import SwiftUI
import Kingfisher

struct AskAIView: View, KeyboardReadable {
    let rando: [randomQ] = [
        randomQ(one: "Give me the URL", two: "for new Supreme tasks"),
        randomQ(one: "Explain to me", two: "what ISP proxies are"),
        randomQ(one: "When should I use", two: "ISP vs Resis proxies"),
        randomQ(one: "List some steps", two: "to setup Supreme tasks"),
        randomQ(one: "Give me some", two: "benefits of Wealth Pro")
    ]
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var history: AIHistory
    @EnvironmentObject var popRoot: PopToRoot
    @EnvironmentObject var vm: ViewModel

    @State var hideOrderNums: Bool? = false
    @State var scrollViewSize: CGSize = .zero
    @State var wholeSize: CGSize = .zero
    @State var showProfileBuilder = false
    @State var isKeyboardVisible = false
    @State var showInfoSheet = false
    @State var inputMessage: String = ""
    @State var showDownButton = true
    @State var showSettings = false
    @State var showContact = false
    @State var isCollapsed = false
    @State var showOptions = true
    @State var showScaleInfo = false
    @State var isTop = false
    @State var atTop = true
    @Namespace var hero
    
    @Binding var showMenu: Bool
    @Binding var should_Scroll_Interacting: Bool

    var body: some View {
        VStack(spacing: 0){
            VStack {
                ScrollViewReader { proxy in
                    ZStack {
                        Color.gray.opacity(0.0001)
                        if vm.messages.isEmpty {
                            VStack {
                                Spacer()
                                AskIcon(isTop: $isTop)
                                Spacer()
                            }
                        } else {
                            ChildSizeReader(size: $wholeSize) {
                                ScrollView {
                                    ChildSizeReader(size: $scrollViewSize) {
                                        LazyVStack(spacing: 0) {
                                            Color.clear.frame(height: 1).id("scrollDown")
                                            ForEach(vm.messages.reversed()) { message in
                                                MessageRowView(message: message) { message in
                                                    Task { @MainActor in
                                                        await vm.retry(message: message)
                                                    }
                                                } alert: { result in
                                                    popRoot.presentAlert(image: result.0, text: result.1)
                                                } openBuilder: {
                                                    showProfileBuilder = true
                                                }
                                                .rotationEffect(.degrees(180.0))
                                                .scaleEffect(x: -1, y: 1, anchor: .center)
                                            }
                                            Color.clear.frame(height: 100)
                                        }
                                        .background(GeometryReader {
                                            Color.clear.preference(key: ViewOffsetKey.self,
                                                                   value: -$0.frame(in: .named("scroll")).origin.y)
                                        })
                                        .onPreferenceChange(ViewOffsetKey.self) { value in
                                            let full = scrollViewSize.height - wholeSize.height
                                            if full > value + 100 {
                                                withAnimation { atTop = false }
                                            } else {
                                                withAnimation { atTop = true }
                                            }
                                        }
                                    }
                                }
                                .scrollDismissesKeyboard(.immediately)
                                .rotationEffect(.degrees(180.0))
                                .scaleEffect(x: -1, y: 1, anchor: .center)
                            }
                        }
                        if !atTop && !vm.messages.isEmpty && showDownButton {
                            VStack {
                                Spacer()
                                Button {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    showDownButton = false
                                    atTop = true
                                    withAnimation {
                                        proxy.scrollTo("scrollDown", anchor: .bottom)
                                    }
                                    if vm.isInteracting {
                                        should_Scroll_Interacting = true
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        showDownButton = true
                                    }
                                } label: {
                                    ZStack {
                                        Circle().foregroundStyle(.indigo)
                                        Image(systemName: "chevron.down")
                                            .font(.title3).foregroundStyle(.white).offset(y: 1)
                                    }.frame(width: 40, height: 40)
                                }
                            }.transition(.move(edge: .bottom)).padding(.bottom, 20)
                        }
                    }
                    .onChange(of: vm.messages.last?.responseText) { _, _ in
                        if should_Scroll_Interacting {
                            withAnimation(.easeInOut(duration: 0.3)){
                                proxy.scrollTo("scrollDown", anchor: .bottomTrailing)
                            }
                        }
                    }
                    .onChange(of: popRoot.tap, { _, _ in
                        if popRoot.tap == 4 && !showMenu {
                            withAnimation(.easeInOut(duration: 0.3)){
                                proxy.scrollTo("scrollDown", anchor: .bottomTrailing)
                            }
                            popRoot.tap = 0
                        }
                    })
                }
            }.padding(.vertical, 8).blur(radius: isCollapsed ? 5 : 0)
            
            if showOptions && vm.messages.isEmpty {
                randomOptions()
                    .padding(.bottom).blur(radius: isCollapsed ? 5 : 0)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            AITextField().padding(.bottom, isKeyboardVisible ? 5 : 75)
        }
        .overlay(alignment: .top, content: {
            HStack(spacing: 18){
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
                .frame(height: 55)
                
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    showContact = true
                } label: {
                    Text("Support")
                        .font(.headline).foregroundStyle(.gray).bold()
                }
                Spacer()
                Button {
                    if vm.isVccBuilding {
                        popRoot.presentAlert(image: "exclamationmark.triangle", text: "Please wait till profiles complete.")
                    } else {
                        if !vm.messages.isEmpty {
                            history.saveChat(mess: vm.messages, hasImage: vm.hasImage)
                        }
                        vm.messages = []
                    }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 25))
                        .foregroundStyle(.gray)
                }.padding(.leading, 25).disabled(vm.isInteracting)
                Button {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    withAnimation {
                        showMenu.toggle()
                    }
                } label: {
                    ZStack {
                        Rectangle().frame(width: 28, height: 40)
                            .foregroundStyle(.gray).opacity(0.0001)
                        
                        VStack(alignment: .trailing, spacing: 4){
                            Rectangle().frame(width: 28, height: 5)
                            Rectangle().frame(width: 20, height: 4)
                        }.foregroundStyle(colorScheme == .dark ? .white : .black)
                    }
                }.offset(y: 2)
            }
            .padding(.top, top_Inset()).padding(.horizontal).padding(.bottom, 10)
            .background {
                TransparentBlurView(removeAllFilters: true).blur(radius: 14, opaque: true)
            }
            .ignoresSafeArea()
        })
        .sheet(isPresented: $showProfileBuilder, content: {
            ProfileBuilderSheet { result in
                DispatchQueue.main.async {
                    if vm.isInteracting {
                        vm.cancelStreamingResponse()
                    }
                    
                    if let id = vm.appendVccToExisting, let idx = vm.messages.firstIndex(where: { $0.id.uuidString == id }) {
                        withAnimation(.easeInOut(duration: 0.3)){
                            vm.isInteracting = true
                            vm.messages[idx].isProfileInteracting = true
                        }
                                                                        
                        var resultString = result.1.joined(separator: "\n")
                        
                        if let previousProfiles = vm.messages[idx].response?.text, !previousProfiles.isEmpty {
                            
                            let newlineCount = previousProfiles.filter { $0 == "\n" }.count
                            
                            let fixedString = updateRange(elements: result.1, start: newlineCount + 2)
                            
                            resultString = previousProfiles + "\n" + fixedString
                        }
                        
                        Task {
                            let parsingTask = ResponseParsingTask()
                            let attributedSend = await parsingTask.parse(text: resultString)
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
                                withAnimation(.easeInOut(duration: 0.3)){
                                    vm.isInteracting = false
                                    if idx < vm.messages.count {
                                        vm.messages[idx].isProfileInteracting = false
                                    }
                                }
                                
                                if idx < vm.messages.count {
                                    self.vm.messages[idx].response = .attributed(attributedSend)
                                }
                            }
                        }
                    } else {
                        let ask = "Create \(result.1.count) '\(result.0)' Profiles for Wealth AIO."
                        
                        let messageRow = MessageRow(isInteracting: true, isProfileBuild: true, send: .rawText(ask), response: .rawText(""), responseError: nil)
                        
                        withAnimation(.easeInOut(duration: 0.3)){
                            vm.isInteracting = true
                            self.vm.messages.append(messageRow)
                        }
                        
                        let resultString = result.1.joined(separator: "\n")
                        
                        Task {
                            let parsingTask = ResponseParsingTask()
                            let attributedSend = await parsingTask.parse(text: resultString)
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
                                withAnimation(.easeInOut(duration: 0.3)){
                                    vm.isInteracting = false
                                }
                                let idx = self.vm.messages.count - 1
                                if idx < self.vm.messages.count && idx >= 0 {
                                    self.vm.messages[idx].response = .attributed(attributedSend)
                                }
                            }
                        }
                    }
                }
            } buildVCC: { result in
                DispatchQueue.main.async {
                    if vm.isInteracting {
                        vm.cancelStreamingResponse()
                    }
                    vm.isVccBuilding = true
                    
                    if result.shouldCreateNew {
                        popRoot.presentAlert(image: "exclamationmark.shield", text: "Do NOT close the app, but you can navigate away.")
                    }
                    
                    if let id = vm.appendVccToExisting, let idx = vm.messages.firstIndex(where: { $0.id.uuidString == id }) {
                        withAnimation(.easeInOut(duration: 0.3)){
                            vm.messages[idx].isProfileInteracting = true
                        }
                        self.vm.createAndFetchBulkVCC(messageId: vm.messages[idx].id, shouldCreate: result.shouldCreateNew, accessToken: result.accessToken, sourceAccountId: result.sourceAccountId, limit: result.cardLimit, reccurStatus: result.recurenceFrequency, genCount: result.dataArray.count, email: result.email) { vcc in
                            
                            vm.isVccBuilding = false
                            
                            if vm.cancelledJobs.contains(id) {
                                popRoot.presentAlert(image: "checkmark", text: "Extend has finished creating your VCC!")
                                return
                            }
                            
                            if vcc.isEmpty {
                                if let idx = vm.messages.firstIndex(where: { $0.id.uuidString == id }) {
                                    withAnimation(.easeInOut(duration: 0.3)){
                                        vm.messages[idx].isProfileInteracting = false
                                    }
                                }
                                popRoot.presentAlert(image: "exclamationmark.triangle.fill", text: "Error creating VCC for '\(result.fileName)' profiles.")
                            } else {
                                let final = mergeVCC(vcc: vcc, profiles: result.dataArray)
                                
                                if let idx = vm.messages.firstIndex(where: { $0.id.uuidString == id }) {
                                    
                                    var resultString = final.joined(separator: "\n")
                                                                        
                                    if let previousProfiles = vm.messages[idx].response?.text, !previousProfiles.isEmpty {
                                        
                                        let newlineCount = previousProfiles.filter { $0 == "\n" }.count
                                        
                                        let fixedString = updateRange(elements: final, start: newlineCount + 2)
                                        
                                        resultString = previousProfiles + "\n" + fixedString
                                    }
                                    
                                    withAnimation(.easeInOut(duration: 0.3)){
                                        vm.messages[idx].isProfileInteracting = false
                                    }
                                    Task {
                                        let parsingTask = ResponseParsingTask()
                                        let attributedSend = await parsingTask.parse(text: resultString)
                                        self.vm.messages[idx].response = .attributed(attributedSend)
                                    }
                                }
                            }
                        }
                    } else {
                        let ask = "Create \(result.dataArray.count) '\(result.fileName)' VCC Profiles for Wealth AIO."
                        
                        let messageRow = MessageRow(isInteracting: true, isProfileBuild: true, isProfileInteracting: true, vccBuildMessage: result.dataArray.count > 50 ? "This may take a while..." : "Please wait a few seconds...", send: .rawText(ask), response: .rawText(""), responseError: nil)
                        
                        withAnimation(.easeInOut(duration: 0.3)){
                            self.vm.messages.append(messageRow)
                        }
                        
                        self.vm.createAndFetchBulkVCC(messageId: messageRow.id, shouldCreate: result.shouldCreateNew, accessToken: result.accessToken, sourceAccountId: result.sourceAccountId, limit: result.cardLimit, reccurStatus: result.recurenceFrequency, genCount: result.dataArray.count, email: result.email) { vcc in
                            
                            vm.isVccBuilding = false
                            
                            if vm.cancelledJobs.contains(messageRow.id.uuidString) {
                                popRoot.presentAlert(image: "checkmark", text: "Extend has finished creating your VCC!")
                                return
                            }
                            
                            if vcc.isEmpty {
                                if let idx = vm.messages.firstIndex(where: { $0.id == messageRow.id }) {
                                    withAnimation(.easeInOut(duration: 0.3)){
                                        vm.messages[idx].isProfileInteracting = false
                                    }
                                }
                                popRoot.presentAlert(image: "exclamationmark.triangle.fill", text: "Error creating VCC for '\(result.fileName)' profiles.")
                            } else {
                                let final = mergeVCC(vcc: vcc, profiles: result.dataArray)
                                
                                if let idx = vm.messages.firstIndex(where: { $0.id == messageRow.id }) {
                                    let resultString = final.joined(separator: "\n")
                                    
                                    withAnimation(.easeInOut(duration: 0.3)){
                                        vm.messages[idx].isProfileInteracting = false
                                    }
                                    Task {
                                        let parsingTask = ResponseParsingTask()
                                        let attributedSend = await parsingTask.parse(text: resultString)
                                        self.vm.messages[idx].response = .attributed(attributedSend)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        })
        .sheet(isPresented: $showSettings, content: {
            SettingsSheetView(hideOrderNums: $hideOrderNums)
        })
        .sheet(isPresented: $showInfoSheet, content: {
            InfoSheet()
        })
        .sheet(isPresented: $showScaleInfo, content: {
            ScaleInfoView()
        })
        .sheet(isPresented: $showContact, content: {
            ContactView()
        })
        .onReceive(keyboardPublisher) { newIsKeyboardVisible in
            withAnimation(.easeInOut(duration: 0.1)){
                isKeyboardVisible = newIsKeyboardVisible
            }
        }
        .onChange(of: scenePhase) { _, _ in
            if scenePhase == .background && !vm.messages.isEmpty {
                history.saveChat(mess: vm.messages, hasImage: vm.hasImage)
            }
        }
        .onChange(of: inputMessage, { _, _ in
            withAnimation(.easeInOut(duration: 0.2)){
                showOptions = inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
        })
        .onAppear {
            isTop = true
            Task {
                if history.allMessages.isEmpty {
                    await history.getChats()
                }
            }
        }
        .onDisappear {
            isTop = false
            if !vm.messages.isEmpty && !vm.isVccBuilding {
                history.saveChat(mess: vm.messages, hasImage: vm.hasImage)
            }
        }
        .overlay {
            LiquidAIMenuButtons(isCollapsed: $isCollapsed, inputMessage: $inputMessage)
                .padding(.bottom, isKeyboardVisible ? 5 : 75)
        }
    }
    func AITextField() -> some View {
        ZStack(alignment: .bottomTrailing){
            HStack {
                Spacer()
                CustomAIField(placeholder: Text("Message"), text: $inputMessage)
                    .frame(width: widthOrHeight(width: true) * 0.83)
            }
            Button {
                if vm.isInteracting {
                    vm.cancelStreamingResponse()
                } else {
                    let toSend = inputMessage
                    inputMessage = ""
                    Task { @MainActor in
                        await vm.sendTapped(main: toSend, newText: nil, text2: "")
                    }
                }
            } label: {
                if vm.isInteracting {
                    Image(systemName: "xmark")
                        .fontWeight(.semibold)
                        .padding(6)
                        .foregroundStyle(.white)
                        .background(.red)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "arrow.up")
                        .fontWeight(.semibold)
                        .padding(6)
                        .foregroundStyle(.white)
                        .background(.blue)
                        .clipShape(Circle())
                        .opacity(inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)
                }
            }
            .disabled(!vm.isInteracting && inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .padding(.trailing, 5).padding(.bottom, 5)
        }.padding(.bottom, 6).padding(.trailing, 12)
    }
    func randomOptions() -> some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                Color.clear.frame(width: 10, height: 10)
                
                if (auth.currentUser?.ownedInstances ?? 0) > 0 {
                    Button {
                        showScaleInfo = true
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    } label: {
                        VStack(spacing: 6){
                            Image(systemName: "flame").font(.system(size: 30)).bold()
                        }
                        .frame(height: 65)
                        .padding(.horizontal, 12)
                        .background(content: {
                            LinearGradient(colors: [.red, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
                        })
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                    }.buttonStyle(.plain)
                }
                
                Button {
                    showInfoSheet = true
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    VStack(spacing: 6){
                        Image(colorScheme == .dark ? "wealthLogoWhite" : "wealthLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 35)
                    }
                    .frame(height: 65)
                    .padding(.horizontal, 14)
                    .background(content: {
                        GeometryReader { geo in
                            Image("WealthBlur")
                                .resizable()
                                .frame(width: geo.size.width, height: geo.size.height)
                        }
                        .ignoresSafeArea()
                    })
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                }

                Button {
                    if (auth.currentUser?.unlockedTools ?? []).contains("Ai Profile+") {
                        vm.appendVccToExisting = nil
                        showProfileBuilder = true
                    } else {
                        popRoot.presentAlert(image: "xmark", text:
                                                "Only users with Ai profile+ can use this. Get access from Tools.")
                    }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    VStack(spacing: 6){
                        HStack {
                            Text("Ai Profile+").fontWeight(.heavy)
                            Spacer()
                        }.padding(.leading, 7)
                        HStack {
                            Text("Build profiles now")
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .font(.system(size: 14))
                            Spacer()
                        }.padding(.leading, 7)
                    }
                    .frame(height: 65)
                    .padding(.horizontal, 8)
                    .background(content: {
                        LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                    })
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                }.buttonStyle(.plain)
                
                ForEach(rando, id: \.self) { element in
                    Button {
                        let toSend = inputMessage
                        inputMessage = ""
                        Task { @MainActor in
                            await vm.sendTapped(main: toSend, newText: element.one + " " + element.two, text2: "")
                        }
                    } label: {
                        VStack(spacing: 6){
                            HStack {
                                Text(element.one).bold()
                                Spacer()
                            }.padding(.leading, 7)
                            HStack {
                                Text(element.two)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .font(.system(size: 14)).foregroundStyle(.gray)
                                Spacer()
                            }.padding(.leading, 7)
                        }
                        .frame(height: 65)
                        .padding(.horizontal, 8)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                    }
                }
                Color.clear.frame(width: 10, height: 10)
            }
        }.scrollIndicators(.hidden)
    }
}

struct CustomAIField: View {
    var placeholder: Text
    @Environment(\.colorScheme) var colorScheme
    @Binding var text: String
    
    var body: some View{
        ZStack(alignment: .leading){
            if text.isEmpty {
                placeholder
                    .opacity(0.5)
                    .offset(x: 8)
                    .foregroundColor(.gray)
                    .font(.system(size: 17))
            }
            TextField("", text: $text, axis: .vertical)
                .tint(.blue)
                .lineLimit(5)
                .padding(.vertical, 3)
                .padding(.leading, 8)
                .padding(.trailing, 40)
                .frame(minHeight: 40)
                .overlay {
                    RoundedRectangle(cornerRadius: 14).stroke(.gray, lineWidth: 1)
                }
            
        }
    }
}

struct LiquidAIMenuButtons: View {
    @State var offsetOne: CGSize = .zero
    @State var offsetTwo: CGSize = .zero
    @Binding var isCollapsed: Bool
    @State private var trueSize: Bool = false
    @State private var showCamera: Bool = false
    @State private var selectedImage: UIImage?
    @State var showImagePicked: Bool = false
    @State var showPicker: Bool = false
    @Environment(\.colorScheme) var colorScheme
    @State private var showing: Bool = false
    @Binding var inputMessage: String
    
    var body: some View {
        ZStack {
            if isCollapsed && showing {
                Color.gray.opacity(0.001)
                    .onTapGesture {
                        showing.toggle()
                        withAnimation(.easeIn(duration: 0.4)){
                            trueSize.toggle()
                        }
                        withAnimation { isCollapsed.toggle() }
                        withAnimation(.interactiveSpring(response: 0.35, dampingFraction: 0.8, blendDuration: 0.1).speed(0.5)) {
                            offsetOne  = isCollapsed ? CGSize(width: 0, height: -75) : .zero
                            offsetTwo  = isCollapsed ? CGSize(width: 0, height: -145) : .zero
                        }
                    }
            }
            VStack {
                Spacer()
                HStack {
                    Rectangle()
                        .fill(.linearGradient(colors: [.gray.opacity(0.5), .gray], startPoint: .bottom, endPoint: .top))
                        .mask(canvas)
                        .overlay {
                            ZStack {
                                CancelButton()
                                    .rotationEffect(Angle(degrees: isCollapsed ? 90 : 45))
                                
                                CameraButton().offset(offsetOne).opacity(isCollapsed ? 1 : 0)
                                PhotosButton().offset(offsetTwo).opacity(isCollapsed ? 1 : 0)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                            .offset(x: 9.5, y: -4)
                        }
                        .frame(width: 65, height: isCollapsed ? 250 : 65)
                    Spacer()
                }
            }
        }
        .fullScreenCover(isPresented: $showCamera, content: {
            SnapCameraHelper(inputMessage: $inputMessage)
        })
        .fullScreenCover(isPresented: $showImagePicked, content: {
            SnapCamera(image: nil, image2: $selectedImage, inputMessage: $inputMessage)
                .onDisappear {
                    selectedImage = nil
                }
        })
        .sheet(isPresented: $showPicker, onDismiss: loadImage){
            ImagePicker(selectedImage: $selectedImage)
                .tint(colorScheme == .dark ? .white : .black)
        }
    }
    var canvas: some View {
        Canvas { context, size in
            context.addFilter(.alphaThreshold(min: 0.9, color: .black))
            context.addFilter(.blur(radius: 5))

            context.drawLayer { ctx in
                for index in [1,2,3,4,5] {
                    if let resolvedView = context.resolveSymbol(id: index) {
                        ctx.draw(resolvedView, at: CGPoint(x: 32, y: size.height - 27))
                    }
                }
            }
        } symbols: {
            Symbol(diameter: 40).tag(1)

            Symbol(offset: offsetOne, diameter: 60).tag(2).opacity(trueSize ? 1 : 0)
            
            Symbol(offset: offsetTwo, diameter: 60).tag(3).opacity(trueSize ? 1 : 0)
        }
    }
}

extension LiquidAIMenuButtons {
    func loadImage() {
        if selectedImage != nil {
            showImagePicked = true
        }
    }
    private func Symbol(offset: CGSize = .zero, diameter: CGFloat) -> some View {
        Circle().frame(width: diameter, height: diameter).offset(offset)
    }
    func closeView(){
        if !isCollapsed {
            showing = true
            withAnimation(.easeIn(duration: 0.05)){
                trueSize.toggle()
            }
        } else {
            showing = false
            withAnimation(.easeIn(duration: 0.4)){
                trueSize.toggle()
            }
        }
        withAnimation { isCollapsed.toggle() }
        withAnimation(.interactiveSpring(response: 0.35, dampingFraction: 0.8, blendDuration: 0.1).speed(0.5)) {
            offsetOne  = isCollapsed ? CGSize(width: 0, height: -75) : .zero
            offsetTwo  = isCollapsed ? CGSize(width: 0, height: -145) : .zero
        }
    }
    func CancelButton() -> some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            closeView()
        } label: {
            ZStack {
                Rectangle().frame(width: 45, height: 45).foregroundStyle(.gray).opacity(0.001)
                Image(systemName: "xmark")
                    .resizable()
                    .foregroundStyle(.white)
                    .frame(width: 12, height: 12)
                    .aspectRatio(.zero, contentMode: .fit).contentShape(Circle())
                    .offset(x: -0.25, y: -0.25)
            }
        }
    }
    func CameraButton() -> some View {
        Button {
            showCamera = true
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            closeView()
        } label: {
            ZStack {
                Image(systemName: "camera.fill").scaleEffect(1.2).foregroundStyle(.white)
            }
        }.frame(width: 45, height: 45)
    }
    func PhotosButton() -> some View {
        Button {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            showPicker = true
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            closeView()
        } label: {
            ZStack {
                Image(systemName: "photo").scaleEffect(1.3).foregroundStyle(.white)
            }
        }.frame(width: 45, height: 45)
    }
}

func updateRange(elements: [String], start: Int) -> String {
    var updatedElements: [String] = []
    var currentStart = start
    var numberToRemove = 1

    for element in elements {
        let components = element.split(separator: ",", maxSplits: 1, omittingEmptySubsequences: false)
        
        if components.count > 1 {
            
            var profileName: String = String(components[0])
            profileName = String(profileName.dropLast(String(numberToRemove).count))
            
            let updatedElement = profileName + "\(currentStart),\(components[1])"
            
            updatedElements.append(updatedElement)
            
            currentStart += 1
        }
        
        numberToRemove += 1
    }

    return updatedElements.joined(separator: "\n")
}
