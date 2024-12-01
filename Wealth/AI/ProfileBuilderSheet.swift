import SwiftUI
import Kingfisher

struct ProfileBuilderSheet: View, KeyboardReadable {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @State var keyBoardShowing: Bool = false
    
    // Misc
    @State var fileName: String = ""
    @State var profileCount: String = "1"
    @State var randomName = true
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var emailStatus = 3
    @State var emailSingle: String = ""
    @State var emailDomain: String = ""
    
    // Shipping
    @State var jigPhone = true
    @State var jigLevel = 2
    @State private var city: String = ""
    @State private var state: String = ""
    @State private var zipcode: String = ""
    @State private var country: String = "US"
    @State private var phoneNumber: String = ""
    @State private var address1: String = ""
    @State private var address2: String = ""
    
    // Billing
    @State var billingMatchesShipping = true
    @State private var billingFirstName: String = ""
    @State private var billingLastName: String = ""
    @State private var billingAddress1: String = ""
    @State private var billingAddress2: String = ""
    @State private var billingCountry: String = "US"
    @State private var billingState: String = ""
    @State private var billingCity: String = ""
    @State private var billingZipCode: String = ""
    
    // Extend
    @State var extend = false
    @State var recurenceFrequency: RecurenceFrequency = .month
    @State private var cardLimit: String = "49999"
    @State var createNew = false
    
    // Card
    @State private var ccNumber: String = ""
    @State private var ccMonth: String = ""
    @State private var ccYear: String = ""
    @State private var cvv: String = ""
    
    // Build
    @State private var buildError: String = ""
    @State var showExtendMessage = false
    @State var showExtendError = false
    @State var showExtendErrorMessage = "An error occured getting extend status, would you like to try again?"
    @State var showWebView = false
    @State var loadingPicker = false
    @State var loadingPickerError = false
    @State var showCards = false
    @State var foundCards: [ExtendAccounts] = []
    @State private var sourceAccountId = ""
    @State private var sourceAccountEmail = ""
    @State var accessToken: String = ""
    
    // Return
    let build: ((String, [String])) -> Void
    let buildVCC: (ExtendPassThrough) -> Void
    
    var body: some View {
        VStack(spacing: 10){
            headerView().padding(.horizontal).padding(.top)
            
            ScrollView {
                LazyVStack(spacing: 30){
                    HStack(spacing: 10){
                        textFieldView(value: $fileName, name: "Group Name", hasXmark: true)
                        textFieldView(value: $profileCount, name: "Create count", hasXmark: false)
                            .keyboardType(.numberPad)
                    }
                    
                    VStack(spacing: 10){
                        HStack {
                            Text("Random Names").font(.headline).bold()
                            Spacer()
                            Toggle("", isOn: $randomName.animation(.easeInOut(duration: 0.2)))
                        }
                        if !randomName {
                            Divider()
                            textFieldView(value: $firstName, name: "First Name", hasXmark: true)
                            textFieldView(value: $lastName, name: "Last Name", hasXmark: true)
                        }
                    }.padding(10).background(.gray.opacity(0.15)).clipShape(RoundedRectangle(cornerRadius: 15))
                    
                    VStack(spacing: 10){
                        HStack(spacing: 5){
                            Text("Email:").font(.headline).bold()
                            Spacer()
                            ZStack {
                                Capsule().frame(height: 40).foregroundStyle(emailStatus == 1 ? Color.babyBlue : Color.gray)
                                Text("Single").font(.subheadline).bold()
                            }
                            .onTapGesture {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                withAnimation(.easeInOut(duration: 0.2)){  emailStatus = 1 }
                            }
                            ZStack {
                                Capsule().frame(height: 40).foregroundStyle(emailStatus == 2 ? Color.babyBlue : Color.gray)
                                Text("Catch-all").font(.subheadline).bold()
                            }
                            .onTapGesture {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                withAnimation(.easeInOut(duration: 0.2)){  emailStatus = 2 }
                            }
                            ZStack {
                                Capsule().frame(height: 40).foregroundStyle(emailStatus == 3 ? Color.babyBlue : Color.gray)
                                Text("Random").font(.subheadline).bold()
                            }
                            .onTapGesture {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                withAnimation(.easeInOut(duration: 0.2)){  emailStatus = 3 }
                            }
                        }
                        if emailStatus == 1 {
                            Divider()
                            textFieldView(value: $emailSingle, name: "Email", hasXmark: true)
                                .keyboardType(.emailAddress)
                        } else if emailStatus == 2 {
                            Divider()
                            textFieldView(value: $emailDomain, name: "Domain", hasXmark: true)
                                .keyboardType(.URL)
                                .onChange(of: emailDomain) { _, _ in
                                    if !emailDomain.hasPrefix("@") {
                                        emailDomain = "@" + emailDomain
                                    }
                                }
                        }
                    }.padding(10).background(.gray.opacity(0.15)).clipShape(RoundedRectangle(cornerRadius: 15))
                    
                    VStack(alignment: .leading, spacing: 8){
                        Text("Shipping address").font(.headline)
                        VStack(spacing: 10){
                            HStack {
                                Text("Randomize Phone").font(.headline).bold()
                                Spacer()
                                Toggle("", isOn: $jigPhone.animation(.easeInOut(duration: 0.2)))
                            }
                            if !jigPhone {
                                textFieldView(value: $phoneNumber, name: "Phone Number", hasXmark: true)
                                    .keyboardType(.phonePad)
                            }
                            
                            HStack(spacing: 15){
                                ZStack {
                                    Capsule().frame(height: 40).foregroundStyle(jigLevel == 1 ? Color.babyBlue : Color.gray)
                                    Text("No Jig").font(.subheadline).bold()
                                }
                                .onTapGesture {
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    jigLevel = 1
                                }
                                ZStack {
                                    Capsule().frame(height: 40).foregroundStyle(jigLevel == 2 ? Color.babyBlue : Color.gray)
                                    Text("Normal Jig").font(.subheadline).bold()
                                }
                                .onTapGesture {
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    jigLevel = 2
                                }
                                ZStack {
                                    Capsule().frame(height: 40).foregroundStyle(jigLevel == 3 ? Color.babyBlue : Color.gray)
                                    Text("Heavy Jig").font(.subheadline).bold()
                                }
                                .onTapGesture {
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    jigLevel = 3
                                }
                            }.padding(.vertical)
                            
                            textFieldView(value: $address1, name: "Address 1", hasXmark: true)
                            textFieldView(value: $address2, name: "Address 2", hasXmark: true)
                            HStack(spacing: 10){
                                textFieldView(value: $country, name: "Country", hasXmark: true)
                                Picker("State", selection: $state) {
                                    ForEach(stateAbbreviations, id: \.self) {
                                        Text($0)
                                    }
                                }
                            }
                            HStack(spacing: 10){
                                textFieldView(value: $city, name: "City", hasXmark: true)
                                textFieldView(value: $zipcode, name: "ZipCode", hasXmark: true)
                            }
                        }.padding(10).background(.gray.opacity(0.15)).clipShape(RoundedRectangle(cornerRadius: 15))
                    }
                    
                    VStack(alignment: .leading, spacing: 8){
                        Text("Billing address").font(.headline)
                        VStack(spacing: 10){
                            ZStack(alignment: .trailing){
                                HStack {
                                    Text("Billing matches Shipping").font(.headline).bold()
                                    Spacer()
                                }
                                Toggle("", isOn: $billingMatchesShipping.animation(.easeInOut(duration: 0.2)))
                            }
                            if !billingMatchesShipping {
                                Divider()
                                HStack(spacing: 10){
                                    textFieldView(value: $billingFirstName, name: "First Name", hasXmark: true)
                                    textFieldView(value: $billingLastName, name: "Last Name", hasXmark: true)
                                }
                                textFieldView(value: $billingAddress1, name: "Address 1", hasXmark: true)
                                textFieldView(value: $billingAddress2, name: "Address 2", hasXmark: true)
                                HStack(spacing: 10){
                                    textFieldView(value: $billingCountry, name: "Country", hasXmark: true)
                                    Picker("State", selection: $billingState) {
                                        ForEach(stateAbbreviations, id: \.self) {
                                            Text($0)
                                        }
                                    }
                                }
                                HStack(spacing: 10){
                                    textFieldView(value: $billingCity, name: "City", hasXmark: true)
                                    textFieldView(value: $billingZipCode, name: "ZipCode", hasXmark: true)
                                }
                            }
                        }.padding(10).background(.gray.opacity(0.15)).clipShape(RoundedRectangle(cornerRadius: 15))
                    }
                    
                    VStack(alignment: .leading, spacing: 8){
                        Text("Card Details").font(.headline)
                        VStack(spacing: 10){
                            HStack {
                                Text("Extend VCC").font(.headline).bold()
                                Spacer()
                                Toggle("", isOn: $extend.animation(.easeInOut(duration: 0.2)))
                            }
                            
                            if extend {
                                HStack(spacing: 5){
                                    ZStack {
                                        Capsule().frame(height: 40).foregroundStyle(createNew == false ? Color.babyBlue : Color.gray)
                                        Text("Use existing VCC").font(.subheadline).bold()
                                    }
                                    .onTapGesture {
                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                        withAnimation(.easeInOut(duration: 0.2)){  createNew = false }
                                    }
                                    ZStack {
                                        Capsule().frame(height: 40).foregroundStyle(createNew == true ? Color.babyBlue : Color.gray)
                                        Text("Create new VCC").font(.subheadline).bold()
                                    }
                                    .onTapGesture {
                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                        withAnimation(.easeInOut(duration: 0.2)){  createNew = true }
                                    }
                                }.padding(.bottom, 10).padding(.top, 6)
                                
                                if createNew {
                                    HStack(alignment: .top, spacing: 2){
                                        Text("-").foregroundStyle(.blue)
                                        Text("One recurring VCC will be generated per profile. \(profileCount) total VCC will be created.")
                                        Spacer()
                                    }.font(.caption).padding(.bottom, 6).bold()
                                    
                                    textFieldView(value: $cardLimit, name: "CC limit", hasXmark: false)
                                        .keyboardType(.numberPad).padding(.vertical, 10)
                                    
                                    VStack(alignment: .leading, spacing: 7){
                                        
                                        Text("Recurrence Frequency").font(.headline).bold()
                                        
                                        HStack(spacing: 5){
                                            ZStack {
                                                Capsule().frame(height: 40).foregroundStyle(recurenceFrequency == .day ? Color.babyBlue : Color.gray)
                                                Text("Day").font(.subheadline).bold()
                                            }
                                            .onTapGesture {
                                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                                withAnimation(.easeInOut(duration: 0.2)){  recurenceFrequency = .day }
                                            }
                                            ZStack {
                                                Capsule().frame(height: 40).foregroundStyle(recurenceFrequency == .week ? Color.babyBlue : Color.gray)
                                                Text("Week").font(.subheadline).bold()
                                            }
                                            .onTapGesture {
                                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                                withAnimation(.easeInOut(duration: 0.2)){  recurenceFrequency = .week }
                                            }
                                            ZStack {
                                                Capsule().frame(height: 40).foregroundStyle(recurenceFrequency == .month ? Color.babyBlue : Color.gray)
                                                Text("Month").font(.subheadline).bold()
                                            }
                                            .onTapGesture {
                                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                                withAnimation(.easeInOut(duration: 0.2)){  recurenceFrequency = .month }
                                            }
                                        }
                                    }
                                }
                            } else {
                                textFieldView(value: $ccNumber, name: "Card Number", hasXmark: true)
                                    .keyboardType(.numberPad)
                                HStack(spacing: 5){
                                    textFieldView(value: $ccMonth, name: "Exp Month", hasXmark: false)
                                        .keyboardType(.numberPad)
                                    textFieldView(value: $ccYear, name: "Exp Year", hasXmark: false)
                                        .keyboardType(.numberPad)
                                    textFieldView(value: $cvv, name: "CVV", hasXmark: false)
                                        .keyboardType(.numberPad)
                                }
                            }
                        }.padding(10).background(.gray.opacity(0.15)).clipShape(RoundedRectangle(cornerRadius: 15))
                    }
                    
                    Color.clear.frame(height: 250)
                }.padding(.horizontal, 12).padding(.top, 2)
            }.padding(.top, 10).scrollIndicators(.hidden)
                        
            let status = buildErrorStatus().isEmpty
            
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()

                if status {
                    if extend {
                        showExtendMessage = true
                    } else {
                        genData(isExtend: false)
                    }
                } else {
                    buildError = buildErrorStatus()
                }
            } label: {
                ZStack {
                    Capsule().foregroundStyle(status ? Color.babyBlue : Color.red).frame(height: 50)
                    if status {
                        Text("Build").font(.headline).bold()
                    } else if buildError.isEmpty {
                        Text("Fill out fields").font(.headline)
                    } else {
                        Text(buildError).font(.caption).fontWeight(.semibold)
                    }
                }
            }
            .ignoresSafeArea().buttonStyle(.plain)
            .padding(.bottom, 40).padding(.horizontal)
        }
        .ignoresSafeArea(edges: .bottom)
        .padding(.top, 5)
        .presentationDetents([.large]).presentationDragIndicator(.visible).presentationCornerRadius(30)
        .background {
            backColor()
        }
        .onReceive(keyboardPublisher) { newIsKeyboardVisible in
            withAnimation(.easeInOut(duration: 0.2)){
                keyBoardShowing = newIsKeyboardVisible
            }
        }
        .alert("To create VCC you have to sign in, wait for the picker to appear, and select the desired source account", isPresented: $showExtendMessage) {
            Button("Continue") {
                if foundCards.isEmpty {
                    accessToken = ""
                }
                loadingPicker = false
                loadingPickerError = false
                
                showWebView = true
            }
            Button("Cancel", role: .cancel) { }
        }
        .alert(showExtendErrorMessage, isPresented: $showExtendError) {
            Button("Try again") {
                if foundCards.isEmpty {
                    accessToken = ""
                }
                loadingPicker = false
                loadingPickerError = false
                
                showWebView = true
            }
            Button("Cancel", role: .cancel) { }
        }
        .sheet(isPresented: $showWebView) {
            WebView (
                url: URL(string: "https://app.paywithextend.com/signin")!,
                accessToken: $accessToken
            )
            .overlay(content: {
                if loadingPicker || loadingPickerError || showCards {
                    Color.gray.opacity(0.2).ignoresSafeArea()
                }
            })
            .overlay(content: {
                if showCards {
                    VStack(spacing: 15){
                        Text("Select an Account").font(.title3).bold()
                        
                        let maxH = widthOrHeight(width: false) * 0.6
                        let calH = CGFloat(foundCards.count * 50)
                        
                        ScrollView {
                            LazyVStack(spacing: 12){
                                ForEach(foundCards) { card in
                                    Button {
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        sourceAccountId = card.id
                                        sourceAccountEmail = card.email
                                        showWebView = false
                                        genData(isExtend: true)
                                    } label: {
                                        HStack {
                                            KFImage(URL(string: card.photo))
                                                .resizable()
                                                .scaledToFit().frame(height: 50)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                                .contentShape(RoundedRectangle(cornerRadius: 8))
                                            VStack(alignment: .leading, spacing: 3){
                                                Text(card.displayName).font(.headline).bold().lineLimit(1)
                                                Text(card.companyName).font(.caption).lineLimit(1)
                                            }
                                            Spacer()
                                        }
                                        .padding(8).background(Color.blue.opacity(0.35))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }.buttonStyle(.plain)
                                }
                            }
                        }.scrollIndicators(.hidden).frame(height: min(calH, maxH))
                    }
                    .padding().background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .transition(.move(edge: .bottom).combined(with: .scale))
                    .padding(.horizontal, 40)
                } else if loadingPicker {
                    VStack(spacing: 25){
                        Text("Loading Accounts...").font(.headline)
                        
                        LottieView(loopMode: .loop, name: "aiLoad")
                            .scaleEffect(0.7).frame(width: 100, height: 100)
                    }
                    .padding().background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .transition(.move(edge: .bottom).combined(with: .scale))
                } else if loadingPickerError {
                    VStack(spacing: 10){
                        Text("Account Error").font(.headline)
                        
                        Text("An error occured loading extend card accounts. Please ensure your extend account has valid card accounts.").font(.subheadline).fontWeight(.light).padding(.vertical, 10)
                        
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            showWebView = false
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 15).foregroundStyle(.gray).frame(height: 45)
                                Text("Cancel").font(.subheadline).bold()
                            }
                        }.buttonStyle(.plain)
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            withAnimation(.easeInOut(duration: 0.2)){
                                loadingPickerError = false
                                loadingPicker = true
                            }
                            setAccounts()
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 15).foregroundStyle(.blue).frame(height: 45)
                                Text("Retry").font(.subheadline).bold()
                            }
                        }.buttonStyle(.plain)
                    }
                    .padding().background(.ultraThickMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .transition(.move(edge: .bottom).combined(with: .scale)).padding(.horizontal, 40)
                }
            })
            .overlay(alignment: .top, content: {
                HStack {
                    Spacer()
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        showWebView = false
                    } label: {
                        Text("Cancel").font(.subheadline).bold()
                            .padding(.horizontal, 9).padding(.vertical, 5)
                            .background(Color.babyBlue).clipShape(Capsule())
                    }.buttonStyle(.plain).padding(.trailing).frame(height: 60)
                }.ignoresSafeArea(edges: .top)
            })
            .ignoresSafeArea(edges: .bottom)
            .onDisappear {
                if accessToken.isEmpty {
                    showExtendErrorMessage = "An error occured getting extend status, would you like to try again?"
                    showExtendError = true
                } else if sourceAccountId.isEmpty {
                    showExtendErrorMessage = "A source account was not selected, if you have active extend credit card accounts you can try again. Otherwise create extend credit card accounts from your browser."
                    showExtendError = true
                }
            }
            .onChange(of: accessToken) { _, _ in
                if !accessToken.isEmpty {
                    withAnimation(.easeInOut(duration: 0.2)){
                        loadingPicker = true
                    }
                    setAccounts()
                }
            }
        }
    }
    func setAccounts() {
        getAccounts(accessToken: accessToken) { accounts in
            if accounts.isEmpty {
                withAnimation(.easeInOut(duration: 0.2)){
                    loadingPicker = false
                    loadingPickerError = true
                }
            } else {
                self.foundCards = accounts
                
                withAnimation(.easeInOut(duration: 0.2)){
                    loadingPicker = false
                    loadingPickerError = false
                    showCards = true
                }
            }
        }
    }
    func buildErrorStatus() -> String {
        if isNotValidString(str: fileName) {
            return "Enter a valid Group Name"
        }
        
        if fileName.contains("'") {
            return "Group name cannot contain single quotes"
        }
        
        if let count = Int(profileCount) {
            if count <= 0 || count > 500 {
                return "Enter a Create Count 1 - 500"
            }
        } else {
            return "Enter a valid Create Count"
        }
        
        if !randomName {
            if isNotValidString(str: firstName) {
                return "Enter a valid first name"
            }
            if isNotValidString(str: lastName) {
                return "Enter a valid last name"
            }
        }
        
        if emailStatus == 1 {
            if isNotValidString(str: emailSingle) {
                return "Enter a valid email"
            }
        } else if emailStatus == 2 {
            if isNotValidString(str: emailDomain) {
                return "Enter a valid domain"
            }
        }
        
        if !jigPhone {
            if isNotValidString(str: phoneNumber) {
                return "Enter a valid phone number"
            }
        }
        if isNotValidString(str: address1) {
            return "Enter a valid address"
        }
        if isNotValidString(str: country) {
            return "Enter a valid country"
        }
        if isNotValidString(str: state) {
            return "Select a state"
        }
        if isNotValidString(str: city) {
            return "Enter a valid city"
        }
        if isNotValidString(str: zipcode) {
            return "Enter a valid zipcode"
        }
        
        if !billingMatchesShipping {
            if isNotValidString(str: billingAddress1) {
                return "Enter a valid billing address"
            }
            if isNotValidString(str: billingCountry) {
                return "Enter a valid billing country"
            }
            if isNotValidString(str: billingState) {
                return "Select a billing state"
            }
            if isNotValidString(str: billingCity) {
                return "Enter a valid billing city"
            }
            if isNotValidString(str: billingZipCode) {
                return "Enter a valid billing zipcode"
            }
        }
        
        if extend {
            if createNew {
                if let val = Int(cardLimit), val < 1 || val > 1000000 {
                    return "Enter a CC limit between 1 and 1 million"
                }
            }
        } else {
            if isNotValidString(str: ccNumber) {
                return "Enter a valid CC number"
            }
            if ccMonth.trimmingCharacters(in: .whitespacesAndNewlines).count != 2 {
                return "Enter a valid CC Expiry month in 'MM' format"
            }
            if ccYear.trimmingCharacters(in: .whitespacesAndNewlines).count != 2 {
                return "Enter a valid CC Expiry month in 'MM' format"
            }
            if isNotValidString(str: cvv) {
                return "Enter a valid CVV code"
            }
        }
        
        return ""
    }
    func genData(isExtend: Bool) {
        var dataArray = [String]()
        
        for i in 1..<((Int(profileCount) ?? 1) + 1) {
            var profileString = "\(fileName)\(i),"

            let randomFirst = commonFirstNames.randomElement() ?? "Jack"
            let randomLast = commonLastNames.randomElement() ?? "Miller"
            if randomName {
                profileString += "\(randomFirst),\(randomLast),"
            } else {
                profileString += "\(firstName),\(lastName),"
            }
            
            if emailStatus == 1 { // Single email
                profileString += "\(emailSingle),"
            } else {
                let randomPrefix = Int.random(in: 1...3)
                let randomNumber = String(Int.random(in: 1...30))
                
                let randomStart = "\(randomFirst)\(randomLast.prefix(randomPrefix))\(randomNumber)"
                
                if emailStatus == 2 { // Domain
                    profileString += "\(randomStart)\(emailDomain),"
                } else { // Full random
                    profileString += "\(randomStart)@gmail.com,"
                }
            }
            
            if jigLevel == 1 {
                profileString += "\(address1),"
                
                if !address2.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    profileString += "\(address2),"
                } else {
                    profileString += ","
                }
            } else if jigLevel == 2 {
                let addy1 = getAddress1Mid(str: address1)
                let addy2 = getAddress2(str: address2)
                
                profileString += "\(addy1),"
                
                if !addy2.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    profileString += "\(addy2),"
                } else {
                    profileString += ","
                }
            } else {
                let addy1 = getAddress1Heavy(str: address1)
                let addy2 = getAddress2(str: address2)
                
                profileString += "\(addy1),"
                
                if !addy2.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    profileString += "\(addy2),"
                } else {
                    profileString += ","
                }
            }
            profileString += "\(city),\(state),\(zipcode),\(country),"
            
            if jigPhone {
                profileString += "\(generateRandomPhoneNumber()),"
            } else {
                profileString += "\(phoneNumber),"
            }
            
            if isExtend {
                profileString += ",,,,"
            } else {
                profileString += "\(ccNumber),\(ccMonth),\(ccYear),\(cvv),"
            }
            
            if billingMatchesShipping {
                profileString += "na,na,na,na,na,na,na,na"
            } else {
                profileString += "\(billingFirstName),\(billingLastName),\(billingAddress1),"
                
                if !billingAddress2.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    profileString += "\(billingAddress2),"
                } else {
                    profileString += ","
                }
                
                profileString += "\(billingCountry),\(billingState),\(billingCity),\(billingZipCode)"
            }
            
            dataArray.append(profileString)
        }
        
        if isExtend {
            let new = ExtendPassThrough(fileName: fileName, sourceAccountId: sourceAccountId, accessToken: accessToken, cardLimit: Int(cardLimit) ?? 2000, email: sourceAccountEmail, dataArray: dataArray, recurenceFrequency: recurenceFrequency, shouldCreateNew: createNew)
            
            buildVCC(new)
        } else {
            build((fileName, dataArray))
        }
        dismiss()
    }
    func getAddress1Mid(str: String) -> String {
        return processAddress(str)
    }
    func getAddress1Heavy(str: String) -> String {
        let prefix = generateRandomUppercaseString()
        let newAddy = processAddress(str)
        
        return "\(prefix) \(newAddy)"
    }
    func getAddress2(str: String) -> String {
        if str.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let val = Int.random(in: 1...6)
            
            if val == 6 {
                return ""
            }
            
            let aptNumber = Int.random(in: 1...30)
            let aptLetter = getRandomAlphabeticString()
            
            if val == 1 {
                return "Apt \(aptLetter)\(aptNumber)"
            } else if val == 2 {
                return "STE \(aptNumber)\(aptLetter)"
            } else if val == 3 {
                return "Unit\(aptLetter)\(aptNumber)"
            } else if val == 4 {
                return "Building \(aptLetter)\(aptNumber)"
            } else if val == 5 {
                return "Condo \(aptLetter)\(aptNumber)"
            }
        }
        
        return ""
    }
    func processAddress(_ address: String) -> String {
        var result = address
        let directions = [
            "sw": "South West",
            "nw": "North West",
            "se": "South East",
            "ne": "North East"
        ]
        
        let prefixes = directions.keys
        let fullNames = directions.values
        
        // Check for prefixes like "sw", "nw", etc.
        for prefix in prefixes {
            if result.lowercased().contains(prefix) {
                if Int.random(in: 1...2) == 2 {
                    result = result.replacingOccurrences(of: "(?i)\\b\(prefix)\\b", with: directions[prefix]!, options: .regularExpression)
                }
                return result
            }
        }
        
        // Check for full names like "South West", "North East", etc.
        for fullName in fullNames {
            if result.lowercased().contains(fullName.lowercased()) {
                if Int.random(in: 1...2) == 2 {
                    let prefix = directions.first(where: { $0.value == fullName })!.key
                    result = result.replacingOccurrences(of: "(?i)\\b\(fullName)\\b", with: prefix.uppercased(), options: .regularExpression)
                }
                return result
            }
        }
        
        return result
    }
    func getRandomAlphabeticString() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return String(letters.randomElement()!)
    }
    func generateRandomUppercaseString() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let randomCount = Int.random(in: 1...4)
        var result = ""
        
        for _ in 0..<randomCount {
            if let randomLetter = letters.randomElement() {
                result.append(randomLetter)
            }
        }
        
        return result
    }
    func generateRandomPhoneNumber() -> String {
        let areaCode = Int.random(in: 200...999) // Random 3-digit area code
        let prefix = Int.random(in: 200...999)  // Random 3-digit prefix
        let lineNumber = Int.random(in: 1000...9999) // Random 4-digit line number

        return "\(areaCode)\(prefix)\(lineNumber)"
    }
    @ViewBuilder
    func textFieldView(value: Binding<String>, name: String, hasXmark: Bool) -> some View {
        TextField("", text: value)
            .lineLimit(1)
            .frame(height: 57)
            .padding(.top, 8).padding(.trailing, hasXmark ? 30 : 0)
            .overlay(alignment: .leading, content: {
                Text(name).font(.system(size: 18)).fontWeight(.light)
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
                if !value.wrappedValue.isEmpty && hasXmark {
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
    func headerView() -> some View {
        ZStack {
            HStack {
                Spacer()
                Text("Profile Builder").font(.title2).bold()
                Spacer()
            }
            HStack {
                Spacer()
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    if keyBoardShowing {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    } else {
                        dismiss()
                    }
                } label: {
                    Image(systemName: keyBoardShowing ? "chevron.down" : "xmark")
                        .font(.title3).bold().foregroundStyle(.gray)
                        .symbolEffect(.bounce, value: keyBoardShowing)
                }
            }
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

func mergeVCC(vcc: [ExtendVCC], profiles: [String]) -> [String] {
    var vccIndex = 0
    var mergedProfiles = [String]()
    
    profiles.forEach { profile in

        let completeProfile = mergeCreditCardInfo(profileString: profile, cardInfo: vcc[vccIndex])
        
        if !completeProfile.isEmpty {
            mergedProfiles.append(completeProfile)
        }
        
        if (vccIndex + 1) < vcc.count {
            vccIndex += 1
        } else {
            vccIndex = 0
        }
    }
    
    return mergedProfiles
}

func mergeCreditCardInfo(profileString: String, cardInfo: ExtendVCC) -> String {
    var components = profileString.components(separatedBy: ",")

    if components.count == 23 {
        components[11] = cardInfo.ccNum
        components[12] = cardInfo.ccMonth
        components[13] = cardInfo.ccYear
        components[14] = cardInfo.cvv
    } else {
        return ""
    }

    return components.joined(separator: ",")
}

func isNotValidString(str: String) -> Bool {
    if !str.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        return false
    }
    return true
}

let stateAbbreviations = [
    "AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA",
    "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD",
    "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ",
    "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC",
    "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY"
]

let commonFirstNames = [
    "James", "Mary", "John", "Patricia", "Robert", "Jennifer", "Michael", "Linda", "William", "Elizabeth",
    "David", "Barbara", "Richard", "Susan", "Joseph", "Jessica", "Thomas", "Sarah", "Charles", "Karen",
    "Christopher", "Nancy", "Daniel", "Lisa", "Matthew", "Betty", "Anthony", "Margaret", "Mark", "Sandra",
    "Donald", "Ashley", "Steven", "Kimberly", "Paul", "Emily", "Andrew", "Donna", "Joshua", "Michelle",
    "Kenneth", "Dorothy", "Kevin", "Carol", "Brian", "Amanda", "George", "Melissa", "Edward", "Deborah",
    "Ronald", "Stephanie", "Timothy", "Rebecca", "Jason", "Laura", "Jeffrey", "Sharon", "Ryan", "Cynthia",
    "Jacob", "Kathleen", "Gary", "Amy", "Nicholas", "Shirley", "Eric", "Angela", "Jonathan", "Helen",
    "Stephen", "Anna", "Larry", "Brenda", "Justin", "Pamela", "Scott", "Nicole", "Brandon", "Emma",
    "Frank", "Samantha", "Benjamin", "Katherine", "Gregory", "Christine", "Raymond", "Debra", "Samuel", "Rachel",
    "Patrick", "Catherine", "Alexander", "Carolyn", "Jack", "Janet", "Dennis", "Ruth", "Jerry", "Maria",
    "Tyler", "Heather", "Aaron", "Diane", "Henry", "Virginia", "Douglas", "Julie", "Jose", "Joyce",
    "Peter", "Victoria", "Adam", "Olivia", "Zachary", "Kelly", "Nathan", "Christina", "Walter", "Lauren",
    "Kyle", "Joan", "Harold", "Evelyn", "Carl", "Judith", "Jeremy", "Megan", "Keith", "Cheryl", "Roger", "Andrea",
    "Gerald", "Hannah", "Ethan", "Martha", "Arthur", "Jacqueline", "Terry", "Frances", "Christian", "Gloria",
    "Sean", "Ann", "Lawrence", "Teresa", "Austin", "Kathryn", "Joe", "Sara", "Noah", "Janice", "Jesse", "Jean",
    "Albert", "Alice", "Bryan", "Madison", "Billy", "Doris", "Bruce", "Abigail", "Willie", "Julia", "Jordan", "Judy",
    "Dylan", "Grace", "Alan", "Denise", "Ralph", "Amber", "Gabriel", "Marilyn", "Roy", "Beverly", "Juan", "Danielle",
    "Wayne", "Theresa", "Eugene", "Sophia", "Logan", "Marie", "Randy", "Diana", "Louis", "Brittany", "Russell", "Natalie",
    "Vincent", "Isabella", "Philip", "Charlotte", "Bobby", "Rose", "Johnny", "Alexis", "Bradley", "Kayla", "Earl", "Lori",
    "Victor", "Linda", "Martin", "Emma", "Ernest", "Mildred", "Phillip", "Stephanie", "Todd", "Jane", "Jared", "Clara",
    "Samuel", "Lucy", "Troy", "Ellie", "Tony", "Sophia", "Curtis", "Scarlett", "Allen", "Ellie", "Craig", "Elijah",
    "Arthur", "Penelope", "Derek", "Riley", "Shawn", "Liam", "Joel", "Aria", "Ronnie", "Isabella", "Oscar", "Amelia",
    "Jay", "Zoey", "Jorge", "Carter", "Ray", "Levi", "Jim", "Miles", "Jason", "Adrian", "Clifford", "Leah",
    "Wesley", "Nathaniel", "Max", "Hayden", "Clayton", "Jonathan", "Bryant", "Lucas", "Isaac", "Hudson",
    "Abby", "Connor", "Ezra", "Jaxon", "Theodore", "Gianna", "Sadie", "Eli", "Ella", "Grayson", "Kinsley",
    "Owen", "Avery", "Landon", "Stella", "Parker", "Nova", "Kayden", "Aubrey", "Josiah", "Claire", "Cooper",
    "Lillian", "Ryder", "Violet", "Lincoln", "Bella", "Carson", "Genesis", "Asher", "Mackenzie", "Easton",
    "Ivy", "Jace", "Hazel", "Micah", "Aurora", "Declan", "Savannah", "Beckett", "Sophie", "Sawyer", "Leilani",
    "Brody", "Valeria", "Charlie", "Peyton", "Mateo", "Layla", "Zane", "Melody", "Emmett", "Madeline", "Jonah",
    "Jade", "Xavier", "Brooklyn", "Maxwell", "Isabelle", "Harrison", "Cora", "Leo", "Eliza", "Rowan", "Anna",
    "Jameson", "Sadie", "Bennett", "Lydia", "Grant", "Alyssa", "Callum", "Natalie", "Kingston", "Sophia",
    "Felix", "Ruby", "Tobias", "Daisy", "Theo", "Adeline", "Ezekiel", "Emilia", "Hugo", "Olive", "Atticus",
    "Vivian", "Silas", "Luna", "Miles", "Autumn", "Camden", "Maeve", "Elliot", "Harper", "Everett", "Alice",
    "Bentley", "Clara", "Brady", "Ellie", "Luca", "Aurora", "Dominic", "Scarlett", "Maximus", "Aria", "Walker",
    "Zoey", "River", "Bella", "Romeo", "Violet", "Finn", "Aubrey", "Nico", "Addison", "Elias", "Eleanor", "Aiden",
    "Layla", "Rowen", "Willow", "Judah", "Naomi", "Enzo", "Penelope", "Malachi", "Maya", "Rhett", "Eva",
    "Kai", "Sienna", "Archer", "Eliana", "Beau", "Daphne", "Dax", "Rose", "Remy", "Avery", "August", "Faith",
    "Emery", "Emerson", "Reid", "Madelyn", "Tucker", "Wren", "Zander", "Gia", "Griffin", "Serenity", "Jayce",
    "Iris", "Maddox", "Briar", "Zayne", "Carmen", "Ellis", "Hope", "Cash", "Fiona", "Emory", "Olivia", "Bryce"
]

let commonLastNames = [
    "Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis", "Rodriguez", "Martinez",
    "Hernandez", "Lopez", "Gonzalez", "Wilson", "Anderson", "Thomas", "Taylor", "Moore", "Jackson", "Martin",
    "Lee", "Perez", "Thompson", "White", "Harris", "Sanchez", "Clark", "Ramirez", "Lewis", "Robinson",
    "Walker", "Young", "Allen", "King", "Wright", "Scott", "Torres", "Nguyen", "Hill", "Flores",
    "Green", "Adams", "Nelson", "Baker", "Hall", "Rivera", "Campbell", "Mitchell", "Carter", "Roberts",
    "Gomez", "Phillips", "Evans", "Turner", "Diaz", "Parker", "Cruz", "Edwards", "Collins", "Reyes",
    "Stewart", "Morris", "Morales", "Murphy", "Cook", "Rogers", "Gutierrez", "Ortiz", "Morgan", "Cooper",
    "Peterson", "Bailey", "Reed", "Kelly", "Howard", "Ramos", "Kim", "Cox", "Ward", "Richardson",
    "Watson", "Brooks", "Chavez", "Wood", "James", "Bennett", "Gray", "Mendoza", "Ruiz", "Hughes",
    "Price", "Alvarez", "Castillo", "Sanders", "Patel", "Myers", "Long", "Ross", "Foster", "Jimenez",
    "Powell", "Jenkins", "Perry", "Russell", "Sullivan", "Bell", "Coleman", "Butler", "Henderson", "Barnes",
    "Gonzales", "Fisher", "Vasquez", "Simmons", "Romero", "Jordan", "Patterson", "Alexander", "Hamilton", "Graham",
    "Reynolds", "Griffin", "Wallace", "Moreno", "West", "Cole", "Hayes", "Bryant", "Herrera", "Gibson",
    "Ellis", "Tran", "Medina", "Aguilar", "Stevens", "Murray", "Ford", "Castro", "Marshall", "Owens",
    "Harrison", "Fernandez", "Mcdonald", "Woods", "Washington", "Kennedy", "Wells", "Vargas", "Henry", "Chen",
    "Freeman", "Webb", "Tucker", "Guzman", "Burns", "Crawford", "Olson", "Simpson", "Porter", "Hunter",
    "Gordon", "Mendez", "Silva", "Shaw", "Snyder", "Mason", "Dixon", "Munoz", "Hunt", "Hicks",
    "Holmes", "Palmer", "Wagner", "Black", "Robertson", "Boyd", "Rose", "Stone", "Salazar", "Fox",
    "Warren", "Mills", "Meyer", "Rice", "Schmidt", "Garza", "Daniels", "Ferguson", "Nichols", "Stephens",
    "Soto", "Weaver", "Ryan", "Gardner", "Payne", "Grant", "Dunn", "Kelley", "Spencer", "Hawkins",
    "Arnold", "Pierce", "Vazquez", "Hansen", "Peters", "Santos", "Hart", "Bradley", "Knight", "Elliott",
    "Cunningham", "Duncan", "Armstrong", "Hudson", "Carroll", "Lane", "Riley", "Andrews", "Alvarado", "Ray",
    "Delgado", "Berry", "Perkins", "Hoffman", "Johnston", "Matthews", "Pena", "Richards", "Contreras", "Willis",
    "Carpenter", "Lawrence", "Sandoval", "Guerrero", "George", "Chapman", "Rios", "Estrada", "Ortega", "Watkins",
    "Greene", "Nunez", "Wheeler", "Valdez", "Harper", "Burke", "Larson", "Santiago", "Maldonado", "Morrison",
    "Franklin", "Carlson", "Austin", "Dominguez", "Carr", "Lawson", "Jacobs", "O'Brien", "Lynch", "Singh",
    "Vega", "Bishop", "Montgomery", "Oliver", "Jensen", "Harvey", "Williamson", "Gilbert", "Dean", "Sims",
    "Espinoza", "Howell", "Li", "Wong", "Reid", "Hanson", "Le", "McCoy", "Garrett", "Burton",
    "Fuller", "Wang", "Weber", "Welch", "Rojas", "Lucas", "Marquez", "Fields", "Park", "Yang",
    "Little", "Banks", "Padilla", "Day", "Walsh", "Bowman", "Schultz", "Luna", "Fowler", "Mejia",
    "Davidson", "Acosta", "Brewer", "May", "Holland", "Juarez", "Newman", "Pearson", "Curtis", "Cortez",
    "Douglas", "Schneider", "Joseph", "Barrett", "Navarro", "Figueroa", "Keller", "Avila", "Wade", "Molina",
    "Stanley", "Hopkins", "Campos", "Barnett", "Bates", "Chambers", "Caldwell", "Beck", "Lambert", "Miranda",
    "Byrd", "Craig", "Ayala", "Lowe", "Frazier", "Powers", "Neal", "Leonard", "Gregory", "Carrillo",
    "Sutton", "Fleming", "Rhodes", "Shelton", "Schwartz", "Norris", "Jennings", "Watts", "Duran", "Walters",
    "Cohen", "McDaniel", "Moran", "Parks", "Steele", "Vaughn", "Becker", "Holt", "DeLeon", "Barker",
    "Terry", "Hale", "Leon", "Hail", "Rich", "Clarkson", "Lopez", "Ryan", "Fisher", "Cross",
    "Hardy", "Shields", "Savage", "Hodges", "Ingram", "Delacruz", "Cervantes", "Wyatt", "Dominguez", "Montoya",
    "Love", "Robbins", "Salinas", "Yates", "Duarte", "Kirk", "Ford", "Pitt", "Bartlett", "Valenzuela"
]

let stateNames = [
    "Alabama",
    "Alaska",
    "Arizona",
    "Arkansas",
    "California",
    "Colorado",
    "Connecticut",
    "Delaware",
    "Florida",
    "Georgia",
    "Hawaii",
    "Idaho",
    "Illinois",
    "Indiana",
    "Iowa",
    "Kansas",
    "Kentucky",
    "Louisiana",
    "Maine",
    "Maryland",
    "Massachusetts",
    "Michigan",
    "Minnesota",
    "Mississippi",
    "Missouri",
    "Montana",
    "Nebraska",
    "Nevada",
    "New Hampshire",
    "New Jersey",
    "New Mexico",
    "New York",
    "North Carolina",
    "North Dakota",
    "Ohio",
    "Oklahoma",
    "Oregon",
    "Pennsylvania",
    "Rhode Island",
    "South Carolina",
    "South Dakota",
    "Tennessee",
    "Texas",
    "Utah",
    "Vermont",
    "Virginia",
    "Washington",
    "West Virginia",
    "Wisconsin",
    "Wyoming"
]
