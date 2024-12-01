import SwiftUI
import Kingfisher

struct FeedRowView: View {
    @State var feedbackGenerator = UIImpactFeedbackGenerator(style: .rigid)
    @Environment(\.colorScheme) var colorScheme
    @State var bounce1: Bool = false
    @State var bounce2: Bool = false
    let publicLogo: String = "https://storage.googleapis.com/xbot-2b603.firebasestorage.app/releases/wealthLogo1.png"
    
    @State var release: Release
    @State var upVoted: Bool
    @State var downVoted: Bool
    @State var releaseImage: String?
    
    let upVote: (Bool) -> Void
    let downVote: (Bool) -> Void
    let alert: (String, String) -> Void
    
    var body: some View {
        ZStack(alignment: .leading){
            ZStack {
                Image("WealthBlur")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 150)
                
                if colorScheme == .dark {
                    Color.black.opacity(0.8)
                } else {
                    Color.white.opacity(0.8)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12)).contentShape(RoundedRectangle(cornerRadius: 12))
            
            HStack(spacing: 0){

                KFImage(URL(string: releaseImage ?? publicLogo))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .scaledToFill()
                    .frame(width: 130, height: 150)
                    .clipShape(UnevenRoundedRectangle(topLeadingRadius: 12, bottomLeadingRadius: 12))
                    .contentShape(UnevenRoundedRectangle(topLeadingRadius: 12, bottomLeadingRadius: 12))
                
                VStack(alignment: .leading, spacing: 12){
                    
                    Text(formatDateToTimeString(release.releaseTime.dateValue()))
                        .font(.subheadline).fontWeight(.semibold)
                    
                    Text(release.title)
                        .fontWeight(.semibold).font(.system(size: 16))
                        .multilineTextAlignment(.leading).textSelection(.enabled)
                        .frame(maxHeight: .infinity)
                    
                    HStack(alignment: .bottom){
                        
                        let diff = release.resell - release.retail
                        let str = diff >= 0 ? "+$\(diff)" : "-$\(abs(diff))"
                        
                        Text(str)
                            .foregroundStyle(diff >= 0 ? .green : .red).font(.subheadline).fontWeight(.bold)
                        
                        Spacer()
                        
                        ZStack {
                            if downVoted {
                                RoundedRectangle(cornerRadius: 12)
                                    .foregroundStyle(.red).opacity(1.0)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 12).stroke(Color.red, lineWidth: 0.5)
                                    }
                            } else {
                                RoundedRectangle(cornerRadius: 12).stroke(lineWidth: 0.5)
                            }
                            
                            HStack(spacing: 4){
                                Text("\(downVoted ? (release.unLikers.count + 1) : release.unLikers.count)").font(.system(size: 13)).fontWeight(.semibold)
                                Image(systemName: "hand.thumbsdown.fill")
                                    .symbolEffect(.bounce, value: bounce2).font(.subheadline)
                            }
                        }
                        .frame(width: 55, height: 28)
                        .onTapGesture {
                            feedbackGenerator.impactOccurred()
                            withAnimation {
                                bounce2.toggle()
                            }
                            downVoted.toggle()
                            downVote(downVoted)
                            if downVoted {
                                upVoted = false
                            }
                        }
                        
                        ZStack {
                            if upVoted {
                                RoundedRectangle(cornerRadius: 12)
                                    .foregroundStyle(.green).opacity(1.0)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 12).stroke(Color.green, lineWidth: 0.5)
                                    }
                            } else {
                                RoundedRectangle(cornerRadius: 12).stroke(lineWidth: 0.5)
                            }
                            
                            HStack(spacing: 4){
                                Text("\(upVoted ? (release.likers.count + 1) : release.likers.count)").font(.system(size: 13)).fontWeight(.semibold)
                                Image(systemName: "hand.thumbsup.fill")
                                    .symbolEffect(.bounce, value: bounce1).font(.subheadline)
                            }
                        }
                        .frame(width: 55, height: 28)
                        .onTapGesture {
                            feedbackGenerator.impactOccurred()
                            withAnimation {
                                bounce1.toggle()
                            }
                            upVoted.toggle()
                            upVote(upVoted)
                            if upVoted {
                                downVoted = false
                            }
                        }
                    }
                }.padding(10)
            }
        }
        .frame(height: 150)
        .overlay(content: {
            RoundedRectangle(cornerRadius: 12).stroke(Color.gray, lineWidth: 1).opacity(0.7)
        })
        .contextMenu {
            Button {
                UIPasteboard.general.string = release.sku
                alert("Sku Copied", "checkmark")
            } label: {
                Label("Copy Sku", systemImage: "link")
            }
            if let link = release.stockxUrl, !link.isEmpty {
                Button {
                    if let url = URL(string: link) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Label("Open StockX", systemImage: "square.and.arrow.up")
                }
            }
            Button {
                if let url = URL(string: "https://wealth.com/releases/\(release.id ?? "")") {
                    showShareSheet(url: url)
                }
            } label: {
                Label("Share", systemImage: "arrowshape.turn.up.right")
            }
        }
        .padding(.horizontal, 12).padding(.vertical, 1)
    }
    func formatDateToTimeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter.string(from: date)
    }
}

struct FeedLoadingView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack(alignment: .leading){
            ZStack {
                GeometryReader { geo in
                    Image("WealthBlur")
                        .resizable().frame(width: geo.size.width, height: geo.size.height)
                }
                if colorScheme == .dark {
                    Color.black.opacity(0.7)
                } else {
                    Color.white.opacity(0.7)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12)).contentShape(RoundedRectangle(cornerRadius: 12))
            
            GeometryReader { geo in
                HStack(spacing: 10){
                    UnevenRoundedRectangle(topLeadingRadius: 12, bottomLeadingRadius: 12)
                        .frame(width: geo.size.width / 2.8, height: 150)
                        .foregroundStyle(.gray).opacity(0.3)
                    VStack(alignment: .leading){
                        Rectangle()
                            .frame(width: 115, height: 8)
                        Rectangle()
                            .frame(width: 70, height: 6)
                        Spacer()
                    }.padding(.top, 12).foregroundStyle(.gray).opacity(0.6)
                }
            }
        }.frame(height: 150).shadow(color: .gray,radius: 1).padding(.horizontal, 12)
    }
}

func showShareSheet(url: URL) {
    let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
    UIApplication.shared.currentUIWindow()?.rootViewController?.present(activityVC, animated: true, completion: nil)
}

func showMultiShareSheet(urls: [URL]) {
    let activityVC = UIActivityViewController(activityItems: urls, applicationActivities: nil)
    UIApplication.shared.currentUIWindow()?.rootViewController?.present(activityVC, animated: true, completion: nil)
}

public extension UIApplication {
    func currentUIWindow() -> UIWindow? {
        let connectedScenes = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
        
        let window = connectedScenes.first?
            .windows
            .first { $0.isKeyWindow }

        return window
        
    }
}
