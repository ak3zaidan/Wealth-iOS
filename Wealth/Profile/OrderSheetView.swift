import SwiftUI
import Firebase
import Kingfisher

struct OrderSheetView: View {
    @Environment(ProfileViewModel.self) private var viewModel
    @EnvironmentObject var popRoot: PopToRoot
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @State var failedReload: Bool? = nil
        
    @Binding var checkout: Checkout?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10){
                if let checkout = getCheckout() ?? checkout {
                    HStack(alignment: .top, spacing: 8){
                        if let image = checkout.image {
                            ZStack {
                                let size = 80.0
                                
                                Image("WealthIcon")
                                    .resizable().frame(width: size, height: size)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .contentShape(RoundedRectangle(cornerRadius: 12))
                                
                                KFImage(URL(string: image))
                                    .resizable()
                                    .aspectRatio(contentMode: .fill).scaledToFill()
                                    .frame(width: size, height: size)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .contentShape(RoundedRectangle(cornerRadius: 12))
                                    .shadow(color: .gray, radius: 2)
                            }
                        }
                        VStack(alignment: .leading, spacing: 2){
                            Text(checkout.title)
                                .font(.system(size: 17)).bold()
                                .lineLimit(3).multilineTextAlignment(.leading)
                            HStack {
                                Text("Site:").lineLimit(1).foregroundStyle(.gray)
                                
                                let pokemonLink: String? = (checkout.site == "Pokemon Center") ? "https://www.pokemoncenter.com" : (checkout.site.lowercased().contains("popmart")) ? "https://www.popmart.com" : nil
                                
                                if let link = allSites[checkout.site] ?? pokemonLink {
                                    Menu {
                                        Button {
                                            if let url = URL(string: link) {
                                                DispatchQueue.main.async {
                                                    UIApplication.shared.open(url)
                                                }
                                            }
                                        } label: {
                                            Label("Open Site", systemImage: "square.and.arrow.up")
                                        }
                                        Button {
                                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                            UIPasteboard.general.string = link
                                        } label: {
                                            Label("Copy Site Link", systemImage: "link")
                                        }
                                    } label: {
                                        Text(checkout.site).lineLimit(1).bold()
                                    }
                                } else {
                                    Text(checkout.site).lineLimit(1).bold()
                                }
                            }.font(.subheadline)
                        }
                    }
                    
                    if !(checkout.size ?? "").isEmpty || !(checkout.color ?? "").isEmpty || checkout.cost != nil || checkout.quantity != nil {
                        HStack(spacing: 3){
                            if let size = checkout.size, !size.isEmpty {
                                Text("Size:").lineLimit(1).foregroundStyle(.gray)
                                Text(size).bold().padding(.trailing, 14).lineLimit(1)
                            }
                            if let color = checkout.color, !color.isEmpty {
                                Text("Color:").lineLimit(1).foregroundStyle(.gray)
                                Text(color).bold().lineLimit(1)
                            }
                            Spacer()
                            if let cost = checkout.cost {
                                Text(String(format: "$%.2f", cost))
                                    .lineLimit(1).bold()
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.babyBlue)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            
                            if let qty = checkout.quantity {
                                Text("x\(qty)")
                                    .bold()
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.babyBlue)
                                    .clipShape(RoundedRectangle(cornerRadius: 12)).padding(.leading, 3)
                            }
                        }.font(.subheadline).padding(.top, 6)
                    }
                    
                    HStack(spacing: 3){
                        Text("Profile:").lineLimit(1).foregroundStyle(.gray)
                        Text(checkout.profile).bold().padding(.trailing, 14).lineLimit(1)

                        Text("Email:").lineLimit(1).foregroundStyle(.gray)
                        Text(checkout.email).bold().lineLimit(1)

                        Spacer()
                    }.font(.subheadline).padding(.top, 6)
   
                    HStack {
                        if let order = checkout.orderNumber, !order.isEmpty {
                            if let link = checkout.orderLink, let url = URL(string: link) {
                                Menu {
                                    Button {
                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                        UIPasteboard.general.string = link
                                    } label: {
                                        Label("Copy Order Link", systemImage: "link")
                                    }
                                    Button {
                                        DispatchQueue.main.async {
                                            UIApplication.shared.open(url)
                                        }
                                    } label: {
                                        Label("Open Order Link", systemImage: "square.and.arrow.up")
                                    }
                                    Button {
                                        showShareSheet(url: url)
                                    } label: {
                                        Label("Share Order Link", systemImage: "arrowshape.turn.up.right")
                                    }
                                } label: {
                                    HStack(spacing: 3){
                                        Text("Order ID:").foregroundStyle(.gray)
                                            .font(.subheadline)
                                        
                                        Text(order)
                                            .lineLimit(1).minimumScaleFactor(0.8).bold()
                                            .foregroundStyle(.blue).font(.subheadline)
                                    }
                                }
                            } else {
                                HStack(spacing: 3){
                                    Text("Order ID:").foregroundStyle(.gray)
                                    Image(systemName: "link")
                                    Text(order).bold()
                                }
                                .lineLimit(1).minimumScaleFactor(0.8)
                                .foregroundStyle(.blue).font(.subheadline)
                                .onTapGesture {
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    UIPasteboard.general.string = order
                                    popRoot.presentAlert(image: "link", text: "Order ID Copied!")
                                }
                            }
                        } else if let link = checkout.orderLink, let url = URL(string: link) {
                            Link(destination: url) {
                                Text("Order Link").font(.subheadline).foregroundStyle(.blue)
                            }
                        }
                        Spacer()
                        
                        let status = getStatus(checkout: checkout)
                        
                        if !(failedReload ?? true) {
                            HStack {
                                Image(systemName: "xmark")
                                Text("Error").fontWeight(.semibold)
                            }
                            .font(.subheadline)
                            .padding(5).background(Color.gray.opacity(0.4))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                    withAnimation(.easeInOut(duration: 0.2)){
                                        failedReload = nil
                                    }
                                }
                            }
                        } else if viewModel.refreshingRowViews.contains(checkout.id ?? "") {
                            HStack {
                                ProgressView().scaleEffect(0.8).tint(colorScheme == .dark ? .white : .black)
                                
                                if let eta = checkout.estimatedDelivery, status == "In Transit" && !eta.isEmpty {
                                    Text(eta).font(.subheadline).fontWeight(.semibold).lineLimit(1)
                                } else {
                                    Text(status).font(.subheadline).fontWeight(.semibold)
                                }
                            }
                            .padding(5).background(Color.gray.opacity(0.4))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            Menu {
                                if checkout.site != "Pokemon Center" && !checkout.site.lowercased().contains("popmart") {
                                    Button {
                                        viewModel.updateOrderStatus(checkout: checkout) { success in
                                            if !success {
                                                withAnimation(.easeInOut(duration: 0.2)){
                                                    failedReload = success
                                                }
                                            }
                                        }
                                    } label: {
                                        Label("Refresh status", systemImage: "arrow.counterclockwise")
                                    }
                                }
                            } label: {
                                HStack {
                                    if status == "In Transit" {
                                        Image(systemName: "airplane").font(.subheadline)
                                        if let eta = checkout.estimatedDelivery, !eta.isEmpty {
                                            Text(eta).font(.subheadline).fontWeight(.semibold).lineLimit(1)
                                        } else {
                                            Text(status).font(.subheadline).fontWeight(.semibold)
                                        }
                                    } else {
                                        Circle().frame(width: 8, height: 8).foregroundStyle(getColor(checkout: checkout))
                                        Text(status).font(.subheadline).fontWeight(.semibold)
                                    }
                                }
                                .padding(5).background(Color.gray.opacity(0.4))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }.buttonStyle(.plain)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 0){
                        HStack(spacing: 10){
                            Circle()
                                .frame(width: 22, height: 22)
                                .foregroundStyle(.blue)
                            Text("Order Placed").font(.body).fontWeight(.semibold)
                            Spacer()
                            Text(formatDateToCustomString(checkout.orderPlaced.dateValue())).font(.subheadline)
                        }
                        
                        Rectangle()
                            .frame(width: 3, height: 40)
                            .padding(.leading, 10)
                            .foregroundStyle(checkout.orderCanceled != nil ? .red : (checkout.orderPreparing == nil && checkout.orderTransit == nil && checkout.orderDelivered == nil) ? .gray : .blue)
                        
                        if let canned = checkout.orderCanceled {
                            HStack(spacing: 10){
                                Circle()
                                    .frame(width: 22, height: 22)
                                    .foregroundStyle(.red)
                                Text("Order Cancelled").font(.body).fontWeight(.semibold)
                                Spacer()
                                Text(formatDateToCustomString(canned.dateValue())).font(.subheadline)
                            }
                        } else {
                            HStack(spacing: 10){
                                let status = checkout.orderPreparing == nil && checkout.orderTransit == nil
                                
                                Circle()
                                    .frame(width: 22, height: 22)
                                    .foregroundStyle(status ? .gray : .blue)
                                Text("Order Preparing").font(.body).fontWeight(.semibold)
                                Spacer()
                                if let preparing = checkout.orderPreparing {
                                    Text(formatDateToCustomString(preparing.dateValue())).font(.subheadline)
                                }
                            }
                            
                            Rectangle()
                                .frame(width: 3, height: 40)
                                .padding(.leading, 10)
                                .foregroundStyle((checkout.orderTransit == nil && checkout.orderDelivered == nil) ? .gray : .blue)
                            
                            HStack(spacing: 10){
                                let status = checkout.orderTransit == nil
                                
                                Circle()
                                    .frame(width: 22, height: 22)
                                    .foregroundStyle(status ? .gray : .blue)
                                
                                HStack {
                                    Text("Order In Transit").font(.body).fontWeight(.semibold)
                                    Spacer()
                                    if let eta = checkout.estimatedDelivery, !eta.isEmpty {
                                        (Text("ETA: ").fontWeight(.light)
                                        + Text(eta).foregroundStyle(.gray)).font(.subheadline)
                                    } else if let transit = checkout.orderTransit {
                                        Text(formatDateToCustomString(transit.dateValue())).font(.subheadline)
                                    }
                                }
                            }
                            
                            Rectangle()
                                .frame(width: 3, height: 40)
                                .padding(.leading, 10)
                                .foregroundStyle(checkout.orderDelivered == nil ? .gray : .blue)
                            
                            HStack(alignment: .top, spacing: 10){
                                let status = checkout.orderDelivered == nil
                                
                                Circle()
                                    .frame(width: 22, height: 22)
                                    .foregroundStyle(status ? .gray : .blue)
                                VStack(alignment: .leading, spacing: 2){
                                    HStack {
                                        Text("Order Delivered").font(.body).fontWeight(.semibold)
                                        Spacer()
                                        if let delivered = checkout.orderDelivered {
                                            Text(formatDateToCustomString(delivered.dateValue())).font(.subheadline)
                                        }
                                    }
                                    if let eta = checkout.deliveredDate, !eta.isEmpty {
                                        (Text("Delivered on: ").fontWeight(.light)
                                        + Text(eta).foregroundStyle(.gray)).font(.subheadline)
                                    }
                                }
                            }
                            
                            if let returned = checkout.orderReturned {
                                Rectangle()
                                    .frame(width: 3, height: 40)
                                    .padding(.leading, 10)
                                    .foregroundStyle(.blue)
                                HStack(spacing: 10){
                                    Circle()
                                        .frame(width: 22, height: 22)
                                        .foregroundStyle(.blue)
                                    Text("Order Returned").font(.body).fontWeight(.semibold)
                                    Spacer()
                                    Text(formatDateToCustomString(returned.dateValue())).font(.subheadline)
                                }
                            }
                        }
                    }.padding(.top, 15)
                    
                    if checkout.site == "Pokemon Center" || checkout.site.lowercased().contains("popmart") {
                        HStack {
                            Text("Tracking not available for this site.")
                                .font(.subheadline).foregroundStyle(.gray)
                            Spacer()
                        }.padding(.top, 6)
                    }
                    if let name = checkout.instanceName, !name.isEmpty {
                        HStack {
                            Image(systemName: "flame")
                            Text(name)
                            Spacer()
                        }.font(.subheadline).bold().padding(.top, 6)
                    }
                } else {
                    VStack(spacing: 12){
                        Text("An error occured...").font(.largeTitle).bold()
                        Text("Please try again later.").font(.caption).foregroundStyle(.gray)
                    }.padding(.top, 70)
                }
                Spacer()
            }.padding(.horizontal, 12).safeAreaPadding(.top, 18).safeAreaPadding(.bottom, 30)
        }
        .scrollIndicators(.hidden)
        .presentationDetents([.fraction(0.75)])
        .presentationCornerRadius(30).presentationDragIndicator(.visible)
        .background {
            ZStack {
                if colorScheme == .dark {
                    Color.white.ignoresSafeArea()
                }
                backColor().ignoresSafeArea().opacity(colorScheme == .dark ? 0.8 : 1.0)
            }
        }
        .onAppear {
            if let checkout, viewModel.shouldReload(checkout: checkout) {
                viewModel.updateOrderStatus(checkout: checkout) { success in
                    withAnimation(.easeInOut(duration: 0.2)){
                        failedReload = success
                    }
                }
            }
        }
    }
    func getCheckout() -> Checkout? {
        if let id = self.checkout?.id {
            for j in 0..<self.viewModel.checkouts.count {
                for i in 0..<self.viewModel.checkouts[j].checkouts.count {
                    if self.viewModel.checkouts[j].checkouts[i].id == id {
                        return self.viewModel.checkouts[j].checkouts[i]
                    }
                }
            }
            
            if !self.viewModel.cachedFilters.isEmpty {
                for i in 0..<(self.viewModel.cachedFilters[0].2?.count ?? 0) {
                    for j in 0..<(self.viewModel.cachedFilters[0].2?[i].checkouts.count ?? 0) {
                        if self.viewModel.cachedFilters[0].2?[i].checkouts[j].id == id {
                            return self.viewModel.cachedFilters[0].2?[i].checkouts[j]
                        }
                    }
                }
            }
        }
        
        return nil
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
