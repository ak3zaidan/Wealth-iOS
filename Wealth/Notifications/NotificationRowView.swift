import SwiftUI
import Kingfisher

struct NotificationRowView: View {
    @Environment(\.colorScheme) var colorScheme
    let notification: Notification
    
    var body: some View {
        HStack(alignment: .top){
            VStack(alignment: .leading, spacing: 10){
                Text(notification.title)
                    .bold().font(.headline)
                    .multilineTextAlignment(.leading).italic()
                Text(notification.body).font(.subheadline)
                    .multilineTextAlignment(.leading)
                    .fontWeight(.semibold)
                Text(formatDate(notification.timestamp.dateValue()))
                    .font(.caption).fontWeight(.light)
            }.padding(.leading, 8)
            
            Spacer()
            
            if notification.type == NotificationTypes.staff.rawValue {
                Image("WealthIcon")
                    .resizable().frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .contentShape(RoundedRectangle(cornerRadius: 12))
            } else if notification.type == NotificationTypes.developer.rawValue {
                ZStack {
                    Image("WealthBlur")
                        .resizable().frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .contentShape(RoundedRectangle(cornerRadius: 12))
                    Image(systemName: "hammer.fill").font(.largeTitle).fontWeight(.semibold)
                }
            } else if notification.type == NotificationTypes.failure.rawValue {
                ZStack {
                    RoundedRectangle(cornerRadius: 12).foregroundStyle(.red).frame(width: 100, height: 100)
                    Image(systemName: "exclamationmark.bubble.fill").font(.largeTitle).fontWeight(.semibold)
                }
            } else if notification.type == NotificationTypes.status.rawValue {
                ZStack {
                    RoundedRectangle(cornerRadius: 12).foregroundStyle(.indigo).frame(width: 100, height: 100)
                    Image(systemName: "slider.horizontal.3").font(.largeTitle).fontWeight(.semibold)
                    if let image = notification.image {
                        KFImage(URL(string: image))
                            .resizable()
                            .aspectRatio(contentMode: .fill).scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .contentShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: .gray, radius: 2)
                    }
                }
            } else {
                ZStack {
                    Image("WealthIcon")
                        .resizable().frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .contentShape(RoundedRectangle(cornerRadius: 12))
                    if let image = notification.image {
                        KFImage(URL(string: image))
                            .resizable()
                            .aspectRatio(contentMode: .fill).scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .contentShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: .gray, radius: 2)
                    }
                }
            }
        }
        .padding(8)
        .background {
            TransparentBlurView(removeAllFilters: true)
                .blur(radius: 14, opaque: true)
                .background(colorScheme == .dark ? .black.opacity(0.5) : .white.opacity(0.5))
        }
        .overlay(alignment: .leading, content: {
            UnevenRoundedRectangle(topLeadingRadius: 12, bottomLeadingRadius: 12)
                .frame(width: 7).foregroundStyle(getColor())
        })
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 12)
    }
    func getColor() -> Color {
        if notification.type == NotificationTypes.developer.rawValue || notification.type == NotificationTypes.staff.rawValue {
            return Color.blue
        } else if notification.type == NotificationTypes.checkout.rawValue {
            return Color.green
        } else if notification.type == NotificationTypes.failure.rawValue {
            return Color.red
        } else if notification.type == NotificationTypes.status.rawValue {
            return Color.indigo
        }
        return Color.clear
    }
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy h:mm a"
        return formatter.string(from: date)
    }
}
