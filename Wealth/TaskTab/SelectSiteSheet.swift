import SwiftUI

struct CountryEndpoint: Identifiable {
    let id = UUID()
    let name: String
    let endpoint: String
}

struct SelectSiteSheet: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @State var selectedSites: [(String, String)] = []
    @State var isCustomSite = false
    @State var customSiteName = ""
    @State var customSiteBase = ""
    @State var showError = false
    @State var scrollUp = false
    @State var showMisc = true
    @FocusState var isEditing
    @State var site = ""
    
    let popmartEndpoints: [CountryEndpoint] = [
        .init(name: "United States", endpoint: "/us"),
        .init(name: "Canada", endpoint: "/ca"),
        .init(name: "Brazil", endpoint: "/br"),
        .init(name: "Australia", endpoint: "/au"),
        .init(name: "New Zealand", endpoint: "/nz"),
        .init(name: "Austria", endpoint: "/at"),
        .init(name: "Belgium", endpoint: "/be"),
        .init(name: "Croatia", endpoint: "/hr"),
        .init(name: "Czech Republic", endpoint: "/cz"),
        .init(name: "Denmark", endpoint: "/dk"),
        .init(name: "Estonia", endpoint: "/ee"),
        .init(name: "Finland", endpoint: "/fi"),
        .init(name: "France", endpoint: "/fr"),
        .init(name: "Germany", endpoint: "/de"),
        .init(name: "Greece", endpoint: "/gr"),
        .init(name: "Hungary", endpoint: "/hu"),
        .init(name: "Ireland", endpoint: "/ie"),
        .init(name: "Italy", endpoint: "/it"),
        .init(name: "Latvia", endpoint: "/lv"),
        .init(name: "Lithuania", endpoint: "/lt"),
        .init(name: "Luxembourg", endpoint: "/lu"),
        .init(name: "Netherlands", endpoint: "/nl"),
        .init(name: "Poland", endpoint: "/pl"),
        .init(name: "Portugal", endpoint: "/pt"),
        .init(name: "Slovakia", endpoint: "/sk"),
        .init(name: "Slovenia", endpoint: "/si"),
        .init(name: "Spain", endpoint: "/es"),
        .init(name: "Sweden", endpoint: "/se"),
        .init(name: "Switzerland", endpoint: "/ch"),
        .init(name: "United Kingdom", endpoint: "/gb"),
        .init(name: "Hong Kong", endpoint: "/hk"),
        .init(name: "Indonesia", endpoint: "/id"),
        .init(name: "Japan", endpoint: "/jp"),
        .init(name: "Macao", endpoint: "/mo"),
        .init(name: "Malaysia", endpoint: "/my"),
        .init(name: "Philippines", endpoint: "/ph"),
        .init(name: "Singapore", endpoint: "/sg"),
        .init(name: "South Korea", endpoint: "/kr"),
        .init(name: "Taiwan", endpoint: "/tw"),
        .init(name: "Thailand", endpoint: "/th"),
        .init(name: "Vietnam", endpoint: "/vn")
    ]
 
    @State var onlyShopify: Bool?
    let maxSelect: Int
    let returnSites: ([(String, String)]) -> Void
    
    var body: some View {
        VStack(spacing: 15){
            headerView().padding(.horizontal).padding(.top)

            ScrollViewReader { proxy in
                ScrollView {
                    customTextField().padding(.horizontal).padding(.top, 2).padding(.bottom, 8)
                        .onChange(of: site) { _, _ in
                            if scrollUp {
                                scrollUp = false
                                withAnimation(.easeInOut(duration: 0.2)){
                                    proxy.scrollTo("scrollTop", anchor: .top)
                                }
                            }
                        }
                    
                    LazyVStack {
                        
                        Color.clear.frame(height: 1).id("scrollTop")
                            .onAppear(perform: {
                                scrollUp = false
                            })
                            .onDisappear {
                                scrollUp = true
                            }
                        
                        if showMisc {
                            if onlyShopify == nil {
                                VStack {
                                    rowView(key: "Nike", value: "www.nike.com")
                                }
                                .padding(10).background(Color.gray.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 10)).padding(.horizontal)
                                
                                VStack {
                                    rowView(key: "Pokemon Center", value: "www.pokemoncenter.com")
                                }
                                .padding(10).background(Color.gray.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 10)).padding(.horizontal)
                                
                                Menu {
                                    ForEach(popmartEndpoints) { element in
                                        Button {
                                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                            if maxSelect == 1 {
                                                returnSites([(element.name, "www.popmart.com" + element.endpoint)])
                                                dismiss()
                                            } else {
                                                if selectedSites.contains(where: { $0.0 == element.name }) {
                                                    selectedSites.removeAll(where: { $0.0 == element.name })
                                                } else {
                                                    if selectedSites.count < maxSelect {
                                                        selectedSites.append((element.name, "www.popmart.com" + element.endpoint))
                                                    } else {
                                                        UINotificationFeedbackGenerator().notificationOccurred(.error)
                                                        withAnimation(.easeInOut(duration: 0.2)){
                                                            showError = true
                                                        }
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                                            withAnimation(.easeInOut(duration: 0.2)){
                                                                showError = false
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        } label: {
                                            Label(element.name, systemImage: "cart")
                                        }
                                    }
                                } label: {
                                    VStack {
                                        menuRowView(key: "PopMart", value: "www.popmart.com")
                                    }
                                    .padding(10).background(Color.gray.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 10)).padding(.horizontal)
                                }.buttonStyle(.plain)
                            }
                            
                            VStack(spacing: 10){
                                HStack {
                                    Text("Custom Site").font(.headline).bold()
                                    Spacer()
                                    Toggle("", isOn: $isCustomSite.animation(.easeInOut(duration: 0.2)))
                                }
                                if isCustomSite {
                                    Divider()
                                    textFieldView(value: $customSiteBase, name: "Base URL", hasXmark: true)
                                        .onChange(of: customSiteBase) { _, _ in
                                            if customSiteBase.hasPrefix("https://") {
                                                customSiteBase = String(customSiteBase.dropLast(8))
                                            } else if customSiteBase.hasPrefix("http://") {
                                                customSiteBase = String(customSiteBase.dropLast(7))
                                            }
                                        }
                                }
                            }
                            .padding(10).background(.gray.opacity(0.1)).clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.horizontal).padding(.bottom, 6)
                        }
                        
                        LazyVStack(spacing: 8) {
                            HStack {
                                Text("Shopify").font(.headline).bold()
                                Spacer()
                            }
                            LazyVStack(spacing: 8) {
                                let allSitesArray = getData()
                                
                                if allSitesArray.isEmpty {
                                    VStack(spacing: 12){
                                        Text("No matches...").font(.largeTitle).bold()
                                        Text("Try a different search.").font(.caption).foregroundStyle(.gray)
                                    }.padding(.vertical, 40)
                                }
                                
                                ForEach(allSitesArray.indices, id: \.self) { index in
                                    let element = allSitesArray[index]
                                    
                                    rowView(key: element.key, value: element.value)
                                    
                                    if index < allSitesArray.count - 1 {
                                        Divider()
                                    }
                                }
                            }.padding(10).background(Color.gray.opacity(0.1)).clipShape(RoundedRectangle(cornerRadius: 10))
                        }.padding(.horizontal)
                        
                        Color.clear.frame(height: 100)
                    }
                }.padding(.top, 10)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .padding(.top, 5)
        .presentationDetents([.large]).presentationDragIndicator(.visible).presentationCornerRadius(30)
        .background {
            backColor()
        }
        .onChange(of: isEditing) { _, _ in
            withAnimation(.easeInOut(duration: 0.25)){
                if isEditing {
                    showMisc = false
                } else {
                    showMisc = true
                }
            }
        }
    }
    func getData() -> [Dictionary<String, String>.Element] {
        let query = site.lowercased()
        
        if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return allSites.sorted { $0.key.lowercased() < $1.key.lowercased() }
        }
        
        return allSites.filter { key, value in
            key.lowercased().contains(query) || value.lowercased().contains(query)
        }.sorted { $0.key.lowercased() < $1.key.lowercased() }
    }
    @ViewBuilder
    func menuRowView(key: String, value: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2){
                Text(key).font(.headline).lineLimit(1)
                Text("\(value)").font(.caption).foregroundStyle(.blue)
                    .lineLimit(1).minimumScaleFactor(0.8)
            }
            Spacer()
            if selectedSites.contains(where: { $0.0 == key }) {
                Image(systemName: "checkmark.circle.fill")
                    .resizable().scaledToFill().frame(width: 21, height: 21)
                    .foregroundStyle(Color.babyBlue)
            }
        }.contentShape(Rectangle())
    }
    @ViewBuilder
    func rowView(key: String, value: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2){
                Text(key).font(.headline).lineLimit(1)
                Text("\(value)").font(.caption).foregroundStyle(.blue)
                    .lineLimit(1).minimumScaleFactor(0.8)
            }
            Spacer()
            if selectedSites.contains(where: { $0.0 == key }) {
                Image(systemName: "checkmark.circle.fill")
                    .resizable().scaledToFill().frame(width: 21, height: 21)
                    .foregroundStyle(Color.babyBlue)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            if maxSelect == 1 {
                returnSites([(key, value)])
                dismiss()
            } else {
                if selectedSites.contains(where: { $0.0 == key }) {
                    selectedSites.removeAll(where: { $0.0 == key })
                } else {
                    if selectedSites.count < maxSelect {
                        selectedSites.append((key, value))
                    } else {
                        UINotificationFeedbackGenerator().notificationOccurred(.error)
                        withAnimation(.easeInOut(duration: 0.2)){
                            showError = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            withAnimation(.easeInOut(duration: 0.2)){
                                showError = false
                            }
                        }
                    }
                }
            }
        }
    }
    @ViewBuilder
    func customTextField() -> some View {
        TextField("", text: $site)
            .lineLimit(1)
            .autocorrectionDisabled()
            .focused($isEditing)
            .frame(height: 57)
            .padding(.top, 8)
            .overlay(alignment: .leading, content: {
                Text("Search Site").font(.system(size: 18)).fontWeight(.light)
                    .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
                    .opacity(isEditing ? 0.8 : 0.5)
                    .offset(y: site.isEmpty && !isEditing ? 0.0 : -21.0)
                    .scaleEffect(site.isEmpty && !isEditing ? 1.0 : 0.8, anchor: .leading)
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
    func headerView() -> some View {
        ZStack {
            HStack {
                Spacer()
                Text("Site Picker").font(.title2).bold()
                Spacer()
            }
            HStack {
                Spacer()
                let customStatus = !customSiteBase.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                
                if selectedSites.isEmpty && !customStatus {
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark").font(.title3).bold().foregroundStyle(.gray)
                    }
                } else {
                    Button {
                        if customStatus {
                            selectedSites.append((customSiteName, customSiteBase))
                        }
                        
                        returnSites(selectedSites)
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        dismiss()
                    } label: {
                        Text("Done").font(.headline).foregroundStyle(.blue)
                    }
                }
            }
            HStack {
                Text("\(selectedSites.count)/\(maxSelect)").font(.headline)
                    .foregroundStyle(showError ? .red : .gray).scaleEffect(showError ? 1.2 : 1.0)
                Spacer()
            }
        }
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
}
