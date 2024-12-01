import SwiftUI
import Kingfisher

struct LeaderBoardView: View {
    @Environment(ProfileViewModel.self) private var viewModel
    @EnvironmentObject var popRoot: PopToRoot
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @State var ScrollOrClose = false
    @State var canFetchMore = true
    @State var canRefresh = true
    @State var appeared = true
    
    let currentUID: String
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 10){
                    Color.clear.frame(height: 1).id("scrolltop")
                    
                    if viewModel.leaderboard.isEmpty {
                        VStack(spacing: 10){
                            ForEach(0..<12) { _ in
                                FeedLoadingView()
                            }
                        }.shimmering()
                    } else {
                        ForEach(Array(viewModel.leaderboard.enumerated()), id: \.element.id) { index, user in
                            userRow(user: user, index: index)
                                .scrollTransition { content, phase in
                                    content
                                        .scaleEffect(phase == .identity ? 1 : 0.65)
                                        .blur(radius: phase == .identity ? 0 : 10)
                                }
                        }
                    }
                    
                    Color.clear.frame(height: 120)
                        .overlay {
                            if viewModel.leaderboard.count > 20 {
                                ProgressView()
                                    .offset(y: -20)
                                    .onAppear {
                                        if canFetchMore {
                                            canFetchMore = false
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                                canFetchMore = true
                                            }
                                            viewModel.getLeaderboardUsers()
                                        }
                                    }
                            }
                        }
                }
            }
            .safeAreaPadding(.top, 75 + top_Inset())
            .scrollIndicators(.hidden)
            .onChange(of: popRoot.tap) { _, _ in
                if appeared {
                    if ScrollOrClose {
                        withAnimation {
                            proxy.scrollTo("scrolltop", anchor: .bottom)
                        }
                    } else {
                        dismiss()
                    }
                    popRoot.tap = 0
                }
            }
        }
        .background(content: {
            backColor()
        })
        .overlay(alignment: .top) {
            headerView()
        }
        .ignoresSafeArea()
        .onAppear(perform: {
            appeared = true
            viewModel.getLeaderboardUsers()
        })
        .onDisappear {
            appeared = false
        }
        .navigationBarBackButtonHidden(true)
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
    func userRow(user: User, index: Int) -> some View {
        HStack(spacing: 4){
            
            Text("\(index + 1).").font(.headline).padding(.trailing, 2)
            
            ZStack {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .foregroundStyle(.gray)
                    .frame(width: 35, height: 35)
                KFImage(URL(string: user.profileImageUrl))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .scaledToFill()
                    .clipShape(Circle())
                    .contentShape(Circle())
                    .frame(width: 35, height: 35)
                    .shadow(color: .gray, radius: 2)
            }
            .overlay(alignment: .bottomTrailing) {
                if (user.isVerified ?? false) == true {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.subheadline).foregroundStyle(Color.red).offset(x: 3, y: 3)
                }
            }
            
            VStack(alignment: .leading, spacing: 1){
                Text(user.username).font(.headline).bold().lineLimit(1).minimumScaleFactor(0.8)
                
                if (user.ownedInstances ?? 0) > 0 {
                    HStack(spacing: 2){
                        Text("Wealth Scale")
                        Image(systemName: "flame")
                    }.font(.subheadline).lineLimit(1).minimumScaleFactor(0.7)
                }
            }
            
            Spacer()
            
            HStack(spacing: 2){
                Text("\(user.checkoutCount)").font(.body).bold()
                Text("Checkouts").font(.caption).fontWeight(.light).lineLimit(1).minimumScaleFactor(0.8)
            }.padding(.trailing, 4)
            
            HStack(spacing: 2){
                Text(formatCurrency(value: user.checkoutTotal))
                    .font(.body).bold().lineLimit(1).minimumScaleFactor(0.7)
                
                Text("Spent").font(.caption).fontWeight(.light).lineLimit(1).minimumScaleFactor(0.8)
            }
        }
        .padding(.vertical, 5).padding(.horizontal, 8)
        .background {
            if user.id == currentUID {
                Color.blue
            } else {
                TransparentBlurView(removeAllFilters: true)
                    .blur(radius: 14, opaque: true)
                    .background(colorScheme == .dark ? .black.opacity(0.5) : .white.opacity(0.5))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12)).contentShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 12)
    }
    func formatCurrency(value: Double) -> String {
        if value >= 1_000_000 {
            let millions = value / 1_000_000
            return "$\(String(format: "%.1f", millions))M"
        } else if value >= 1_000 {
            let thousands = value / 1_000
            return "$\(String(format: "%.1f", thousands))k"
        } else {
            return "$\(String(format: "%.1f", value))"
        }
    }
    @ViewBuilder
    func headerView() -> some View {
        ZStack {
            HStack {
                Spacer()
                VStack(spacing: 3){
                    Image(colorScheme == .dark ? "wealthLogoWhite" : "wealthLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 45)
                    Text("Leaderboard").font(.caption).fontWeight(.semibold)
                }
                Spacer()
            }
            HStack {
                Button {
                    dismiss()
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    ZStack {
                        Rectangle().frame(width: 40, height: 50)
                            .foregroundStyle(.gray).opacity(0.001)
                        Image(systemName: "chevron.left").font(.title3).bold()
                    }
                }.buttonStyle(.plain)
                
                Spacer()
                
                VStack(spacing: 2){
                    Text("\(viewModel.leaderBoardPosition)").font(.headline).bold()
                    Text("Ranking").font(.caption)
                }
            }
        }
        .padding(.top, top_Inset()).padding(.horizontal).padding(.bottom, 10)
        .background {
            TransparentBlurView(removeAllFilters: true).blur(radius: 14, opaque: true)
        }
    }
}
