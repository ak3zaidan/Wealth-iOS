import SwiftUI
import CryptoKit
import FirebaseCore
import FirebaseAuth
import Charts
import Kingfisher
import GoogleSignIn
import AuthenticationServices

struct SettingsSheetView: View {
    @Environment(NotificationViewModel.self) private var notifModel
    @Environment(ProfileViewModel.self) private var viewModel
    @Environment(TaskViewModel.self) private var taskModel
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var popRoot: PopToRoot
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    @State var deleteAccErr = ""
        
    @State var lineColor: Color = .green
    @State var showEditUsername: Bool = false
    @State var sendAutoPush: Bool = true
    @State var useResiToUpdate: Bool = true
    @State var newKeyLoad: Bool = false
    @State var showAlert: Bool = false
    @State var showDiscordSheet: Bool = false
    @State var showDeleteAccountAlert: Bool = false
    @State var clothingSize = ""
    @State var newUsername = ""
    @State var shoeSize = ""
    @State var deleteUsername = ""
    @State var deletePassword = ""
    @State var deleteAccountError = ""
    @State var deleteLoading: Bool = false
    @FocusState var isEditing
    @FocusState var isEditingUsername
    @FocusState var isEditingPassword
 
    @Binding var hideOrderNums: Bool?
    
    var body: some View {
        ScrollView {
            VStack {
                headerView().padding(.top).padding(.bottom, 12)
                
                LineChart(data: viewModel.yearIncrease, lineColor: lineColor)
                    .frame(height: 200).padding(15)
                    .background(.gray.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .padding(.bottom, 10)
                    .overlay(alignment: .topLeading){
                        VStack(alignment: .leading){
                            Text("Year Checkouts").font(.headline).bold()
                                .padding(.leading, 12).padding(.top, 12)
                            
                            if let change = calculateYearPercentChange(data: viewModel.yearIncrease) {
                                Text(String(format: "\(change >= 0 ? "+" : "")%.1f%%", change))
                                    .font(.title3).bold()
                                    .padding(.leading, 12)
                                    .foregroundStyle(lineColor)
                            }
                            Spacer()
                        }
                    }
                    .overlay {
                        if viewModel.yearIncrease.isEmpty {
                            LoadingStocks()
                        }
                    }
                    .padding(.top, 14).padding(.bottom, 20)

                if hideOrderNums != nil {
                    toggleRowView(
                        name: "Hide Order Numbers",
                        status: Binding(
                            get: { hideOrderNums ?? false },
                            set: { hideOrderNums = $0 }
                        )
                    )
                }
                
                HStack {
                    Text("My Shoe Size:")
                        .font(.headline).fontWeight(.semibold).lineLimit(1)
                    Spacer()
                    Picker("", selection: $shoeSize) {
                        ForEach(["No selection"] + shoeSizes, id: \.self) {
                            Text($0)
                        }
                    }
                }
                .padding(10)
                .background {
                    TransparentBlurView(removeAllFilters: true)
                        .blur(radius: 10, opaque: true)
                        .background(colorScheme == .dark ? .black.opacity(0.5) : .white.opacity(0.5))
                }
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .onChange(of: shoeSize) { _, _ in
                    if shoeSize != "No selection" {
                        if let current = auth.currentUser?.shoeSize, current != shoeSize {
                            UserService().updateSize(size: shoeSize, field: "shoeSize")
                            DispatchQueue.main.async {
                                auth.currentUser?.shoeSize = shoeSize
                            }
                        } else {
                            UserService().updateSize(size: shoeSize, field: "shoeSize")
                            DispatchQueue.main.async {
                                auth.currentUser?.shoeSize = shoeSize
                            }
                        }
                    }
                }
                
                HStack {
                    Text("My Clothing Size:")
                        .font(.headline).fontWeight(.semibold).lineLimit(1)
                    Spacer()
                    Picker("", selection: $clothingSize) {
                        ForEach(["No selection"] + clothingSizes, id: \.self) {
                            Text($0)
                        }
                    }
                }
                .padding(10)
                .background {
                    TransparentBlurView(removeAllFilters: true)
                        .blur(radius: 10, opaque: true)
                        .background(colorScheme == .dark ? .black.opacity(0.5) : .white.opacity(0.5))
                }
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .onChange(of: clothingSize) { _, _ in
                    if clothingSize != "No selection" {
                        if let current = auth.currentUser?.clothingSize, current != clothingSize {
                            UserService().updateSize(size: clothingSize, field: "clothingSize")
                            DispatchQueue.main.async {
                                auth.currentUser?.clothingSize = clothingSize
                            }
                        } else {
                            UserService().updateSize(size: clothingSize, field: "clothingSize")
                            DispatchQueue.main.async {
                                auth.currentUser?.clothingSize = clothingSize
                            }
                        }
                    }
                }
                
                HStack {
                    Text("App version:")
                        .font(.headline).fontWeight(.semibold).lineLimit(1)
                    Spacer()
                    Text(APPVERSION).font(.body).fontWeight(.heavy).italic()
                }
                .padding(10)
                .background {
                    TransparentBlurView(removeAllFilters: true)
                        .blur(radius: 10, opaque: true)
                        .background(colorScheme == .dark ? .black.opacity(0.5) : .white.opacity(0.5))
                }
                .clipShape(RoundedRectangle(cornerRadius: 15))

                HStack {
                    Text("Manage AIO subscription")
                        .font(.headline).fontWeight(.semibold).lineLimit(1)
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding(10)
                .background {
                    TransparentBlurView(removeAllFilters: true)
                        .blur(radius: 10, opaque: true)
                        .background(colorScheme == .dark ? .black.opacity(0.5) : .white.opacity(0.5))
                }
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .onTapGesture {
                    if let url = URL(string: "https://wealth-aio.com/admin/dashboard") {
                        DispatchQueue.main.async {
                            UIApplication.shared.open(url, completionHandler: nil)
                        }
                    }
                }
                
                HStack {
                    Text("Privacy Policy")
                        .font(.headline).fontWeight(.semibold).lineLimit(1)
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding(10)
                .background {
                    TransparentBlurView(removeAllFilters: true)
                        .blur(radius: 10, opaque: true)
                        .background(colorScheme == .dark ? .black.opacity(0.5) : .white.opacity(0.5))
                }
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .onTapGesture {
                    if let url = URL(string: "https://wealth-aio.com/privacy-policy") {
                        DispatchQueue.main.async {
                            UIApplication.shared.open(url, completionHandler: nil)
                        }
                    }
                }
                
                HStack {
                    Text("Terms of Service")
                        .font(.headline).fontWeight(.semibold).lineLimit(1)
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding(10)
                .background {
                    TransparentBlurView(removeAllFilters: true)
                        .blur(radius: 10, opaque: true)
                        .background(colorScheme == .dark ? .black.opacity(0.5) : .white.opacity(0.5))
                }
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .onTapGesture {
                    if let url = URL(string: "https://wealth-aio.com/terms-service") {
                        DispatchQueue.main.async {
                            UIApplication.shared.open(url, completionHandler: nil)
                        }
                    }
                }
                
                HStack {
                    if let username = auth.currentUser?.discordUsername, !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        
                        Text("Discord Account:")
                            .font(.headline).fontWeight(.light).lineLimit(1)
                        Text(username)
                            .font(.headline).fontWeight(.bold).lineLimit(1)
                        
                    } else {
                        Text("Discord not Linked!")
                            .font(.headline).fontWeight(.semibold).lineLimit(1)
                    }
                    Spacer()
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        showDiscordSheet = true
                    } label: {
                        Text(auth.currentUser?.discordUID == nil ? "Link Now" : "Switch").font(.subheadline).bold()
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background(Color.babyBlue).clipShape(Capsule())
                    }.buttonStyle(.plain)
                }
                .padding(10)
                .background {
                    TransparentBlurView(removeAllFilters: true)
                        .blur(radius: 10, opaque: true)
                        .background(colorScheme == .dark ? .black.opacity(0.5) : .white.opacity(0.5))
                }
                .clipShape(RoundedRectangle(cornerRadius: 15))
                
                if auth.currentUser?.hasBotAccess ?? false {
                    toggleRowView(name: "Use Wealth Proxies to quickly update order status", status: $useResiToUpdate)
                        .onChange(of: useResiToUpdate) { _, _ in
                            UserService().updateUseResiToUpdate(shouldUse: useResiToUpdate)
                            auth.currentUser?.useResiToUpdate = useResiToUpdate
                        }
                        .onAppear {
                            self.useResiToUpdate = auth.currentUser?.useResiToUpdate ?? true
                        }
                    
                    toggleRowView(name: "Automation Notifications", status: $sendAutoPush)
                        .onChange(of: sendAutoPush) { _, _ in
                            UserService().editAutoPush(value: sendAutoPush)
                            auth.currentUser?.disableAutoPush = !sendAutoPush
                        }
                        .onAppear {
                            self.sendAutoPush = !(auth.currentUser?.disableAutoPush ?? false)
                        }
                    
                    HStack(spacing: 3){
                        Text("AIO Key: ")
                            .font(.headline).fontWeight(.semibold).lineLimit(1)
                        
                        if newKeyLoad {
                            Spacer()
                            Text("Refreshing...")
                                .font(.headline).fontWeight(.semibold).lineLimit(1)
                        } else {
                            Text(auth.currentUser?.botKey ?? "NA")
                                .frame(width: 60).lineLimit(1).truncationMode(.tail)
                                .font(.headline).fontWeight(.light)
                            
                            Spacer()
                            Image(systemName: "link").foregroundStyle(.blue)
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
                        if !newKeyLoad {
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                            UIPasteboard.general.string = auth.currentUser?.botKey ?? ""
                        } else {
                            UINotificationFeedbackGenerator().notificationOccurred(.error)
                        }
                    }
                    
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)){
                            newKeyLoad = true
                        }
                        UserService().resetKey { newKey in
                            if let newKey {
                                auth.currentUser?.botKey = newKey
                                UINotificationFeedbackGenerator().notificationOccurred(.success)
                            } else {
                                UINotificationFeedbackGenerator().notificationOccurred(.error)
                            }
                            withAnimation(.easeInOut(duration: 0.3)){
                                newKeyLoad = false
                            }
                        }
                    } label: {
                        HStack {
                            VStack(alignment: .leading){
                                Text("Reset AIO Key.").font(.headline).bold()
                                Text("This will terminate running Wealth AIO servers.").font(.caption)
                            }
                            Spacer()
                            if newKeyLoad {
                                ProgressView()
                            }
                        }
                        .padding(8).background(.red.gradient)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }.buttonStyle(.plain).disabled(newKeyLoad).padding(.top, 20)
                    Button {
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                        UserService().resetPhoneIP()
                    } label: {
                        HStack {
                            VStack(alignment: .leading){
                                Text("Reset Wealth AIO Mobile Remote.").font(.headline).bold()
                                Text("This will reset connected mobile devices.").font(.caption)
                            }
                            Spacer()
                        }
                        .padding(8).background(.indigo.gradient)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }.buttonStyle(.plain).padding(.top, 5)
                    Button {
                        showAlert = true
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    } label: {
                        HStack {
                            VStack(alignment: .leading){
                                Text("Reset Wealth AIO Server Session.").font(.headline).bold()
                                Text("This will terminate running Wealth AIO servers.").font(.caption)
                            }
                            Spacer()
                        }
                        .padding(8).background(.red.gradient)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }.buttonStyle(.plain).padding(.top, 5)
                    Button {
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                        ServerSend().updateServer(instance: 1)
                        
                        if let owned = auth.currentUser?.ownedInstances, owned > 0 {
                            for i in 0..<owned {
                                ServerSend().updateServer(instance: i + 2)
                            }
                        }
                    } label: {
                        HStack {
                            VStack(alignment: .leading){
                                Text("Update Wealth AIO server.").font(.headline).bold()
                                Text("This may restart running Wealth AIO servers.").font(.caption)
                            }
                            Spacer()
                        }
                        .padding(8).background(.indigo.gradient)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }.buttonStyle(.plain).padding(.top, 5)
                }
                
                if let tags = auth.currentUser?.unlockedTools, !tags.isEmpty {
                    HStack {
                        Spacer()
                        Text("Unlocked Tools:").font(.headline).bold().padding(.top, 20)
                        Spacer()
                    }
                    TagLayout(alignment: .center, spacing: 10) {
                        ForEach(tags, id: \.self) { tag in
                            Text(tag)
                                .font(.body).bold()
                                .foregroundStyle(colorScheme == .dark ? .black : .white)
                                .padding(.horizontal, 12).padding(.vertical, 8)
                                .background(.blue.gradient)
                                .clipShape(Capsule())
                        }
                        Text("Wealth Proxies")
                            .font(.body).bold()
                            .foregroundStyle(colorScheme == .dark ? .black : .white)
                            .padding(.horizontal, 12).padding(.vertical, 8)
                            .background(.blue.gradient)
                            .clipShape(Capsule())
                    }
                }
                
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    dismiss()
                    logout()
                } label: {
                    ZStack {
                        Capsule().foregroundStyle(.red).frame(height: 50)
                        Text("Logout").font(.headline).bold()
                    }
                }.buttonStyle(.plain).padding(.top, 80).padding(.bottom, 12)
                
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    
                    let type = detectUserSignInMethod()
                    
                    if type == "apple" {
                        deleteAppleUser { error in
                            if error == "" {
                                deleteAccErr = ""
                                
                                dismiss()
                                
                                logout()
                            } else {
                                UINotificationFeedbackGenerator().notificationOccurred(.error)
                                
                                deleteAccErr = error
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                    deleteAccErr = ""
                                }
                            }
                        }
                    } else if type == "google" {
                        deleteUser { error in
                            if error == "" {
                                deleteAccErr = ""
                                
                                dismiss()
                                
                                logout()
                            } else {
                                UINotificationFeedbackGenerator().notificationOccurred(.error)
                                
                                deleteAccErr = error
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                    deleteAccErr = ""
                                }
                            }
                        }
                    } else {
                        withAnimation(.easeInOut(duration: 0.3)){
                            showDeleteAccountAlert = true
                        }
                    }
                } label: {
                    ZStack {
                        Capsule().foregroundStyle(.red).frame(height: 50)
                        Text(deleteAccErr.isEmpty ? "DELETE ACCOUNT" : deleteAccErr)
                            .font(.headline).bold()
                    }
                }.buttonStyle(.plain).padding(.bottom, 40)
            }.padding(.horizontal, 12)
        }
        .scrollIndicators(.hidden)
        .alert("Confirm Server Reset", isPresented: $showAlert, actions: {
            Button("Reset", role: .destructive) {
                UserService().resetServerIP(hasScale: (auth.currentUser?.ownedInstances ?? 0) > 0)
            }
            Button("Cancel", role: .cancel) { }
        })
        .background(content: {
            DiscordLinkerSheet(showDiscordSheet: $showDiscordSheet)
        })
        .background(content: {
            backColor()
        })
        .presentationDetents([.large])
        .presentationCornerRadius(30).presentationDragIndicator(.visible)
        .onAppear {
            if let user = auth.currentUser {

                self.shoeSize = user.shoeSize ?? "No selection"
 
                self.clothingSize = user.clothingSize ?? "No selection"
                
                if user.checkoutCount > 0 && viewModel.yearIncrease.isEmpty {
                    CheckoutService().getYearIncrease { vals in
                        DispatchQueue.main.async {
                            withAnimation(.easeInOut(duration: 0.3)){
                                viewModel.yearIncrease = vals
                            }
                        }
                        if !vals.isEmpty {
                            determineLineColor(data: vals)
                        }
                    }
                }
            }
        }
        .overlay {
            if showEditUsername || showDeleteAccountAlert {
                TransparentBlurView(removeAllFilters: true)
                    .blur(radius: 14, opaque: true).ignoresSafeArea()
                    .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white.opacity(0.5))
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.25)){
                            showEditUsername = false
                            showDeleteAccountAlert = false
                            deleteAccountError = ""
                        }
                    }
            }
        }
        .overlay(content: {
            if showDeleteAccountAlert {
                VStack(spacing: 25){
                    VStack(spacing: 5){
                        Text("Delete Account").font(.title2).bold()
                        
                        if deleteAccountError == "" {
                            Text("Verify login to continue").font(.caption).bold()
                        } else {
                            Text(deleteAccountError).font(.caption).foregroundStyle(.red).bold()
                        }
                    }
                    
                    VStack(spacing: 12){
                        
                        TextField("", text: $deleteUsername)
                            .lineLimit(1)
                            .focused($isEditingUsername)
                            .frame(height: 57)
                            .padding(.top, 8)
                            .overlay(alignment: .leading, content: {
                                Text("Email").font(.system(size: 18)).fontWeight(.light)
                                    .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
                                    .opacity(isEditingUsername ? 0.8 : 0.5)
                                    .offset(y: deleteUsername.isEmpty && !isEditingUsername ? 0.0 : -21.0)
                                    .scaleEffect(deleteUsername.isEmpty && !isEditingUsername ? 1.0 : 0.8, anchor: .leading)
                                    .animation(.easeInOut(duration: 0.2), value: isEditingUsername)
                                    .onTapGesture {
                                        isEditingUsername = true
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
                                    .opacity(isEditingUsername ? 0.8 : 0.5)
                            })
                        
                        TextField("", text: $deletePassword)
                            .lineLimit(1)
                            .focused($isEditingPassword)
                            .frame(height: 57)
                            .padding(.top, 8)
                            .overlay(alignment: .leading, content: {
                                Text("Password").font(.system(size: 18)).fontWeight(.light)
                                    .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
                                    .opacity(isEditingPassword ? 0.8 : 0.5)
                                    .offset(y: deletePassword.isEmpty && !isEditingPassword ? 0.0 : -21.0)
                                    .scaleEffect(deletePassword.isEmpty && !isEditingPassword ? 1.0 : 0.8, anchor: .leading)
                                    .animation(.easeInOut(duration: 0.2), value: isEditingPassword)
                                    .onTapGesture {
                                        isEditingPassword = true
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
                                    .opacity(isEditingPassword ? 0.8 : 0.5)
                            })
                    }
                    
                    let status = !deleteUsername.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !deletePassword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    
                    Button {
                        if !deleteLoading {
                            
                            withAnimation(.easeInOut(duration: 0.2)){
                                deleteLoading = true
                            }
                            
                            if status {
                                deleteAccount { error in
                                    withAnimation(.easeInOut(duration: 0.2)){
                                        deleteLoading = false
                                    }
                                    
                                    if error == "" {
                                        deleteAccountError = ""
                                        
                                        withAnimation(.easeInOut(duration: 0.15)){
                                            showDeleteAccountAlert = false
                                        }
                                        
                                        dismiss()
                                        
                                        logout()
                                        
                                    } else {
                                        deleteAccountError = error
                                        UINotificationFeedbackGenerator().notificationOccurred(.error)
                                    }
                                }
                            } else {
                                UINotificationFeedbackGenerator().notificationOccurred(.error)
                            }
                        }
                    } label: {
                        ZStack {
                            Color.red
                            
                            if deleteLoading {
                                ProgressView()
                            } else {
                                Text("Delete").fontWeight(status ? .heavy : .regular).opacity(status ? 1.0 : 0.6)
                            }
                        }
                        .frame(height: 45)
                        .background(Color.red)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                    }.buttonStyle(.plain)
                }
                .padding(12).background(Color.gray.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 15)).padding(.horizontal, 40)
                .ignoresSafeArea(edges: .bottom)
                .transition(.move(edge: .bottom).combined(with: .opacity).combined(with: .scale))
                .offset(y: -130)
            }
        })
        .overlay {
            if showEditUsername {
                VStack(spacing: 25){
                    Text("Edit Username").font(.title2).bold()
                    
                    TextField("", text: $newUsername)
                        .lineLimit(1)
                        .focused($isEditing)
                        .frame(height: 57)
                        .padding(.top, 8)
                        .overlay(alignment: .leading, content: {
                            Text("New Username").font(.system(size: 18)).fontWeight(.light)
                                .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
                                .opacity(isEditing ? 0.8 : 0.5)
                                .offset(y: newUsername.isEmpty && !isEditing ? 0.0 : -21.0)
                                .scaleEffect(newUsername.isEmpty && !isEditing ? 1.0 : 0.8, anchor: .leading)
                                .animation(.easeInOut(duration: 0.2), value: isEditing)
                                .onTapGesture {
                                    isEditing = true
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
                                .opacity(isEditing ? 0.8 : 0.5)
                        })
                    
                    let status = usernameStatus()
                    
                    Button {
                        if status {
                            withAnimation(.easeInOut(duration: 0.25)){
                                showEditUsername = false
                            }
                            auth.currentUser?.username = "@\(newUsername)"
                            UserService().editUsername(username: "@\(newUsername)")
                            newUsername = ""
                        }
                    } label: {
                        ZStack {
                            Color.babyBlue
                            Text("Save").fontWeight(status ? .heavy : .regular).opacity(status ? 1.0 : 0.6)
                        }
                        .frame(height: 45)
                        .background(Color.babyBlue)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                    }.buttonStyle(.plain)
                }
                .padding(12).background(Color.gray.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 15)).padding(.horizontal, 40)
                .ignoresSafeArea(edges: .bottom)
                .transition(.move(edge: .bottom).combined(with: .opacity).combined(with: .scale))
                .offset(y: -100)
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
    // Apple delete
    func deleteAppleUser(completion: @escaping(String) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion("No user is currently signed in.")
            return
        }

        guard let rawNonce = randomNonceString() else {
            completion("Failed to generate nonce.")
            return
        }

        let hashedNonce = sha256(rawNonce)

        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = hashedNonce

        let controller = ASAuthorizationController(authorizationRequests: [request])
        let delegate = AppleAuthDelegate(rawNonce: rawNonce) { credential, error in
            if error != nil {
                completion("Apple reauthentication failed")
                return
            }

            guard let appleIDToken = credential?.identityToken,
                  let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                
                completion("Unable to get Apple ID token.")
                return
            }

            let firebaseCredential = OAuthProvider.credential(
                providerID: AuthProviderID.apple,
                idToken: idTokenString,
                rawNonce: rawNonce,
                accessToken: nil
            )

            currentUser.reauthenticate(with: firebaseCredential) { _, error in
                if error != nil {
                    completion("Reauthentication failed")
                    return
                }

                currentUser.delete { error in
                    if error != nil {
                        completion("Failed to delete user")
                    } else {
                        completion("")
                    }
                }
            }
        }

        controller.delegate = delegate
        controller.performRequests()
    }
    private func randomNonceString(length: Int = 32) -> String? {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            return nil
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    // Google delete user
    func deleteUser(completion: @escaping(String) -> Void) {
        guard Auth.auth().currentUser != nil else {
            completion("No user is currently signed in")
            return
        }
        
        // Get Google credential
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion("Unable to get Firebase client ID")
            return
        }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let presentingViewController = windowScene.windows.first?.rootViewController else {
            completion("Unable to get presenting view controller")
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { result, error in
            guard error == nil,
                  let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                completion("Google sign-in failed")
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: user.accessToken.tokenString)
            
            // Re-authenticate
            Auth.auth().currentUser?.reauthenticate(with: credential) { _, error in
                if error != nil {
                    completion("Re-authentication failed")
                } else {
                    // Now delete the user
                    Auth.auth().currentUser?.delete { error in
                        if error != nil {
                            completion("Error deleting user")
                        } else {
                            completion("") // Empty string on success
                        }
                    }
                }
            }
        }
    }
    // Email delete user
    func deleteAccount(completion: @escaping(String) -> Void){
        guard let user = Auth.auth().currentUser else {
            completion("Error deleting account, try again later")
            return
        }
        
        let credential = EmailAuthProvider.credential(withEmail: deleteUsername, password: deletePassword)
        
        user.reauthenticate(with: credential) { (result, error) in
            if let error = error {
                
                let str = error.localizedDescription
                
                if str.contains("password") || str.contains("supplied credentials do not correspond"){
                    completion("Wrong username or password please try again")
                } else {
                    completion("Error deleting account, try again later")
                }
            } else {
                user.delete { error in
                    if error != nil {
                        completion("Error deleting account, try again later")
                    } else {
                        completion("")
                    }
                }
            }
        }
    }
    func usernameStatus() -> Bool {
        var usernameError = inputChecker().myInputChecker(withString: newUsername, withLowerSize: 1, withUpperSize: 14, needsLower: true)
        
        if newUsername == "WealthStaff" {
            usernameError = "Username cannot be 'WealthStaff'"
        } else if newUsername.hasPrefix("@") {
            usernameError = "Username cannot start with '@'"
        }

        return !newUsername.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && usernameError.isEmpty
    }
    @ViewBuilder
    func toggleRowView(name: String, status: Binding<Bool>) -> some View {
        ZStack(alignment: .leading){
            Text(name).font(.headline).fontWeight(.semibold).multilineTextAlignment(.leading)
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
    func headerView() -> some View {
        ZStack(alignment: .topTrailing){
            HStack {
                Spacer()
                VStack(spacing: 25){
                    
                    ImagePickerButton(image: auth.currentUser?.profileImageUrl) { image in
                        auth.uploadImage(image: image, location: "userPhotos", compression: 0.25) { im, _ in
                            if !im.isEmpty {
                                UserService().editImage(newURL: im)
                                
                                DispatchQueue.main.async {
                                    auth.currentUser?.profileImageUrl = im
                                }
                            }
                        }
                    }
                    
                    VStack(spacing: 8){
                        Text((auth.currentUser?.username ?? "@randomUser")).font(.title).bold()
                            .onTapGesture {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                withAnimation(.easeInOut(duration: 0.25)){
                                    showEditUsername = true
                                }
                            }
                        
                        Text(formatSince()).font(.subheadline).foregroundStyle(.gray).fontWeight(.light)
                    }
                }
                Spacer()
            }.padding(.top, 35)
                
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                dismiss()
            } label: {
                Image(systemName: "xmark").font(.title3).bold()
                    .padding(8).background(.gray).clipShape(Circle())
            }.buttonStyle(.plain)
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
    func logout() {
        auth.signOut()
        
        DispatchQueue.main.async {
            notifModel.gotReleases = false
            notifModel.notifications = []
            notifModel.unseenCount = 0
            
            viewModel.checkouts = []
            viewModel.cachedFilters = []
            viewModel.dayIncrease = (0, 0.0)
            viewModel.monthIncrease = (0, 0.0)
            viewModel.yearIncrease = []
            viewModel.leaderBoardPosition = 0
            viewModel.gotCheckouts = false
            
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
    private func determineLineColor(data: [Int]) {
        let lastThreeMonths = Array(data.suffix(3))
        if lastThreeMonths.count == 3, lastThreeMonths[2] < lastThreeMonths[0] {
            self.lineColor = .red
        } else {
            self.lineColor = .green
        }
    }
    func calculateYearPercentChange(data: [Int]) -> Double? {
        guard let first = data.first(where: { $0 > 0 }), let last = data.last, first != 0 else {
            return nil
        }
        
        let percentChange = (Double(last - first) / Double(first)) * 100
        return percentChange
    }
}

class AppleAuthDelegate: NSObject, ASAuthorizationControllerDelegate {
    private let rawNonce: String
    private let onCompletion: (ASAuthorizationAppleIDCredential?, Error?) -> Void
    private var selfRetain: AppleAuthDelegate?

    init(rawNonce: String, onCompletion: @escaping (ASAuthorizationAppleIDCredential?, Error?) -> Void) {
        self.rawNonce = rawNonce
        self.onCompletion = onCompletion
        super.init()
        self.selfRetain = self // Retain self
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        defer { selfRetain = nil } // Release self after completion
        
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            onCompletion(credential, nil)
        } else {
            onCompletion(nil, NSError(domain: "AppleID", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid credential"]))
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        defer { selfRetain = nil } // Release self after completion
        onCompletion(nil, error)
    }
}

func detectUserSignInMethod() -> String {
    guard let user = Auth.auth().currentUser else {
        return "No user signed in"
    }

    for userInfo in user.providerData {
        switch userInfo.providerID {
        case "password":
            return "email"
        case "google.com":
            return "google"
        case "apple.com":
            return "apple"
        default:
            return "unknown"
        }
    }

    return "unknown"
}

struct DiscordLinkerSheet: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var popRoot: PopToRoot
    @State var discordUsername = ""
    @State var discordUID = ""
    @State var isLoggedIn = false
    @Binding var showDiscordSheet: Bool
 
    var body: some View {
        VStack {
            
        }
        .onChange(of: discordUsername, { _, _ in
            if !discordUsername.isEmpty && !discordUID.isEmpty {
                UserService().updateDiscordInfo(username: discordUsername, discordUid: discordUID)
                if auth.currentUser?.discordUsername != discordUsername {
                    refreshDate()
                }
                auth.currentUser?.discordUsername = discordUsername
                auth.currentUser?.discordUID = discordUID
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
}


struct ImagePickerButton: View {
    @Environment(\.colorScheme) var colorScheme
    @State var showPicker: Bool = false
    @State var selectedImage: UIImage?
    let image: String?
    let sendImage: (UIImage) -> Void
    
    var body: some View {
        Button {
            showPicker = true
        } label: {
            ZStack {
                Circle()
                    .foregroundStyle(.gray)
                    .frame(width: 100, height: 100)
                
                Image(systemName: "plus").font(.title3).foregroundStyle(.blue)
                
                if let image {
                    KFImage(URL(string: image))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .contentShape(Circle())
                        .shadow(color: .gray, radius: 2)
                        .overlay(alignment: .bottomTrailing) {
                            Image(systemName: "plus")
                                .font(.subheadline)
                                .padding(10)
                                .background(Color.babyBlue)
                                .clipShape(Circle())
                                .padding(3)
                                .background(colorScheme == .dark ? .black : .white)
                                .clipShape(Circle())
                                .offset(x: 4, y: 4)
                        }
                }
            }
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showPicker, onDismiss: loadImage){
            ImagePicker(selectedImage: $selectedImage)
        }
    }
    func loadImage() {
        guard let selectedImage = selectedImage else { return }
        
        sendImage(selectedImage)
    }
}

struct LineChart: View {
    let data: [Int]
    let lineColor: Color
    
    var body: some View {
        GeometryReader { geometry in
            let maxValue = data.max() ?? 1
            let points = data.enumerated().map { index, value -> CGPoint in
                let x = geometry.size.width * CGFloat(index) / CGFloat(data.count - 1)
                let y = geometry.size.height * (1 - CGFloat(value) / CGFloat(maxValue))
                return CGPoint(x: x, y: y)
            }
            
            ZStack {
                Path { path in
                    guard let firstPoint = points.first else { return }
                    path.move(to: firstPoint)
                    points.dropFirst().forEach { path.addLine(to: $0) }
                }
                .stroke(lineColor, lineWidth: 2)
                
                ForEach(points.indices, id: \.self) { index in
                    ZStack {
                        Circle()
                            .foregroundStyle(.clear)
                            .frame(width: 20, height: 20)
                        Circle()
                            .fill(lineColor)
                            .frame(width: 6, height: 6)
                    }
                    .overlay {
                        let max = data.max() ?? 0
                        
                        Text("\(data[index])")
                            .font(.caption).offset(y: max <= data[index] ? 20 : -20)
                    }
                    .position(points[index])
                }
            }
        }
    }
}

struct LoadingStocks: View {
    var body: some View {
        ZStack {
            LoaderLine(restart: true, data: (0..<60).map { _ in Double.random(in: 0...550) }).shimmering()
        }.frame(height: 180)
    }
}

struct LoaderLine: View {
    let restart: Bool
    var data: [Double]
    @State var graphProgress: CGFloat = 0
    
    var body: some View {
        GeometryReader { proxy in
            let height = proxy.size.height
            let width = (proxy.size.width) / CGFloat(data.count - 1)
            
            let maxPoint = (data.max() ?? 0)
            let minPoint = data.min() ?? 0
            
            let points = data.enumerated().compactMap { item -> CGPoint in

                let progress = (item.element - minPoint) / (maxPoint - minPoint)
                
                let pathHeight = progress * (height - 50)

                let pathWidth = width * CGFloat(item.offset)

                return CGPoint(x: pathWidth, y: -pathHeight + height)
            }
            AnimatedGraphPath(progress: graphProgress, points: points)   .foregroundStyle(LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .leading, endPoint: .trailing))
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                withAnimation(.easeInOut(duration: 4.0)){
                    graphProgress = 1
                }
            }
            if restart {
                Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
                    withAnimation(.easeInOut(duration: 4.0)){
                        if graphProgress == 1 {
                            graphProgress = 0
                        } else {
                            graphProgress = 1
                        }
                    }
                }
            }
        }
    }
}

struct AnimatedGraphPath: Shape{
    var progress: CGFloat
    var points: [CGPoint]
    var animatableData: CGFloat{
        get{return progress}
        set{progress = newValue}
    }
    func path(in rect: CGRect) -> Path {
        Path { path in

            path.move(to: CGPoint(x: 0, y: 0))
            
            path.addLines(points)
        }
        .trimmedPath(from: 0, to: progress)
        .strokedPath(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
    }
}
