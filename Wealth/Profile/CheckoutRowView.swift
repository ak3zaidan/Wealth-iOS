import SwiftUI
import Firebase
import Kingfisher

struct CheckoutRowView: View {
    @Environment(\.colorScheme) var colorScheme
    
    let checkout: Checkout
    let isRefreshing: Bool
    @Binding var isSelecting: Bool
    @Binding var hideOrderNum: Bool?
    let isSelected: Bool
    let refresh: () -> Void
    
    var body: some View {
        HStack(spacing: 0){
            
            if isSelecting {
                ZStack(alignment: .trailing){
                    Rectangle()
                        .foregroundStyle(.gray).opacity(0.001)
                        .frame(width: 30, height: 50)
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable().scaledToFill().frame(width: 21, height: 21)
                            .foregroundStyle(Color.babyBlue)
                    } else {
                        Circle()
                            .stroke(Color.babyBlue, lineWidth: 2)
                            .frame(width: 20, height: 20)
                    }
                }
            }
            
            HStack(spacing: 10){
                ZStack {
                    let size = isSelecting ? 50.0 : 90.0

                    if let image = checkout.image, !image.isEmpty {
                        Image("WealthBlur")
                            .resizable().frame(width: size, height: 90.0)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .contentShape(RoundedRectangle(cornerRadius: 12))
                        
                        KFImage(URL(string: image))
                            .resizable()
                            .aspectRatio(contentMode: .fill).scaledToFill()
                            .frame(width: size, height: 90.0)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .contentShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: .gray, radius: 2)
                    } else {
                        Image("WealthIcon")
                            .resizable().frame(width: size, height: 90.0)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .contentShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .overlay(alignment: .bottomLeading) {
                    if let qty = checkout.quantity {
                        Text("x\(qty)").font(.subheadline).bold()
                            .padding(5).background(Color.babyBlue).clipShape(Circle())
                            .offset(x: 2, y: -2)
                    }
                }
                
                VStack(alignment: .leading, spacing: 0){
                    Text(checkout.title).lineLimit(1).font(.headline).bold()
                    
                    if !(checkout.size ?? "").isEmpty || !(checkout.color ?? "").isEmpty {
                        HStack(spacing: 3){
                            if let size = checkout.size, !size.isEmpty {
                                Text("Size:").lineLimit(1).foregroundStyle(.gray)
                                Text(size).bold().padding(.trailing, 4)
                                    .lineLimit(1)
                            }
                            if let color = checkout.color, !color.isEmpty {
                                Text("Color:").lineLimit(1).foregroundStyle(.gray)
                                Text(color).bold().lineLimit(1)
                            }
                            Spacer()
                            if let cost = checkout.cost {
                                Text(String(format: "$%.1f", cost))
                                    .lineLimit(1)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 3)
                                    .background(Color.babyBlue)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }.font(.subheadline).padding(.top, 6)
                    } else if checkout.cost != nil {
                        HStack(spacing: 3){
                            Text("Site:").lineLimit(1).foregroundStyle(.gray)
                            Text(checkout.site).bold().lineLimit(1)
                            Spacer()
                            if let cost = checkout.cost {
                                Text(String(format: "$%.1f", cost))
                                    .lineLimit(1)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 3)
                                    .background(Color.babyBlue)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }.font(.subheadline).padding(.top, 6)
                    } else {
                        HStack(spacing: 3){
                            Text("Site:").lineLimit(1).foregroundStyle(.gray)
                            Text(checkout.site).bold().lineLimit(1)
                            Spacer()
                            Text(formatDateToCustomString(checkout.orderPlaced.dateValue()))
                        }.font(.subheadline).padding(.top, 6)
                    }
                    
                    Spacer()
                    
                    HStack {
                        if let order = checkout.orderNumber, !order.isEmpty {
                            if let link = checkout.orderLink, let url = URL(string: link) {
                                Menu {
                                    Text(formatDateToCustomString(checkout.orderPlaced.dateValue()))
                                    Divider()
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
                                    Text(order)
                                        .lineLimit(1).minimumScaleFactor(0.8)
                                        .foregroundStyle(.blue).font(.subheadline)
                                }
                                .overlay {
                                    if hideOrderNum ?? false {
                                        Rectangle().foregroundStyle(.gray)
                                    }
                                }
                            } else {
                                HStack(spacing: 2){
                                    Image(systemName: "link")
                                    Text(order)
                                }
                                .lineLimit(1).minimumScaleFactor(0.8)
                                .foregroundStyle(.blue).font(.subheadline)
                                .onTapGesture {
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    UIPasteboard.general.string = order
                                }
                                .overlay {
                                    if hideOrderNum ?? false {
                                        Rectangle().foregroundStyle(.gray)
                                    }
                                }
                            }
                        } else if let link = checkout.orderLink, let url = URL(string: link) {
                            Link(destination: url) {
                                Text("Order Link").font(.subheadline).foregroundStyle(.blue)
                            }
                        }
                        Spacer()
                        
                        let status = getStatus(checkout: checkout)
                        
                        if isRefreshing {
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
                                if checkout.site != "Pokemon Center" {
                                    Button {
                                        refresh()
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
                            }
                        }
                    }
                }.frame(height: 90)
            }
            .padding(8)
            .background {
                TransparentBlurView(removeAllFilters: true)
                    .blur(radius: 14, opaque: true)
                    .background(colorScheme == .dark ? .black.opacity(0.5) : .white.opacity(0.5))
            }
            .clipShape(RoundedRectangle(cornerRadius: 12)).contentShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 12)
        }
    }
}

func getColor(checkout: Checkout) -> Color {
    if checkout.orderReturned != nil {
        return Color.blue
    }
    if checkout.orderDelivered != nil {
        return Color.green
    }
    if checkout.orderCanceled != nil {
        return Color.red
    }
    if checkout.orderTransit != nil {
        return Color.green
    }
    if checkout.orderPreparing != nil {
        return Color.green
    }
            
    return Color.yellow
}

func formatDateToCustomString(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "M/d/yy h:mm a"
    return formatter.string(from: date)
}

func getStatus(checkout: Checkout) -> String {
    if checkout.orderReturned != nil {
        return "Returned"
    }
    if checkout.orderDelivered != nil {
        return "Delivered"
    }
    if checkout.orderCanceled != nil {
        return "Cancelled"
    }
    if checkout.orderTransit != nil {
        return "In Transit"
    }
    if checkout.orderPreparing != nil {
        return "Preparing"
    }
            
    return "Order Placed"
}
