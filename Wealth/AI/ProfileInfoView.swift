import SwiftUI

struct ProfileInfoView: View {
    @Environment(ProfileViewModel.self) private var viewModel
    @EnvironmentObject var popRoot: PopToRoot
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
   
    @State var filter: CheckoutFilter? = nil
    @State private var hasError = false
    @State private var copied = ""
    
    @State var profileName: String
    @State var fields: [(label: String, value: String)]
    
    init(profile: String) {
        let parts = profile.components(separatedBy: ",")
        
        let defaultFields = [
            ("F. Name", ""),
            ("L. Name", ""),
            ("Email", ""),
            ("Address1", ""),
            ("Address2", ""),
            ("City", ""),
            ("State", ""),
            ("Zip", ""),
            ("Country", ""),
            ("Phone", ""),
            ("CC #", ""),
            ("CC M", ""),
            ("CC Y", ""),
            ("CVV", ""),
            ("Billing F. Name", ""),
            ("Billing L. Name", ""),
            ("Billing Addy1", ""),
            ("Billing Addy2", ""),
            ("Billing Country", ""),
            ("Billing State", ""),
            ("Billing City", ""),
            ("Billing Zip", "")
        ]
        
        var initializedFields: [(label: String, value: String)] = []
        
        if parts.count == 23 {
            _profileName = State(initialValue: parts[0])
            for i in 1..<parts.count {
                let field = defaultFields[i - 1]
                initializedFields.append((field.0, parts[i]))
            }
        } else {
            _profileName = State(initialValue: "")
            _hasError = State(initialValue: true)
            initializedFields = defaultFields
        }
        
        _fields = State(initialValue: initializedFields)
    }
    
    var body: some View {
        VStack(spacing: 0){
            if hasError {
                HStack {
                    Spacer()
                    VStack(spacing: 12){
                        Spacer()
                        Text("Profile Error...").font(.largeTitle).bold()
                        Text("Failed to load this profile.").font(.caption).foregroundStyle(.gray)
                        Spacer()
                    }
                    Spacer()
                }
            } else {
                HStack {
                    Text("'\(profileName)'").font(.title).bold()
                    Spacer()
                    Button {
                        dismiss()
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.headline).padding(10)
                            .background(Color.babyBlue).clipShape(Circle()).shadow(radius: 1)
                    }.buttonStyle(.plain)
                }
                .padding(.top).padding(.bottom, 10).padding(.horizontal, 12)
                .overlay(alignment: .bottom) { Divider() }
                
                ScrollView {
                    LazyVStack(spacing: 10, pinnedViews: [.sectionHeaders]){
                        
                        info().padding(.horizontal, 12)
                        
                        if viewModel.cachedFilters.isEmpty {
                            VStack(spacing: 10){
                                ForEach(0..<12) { _ in
                                    FeedLoadingView()
                                }
                            }.shimmering()
                        } else {
                            if viewModel.cachedFilters[0].2 == nil {
                                VStack(spacing: 10){
                                    ForEach(0..<12) { _ in
                                        FeedLoadingView()
                                    }
                                }.shimmering()
                            } else if (viewModel.cachedFilters[0].2 ?? []).isEmpty {
                                VStack(spacing: 12){
                                    Text("Nothing yet...").font(.largeTitle).bold()
                                    Text("No checkouts found for this profile.").font(.caption).foregroundStyle(.gray)
                                }.padding(.top, 70)
                            } else {
                                let holders = viewModel.cachedFilters[0].2 ?? []
                                
                                ForEach(holders) { holder in
                                    Section {
                                        ForEach(holder.checkouts) { checkout in
                                            CheckoutRowView(checkout: checkout, isRefreshing: viewModel.refreshingRowViews.contains(checkout.id ?? ""), isSelecting: .constant(false), hideOrderNum: .constant(false), isSelected: false) {
                                                popRoot.presentAlert(image: "arrow.counterclockwise", text: "Refreshing")
                                                viewModel.updateOrderStatus(checkout: checkout) { _ in }
                                            }
                                            .scrollTransition { content, phase in
                                                content
                                                    .scaleEffect(phase == .identity ? 1 : 0.65)
                                                    .blur(radius: phase == .identity ? 0 : 10)
                                                    .opacity(phase == .identity ? 1.0 : 0.2)
                                            }
                                            .contextMenu {
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
                                                        UIApplication.shared.open(url)
                                                    } label: {
                                                        Label("Open Order Link", systemImage: "square.and.arrow.up")
                                                    }
                                                }
                                                Button {
                                                    viewModel.updateOrderStatus(checkout: checkout) { success in
                                                        if !success {
                                                            popRoot.presentAlert(image: "exclamationmark.triangle", text: "Error reloading status!")
                                                        }
                                                    }
                                                } label: {
                                                    Label("Refresh Status", systemImage: "arrow.counterclockwise")
                                                }
                                            }
                                        }
                                    } header: {
                                        HStack {
                                            Text("(\(holder.checkouts.count)) \(holder.dateString)").font(.headline).bold()
                                            Spacer()
                                        }
                                        .padding(.horizontal, 12).padding(.vertical, 12)
                                        .background {
                                            TransparentBlurView(removeAllFilters: true).blur(radius: 14, opaque: true)
                                        }
                                    }
                                }
                            }
                        }
                        
                        Color.clear.frame(height: 100)
                    }
                }.scrollIndicators(.hidden)
            }
        }
        .ignoresSafeArea()
        .presentationDetents([.large])
        .presentationCornerRadius(30)
        .presentationDragIndicator(.visible)
        .background(content: {
            backColor()
        })
        .onAppear {
            if !profileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                self.filter = CheckoutFilter()
                filter?.forProfile = profileName
                viewModel.getCheckoutsFilter(filter: self.filter!)
            }
        }
    }
    @ViewBuilder
    func info() -> some View {
        TagLayout(spacing: 6) {
            ForEach(fields, id: \.label) { field in
                if (field.label.contains("Billing") && field.value != "na") || !field.label.contains("Billing") {
                    if !field.value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        HStack(spacing: 2){
                            if copied == field.label {
                                Image(systemName: "link").font(.subheadline)
                            }
                            (Text("\(field.label): ").bold()
                             + Text(field.value).fontWeight(.light)).font(.system(size: 15))
                        }
                        .padding(.horizontal, 8).frame(height: 38)
                        .background(Color.blue.gradient).clipShape(Capsule()).shadow(radius: 1)
                        .onTapGesture {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            withAnimation(.easeInOut(duration: 0.3)){
                                copied = field.label
                            }
                            UIPasteboard.general.string = field.value
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                if copied == field.label {
                                    withAnimation(.easeInOut(duration: 0.3)){
                                        copied = ""
                                    }
                                }
                            }
                        }
                    }
                } else if field.label == "Billing Zip" && field.value == "na" {
                    HStack(spacing: 2){
                        Text("Billing = Shipping").font(.system(size: 15))
                    }
                    .padding(.horizontal, 8).frame(height: 38)
                    .background(Color.purple.gradient).clipShape(Capsule()).shadow(radius: 1)
                }
            }
        }.padding(.top)
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
