import SwiftUI
import Kingfisher
import Firebase

struct ReleaseView: View {
    @EnvironmentObject var subManager: SubscriptionsManager
    @EnvironmentObject var popRoot: PopToRoot
    @EnvironmentObject var auth: AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @State var showBuy = true
    @State var assigningRole = false
    @State var discordJoin = false
    @State var showDiscordSheet: Bool = false
    
    @State var release: Release
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 20){
                    TabView {
                        ForEach(release.images, id: \.self) { image in
                            KFImage(URL(string: image))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .scaledToFill()
                                .frame(height: 400)
                        }
                    }
                    .tabViewStyle(.page)
                    .frame(height: 400)
                    
                    LazyVStack(alignment: .leading, spacing: 12){
                        Text(release.title)
                            .font(.title).fontWeight(.semibold)
                        HStack(spacing: 4){
                            Text("Retail:")
                                .foregroundStyle(.gray)
                                .font(.body).fontWeight(.light)
                            Text("$\(release.retail)")
                                .font(.body).fontWeight(.semibold)
                                .padding(.trailing, 16)
                            Text("Resell:")
                                .foregroundStyle(.gray)
                                .font(.body).fontWeight(.light)
                            Text("$\(release.resell)")
                                .font(.body).fontWeight(.semibold)
                                .foregroundStyle(release.resell >= release.retail ? .green : .red)
                            Spacer()
                        }
                        
                        Text(releaseTime()).font(.body)
                        
                        if let size = release.sizeRange, !size.isEmpty {
                            HStack(spacing: 4){
                                Text("Size Range:").foregroundStyle(.gray).font(.body).fontWeight(.light)
                                Text(size).font(.body).fontWeight(.semibold)
                                Spacer()
                            }
                        }
                        
                        Text(release.desc)
                            .font(.body).multilineTextAlignment(.leading)
                            .textSelection(.enabled).lineSpacing(8).padding(.top, 20)
                        
                        HStack(spacing: 6){
                            Text("SKU: \(release.sku ?? "NA")").font(.body)
                            Image(systemName: "document.on.document")
                                .font(.subheadline)
                            Spacer()
                        }
                        .onTapGesture {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            if let sku = release.sku {
                                UIPasteboard.general.string = sku
                            }
                            popRoot.presentAlert(image: "checkmark", text: "Sku Copied")
                        }
                        .padding(.top, 20)
                        
                        if let link = release.stockxUrl, let url = URL(string: link) {
                            Link(destination: url) {
                                HStack(spacing: 8){
                                    Image("stockX")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 30).scaleEffect(1.5).offset(x: 12)
                                    
                                    Spacer()
                                    
                                    Text("Open")
                                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                                        .padding(.horizontal, 10).padding(.vertical, 3)
                                        .background(Color.babyBlue).bold()
                                        .clipShape(Capsule())
                                }
                            }
                            .padding(12).background { backColorSec() }.clipShape(RoundedRectangle(cornerRadius: 12.0))
                        }
                        
                        if subManager.hasInfoAccess {
                            if discordJoin {
                                if let url = URL(string: "https://discord.gg/veTEKuHppZ") {
                                    Link(destination: url) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4){
                                                Text("Join Wealth AIO").font(.headline).fontWeight(.heavy)
                                                Text("Click to join the Discord Server.")
                                                    .font(.caption).foregroundStyle(.gray)
                                            }
                                            
                                            Spacer()
                                            
                                            Image(systemName: "arrowshape.turn.up.right")
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
                                    }.padding(.top, 15)
                                }
                            } else if (auth.currentUser?.discordUsername ?? "").isEmpty {
                                Button {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    showDiscordSheet = true
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4){
                                            Text("Link Discord").font(.headline).fontWeight(.heavy)
                                            Text("Connect Discord to access Perks")
                                                .font(.caption).foregroundStyle(.gray)
                                        }
                                        
                                        Spacer()
                                        
                                        Text("Link")
                                            .font(.subheadline).bold()
                                            .padding(.horizontal, 12).padding(.vertical, 6)
                                            .background(Color.blue).clipShape(Capsule()).shadow(color: .gray, radius: 3)
                                    }
                                    .padding(12)
                                    .background {
                                        TransparentBlurView(removeAllFilters: true)
                                            .blur(radius: 14, opaque: true)
                                            .background(colorScheme == .dark ? .black.opacity(0.4) : .white.opacity(0.5))
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .contentShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(content: {
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.red, lineWidth: 1).opacity(0.2)
                                    })
                                }.buttonStyle(.plain).padding(.top, 15)
                            } else {
                                Button {
                                    if !assigningRole {
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        
                                        withAnimation(.easeInOut(duration: 0.2)){
                                            assigningRole = true
                                        }
                                        
                                        Task {
                                            do {
                                                let username = auth.currentUser?.discordUsername ?? ""
                                                let succeeded = try await assignDiscordRole(username: username)
                                                
                                                if succeeded {
                                                    self.discordJoin = true
                                                    popRoot.presentAlert(image: "checkmark",
                                                                         text: "Role assigned! Visit Discord.")
                                                } else {
                                                    popRoot.presentAlert(image: "bubble.left.and.exclamationmark.bubble.right.fill",
                                                                         text: "Failed to assign role!")
                                                }
                                            } catch {
                                                popRoot.presentAlert(image: "bubble.left.and.exclamationmark.bubble.right.fill",
                                                                     text: "Failed to assign role!")
                                            }
                                            
                                            withAnimation(.easeInOut(duration: 0.2)){
                                                assigningRole = false
                                            }
                                        }
                                    }
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4){
                                            Text("Discord Pro Role").font(.headline).fontWeight(.heavy)
                                            Text("Click to get Role and Unlock Perks")
                                                .font(.caption).foregroundStyle(.gray)
                                        }
                                        
                                        Spacer()
                                        
                                        if assigningRole {
                                            ProgressView().transition(.scale)
                                        } else {
                                            Text("Get Role")
                                                .font(.subheadline).bold()
                                                .padding(.horizontal, 12).padding(.vertical, 6)
                                                .background(Color.blue).clipShape(Capsule()).shadow(color: .gray, radius: 3)
                                                .transition(.scale)
                                        }
                                    }
                                    .padding(12)
                                    .background {
                                        TransparentBlurView(removeAllFilters: true)
                                            .blur(radius: 14, opaque: true)
                                            .background(colorScheme == .dark ? .black.opacity(0.4) : .white.opacity(0.5))
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .contentShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(content: {
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.green, lineWidth: 1).opacity(0.2)
                                    })
                                }.buttonStyle(.plain).padding(.top, 15)
                            }
                            
                            infoView().padding(.top, 15)
                        } else {
                            Button {
                                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                                Task {
                                    await subManager.restorePurchases()
                                }
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4){
                                        Text("Restore Subscription").font(.headline).fontWeight(.heavy)
                                        Text("Have a subscription already?")
                                            .font(.caption).foregroundStyle(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("Restore")
                                        .font(.subheadline).bold().foregroundStyle(.white)
                                        .padding(.horizontal, 12).padding(.vertical, 6)
                                        .background(Color.blue).clipShape(Capsule()).shadow(color: .gray, radius: 3)
                                }
                                .padding(12)
                                .background {
                                    TransparentBlurView(removeAllFilters: true)
                                        .blur(radius: 14, opaque: true)
                                        .background(colorScheme == .dark ? .black.opacity(0.4) : .white.opacity(0.5))
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .contentShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(content: {
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(lineWidth: 1).opacity(0.2)
                                })
                            }.padding(.top, 30)

                            buyView()
                                .onAppear {
                                    if subManager.products.isEmpty {
                                        Task {
                                            await subManager.loadProducts()
                                        }
                                    }
                                }
                        }
                    }
                    .padding(.horizontal)
                    
                    Color.clear.frame(height: 180).id("buyNow")
                }
                .background(GeometryReader {
                    Color.clear.preference(key: ViewOffsetKey.self,
                                           value: -$0.frame(in: .named("scroll")).origin.y)
                })
                .onPreferenceChange(ViewOffsetKey.self) { value in
                    if !subManager.hasInfoAccess {
                        if value > 80.0 {
                            withAnimation(.easeInOut(duration: 0.2)){
                                showBuy = false
                            }
                        } else {
                            withAnimation(.easeInOut(duration: 0.2)){
                                showBuy = true
                            }
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
            .overlay(alignment: .top){
                if showBuy && !subManager.hasInfoAccess {
                    HStack {
                        Button {
                            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                            withAnimation(.easeInOut(duration: 0.1)){
                                proxy.scrollTo("buyNow", anchor: .top)
                            }
                            withAnimation(.easeInOut(duration: 0.2)){
                                showBuy = false
                            }
                        } label: {
                            ZStack {
                                Capsule().frame(width: 110, height: 40).foregroundStyle(Color.babyBlue)
                                    .shadow(color: .gray, radius: 4)
                                Text("View Pro").font(.headline).fontWeight(.heavy)
                            }
                        }.buttonStyle(.plain)
                    }
                    .padding(.top, top_Inset())
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
        .background(content: {
            DiscordLinkerSheet(showDiscordSheet: $showDiscordSheet)
        })
        .onAppear(perform: {
            if let user = auth.currentUser {
                if user.hasInfoAccess != subManager.hasInfoAccess {
                    UserService().editInfoStatus(hasAccess: subManager.hasInfoAccess)
                    auth.currentUser?.hasInfoAccess = subManager.hasInfoAccess
                }
                
                if !auth.subbedToInfoTopic && subManager.infoWasSet {
                    auth.subbedToInfoTopic = true
                    
                    if subManager.hasInfoAccess {
                        Messaging.messaging().subscribe(toTopic: "info") { error in
                            print("Subscribed to info topic")
                            if let error {
                                print("Err \(error.localizedDescription)")
                            }
                        }
                    } else {
                        Messaging.messaging().unsubscribe(fromTopic: "info") { error in
                            print("UnSubscribed from info topic")
                            if let error {
                                print("Err \(error.localizedDescription)")
                            }
                        }
                    }
                }
            }
        })
        .background(content: {
            backColor()
        })
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .overlay(alignment: .top){
            HStack {
                Button {
                    dismiss()
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .frame(width: 44, height: 44)
                        .background(.ultraThickMaterial)
                        .clipShape(Circle())
                }.buttonStyle(.plain)
                Spacer()
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    if let url = URL(string: "https://wealth.com/releases/\(release.id ?? "")") {
                        showShareSheet(url: url)
                    }
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title3)
                        .frame(width: 44, height: 44)
                        .background(.ultraThickMaterial)
                        .clipShape(Circle()).offset(y: -1.5)
                }.buttonStyle(.plain)
            }.padding(.horizontal)
        }
        .onChange(of: popRoot.tap) { _, _ in
            if popRoot.tap == 1 {
                dismiss()
                popRoot.tap = 0
            }
        }
    }
    func releaseTime() -> String {
        let date = release.releaseTime.dateValue()
        let calendar = Calendar.current
        let formatter = DateFormatter()
        
        if calendar.isDateInToday(date) {
            formatter.dateFormat = "h:mm a"
            return "Today, \(formatter.string(from: date))"
        } else if calendar.isDateInTomorrow(date) {
            formatter.dateFormat = "h:mm a"
            return "Tomorrow, \(formatter.string(from: date))"
        }
        
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMMM"
        
        let day = calendar.component(.day, from: date)
        let ordinalFormatter = NumberFormatter()
        ordinalFormatter.numberStyle = .ordinal
        let dayOrdinal = ordinalFormatter.string(from: NSNumber(value: day)) ?? String(day)
        
        formatter.dateFormat = "h:mm a"
        let time = formatter.string(from: date)
        return "\(monthFormatter.string(from: date)) \(dayOrdinal), \(time)"
    }
    @ViewBuilder
    func buyView() -> some View {
        VStack(alignment: .leading, spacing: 8){
            HStack {
                Text("Wealth Pro")
                    .font(.title).bold()
                Spacer()
                Text("$9.99 Monthly")
                    .fontWeight(.semibold)
            }
            Text("With Pro you unlock:").italic().fontWeight(.light).padding(.bottom, 6)
            
            Text("- Discord server with Live Alerts/Info.")
            Text("- Exclusive Popmart and Pokemon Info.")
            Text("- Bot setup (Delays, Modes, Keywords).")
            Text("- Wealth AIO staff analysis on drops.")
            Text("- Push notifications for shock drops.")
            Text("- Live Stock Count (if available).")
            Text("- Stock count push notifications.")
            Text("- Important release information.")
            Text("- Links to all releasing sites.")
            Text("- Links to all raffles.")
            Text("- One-click task setup")
            Text("- Release variants.")
            Text("- Ebay sale data.")
            
            Button {
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                if let product = subManager.products.first {
                    Task {
                        do {
                            try await subManager.buyProduct(product)
                            popRoot.presentAlert(image: "checkmark", text: "Purchase successful!")
                            self.subManager.hasInfoAccess = true
                            
                            try await Messaging.messaging().subscribe(toTopic: "info")
                            print("Subscribed to 'info' topic successfully!")
                            
                        } catch PurchaseError.verificationFailed(_) {
                            popRoot.presentAlert(image: "xmark", text: "Verification failed")
                        } catch PurchaseError.transactionPending {
                            popRoot.presentAlert(image: "xmark", text: "Transaction is pending approval.")
                        } catch PurchaseError.userCancelled {
                            popRoot.presentAlert(image: "xmark", text: "Please reattempt purchase.")
                        } catch PurchaseError.unknownState {
                            popRoot.presentAlert(image: "xmark", text: "Unknown error occurred during the purchase.")
                        } catch {
                            popRoot.presentAlert(image: "xmark", text: "Error making purchase.")
                        }
                    }
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 12.0)
                        .foregroundStyle(Color.babyBlue)
                        .frame(height: 40)
                    Text("Purchase")
                        .font(.headline)
                }
            }.padding(.top, 10).buttonStyle(.plain)
        }
        .padding(12)
        .background {
            TransparentBlurView(removeAllFilters: true)
                .blur(radius: 14, opaque: true)
                .background(colorScheme == .dark ? .black.opacity(0.4) : .white.opacity(0.5))
        }
        .clipShape(RoundedRectangle(cornerRadius: 12.0))
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
    @ViewBuilder
    func infoView() -> some View {
        LazyVStack(alignment: .leading, spacing: 12){
            if let stock = release.stockCount {
                HStack(spacing: 8){
                    Text("Stock Count:").font(.title3).bold().padding(.bottom, 6)
                    
                    Spacer()
                    
                    Text("\(stock)")
                        .padding(.horizontal, 10).padding(.vertical, 3)
                        .background(Color.babyBlue).bold()
                        .clipShape(Capsule())
                }
                .padding(12).background { backColorSec() }.clipShape(RoundedRectangle(cornerRadius: 12.0))
            }
            if let staff = release.staffAnalysis, !staff.isEmpty {
                VStack(alignment: .leading, spacing: 8){
                    HStack {
                        Text("Staff Analysis:")
                            .font(.title3).bold().padding(.bottom, 6)
                        Spacer()
                    }
                    
                    if let cost = release.estimatedShipping {
                        HStack(spacing: 5){
                            Text("Estimated Shipping:").bold()
                                .foregroundStyle(.blue)
                            Text("$\(cost)")
                            Spacer()
                        }
                    }
                    
                    Text(staff).multilineTextAlignment(.leading)
                }
                .padding(12).background { backColorSec() }.clipShape(RoundedRectangle(cornerRadius: 12.0))
            }
            if let raffles = release.raffles, !raffles.isEmpty {
                VStack(alignment: .leading, spacing: 8){
                    HStack {
                        Text("Raffles").font(.title3).bold().padding(.bottom, 6)
                        Spacer()
                    }
                    
                    ForEach(raffles, id: \.self) { link in
                        if let url = URL(string: link) {
                            Link(destination: url) {
                                Text(link).lineLimit(1).foregroundStyle(.blue)
                            }
                        }
                    }
                }
                .padding(12).background { backColorSec() }.clipShape(RoundedRectangle(cornerRadius: 12.0))
            }
            if let available = release.availableAtUrl, !available.isEmpty {
                VStack(alignment: .leading, spacing: 8){
                    HStack {
                        Text("Sites Releasing").font(.title3).bold().padding(.bottom, 6)
                        Spacer()
                    }
                    
                    ForEach(available, id: \.self) { link in
                        if let url = URL(string: link) {
                            Link(destination: url) {
                                Text(link).lineLimit(1).foregroundStyle(.blue)
                            }
                        }
                    }
                }
                .padding(12).background { backColorSec() }.clipShape(RoundedRectangle(cornerRadius: 12.0))
            }
            if let variants = release.variants, !variants.isEmpty {
                VStack(alignment: .leading, spacing: 8){
                    HStack {
                        Text("Variants").font(.title3).bold().padding(.bottom, 6)
                        
                        Image(systemName: "document.on.document").font(.subheadline).offset(y: -1)
                        
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        UIPasteboard.general.string = variants.joined(separator: ",")
                        popRoot.presentAlert(image: "checkmark", text: "Variants Copied")
                    }

                    ForEach(variants, id: \.self) { link in
                        Text(link).foregroundStyle(.blue).textSelection(.enabled)
                    }
                }
                .padding(12).background { backColorSec() }.clipShape(RoundedRectangle(cornerRadius: 12.0))
            }
            if let countries = release.availableCountries, !countries.isEmpty {
                HStack(spacing: 8){
                    Text("For Countries:").font(.title3).bold().padding(.bottom, 6)
                    
                    Spacer()
                    
                    ForEach(countries, id: \.self) { link in
                        Text(link)
                            .padding(.horizontal, 10).padding(.vertical, 3)
                            .background(Color.babyBlue).bold()
                            .clipShape(Capsule())
                    }
                }
                .padding(12).background { backColorSec() }.clipShape(RoundedRectangle(cornerRadius: 12.0))
            }
            if release.suggestedMode != nil || release.suggestedKeywords != nil || release.suggestedDelays != nil {
                VStack(alignment: .leading, spacing: 8){
                    HStack {
                        Text("Suggested Setup").font(.title3).bold().padding(.bottom, 6)
                        Spacer()
                    }
                    
                    if let mode = release.suggestedMode {
                        HStack(spacing: 5){
                            Text("Mode:").foregroundStyle(.blue).bold()
                            Text(mode)
                            Spacer()
                        }
                    }
                    if let delay = release.suggestedDelays {
                        HStack(spacing: 5){
                            Text("Delay:").foregroundStyle(.blue).bold()
                            Text("\(delay)")
                            Spacer()
                        }
                    }
                    if let keywords = release.suggestedKeywords {
                        HStack(spacing: 5){
                            Text("Keywords:  ").foregroundStyle(.blue).bold()
                            + Text(keywords)
                            Spacer()
                        }
                        .onTapGesture {
                            UIPasteboard.general.string = keywords
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            popRoot.presentAlert(image: "checkmark", text: "Keywords Copied")
                        }
                    }
                }
                .padding(12).background { backColorSec() }.clipShape(RoundedRectangle(cornerRadius: 12.0))
            }
            if release.ebaySoldUrl != nil || release.ebaySoldCount != nil {
                VStack(alignment: .leading, spacing: 8){
                    HStack {
                        Text("Ebay Data").font(.title3).bold().padding(.bottom, 6)
                        Spacer()
                    }
                    
                    if let link = release.ebaySoldUrl, let url = URL(string: link) {
                        HStack(spacing: 5){
                            Text("Sold URL:").bold()
                            Link(destination: url) {
                                Text(link).foregroundStyle(.blue).lineLimit(1).truncationMode(.tail)
                            }
                            Spacer()
                        }
                    }
                    if let count = release.ebaySoldCount {
                        HStack(spacing: 5){
                            Text("Sold Count:").bold()
                            Text("\(count)")
                            Spacer()
                        }
                    }
                }
                .padding(12).background { backColorSec() }.clipShape(RoundedRectangle(cornerRadius: 12.0))
            }
            if let tags = release.tags, !tags.isEmpty {
                TagLayout(alignment: .center, spacing: 8) {
                    ForEach(tags, id: \.self) { tag in
                        Text(tag)
                            .font(.subheadline).bold()
                            .foregroundStyle(colorScheme == .dark ? .black : .white)
                            .padding(.horizontal, 12).padding(.vertical, 4)
                            .background(.blue.gradient)
                            .clipShape(Capsule())
                    }
                }.padding(.top)
            }
        }
    }
    @ViewBuilder
    func backColorSec() -> some View {
        TransparentBlurView(removeAllFilters: true)
            .blur(radius: 14, opaque: true)
            .background(colorScheme == .dark ? .black.opacity(0.35) : .white.opacity(0.35))
    }
}

func assignDiscordRole(username: String) async throws -> Bool {
    let url = URL(string: "https://assignrole-7jwus4bkna-uc.a.run.app/assign")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let payload: [String: String] = [
        "authKey": "adminMobileDelivery",
        "discordUsername": username
    ]
    
    request.httpBody = try JSONEncoder().encode(payload)
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse else {
        throw NSError(domain: "InvalidResponse", code: 0)
    }
    
    if httpResponse.statusCode == 200 {
        if let responseDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           responseDict["success"] != nil {
            return true
        }
    }
    
    return false
}
