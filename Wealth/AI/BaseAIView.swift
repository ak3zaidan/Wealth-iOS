import SwiftUI
import Combine

let countryPicker = "Aox1OuTG8xT3BlbkFJA"

struct BaseAIView: View, KeyboardReadable {
    @EnvironmentObject var vm: ViewModel
    
    @State var mainKeyBoardShowing: Bool = false
    @State var should_Scroll_Interacting = true
    @GestureState var gestureOffset: CGFloat = 0
    @State var lastStoredOffset: CGFloat = 0
    @State var keyBoardShowing: Bool = false
    @State var showMenu: Bool = false
    @State var offset: CGFloat = 0
   
    var body: some View {
        let sideBarWidth = keyBoardShowing ? widthOrHeight(width: true) : widthOrHeight(width: true) - 90
        VStack {
            HStack(spacing: 0) {
                AISideMenu(showMenu: $showMenu, keyboardShowing: $keyBoardShowing).frame(width: sideBarWidth)

                VStack(spacing: 0) {
                    AskAIView(showMenu: $showMenu, should_Scroll_Interacting: $should_Scroll_Interacting)
                }
                .frame(width: widthOrHeight(width: true))
                .overlay(
                    Rectangle()
                        .fill (
                            Color.primary.opacity( (offset / sideBarWidth) / 6.0 )
                        )
                        .ignoresSafeArea(.container, edges: .all)
                        .onTapGesture {
                            if showMenu {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                showMenu = false
                            }
                        }
                )
            }
            .frame(width: sideBarWidth + widthOrHeight(width: true))
            .offset(x: -sideBarWidth / 2)
            .offset(x: offset)
            .offset(x: keyBoardShowing && showMenu ? 90.0 : 0.0)
            .gesture(
                DragGesture()
                    .updating($gestureOffset, body: { value, out, _ in
                        out = value.translation.width
                    })
                    .onChanged({ value in
                        if vm.isInteracting && value.translation.height > 15 {
                            should_Scroll_Interacting = false
                        }
                        if abs(value.translation.height) > 10 && mainKeyBoardShowing && !showMenu {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                    })
                    .onEnded(onEnd(value:))
            )
        }
        .onReceive(keyboardPublisher) { newIsKeyboardVisible in
            mainKeyBoardShowing = newIsKeyboardVisible
        }
        .animation(.linear(duration: 0.15), value: offset == 0)
        .onChange(of: showMenu) { _, newValue in
            if showMenu {
                if offset == 0 {
                    offset = sideBarWidth
                    lastStoredOffset = offset
                }
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            
            if !showMenu && offset == sideBarWidth {
                offset = 0
                lastStoredOffset = 0
            }
        }
        .onChange(of: gestureOffset) { _, newValue in
            if keyBoardShowing && showMenu {
                if newValue < 0 {
                    if gestureOffset != 0 {
                        if gestureOffset + lastStoredOffset < sideBarWidth && (gestureOffset + lastStoredOffset) > 0 {
                            offset = lastStoredOffset + gestureOffset
                        } else {
                            if gestureOffset + lastStoredOffset < 0 {
                                offset = 0
                            }
                        }
                    }
                }
            } else {
                if gestureOffset != 0 {
                    if gestureOffset + lastStoredOffset < sideBarWidth && (gestureOffset + lastStoredOffset) > 0 {
                        offset = lastStoredOffset + gestureOffset
                    } else {
                        if gestureOffset + lastStoredOffset < 0 {
                            offset = 0
                        }
                    }
                }
            }
        }
    }
    
    func onEnd(value: DragGesture.Value) {
        let sideBarWidth = widthOrHeight(width: true) - 90
        withAnimation(.spring(duration: 0.15)) {
            if value.translation.width > 0 {
                if value.translation.width > sideBarWidth / 2 {
                    offset = sideBarWidth
                    lastStoredOffset = sideBarWidth
                    if !showMenu {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }
                    showMenu = true
                } else {
                    if value.translation.width > sideBarWidth && showMenu {
                        offset = 0
                        if showMenu {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        showMenu = false
                    } else {
                        if value.velocity.width > 800 {
                            offset = sideBarWidth
                            if !showMenu {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            }
                            showMenu = true
                        } else if showMenu == false {
                            offset = 0
                        }
                    }
                }
            } else {
                if -value.translation.width > sideBarWidth / 2 {
                    offset = 0
                    if showMenu {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    showMenu = false
                } else {
                    guard showMenu else { return }
                    if -value.velocity.width > 800 {
                        offset = 0
                        if showMenu {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        showMenu = false
                    } else {
                        offset = sideBarWidth
                        if !showMenu {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        }
                        showMenu = true
                    }
                }
            }
        }
        lastStoredOffset = offset
    }
}

struct AISideMenu: View, KeyboardReadable {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var popRoot: PopToRoot
    @EnvironmentObject var history: AIHistory
    @EnvironmentObject var vm: ViewModel
    
    @State var searchingProfiles = false
    @State var showProfileSheet = false
    @State var selectedProfile = ""
    @State var sheetID = false
    @FocusState var isEditing
    @State var text = ""
    
    @Binding var showMenu: Bool
    @Binding var keyboardShowing: Bool

    var body: some View {
        VStack {
            HStack {
                ZStack(alignment: .trailing){
                    TextField(searchingProfiles ? "Search Profiles" : "Search", text: $text)
                        .tint(.blue).focused($isEditing)
                        .autocorrectionDisabled(true)
                        .padding(8)
                        .padding(.horizontal, 24).padding(.leading, 6)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .overlay(alignment: .leading, content: {
                            if searchingProfiles {
                                Image(systemName: "person.fill")
                                    .font(.subheadline).padding(6)
                                    .background {
                                        LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    }
                                    .clipShape(Circle()).shadow(color: .gray, radius: 2).padding(.leading, 7)
                                    .transition(.scale)
                            } else {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray).padding(.leading, 12).transition(.scale)
                            }
                        })
                        .onChange(of: text) { _, _ in
                            if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                history.sortSearch(text: text)
                            } else {
                                history.sortTime()
                            }
                        }
                    if !text.isEmpty {
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            text = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .padding(.trailing, 5).padding(.bottom, 2)
                                .foregroundStyle(.gray)
                        }
                    }
                }
                if keyboardShowing {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)){
                            isEditing = false
                            searchingProfiles = false
                        }
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        text = ""
                    } label: {
                        Text("Cancel").font(.system(size: 20)).foregroundStyle(.blue)
                    }.animation(.easeInOut, value: keyboardShowing)
                }
            }.padding(.horizontal)
            ScrollView {
                LazyVStack(alignment: .leading){
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        
                        if vm.isVccBuilding {
                            popRoot.presentAlert(image: "exclamationmark.triangle", text: "Please wait till profiles complete.")
                        } else {
                            if !vm.messages.isEmpty {
                                history.saveChat(mess: vm.messages, hasImage: vm.hasImage)
                            }
                            vm.messages = []
                            if keyboardShowing {
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    text = ""
                                    showMenu = false
                                }
                            } else {
                                text = ""
                                showMenu = false
                            }
                        }
                    } label: {
                        HStack(spacing: 10){
                            Image(systemName: "square.and.pencil")
                                .font(.system(size: 20))
                            Text("New Chat").font(.system(size: 20))
                            Spacer()
                        }
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                    }.padding(.top).disabled(vm.isInteracting)
                    
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        if (auth.currentUser?.unlockedTools ?? []).contains("Ai Profile+") {
                            if searchingProfiles {
                                withAnimation(.easeInOut(duration: 0.3)){
                                    searchingProfiles.toggle()
                                    isEditing = searchingProfiles
                                }
                            } else {
                                searchingProfiles.toggle()
                                isEditing = searchingProfiles
                            }
                        } else {
                            popRoot.presentAlert(image: "xmark", text: "Only users with Ai profile+ can use this. Get access from Tools.")
                        }
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2){
                                Text("Search specific profiles").font(.headline).bold().lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                Text("Or type 'profile' to see groups").font(.caption).lineLimit(1)
                                    .minimumScaleFactor(0.8)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 8).padding(.vertical, 5)
                        .overlay(alignment: .trailing, content: {
                            Image(systemName: "magnifyingglass").font(.subheadline).fontWeight(.heavy)
                                .padding(.trailing, 12)
                        })
                        .background {
                            LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 13))
                        .shadow(color: .gray, radius: 2)
                    }.buttonStyle(.plain).padding(.top, 8)
                    
                    if searchingProfiles {
                        let data = getProfileData()
                        
                        if data.isEmpty {
                            HStack {
                                Spacer()
                                Text("No profiles found").font(Font.custom("Revalia-Regular", size: 17, relativeTo: .title))
                                Spacer()
                            }.padding(.top, 40)
                        } else {
                            Color.clear.frame(height: 15)
                            
                            LazyVStack(spacing: 10){
                                ForEach(data, id: \.self) { profile in
                                    Button {
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        selectedProfile = profile
                                        showProfileSheet = true
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                            sheetID.toggle()
                                        }
                                    } label: {
                                        HStack {
                                            Text(profile).lineLimit(1).truncationMode(.tail)
                                            Spacer()
                                        }
                                        .padding(.horizontal, 12).padding(.vertical, 8)
                                        .background(Color.gray.opacity(0.15))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }.buttonStyle(.plain)
                                }
                            }.transition(.opacity)
                        }
                    } else {
                        if history.searchMessages.isEmpty {
                            HStack {
                                Spacer()
                                Text("No history").font(Font.custom("Revalia-Regular", size: 17, relativeTo: .title))
                                Spacer()
                            }.padding(.top, 40)
                        } else {
                            LazyVStack(spacing: 15){
                                if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    Divider().overlay(colorScheme == .dark ? Color(UIColor.lightGray) : .gray)
                                }
                                ForEach(history.searchMessages.indices, id: \.self) { index in
                                    if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                        if let found = history.dateIndices.first(where: { $0.place == index }) {
                                            Divider().overlay(colorScheme == .dark ? Color(UIColor.lightGray) : .gray)
                                            HStack {
                                                Text(found.name).font(.system(size: 17)).foregroundStyle(.gray)
                                                Spacer()
                                            }
                                        }
                                    }
                                    
                                    Button {
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        if vm.isVccBuilding {
                                            popRoot.presentAlert(image: "exclamationmark.triangle", text: "Please wait till profiles complete.")
                                        } else if !vm.isInteracting {
                                            if let ele = history.allMessages.first(where: { $0.id ==  history.searchMessages[index].parentID}) {
                                                if !vm.messages.isEmpty {
                                                    history.saveChat(mess: vm.messages, hasImage: vm.hasImage)
                                                }
                                                vm.messages = ele.allM
                                                if keyboardShowing {
                                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                        text = ""
                                                        showMenu = false
                                                    }
                                                } else {
                                                    text = ""
                                                    showMenu = false
                                                }
                                            }
                                        }
                                    } label: {
                                        VStack(spacing: 4){
                                            HStack {
                                                if history.searchMessages[index].isProfileBuild {
                                                    let query = history.searchMessages[index].question
                                                    
                                                    (Text("Profiles: ").foregroundStyle(.purple).fontWeight(.heavy)
                                                     + Text(extractProfileName(query)).foregroundStyle(colorScheme == .dark ? .white : .black).bold()
                                                    ).font(.system(size: 17)).lineLimit(1).truncationMode(.tail)
                                                    
                                                } else if history.searchMessages[index].question.isEmpty {
                                                    Text("Image Sent").font(.system(size: 17)).bold()
                                                } else {
                                                    Text(history.searchMessages[index].question)
                                                        .font(.system(size: 17)).lineLimit(1).truncationMode(.tail).bold()
                                                }
                                                Spacer()
                                            }
                                            HStack {
                                                if history.searchMessages[index].isProfileBuild {
                                                    let count = history.searchMessages[index].answer.split(separator: "\n").count
                                                    
                                                    Text("\(count) Wealth AIO profiles.")
                                                        .foregroundStyle(.gray).font(.system(size: 14))
                                                } else {
                                                    Text(history.searchMessages[index].answer)
                                                        .foregroundStyle(.gray)
                                                        .font(.system(size: 14)).lineLimit(1).truncationMode(.tail)
                                                }
                                                Spacer()
                                            }
                                        }
                                    }
                                    .contextMenu {
                                        if !history.searchMessages[index].isProfileBuild {
                                            Button {
                                                if !vm.isInteracting {
                                                    let x = history.searchMessages[index]
                                                    var finalText = x.question
                                                    
                                                    if finalText.isEmpty && !x.answer.isEmpty {
                                                        finalText = "Do this in a different way: \(x.answer)"
                                                    }
                                                    if !finalText.isEmpty {
                                                        showMenu = false
                                                        text = ""
                                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                                        Task { @MainActor in
                                                            await vm.sendTapped(main: "", newText: finalText, text2: "")
                                                        }
                                                    }
                                                }
                                            } label: {
                                                Label("Regenerate", systemImage: "arrow.uturn.forward")
                                            }
                                        }
                                        Button(role: .destructive) {
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                            let x = history.searchMessages[index]
                                            history.deleteHistory(id: x.id, answer: x.answer)
                                            if !x.answer.isEmpty {
                                                vm.messages.removeAll(where: { $0.responseText == x.answer })
                                            }
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    } preview: {
                                        VStack {
                                            let x = history.searchMessages[index]
                                            if x.question.isEmpty {
                                                Text("Image Question.")
                                                    .font(.body).padding().multilineTextAlignment(.leading)
                                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                            } else {
                                                Text(x.question)
                                                    .lineLimit(10).truncationMode(.tail)
                                                    .font(.body).padding().multilineTextAlignment(.leading)
                                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                            }
                                        }
                                    }
                                }
                            }.padding(.top, 15).transition(.move(edge: .bottom))
                        }
                    }
                    Color.clear.frame(height: 100)
                }.padding(.horizontal)
            }
        }
        .onChange(of: popRoot.tap, { _, _ in
            if popRoot.tap == 4 && showMenu {
                withAnimation(.easeInOut(duration: 0.2)){
                    showMenu = false
                }
                popRoot.tap = 0
            }
        })
        .onReceive(keyboardPublisher) { newIsKeyboardVisible in
            if !showProfileSheet {
                withAnimation {
                    keyboardShowing = newIsKeyboardVisible
                }
            }
        }
        .sheet(isPresented: $showProfileSheet) {
            ProfileInfoView(profile: selectedProfile).id(sheetID)
        }
    }
    func getProfileData() -> [String] {
        var allProfiles = [String]()
        
        history.searchMessages.forEach { element in

            if element.isProfileBuild {
                
                let lines = element.answer.components(separatedBy: "\n")
                let isEmpty = text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                
                lines.forEach { single in
                    if isEmpty || single.lowercased().contains(text.lowercased()){
                        
                        if hasExactly22Commas(single) {
                            allProfiles.append(single)
                        }
                    }
                }
            }
        }
        
        return allProfiles
    }
}

func hasExactly22Commas(_ input: String) -> Bool {
    return input.filter { $0 == "," }.count == 22
}

protocol KeyboardReadable {
    var keyboardPublisher: AnyPublisher<Bool, Never> { get }
}

extension KeyboardReadable {
    var keyboardPublisher: AnyPublisher<Bool, Never> {
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .map { _ in true },
            
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in false }
        )
        .eraseToAnyPublisher()
    }
}
