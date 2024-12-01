import SwiftUI
import Kingfisher
import PassKit
import Stripe
import MessageUI

struct ToolsView: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var popRoot: PopToRoot
    @Environment(\.colorScheme) var colorScheme
    @State var filter = "No filter"
    @State var filterImage = "shoe"
    @State var canRefresh = true
    @State var canFetchMore = true
    @State var showSettings = false
    @State var showContact = false
    @State var appeared = true
    @Namespace var hero
    
    @State var showBuySheet = false
    @State var buyImage = ""
    @State var buyTitle = ""
    @State var buyPoints: [String] = []
    @State var buyPrice = 0.0
    @State var sheetID = false
 
    @State var showThanksSheet = false
    @State var contactInfo = ""
    @State var thanksImage = ""
    @State var thanksTitle = ""
    @State var sheetIDThanks = UUID().uuidString
    
    @State var hideOrderNums: Bool? = false
    
    @State var sentTotal = 0
    @State private var isShowingMessages = false
    @State private var recipients: [String] = []
    @State private var message = "Download Wealth AIO so you can stay up to date on profitable releases and never miss out! https://wealth-aio.com"
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 15){
                    Color.clear.frame(height: 1).id("scrolltop")
                    
                    if filter == "Owned Tools" {
                        
                        if let tools = auth.currentUser?.unlockedTools, !tools.isEmpty {
                                                        
                            if (auth.currentUser?.hasBotAccess ?? false) {
                                ToolRowView(type: 0, image: "WealthIcon", title: "Wealth AIO", points: wealthAioPoints, owned: auth.currentUser?.hasBotAccess ?? false, price: "$49.99", sentTotal: $sentTotal, isShowingMessages: $isShowingMessages, showBuySheet: $showBuySheet, buyImage: $buyImage, buyTitle: $buyTitle, buyPoints: $buyPoints, buyPrice: $buyPrice, sheetID: $sheetID)
                                    .scrollTransition { content, phase in
                                        content
                                            .scaleEffect(phase == .identity ? 1 : 0.65)
                                            .blur(radius: phase == .identity ? 0 : 10)
                                    }
                                
                                if auth.currentUser?.ownedInstances != nil {
                                    ToolRowView(type: -3, image: "instances", title: "Wealth Scale", points: wealthScalePoints, owned: true, price: "$34.99", sentTotal: $sentTotal, isShowingMessages: $isShowingMessages, showBuySheet: $showBuySheet, buyImage: $buyImage, buyTitle: $buyTitle, buyPoints: $buyPoints, buyPrice: $buyPrice, sheetID: $sheetID)
                                        .scrollTransition { content, phase in
                                            content
                                                .scaleEffect(phase == .identity ? 1 : 0.65)
                                                .blur(radius: phase == .identity ? 0 : 10)
                                        }
                                }
                                
                                automationsButton()
                                    .scrollTransition { content, phase in
                                        content
                                            .scaleEffect(phase == .identity ? 1 : 0.65)
                                            .blur(radius: phase == .identity ? 0 : 10)
                                    }
                            }
                            
                            ForEach(tools, id: \.self) { item in
                                if item == "Ai Profile+" {
                                    ToolRowView(type: 9, image: "aiLogo", title: "Ai Profile+", points: aiProfilePoints, owned: true, price: "$29.99", sentTotal: $sentTotal, isShowingMessages: $isShowingMessages, showBuySheet: $showBuySheet, buyImage: $buyImage, buyTitle: $buyTitle, buyPoints: $buyPoints, buyPrice: $buyPrice, sheetID: $sheetID)
                                        .scrollTransition { content, phase in
                                            content
                                                .scaleEffect(phase == .identity ? 1 : 0.65)
                                                .blur(radius: phase == .identity ? 0 : 10)
                                        }
                                } else if item == "Forward Pro" {
                                    ToolRowView(type: 1, image: "forwardPro", title: "Forward Pro", points: forwardProPoints, owned: true, price: "$149.99", sentTotal: $sentTotal, isShowingMessages: $isShowingMessages, showBuySheet: $showBuySheet, buyImage: $buyImage, buyTitle: $buyTitle, buyPoints: $buyPoints, buyPrice: $buyPrice, sheetID: $sheetID)
                                        .scrollTransition { content, phase in
                                            content
                                                .scaleEffect(phase == .identity ? 1 : 0.65)
                                                .blur(radius: phase == .identity ? 0 : 10)
                                        }
                                } else if item == "Forward Lite" {
                                    ToolRowView(type: 2, image: "forwardLite", title: "Forward Lite", points: forwardLitePoints, owned: true, price: "$99.99", sentTotal: $sentTotal, isShowingMessages: $isShowingMessages, showBuySheet: $showBuySheet, buyImage: $buyImage, buyTitle: $buyTitle, buyPoints: $buyPoints, buyPrice: $buyPrice, sheetID: $sheetID)
                                        .scrollTransition { content, phase in
                                            content
                                                .scaleEffect(phase == .identity ? 1 : 0.65)
                                                .blur(radius: phase == .identity ? 0 : 10)
                                        }
                                } else if item == "CSV Pro" {
                                    ToolRowView(type: 3, image: "CsvPro", title: "CSV Pro", points: csvProPoints, owned: true, price: "$149.99", sentTotal: $sentTotal, isShowingMessages: $isShowingMessages, showBuySheet: $showBuySheet, buyImage: $buyImage, buyTitle: $buyTitle, buyPoints: $buyPoints, buyPrice: $buyPrice, sheetID: $sheetID)
                                        .scrollTransition { content, phase in
                                            content
                                                .scaleEffect(phase == .identity ? 1 : 0.65)
                                                .blur(radius: phase == .identity ? 0 : 10)
                                        }
                                } else if item == "CSV Lite" {
                                    ToolRowView(type: 4, image: "CsvLite", title: "CSV Lite", points: csvLitePoints, owned: true, price: "$99.99", sentTotal: $sentTotal, isShowingMessages: $isShowingMessages, showBuySheet: $showBuySheet, buyImage: $buyImage, buyTitle: $buyTitle, buyPoints: $buyPoints, buyPrice: $buyPrice, sheetID: $sheetID)
                                        .scrollTransition { content, phase in
                                            content
                                                .scaleEffect(phase == .identity ? 1 : 0.65)
                                                .blur(radius: phase == .identity ? 0 : 10)
                                        }
                                } else if item == "Stock Checker" {
                                    ToolRowView(type: 5, image: "stockChecker", title: "Stock Checker", points: stockPoints, owned: true, price: "$49.99", sentTotal: $sentTotal, isShowingMessages: $isShowingMessages, showBuySheet: $showBuySheet, buyImage: $buyImage, buyTitle: $buyTitle, buyPoints: $buyPoints, buyPrice: $buyPrice, sheetID: $sheetID)
                                        .scrollTransition { content, phase in
                                            content
                                                .scaleEffect(phase == .identity ? 1 : 0.65)
                                                .blur(radius: phase == .identity ? 0 : 10)
                                        }
                                } else if item == "Variant Scraper" {
                                    ToolRowView(type: 6, image: "variantScraper", title: "Variant Scraper", points: variantPoints, owned: true, price: "$99.99", sentTotal: $sentTotal, isShowingMessages: $isShowingMessages, showBuySheet: $showBuySheet, buyImage: $buyImage, buyTitle: $buyTitle, buyPoints: $buyPoints, buyPrice: $buyPrice, sheetID: $sheetID)
                                        .scrollTransition { content, phase in
                                            content
                                                .scaleEffect(phase == .identity ? 1 : 0.65)
                                                .blur(radius: phase == .identity ? 0 : 10)
                                        }
                                } else if item == "In-App Queue" {
                                    ToolRowView(type: 7, image: "qApp", title: "In-App Queue", points: inAppQPoints, owned: true, price: "$39.99", sentTotal: $sentTotal, isShowingMessages: $isShowingMessages, showBuySheet: $showBuySheet, buyImage: $buyImage, buyTitle: $buyTitle, buyPoints: $buyPoints, buyPrice: $buyPrice, sheetID: $sheetID)
                                        .scrollTransition { content, phase in
                                            content
                                                .scaleEffect(phase == .identity ? 1 : 0.65)
                                                .blur(radius: phase == .identity ? 0 : 10)
                                        }
                                } else if item == "Discord Queue" {
                                    ToolRowView(type: 8, image: "qDiscord", title: "Discord Queue", points: discordQPoints, owned: true, price: "$99.99", sentTotal: $sentTotal, isShowingMessages: $isShowingMessages, showBuySheet: $showBuySheet, buyImage: $buyImage, buyTitle: $buyTitle, buyPoints: $buyPoints, buyPrice: $buyPrice, sheetID: $sheetID)
                                        .scrollTransition { content, phase in
                                            content
                                                .scaleEffect(phase == .identity ? 1 : 0.65)
                                                .blur(radius: phase == .identity ? 0 : 10)
                                        }
                                } else if item == "BB Builder" {
                                    ToolRowView(type: 11, image: "builder", title: "BB Builder", points: builderPoints, owned: true, price: "$99.99", sentTotal: $sentTotal, isShowingMessages: $isShowingMessages, showBuySheet: $showBuySheet, buyImage: $buyImage, buyTitle: $buyTitle, buyPoints: $buyPoints, buyPrice: $buyPrice, sheetID: $sheetID)
                                        .scrollTransition { content, phase in
                                            content
                                                .scaleEffect(phase == .identity ? 1 : 0.65)
                                                .blur(radius: phase == .identity ? 0 : 10)
                                        }
                                } else if item == "Nike Builder" {
                                    ToolRowView(type: 13, image: "nikeBuilder", title: "Nike Builder", points: nikeBuilderPoints, owned: true, price: "$99.99", sentTotal: $sentTotal, isShowingMessages: $isShowingMessages, showBuySheet: $showBuySheet, buyImage: $buyImage, buyTitle: $buyTitle, buyPoints: $buyPoints, buyPrice: $buyPrice, sheetID: $sheetID)
                                        .scrollTransition { content, phase in
                                            content
                                                .scaleEffect(phase == .identity ? 1 : 0.65)
                                                .blur(radius: phase == .identity ? 0 : 10)
                                        }
                                } else if item == "Pokemon Builder" {
                                    ToolRowView(type: 15, image: "pokemonBuilder", title: "Pokemon Builder", points: nikeBuilderPoints, owned: true, price: "$69.99", sentTotal: $sentTotal, isShowingMessages: $isShowingMessages, showBuySheet: $showBuySheet, buyImage: $buyImage, buyTitle: $buyTitle, buyPoints: $buyPoints, buyPrice: $buyPrice, sheetID: $sheetID)
                                        .scrollTransition { content, phase in
                                            content
                                                .scaleEffect(phase == .identity ? 1 : 0.65)
                                                .blur(radius: phase == .identity ? 0 : 10)
                                        }
                                } else if item == "Costco Builder" {
                                    ToolRowView(type: 18, image: "costco", title: "Costco Builder", points: costcoBuilderPoints, owned: true, price: "$69.99", sentTotal: $sentTotal, isShowingMessages: $isShowingMessages, showBuySheet: $showBuySheet, buyImage: $buyImage, buyTitle: $buyTitle, buyPoints: $buyPoints, buyPrice: $buyPrice, sheetID: $sheetID)
                                        .scrollTransition { content, phase in
                                            content
                                                .scaleEffect(phase == .identity ? 1 : 0.65)
                                                .blur(radius: phase == .identity ? 0 : 10)
                                        }
                                } else if item == "Uber Builder" {
                                    ToolRowView(type: 20, image: "uber1", title: "Uber Builder", points: uberBuilderPoints, owned: true, price: "$69.99", sentTotal: $sentTotal, isShowingMessages: $isShowingMessages, showBuySheet: $showBuySheet, buyImage: $buyImage, buyTitle: $buyTitle, buyPoints: $buyPoints, buyPrice: $buyPrice, sheetID: $sheetID)
                                        .scrollTransition { content, phase in
                                            content
                                                .scaleEffect(phase == .identity ? 1 : 0.65)
                                                .blur(radius: phase == .identity ? 0 : 10)
                                        }
                                }
                            }
        
                        } else if (auth.currentUser?.hasBotAccess ?? false) {
                            ToolRowView(type: 0, image: "WealthIcon", title: "Wealth AIO", points: wealthAioPoints, owned: auth.currentUser?.hasBotAccess ?? false, price: "$49.99", sentTotal: $sentTotal, isShowingMessages: $isShowingMessages, showBuySheet: $showBuySheet, buyImage: $buyImage, buyTitle: $buyTitle, buyPoints: $buyPoints, buyPrice: $buyPrice, sheetID: $sheetID)
                                .scrollTransition { content, phase in
                                    content
                                        .scaleEffect(phase == .identity ? 1 : 0.65)
                                        .blur(radius: phase == .identity ? 0 : 10)
                                }
                            
                            if auth.currentUser?.ownedInstances != nil {
                                ToolRowView(type: -3, image: "instances", title: "Wealth Scale", points: wealthScalePoints, owned: true, price: "$34.99", sentTotal: $sentTotal, isShowingMessages: $isShowingMessages, showBuySheet: $showBuySheet, buyImage: $buyImage, buyTitle: $buyTitle, buyPoints: $buyPoints, buyPrice: $buyPrice, sheetID: $sheetID)
                                    .scrollTransition { content, phase in
                                        content
                                            .scaleEffect(phase == .identity ? 1 : 0.65)
                                            .blur(radius: phase == .identity ? 0 : 10)
                                    }
                            }
                            
                            automationsButton()
                                .scrollTransition { content, phase in
                                    content
                                        .scaleEffect(phase == .identity ? 1 : 0.65)
                                        .blur(radius: phase == .identity ? 0 : 10)
                                }
                        } else {
                            VStack(spacing: 12){
                                Text("Nothing yet...").font(.largeTitle).bold()
                                Text("Tools you own will appear here.").font(.caption).foregroundStyle(.gray)
                            }.padding(.top, 150)
                        }
                        
                    } else {
                        ToolRowView(type: 0, image: "WealthIcon", title: "Wealth AIO", points: wealthAioPoints, owned: auth.currentUser?.hasBotAccess ?? false, price: "$49.99", sentTotal: $sentTotal, isShowingMessages: $isShowingMessages, showBuySheet: $showBuySheet, buyImage: $buyImage, buyTitle: $buyTitle, buyPoints: $buyPoints, buyPrice: $buyPrice, sheetID: $sheetID)
                            .scrollTransition { content, phase in
                                content
                                    .scaleEffect(phase == .identity ? 1 : 0.65)
                                    .blur(radius: phase == .identity ? 0 : 10)
                            }
                        
                        ToolRowView(type: -3, image: "instances", title: "Wealth Scale", points: wealthScalePoints, owned: auth.currentUser?.ownedInstances != nil, price: "$34.99", sentTotal: $sentTotal, isShowingMessages: $isShowingMessages, showBuySheet: $showBuySheet, buyImage: $buyImage, buyTitle: $buyTitle, buyPoints: $buyPoints, buyPrice: $buyPrice, sheetID: $sheetID)
                            .scrollTransition { content, phase in
                                content
                                    .scaleEffect(phase == .identity ? 1 : 0.65)
                                    .blur(radius: phase == .identity ? 0 : 10)
                            }
                        
                        ToolRowView(type: -1, image: "Proxies", title: "Wealth Proxies", points: wealthProxyPoints, owned: true, price: "", sentTotal: $sentTotal, isShowingMessages: $isShowingMessages, showBuySheet: $showBuySheet, buyImage: $buyImage, buyTitle: $buyTitle, buyPoints: $buyPoints, buyPrice: $buyPrice, sheetID: $sheetID)
                            .scrollTransition { content, phase in
                                content
                                    .scaleEffect(phase == .identity ? 1 : 0.65)
                                    .blur(radius: phase == .identity ? 0 : 10)
                            }
                        
                        ToolRowView(type: -4, image: "WealthAccounts", title: "Account Vault", points: wealthAccountsPoints, owned: true, price: "", sentTotal: $sentTotal, isShowingMessages: $isShowingMessages, showBuySheet: $showBuySheet, buyImage: $buyImage, buyTitle: $buyTitle, buyPoints: $buyPoints, buyPrice: $buyPrice, sheetID: $sheetID)
                            .scrollTransition { content, phase in
                                content
                                    .scaleEffect(phase == .identity ? 1 : 0.65)
                                    .blur(radius: phase == .identity ? 0 : 10)
                            }
                        
                        ToolRowView(type: -2, image: "Server", title: "Wealth Servers", points: wealthServerPoints, owned: true, price: "", sentTotal: $sentTotal, isShowingMessages: $isShowingMessages, showBuySheet: $showBuySheet, buyImage: $buyImage, buyTitle: $buyTitle, buyPoints: $buyPoints, buyPrice: $buyPrice, sheetID: $sheetID)
                            .scrollTransition { content, phase in
                                content
                                    .scaleEffect(phase == .identity ? 1 : 0.65)
                                    .blur(radius: phase == .identity ? 0 : 10)
                            }
                        
                        ToolRowView(type: 9, image: "aiLogo", title: "Ai Profile+", points: aiProfilePoints, owned: (auth.currentUser?.unlockedTools ?? []).contains("Ai Profile+"), price: "$29.99", sentTotal: $sentTotal, isShowingMessages: $isShowingMessages, showBuySheet: $showBuySheet, buyImage: $buyImage, buyTitle: $buyTitle, buyPoints: $buyPoints, buyPrice: $buyPrice, sheetID: $sheetID)
                            .scrollTransition { content, phase in
                                content
                                    .scaleEffect(phase == .identity ? 1 : 0.65)
                                    .blur(radius: phase == .identity ? 0 : 10)
                            }
                                                
                        ToolRowView(type: 11, image: "builder", title: "BB Builder", points: builderPoints, owned: (auth.currentUser?.unlockedTools ?? []).contains("BB Builder"), price: "$499.99", sentTotal: $sentTotal, isShowingMessages: $isShowingMessages, showBuySheet: $showBuySheet, buyImage: $buyImage, buyTitle: $buyTitle, buyPoints: $buyPoints, buyPrice: $buyPrice, sheetID: $sheetID)
                            .scrollTransition { content, phase in
                                content
                                    .scaleEffect(phase == .identity ? 1 : 0.65)
                                    .blur(radius: phase == .identity ? 0 : 10)
                            }
                        
                        ToolRowView(type: 12, image: "bb", title: "BB Accounts", points: bbPoints, owned: false, price: "$19.99", sentTotal: $sentTotal, isShowingMessages: $isShowingMessages, showBuySheet: $showBuySheet, buyImage: $buyImage, buyTitle: $buyTitle, buyPoints: $buyPoints, buyPrice: $buyPrice, sheetID: $sheetID)
                            .scrollTransition { content, phase in
                                content
                                    .scaleEffect(phase == .identity ? 1 : 0.65)
                                    .blur(radius: phase == .identity ? 0 : 10)
                            }

                        ToolRowView(type: 13, image: "nikeBuilder", title: "Nike Builder", points: nikeBuilderPoints, owned: (auth.currentUser?.unlockedTools ?? []).contains("Nike Builder"), price: "$699.99", sentTotal: $sentTotal, isShowingMessages: $isShowingMessages, showBuySheet: $showBuySheet, buyImage: $buyImage, buyTitle: $buyTitle, buyPoints: $buyPoints, buyPrice: $buyPrice, sheetID: $sheetID)
                            .scrollTransition { content, phase in
                                content
                                    .scaleEffect(phase == .identity ? 1 : 0.65)
                                    .blur(radius: phase == .identity ? 0 : 10)
                            }
                        
                        ToolRowView(type: 14, image: "nikeAcc", title: "Nike Accounts", points: nikeAccountPoints, owned: false, price: "$24.99", sentTotal: $sentTotal, isShowingMessages: $isShowingMessages, showBuySheet: $showBuySheet, buyImage: $buyImage, buyTitle: $buyTitle, buyPoints: $buyPoints, buyPrice: $buyPrice, sheetID: $sheetID)
                            .scrollTransition { content, phase in
                                content
                                    .scaleEffect(phase == .identity ? 1 : 0.65)
                                    .blur(radius: phase == .identity ? 0 : 10)
                            }
                        
                        ToolRowView(type: 15, image: "pokemonBuilder", title: "Pokemon Builder", points: pokemonBuilderPoints, owned: (auth.currentUser?.unlockedTools ?? []).contains("Pokemon Builder"), price: "$469.99", sentTotal: $sentTotal, isShowingMessages: $isShowingMessages, showBuySheet: $showBuySheet, buyImage: $buyImage, buyTitle: $buyTitle, buyPoints: $buyPoints, buyPrice: $buyPrice, sheetID: $sheetID)
                            .scrollTransition { content, phase in
                                content
                                    .scaleEffect(phase == .identity ? 1 : 0.65)
                                    .blur(radius: phase == .identity ? 0 : 10)
                            }
                        
                        ToolRowView(type: 16, image: "pokemon", title: "Pokemon Accounts", points: pokemonAccountPoints, owned: false, price: "$19.99", sentTotal: $sentTotal, isShowingMessages: $isShowingMessages, showBuySheet: $showBuySheet, buyImage: $buyImage, buyTitle: $buyTitle, buyPoints: $buyPoints, buyPrice: $buyPrice, sheetID: $sheetID)
                            .scrollTransition { content, phase in
                                content
                                    .scaleEffect(phase == .identity ? 1 : 0.65)
                                    .blur(radius: phase == .identity ? 0 : 10)
                            }
                        
                        ToolRowView(type: 17, image: "popmart", title: "Popmart Accounts", points: popmartAccountPoints, owned: false, price: "$19.99", sentTotal: $sentTotal, isShowingMessages: $isShowingMessages, showBuySheet: $showBuySheet, buyImage: $buyImage, buyTitle: $buyTitle, buyPoints: $buyPoints, buyPrice: $buyPrice, sheetID: $sheetID)
                            .scrollTransition { content, phase in
                                content
                                    .scaleEffect(phase == .identity ? 1 : 0.65)
                                    .blur(radius: phase == .identity ? 0 : 10)
                            }
                        
                        ToolRowView(type: 18, image: "costco", title: "Costco Builder", points: costcoBuilderPoints, owned: (auth.currentUser?.unlockedTools ?? []).contains("Costco Builder"), price: "$469.99", sentTotal: $sentTotal, isShowingMessages: $isShowingMessages, showBuySheet: $showBuySheet, buyImage: $buyImage, buyTitle: $buyTitle, buyPoints: $buyPoints, buyPrice: $buyPrice, sheetID: $sheetID)
                            .scrollTransition { content, phase in
                                content
                                    .scaleEffect(phase == .identity ? 1 : 0.65)
                                    .blur(radius: phase == .identity ? 0 : 10)
                            }
                        
                        ToolRowView(type: 19, image: "costcoAcc", title: "Costco Accounts", points: costcoAccountPoints, owned: false, price: "$19.99", sentTotal: $sentTotal, isShowingMessages: $isShowingMessages, showBuySheet: $showBuySheet, buyImage: $buyImage, buyTitle: $buyTitle, buyPoints: $buyPoints, buyPrice: $buyPrice, sheetID: $sheetID)
                            .scrollTransition { content, phase in
                                content
                                    .scaleEffect(phase == .identity ? 1 : 0.65)
                                    .blur(radius: phase == .identity ? 0 : 10)
                            }
                        
                        ToolRowView(type: 20, image: "uber1", title: "Uber Builder", points: uberBuilderPoints, owned: (auth.currentUser?.unlockedTools ?? []).contains("Uber Builder"), price: "$469.99", sentTotal: $sentTotal, isShowingMessages: $isShowingMessages, showBuySheet: $showBuySheet, buyImage: $buyImage, buyTitle: $buyTitle, buyPoints: $buyPoints, buyPrice: $buyPrice, sheetID: $sheetID)
                            .scrollTransition { content, phase in
                                content
                                    .scaleEffect(phase == .identity ? 1 : 0.65)
                                    .blur(radius: phase == .identity ? 0 : 10)
                            }
                        
                        ToolRowView(type: 21, image: "uber2", title: "Uber Accounts", points: uberAccountPoints, owned: false, price: "$19.99", sentTotal: $sentTotal, isShowingMessages: $isShowingMessages, showBuySheet: $showBuySheet, buyImage: $buyImage, buyTitle: $buyTitle, buyPoints: $buyPoints, buyPrice: $buyPrice, sheetID: $sheetID)
                            .scrollTransition { content, phase in
                                content
                                    .scaleEffect(phase == .identity ? 1 : 0.65)
                                    .blur(radius: phase == .identity ? 0 : 10)
                            }
                        
                        ToolRowView(type: 7, image: "qApp", title: "In-App Queue", points: inAppQPoints, owned: (auth.currentUser?.unlockedTools ?? []).contains("In-App Queue"), price: "$39.99", sentTotal: $sentTotal, isShowingMessages: $isShowingMessages, showBuySheet: $showBuySheet, buyImage: $buyImage, buyTitle: $buyTitle, buyPoints: $buyPoints, buyPrice: $buyPrice, sheetID: $sheetID)
                            .scrollTransition { content, phase in
                                content
                                    .scaleEffect(phase == .identity ? 1 : 0.65)
                                    .blur(radius: phase == .identity ? 0 : 10)
                            }
                        
                        ToolRowView(type: 8, image: "qDiscord", title: "Discord Queue", points: discordQPoints, owned: (auth.currentUser?.unlockedTools ?? []).contains("Discord Queue"), price: "$99.99", sentTotal: $sentTotal, isShowingMessages: $isShowingMessages, showBuySheet: $showBuySheet, buyImage: $buyImage, buyTitle: $buyTitle, buyPoints: $buyPoints, buyPrice: $buyPrice, sheetID: $sheetID)
                            .scrollTransition { content, phase in
                                content
                                    .scaleEffect(phase == .identity ? 1 : 0.65)
                                    .blur(radius: phase == .identity ? 0 : 10)
                            }
                        
                        ToolRowView(type: 6, image: "variantScraper", title: "Variant Scraper", points: variantPoints, owned: (auth.currentUser?.unlockedTools ?? []).contains("Variant Scraper"), price: "$99.99", sentTotal: $sentTotal, isShowingMessages: $isShowingMessages, showBuySheet: $showBuySheet, buyImage: $buyImage, buyTitle: $buyTitle, buyPoints: $buyPoints, buyPrice: $buyPrice, sheetID: $sheetID)
                            .scrollTransition { content, phase in
                                content
                                    .scaleEffect(phase == .identity ? 1 : 0.65)
                                    .blur(radius: phase == .identity ? 0 : 10)
                            }
                        
                        ToolRowView(type: 1, image: "forwardPro", title: "Forward Pro", points: forwardProPoints, owned: (auth.currentUser?.unlockedTools ?? []).contains("Forward Pro"), price: "$149.99", sentTotal: $sentTotal, isShowingMessages: $isShowingMessages, showBuySheet: $showBuySheet, buyImage: $buyImage, buyTitle: $buyTitle, buyPoints: $buyPoints, buyPrice: $buyPrice, sheetID: $sheetID)
                            .scrollTransition { content, phase in
                                content
                                    .scaleEffect(phase == .identity ? 1 : 0.65)
                                    .blur(radius: phase == .identity ? 0 : 10)
                            }
                        
                        ToolRowView(type: 2, image: "forwardLite", title: "Forward Lite", points: forwardLitePoints, owned: (auth.currentUser?.unlockedTools ?? []).contains("Forward Lite"), price: "$99.99", sentTotal: $sentTotal, isShowingMessages: $isShowingMessages, showBuySheet: $showBuySheet, buyImage: $buyImage, buyTitle: $buyTitle, buyPoints: $buyPoints, buyPrice: $buyPrice, sheetID: $sheetID)
                            .scrollTransition { content, phase in
                                content
                                    .scaleEffect(phase == .identity ? 1 : 0.65)
                                    .blur(radius: phase == .identity ? 0 : 10)
                            }
                        
                        ToolRowView(type: 3, image: "CsvPro", title: "CSV Pro", points: csvProPoints, owned: (auth.currentUser?.unlockedTools ?? []).contains("CSV Pro"), price: "$149.99", sentTotal: $sentTotal, isShowingMessages: $isShowingMessages, showBuySheet: $showBuySheet, buyImage: $buyImage, buyTitle: $buyTitle, buyPoints: $buyPoints, buyPrice: $buyPrice, sheetID: $sheetID)
                            .scrollTransition { content, phase in
                                content
                                    .scaleEffect(phase == .identity ? 1 : 0.65)
                                    .blur(radius: phase == .identity ? 0 : 10)
                            }
                        
                        ToolRowView(type: 4, image: "CsvLite", title: "CSV Lite", points: csvLitePoints, owned: (auth.currentUser?.unlockedTools ?? []).contains("CSV Lite"), price: "$99.99", sentTotal: $sentTotal, isShowingMessages: $isShowingMessages, showBuySheet: $showBuySheet, buyImage: $buyImage, buyTitle: $buyTitle, buyPoints: $buyPoints, buyPrice: $buyPrice, sheetID: $sheetID)
                            .scrollTransition { content, phase in
                                content
                                    .scaleEffect(phase == .identity ? 1 : 0.65)
                                    .blur(radius: phase == .identity ? 0 : 10)
                            }
                        
                        ToolRowView(type: 5, image: "stockChecker", title: "Stock Checker", points: stockPoints, owned: (auth.currentUser?.unlockedTools ?? []).contains("Stock Checker"), price: "$49.99", sentTotal: $sentTotal, isShowingMessages: $isShowingMessages, showBuySheet: $showBuySheet, buyImage: $buyImage, buyTitle: $buyTitle, buyPoints: $buyPoints, buyPrice: $buyPrice, sheetID: $sheetID)
                            .scrollTransition { content, phase in
                                content
                                    .scaleEffect(phase == .identity ? 1 : 0.65)
                                    .blur(radius: phase == .identity ? 0 : 10)
                            }
                        
                        automationsButton()
                            .scrollTransition { content, phase in
                                content
                                    .scaleEffect(phase == .identity ? 1 : 0.65)
                                    .blur(radius: phase == .identity ? 0 : 10)
                            }
                        
                        createView()
                            .scrollTransition { content, phase in
                                content
                                    .scaleEffect(phase == .identity ? 1 : 0.65)
                                    .blur(radius: phase == .identity ? 0 : 10)
                            }
                    }
                    
                    Color.clear.frame(height: 150)
                }
            }
            .safeAreaPadding(.top, 60 + top_Inset())
            .scrollIndicators(.hidden)
            .onChange(of: popRoot.tap) { _, _ in
                if popRoot.tap == 2 && appeared {
                    withAnimation {
                        proxy.scrollTo("scrolltop", anchor: .bottom)
                    }
                    popRoot.tap = 0
                }
            }
        }
        .sheet(isPresented: $isShowingMessages) {
            MessageUIView(recipients: $recipients, body: $message, completion: handleCompletion(_:))
        }
        .sheet(isPresented: $showSettings, content: {
            SettingsSheetView(hideOrderNums: $hideOrderNums)
        })
        .overlay(alignment: .top) {
            headerView()
        }
        .ignoresSafeArea()
        .onAppear(perform: {
            appeared = true
            
            if !(auth.currentUser?.hasBotAccess ?? false) && isDateNilOrOld(date: popRoot.lastCheckInStock) {
                popRoot.lastCheckInStock = Date()
                UserService().BotInStock { bool in
                    popRoot.botInStock = bool
                }
            }
            
            if popRoot.randomVal.isEmpty {
                UserService().getRandomVal { val in
                    popRoot.randomVal = val
                }
            }
            
            if popRoot.soldQuantities == nil {
                UserService().getSoldQuantiites { item in
                    if let item {
                        self.popRoot.soldQuantities = item
                    }
                }
            }
        })
        .sheet(isPresented: $showBuySheet) {
            buySheet().id(sheetID)
        }
        .sheet(isPresented: $showThanksSheet) {
            thanksSheet().id(sheetIDThanks)
        }
        .sheet(isPresented: $showContact, content: {
            ContactView()
        })
        .onDisappear {
            appeared = false
        }
    }
    func handleCompletion(_ result: MessageComposeResult) {
        switch result {
        case .cancelled:
            break
        case .sent:
            sentTotal += 1
            
            if sentTotal == 10 {
                auth.currentUser?.unlockedTools.append("Ai Profile+")
                UserService().addToolAccess(tool: "Ai Profile+")
                incrementSold(image: "aiLogo")
                popRoot.presentAlert(image: "checkmark", text: "Ai Profile+ Unlocked! Use it from the Ai Tab.")
            }
            
            break
        case .failed:
            break
        @unknown default:
            break
        }
    }
    func isDateNilOrOld(date: Date?) -> Bool {
        guard let date = date else {
            return true
        }
        
        return Date().timeIntervalSince(date) >= 60
    }
    @ViewBuilder
    func thanksSheet() -> some View {
        ZStack {
            backColor()

            VStack(alignment: .leading){
                Text("Thanks for your Purchase!")
                    .font(.title).fontWeight(.heavy)
                    .lineLimit(1).minimumScaleFactor(0.7)
                
                HStack(spacing: 10){
                    Image(thanksImage)
                        .resizable().scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .contentShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(content: {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.gray, lineWidth: 1).opacity(0.6)
                        })
                    
                    Text(thanksTitle).font(.headline).bold()
                    
                    Spacer()
                }.padding(.bottom, 20)
                
                TextField("", text: $contactInfo)
                    .lineLimit(1)
                    .frame(height: 57)
                    .padding(.top, 8)
                    .overlay(alignment: .leading, content: {
                        Text("Confirm Email").font(.system(size: 18)).fontWeight(.light)
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
                
                Spacer()
                
                HStack {
                    Spacer()
 
                    (Text("Confirm email for service setup steps. If buying accounts, screenshot this screen and join ")
                     + Text("Account Vault").foregroundStyle(.blue)
                     + Text(", then follow the steps and open a ticket in the correct channel")
                    )
                    .multilineTextAlignment(.center).font(.subheadline)
                    .onTapGesture {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        if let url = URL(string: "https://discord.gg/account-vault") {
                            DispatchQueue.main.async {
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                    
                    Spacer()
                }
                HStack {
                    Spacer()
                    
                    let status = !contactInfo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    
                    Button {
                        if status {
                            showThanksSheet = false
                            
                            popRoot.presentAlert(image: "checkmark", text: "We will be with you very soon!")
                            
                            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                            
                            UserService().verifyPurchase(email: contactInfo, itemBought: thanksTitle)
                        }
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundStyle(Color.babyBlue)
                                .frame(height: 55)
                            Text("Submit").font(.headline).bold()
                        }
                    }.opacity(status ? 1.0 : 0.6).buttonStyle(.plain)
                    
                    Spacer()
                }.padding(.bottom, 8)
            }.padding(.horizontal).padding(.top)
        }
        .presentationDetents([.medium])
        .presentationCornerRadius(30)
        .interactiveDismissDisabled(true)
    }
    @ViewBuilder
    func buySheet() -> some View {
        ZStack {
            backColor()

            VStack(alignment: .leading, spacing: 10){
                HStack(spacing: 10){
                    Image(buyImage)
                        .resizable().scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .contentShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(content: {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.gray, lineWidth: 1).opacity(0.6)
                        })
                    Text(buyTitle).font(.title2).bold()
                        .lineLimit(1).minimumScaleFactor(0.7)
                    Spacer()
                    VStack(spacing: 6){
                        Text("$\(String(format: "%.2f", buyPrice))").fontWeight(.heavy).font(.headline)
                        Text("Lifetime Access")
                            .font(.caption).foregroundStyle(.blue)
                    }
                }.padding(.bottom, 20)
                
                Text("Service Perks").font(.headline).bold().padding(.bottom, 5)
                
                ScrollView {
                    VStack(spacing: 8){
                        ForEach(buyPoints, id: \.self) { item in
                            HStack(alignment: .top, spacing: 3){
                                Text("-").bold().foregroundStyle(.blue)
                                
                                Text(item)
                                
                                Spacer()
                            }.font(.subheadline).multilineTextAlignment(.leading)
                        }
                    }
                }.scrollIndicators(.hidden)
                                
                HStack {
                    Spacer()
                    (Text("By purchasing this product you agree to our")
                        .font(.caption)
                     + Text(" Term of Service along with out Terms of Purchase.")
                        .foregroundStyle(.blue).font(.caption)
                    )
                    .multilineTextAlignment(.center)
                    .onTapGesture {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        if let url = URL(string: "https://WealthAIO.com") {
                            DispatchQueue.main.async {
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                    Spacer()
                }.padding(.top, 5)
                
                HStack {
                    Spacer()
                    
                    if let user = auth.currentUser, !buyTitle.isEmpty {
                        ApplePayButtonView(
                            merchantIdentifier: "merchant.com.wealth.Wealth",
                            countryCode: "US",
                            currency: "USD",
                            randomVal: popRoot.randomVal,
                            amount: buyPrice,
                            businessName: "Wealth AIO"
                        ) { result in
                            switch result {
                            case .success:
                                auth.currentUser?.unlockedTools.append(buyTitle)
                                UserService().uploadPurchase(email: user.email, itemBought: buyTitle)
                                UserService().addToolAccess(tool: buyTitle)
                                incrementSold(image: buyImage)
                                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                                thanksImage = buyImage
                                thanksTitle = buyTitle
                                showBuySheet = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                                    showThanksSheet = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4){
                                    sheetIDThanks = UUID().uuidString
                                }
                            case .failure(_):
                                popRoot.presentAlert(image: "xmark", text: "Transaction failed! Please try again.")
                            }
                        }
                        .frame(height: 55).padding(.top, 20).clipped()
                    }
                    
                    Spacer()
                }
            }.padding(.horizontal).padding(.top)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(30)
    }
    func incrementSold(image: String) {
        if image == "CsvLite" {
            UserService().updateSold(field: "CsvLite")
            popRoot.soldQuantities?.CsvLite += 1
        } else if image == "CsvPro" {
            UserService().updateSold(field: "CsvPro")
            popRoot.soldQuantities?.CsvPro += 1
        } else if image == "WealthIcon" {
            UserService().updateSold(field: "WealthIcon")
            popRoot.soldQuantities?.WealthIcon += 1
        } else if image == "aiLogo" {
            UserService().updateSold(field: "aiLogo")
            popRoot.soldQuantities?.aiLogo += 1
        } else if image == "forwardLite" {
            UserService().updateSold(field: "forwardLite")
            popRoot.soldQuantities?.forwardLite += 1
        } else if image == "forwardPro" {
            UserService().updateSold(field: "forwardPro")
            popRoot.soldQuantities?.forwardPro += 1
        } else if image == "builder" {
            UserService().updateSold(field: "builder")
            popRoot.soldQuantities?.builder += 1
        } else if image == "variantScraper" {
            UserService().updateSold(field: "variantScraper")
            popRoot.soldQuantities?.variantScraper += 1
        } else if image == "qApp" {
            UserService().updateSold(field: "qApp")
            popRoot.soldQuantities?.qApp += 1
        } else if image == "qDiscord" {
            UserService().updateSold(field: "qDiscord")
            popRoot.soldQuantities?.qDiscord += 1
        } else if image == "stockChecker" {
            UserService().updateSold(field: "stockChecker")
            popRoot.soldQuantities?.stockChecker += 1
        } else if image == "pokemonBuilder" {
           UserService().updateSold(field: "pokemonBuilder")
           popRoot.soldQuantities?.pokemonBuilder += 1
        } else if image == "nikeBuilder" {
            UserService().updateSold(field: "nikeBuilder")
            popRoot.soldQuantities?.nikeBuilder += 1
        } else if image == "costco" {
            UserService().updateSold(field: "costco")
            popRoot.soldQuantities?.costcoBuilder += 1
        } else if image == "uber1" {
            UserService().updateSold(field: "uber1")
            popRoot.soldQuantities?.uberBuilder += 1
        }
    }
    @ViewBuilder
    func automationsButton() -> some View {
        VStack(spacing: 0){
            Image("autos")
                .resizable().scaledToFill()
                .frame(height: 100).blur(radius: 6)
                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 12, topTrailingRadius: 12))
                .contentShape(UnevenRoundedRectangle(topLeadingRadius: 12, topTrailingRadius: 12))
                .overlay(alignment: .topLeading){
                    VStack(alignment: .leading, spacing: 3){
                        Text("Coming Soon")
                            .fontWeight(.heavy).font(.subheadline)
                            .padding(.horizontal, 10).padding(.vertical, 4)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule()).padding(.leading, 10).padding(.top, 10)
                        
                        Spacer()
                    }
                }
                .overlay(alignment: .bottomTrailing){
                    Image("autos")
                        .resizable().scaledToFill()
                        .frame(width: 70, height: 70)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .contentShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(content: {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.gray, lineWidth: 1).opacity(0.6)
                        })
                        .offset(y: 36).padding(.trailing, 20)
                }
            
            HStack(alignment: .top){
                Text("Automations").font(.title2).bold()
                Spacer()
            }.padding(.horizontal, 10).padding(.top, 10)
            
            let points = [
                "Autos for Shopify, Nike, Pokémon, and Popmart!",
                "Set up autos effortlessly with Wealth iOS.",
                "Available for free to Wealth AIO members.",
                "Scheduled for release in June 2025!"
            ]
            
            VStack(alignment: .leading, spacing: 7){
                ForEach(points, id: \.self) { item in
                    HStack(spacing: 2){
                        Text("-").font(.system(size: 13)).bold().foregroundStyle(.blue)
                        
                        Text(item).multilineTextAlignment(.leading).font(.system(size: 13))
                        
                        Spacer()
                    }
                }
            }.padding(.horizontal, 10).padding(.top, 10).padding(.bottom, 10)
        }
        .background(content: {
            TransparentBlurView(removeAllFilters: true)
                .blur(radius: 14, opaque: true)
                .background(colorScheme == .dark ? .black.opacity(0.4) : .white.opacity(0.4))
        })
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .overlay(content: {
            RoundedRectangle(cornerRadius: 12)
                .stroke(lineWidth: 1).opacity(0.4)
        })
        .onTapGesture {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            popRoot.presentAlert(image: "exclamationmark.bubble", text: "Coming Soon to Wealth AIO members!")
        }
        .padding(.horizontal, 12).padding(.top, 10)
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
                Image(colorScheme == .dark ? "wealthLogoWhite" : "wealthLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 55)
                Spacer()
            }
            HStack {
                NavigationLink {
                    ProfileView().navigationTransition(.zoom(sourceID: "mainProfile", in: hero))
                } label: {
                    ZStack {
                        Image("WealthIcon")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 42, height: 42)
                            .clipShape(Circle())
                            .contentShape(Circle())
                        
                        if let image = auth.currentUser?.profileImageUrl {
                            KFImage(URL(string: image))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 42, height: 42)
                                .clipShape(Circle())
                                .contentShape(Circle())
                        }
                    }
                }
                .matchedTransitionSource(id: "mainProfile", in: hero)
                .contextMenu {
                    Button {
                        showSettings = true
                    } label: {
                        Label("Settings", systemImage: "gear")
                    }
                }
                .shadow(color: .gray, radius: 4)
                .overlay(alignment: .bottomTrailing){
                    if popRoot.unSeenProfileCheckouts > 0 {
                        Text("\(popRoot.unSeenProfileCheckouts)")
                            .font(.caption2).bold().padding(6).background(.red).clipShape(Circle())
                            .offset(x: 4, y: 4)
                    }
                }
                
                Spacer()
                
                Menu {
                    Button {
                        filterImage = "person"
                        filter = "Owned Tools"
                    } label: {
                        Label("Owned Tools", systemImage: "person")
                    }
                    Divider()
                    Button {
                        filterImage = "xmark"
                        filter = "No filter"
                    } label: {
                        Label("No filter", systemImage: "xmark")
                    }
                } label: {
                    ZStack {
                        Rectangle()
                            .foregroundStyle(.gray).opacity(0.001).frame(width: 40, height: 40)
                        HStack(spacing: 4){
                            Image(systemName: filter == "No filter" ? "line.3.horizontal.decrease" : filterImage)
                                .font(.title3)
                            Image(systemName: "chevron.down").font(.headline)
                        }
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                    }
                }
            }
        }
        .padding(.top, top_Inset()).padding(.horizontal).padding(.bottom, 10)
        .background {
            TransparentBlurView(removeAllFilters: true).blur(radius: 14, opaque: true)
        }
    }
    @ViewBuilder
    func createView() -> some View {
        VStack(spacing: 0){
            Image("WealthBlur")
                .resizable().scaledToFill()
                .frame(height: 100).blur(radius: 6)
                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 12, topTrailingRadius: 12))
                .contentShape(UnevenRoundedRectangle(topLeadingRadius: 12, topTrailingRadius: 12))
                .overlay(alignment: .bottomTrailing){
                    Image("WealthBlur")
                        .resizable().scaledToFill()
                        .frame(width: 70, height: 70)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .contentShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(content: {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.gray, lineWidth: 1).opacity(0.6)
                        })
                        .overlay(content: {
                            Image(systemName: "hammer.fill").font(.title3)
                        })
                        .offset(y: 36).padding(.trailing, 20)
                }
            
            HStack(alignment: .top){
                Text("Create Tools").font(.title2).bold()
                Spacer()
            }.padding(.horizontal, 10).padding(.top, 10)
            
            VStack(alignment: .leading, spacing: 7){
                HStack(spacing: 2){
                    Text("-").font(.system(size: 13)).bold().foregroundStyle(.blue)
                    Text("Build tools and get paid a Royalty.")
                        .multilineTextAlignment(.leading).font(.system(size: 13))
                    Spacer()
                }
                HStack(spacing: 2){
                    Text("-").font(.system(size: 13)).bold().foregroundStyle(.blue)
                    Text("Contact us for any proposals.")
                        .multilineTextAlignment(.leading).font(.system(size: 13))
                    Spacer()
                }
            }.padding(.horizontal, 10).padding(.top, 10).padding(.bottom, 10)
        }
        .background(content: {
            TransparentBlurView(removeAllFilters: true)
                .blur(radius: 14, opaque: true)
                .background(colorScheme == .dark ? .black.opacity(0.4) : .white.opacity(0.4))
        })
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .overlay(content: {
            RoundedRectangle(cornerRadius: 12)
                .stroke(lineWidth: 1).opacity(0.4)
        })
        .onTapGesture {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            showContact = true
        }.padding(.horizontal, 12)
    }
}

struct ToolRowView: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var popRoot: PopToRoot
    @Environment(\.colorScheme) var colorScheme
    
    var type: Int
    var image: String
    var title: String
    var points: [String]
    var owned: Bool
    var price: String
    
    @Binding var sentTotal: Int
    @Binding var isShowingMessages: Bool
    
    @Binding var showBuySheet: Bool
    @Binding var buyImage: String
    @Binding var buyTitle: String
    @Binding var buyPoints: [String]
    @Binding var buyPrice: Double
    @Binding var sheetID: Bool
    
    var body: some View {
        VStack(spacing: 0){
            Image(image == "WealthAccounts" ? "WealthAccountsWide" : image == "Proxies" ? "ProxiesName" : image)
                .resizable().scaledToFill()
                .frame(height: 100).blur(radius: 6)
                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 12, topTrailingRadius: 12))
                .contentShape(UnevenRoundedRectangle(topLeadingRadius: 12, topTrailingRadius: 12))
                .overlay(alignment: .topLeading){
                    VStack(alignment: .leading, spacing: 3){
                        if type == 12 || type == 14 || type == 16 || type == 17 || type == 19 || type == 21 {
                            Text("One Time: \(price)")
                                .fontWeight(.heavy).font(.subheadline)
                                .padding(.horizontal, 10).padding(.vertical, 4)
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule()).padding(.leading, 10).padding(.top, 10)
                        } else if type == -1 || type == -4 {
                            Text("Pay as you go")
                                .fontWeight(.heavy).font(.subheadline)
                                .padding(.horizontal, 10).padding(.vertical, 4)
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule()).padding(12)
                        } else if type == -2 {
                            Text("Monthly")
                                .fontWeight(.heavy).font(.subheadline)
                                .padding(.horizontal, 10).padding(.vertical, 4)
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule()).padding(.leading, 10).padding(.top, 10)
                        } else if owned {
                            Text("Owned")
                                .fontWeight(.heavy).font(.subheadline)
                                .padding(.horizontal, 10).padding(.vertical, 4)
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule()).padding(.leading, 10).padding(.top, 10)
                        } else if type == 0 || type == -3 {
                            Text("Monthly: \(price)")
                                .fontWeight(.heavy).font(.subheadline)
                                .padding(.horizontal, 10).padding(.vertical, 4)
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule()).padding(.leading, 10).padding(.top, 10)
                        } else {
                            Text("Lifetime: \(price)")
                                .fontWeight(.heavy).font(.subheadline)
                                .padding(.horizontal, 10).padding(.vertical, 4)
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule()).padding(.leading, 10).padding(.top, 10)
                        }
                        
                        if let sold = getSold(image: image) {
                            Text("\(sold) bought")
                                .bold().font(.subheadline)
                                .padding(.horizontal, 10).padding(.vertical, 4)
                                .background(.ultraThinMaterial)
                                .background(Color.blue.opacity(0.2))
                                .clipShape(Capsule()).padding(.leading, 10)
                        }
                        Spacer()
                    }
                }
                .overlay(alignment: .bottomTrailing){
                    Image(image)
                        .resizable().scaledToFill()
                        .frame(width: 70, height: 70)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .contentShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(content: {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.gray, lineWidth: 1).opacity(0.6)
                        })
                        .offset(y: 36).padding(.trailing, 20)
                }
            
            HStack(alignment: .top){
                Text(title).font(.title2).bold()
                Spacer()
            }.padding(.horizontal, 10).padding(.top, 10)
            
            VStack(alignment: .leading, spacing: 7){
                if type == -4 {
                    ForEach(points, id: \.self) { item in
                        HStack(spacing: 2){
                            Text("-").font(.system(size: 13)).bold().foregroundStyle(.blue)
                            
                            Text(item).multilineTextAlignment(.leading).font(.system(size: 13))
                            
                            Spacer()
                        }
                    }
                    
                    HStack(spacing: 2){
                        Button {
                            if let url = URL(string: "https://discord.gg/account-vault") {
                                DispatchQueue.main.async {
                                    UIApplication.shared.open(url)
                                }
                            }
                        } label: {
                            Text("Join Discord")
                                .font(.subheadline).bold()
                                .padding(.horizontal, 10).padding(.vertical, 6)
                                .background(Color.babyBlue)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(color: .gray, radius: 3)
                        }.buttonStyle(.plain)

                        Spacer()
                    }
                } else if type == 0 && owned {
                    HStack(spacing: 2){
                        Button {
                            if let url = URL(string: "https://discord.gg/UMYeDWpkf4") {
                                DispatchQueue.main.async {
                                    UIApplication.shared.open(url)
                                }
                            }
                        } label: {
                            Text("Join Discord")
                                .font(.subheadline).bold()
                                .padding(.horizontal, 10).padding(.vertical, 6)
                                .background(Color.babyBlue)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(color: .gray, radius: 3)
                        }.buttonStyle(.plain)

                        Spacer()
                    }
                } else {
                    ForEach(points, id: \.self) { item in
                        HStack(spacing: 2){
                            Text("-").font(.system(size: 13)).bold().foregroundStyle(.blue)
                            
                            Text(item).multilineTextAlignment(.leading).font(.system(size: 13))
                            
                            Spacer()
                        }
                    }
                }
                if !owned && type == 9 {
                    HStack(spacing: 2){
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            isShowingMessages = true
                        } label: {
                            Text("Invite \(10 - sentTotal) Friends for Free Access")
                                .font(.subheadline).bold()
                                .padding(.horizontal, 10).padding(.vertical, 6)
                                .background(Color.babyBlue)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(color: .gray, radius: 3)
                        }.buttonStyle(.plain)

                        Spacer()
                    }
                }
            }.padding(.horizontal, 10).padding(.top, 10).padding(.bottom, 10)
        }
        .background(content: {
            TransparentBlurView(removeAllFilters: true)
                .blur(radius: 14, opaque: true)
                .background(colorScheme == .dark ? .black.opacity(0.4) : .white.opacity(0.4))
        })
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .overlay(content: {
            RoundedRectangle(cornerRadius: 12)
                .stroke(lineWidth: 1).opacity(0.4)
        })
        .onTapGesture {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            
            if type == -3 { // Wealth Scale
                if auth.currentUser?.hasBotAccess ?? false {
                    if let url = URL(string: "https://WealthAIO.com") {
                        DispatchQueue.main.async {
                            UIApplication.shared.open(url)
                        }
                    }
                } else {
                    popRoot.presentAlert(image: "exclamationmark.bubble",
                                         text: "You must first own Wealth AIO to access Scale.")
                }
            } else if type == -2 { // Wealth Servers
                if let url = URL(string: "https://discord.gg/wealthproxies") {
                    DispatchQueue.main.async {
                        UIApplication.shared.open(url)
                    }
                }
            } else if type == -1 {  // Wealth proxies
                if let url = URL(string: "https://discord.gg/wealthproxies") {
                    DispatchQueue.main.async {
                        UIApplication.shared.open(url)
                    }
                }
            } else if type == -4 {  // Wealth Accounts
                if let url = URL(string: "https://discord.gg/account-vault") {
                    DispatchQueue.main.async {
                        UIApplication.shared.open(url)
                    }
                }
            } else if type == 0 {   // Wealth AIO
                if auth.currentUser?.hasBotAccess ?? false {
                    popRoot.presentAlert(image: "checkmark", text: "You already own this!")
                } else if popRoot.botInStock {
                    if let url = URL(string: "https://WealthAIO.com") {
                        DispatchQueue.main.async {
                            UIApplication.shared.open(url)
                        }
                    }
                } else if popRoot.joinedWaitlist {
                    popRoot.presentAlert(image: "exclamationmark.bubble",
                                         text: "This product is OOS, you are already on the waitlist.")
                } else {
                    popRoot.presentAlert(image: "exclamationmark.bubble",
                                         text: "This product is OOS, we have added you to the waitlist.")
                    popRoot.joinedWaitlist = true
                    if let email = auth.currentUser?.email {
                        UserService().joinWaitlist(email: email)
                    }
                }
            } else if type == 1 {
                if owned {
                    popRoot.presentAlert(image: "exclamationmark.bubble",
                                         text: "You already own this. Contact us for help.")
                } else {
                    buyImage = image
                    buyTitle = title
                    buyPoints = forwardProPointsBuy
                    buyPrice = 149.99
                    
                    showBuySheet = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                        sheetID.toggle()
                    }
                }
            } else if type == 2 {
                if owned {
                    popRoot.presentAlert(image: "exclamationmark.bubble",
                                         text: "You already own this. Contact us for help.")
                } else {
                    buyImage = image
                    buyTitle = title
                    buyPoints = forwardLitePointsBuy
                    buyPrice = 99.99
                    
                    showBuySheet = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                        sheetID.toggle()
                    }
                }
            } else if type == 3 {
                if owned {
                    popRoot.presentAlert(image: "exclamationmark.bubble",
                                         text: "You already own this. Contact us for help.")
                } else {
                    buyImage = image
                    buyTitle = title
                    buyPoints = csvProPointsBuy
                    buyPrice = 149.99
                    
                    showBuySheet = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                        sheetID.toggle()
                    }
                }
            } else if type == 4 {
                if owned {
                    popRoot.presentAlert(image: "exclamationmark.bubble",
                                         text: "You already own this. Contact us for help.")
                } else {
                    buyImage = image
                    buyTitle = title
                    buyPoints = csvLitePointsBuy
                    buyPrice = 99.99
                    
                    showBuySheet = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                        sheetID.toggle()
                    }
                }
            } else if type == 5 {   // Stock checker
               if owned {
                   popRoot.presentAlert(image: "exclamationmark.bubble",
                                        text: "You already own this. Contact us for help.")
               } else {
                   buyImage = image
                   buyTitle = title
                   buyPoints = stockCheckerPointsBuy
                   buyPrice = 49.99
                   
                   showBuySheet = true
                   DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                       sheetID.toggle()
                   }
               }
           } else if type == 6 {    // variant scraper
               if owned {
                   popRoot.presentAlert(image: "exclamationmark.bubble",
                                        text: "You already own this. Contact us for help.")
               } else {
                   buyImage = image
                   buyTitle = title
                   buyPoints = variantPointsBuy
                   buyPrice = 99.99
                   
                   showBuySheet = true
                   DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                       sheetID.toggle()
                   }
               }
           } else if type == 7 {    // in app queue
               if owned {
                   popRoot.presentAlert(image: "exclamationmark.bubble",
                                        text: "You already own this. Contact us for help.")
               } else {
                   buyImage = image
                   buyTitle = title
                   buyPoints = inAppQPointsBuy
                   buyPrice = 39.99
                   
                   showBuySheet = true
                   DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                       sheetID.toggle()
                   }
               }
           } else if type == 8 {    // discord queue
               if owned {
                   popRoot.presentAlert(image: "exclamationmark.bubble",
                                        text: "You already own this. Contact us for help.")
               } else {
                   buyImage = image
                   buyTitle = title
                   buyPoints = discordQPointsBuy
                   buyPrice = 99.99
                   
                   showBuySheet = true
                   DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                       sheetID.toggle()
                   }
               }
           } else if type == 9 {
                if owned {
                    popRoot.presentAlert(image: "exclamationmark.bubble",
                                         text: "You already own this. Contact us for help.")
                } else {
                    buyImage = image
                    buyTitle = title
                    buyPoints = aiProfilePointsBuy
                    buyPrice = 29.99
                    
                    showBuySheet = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                        sheetID.toggle()
                    }
                }
            } else if type == 11 {
                if owned {
                    popRoot.presentAlert(image: "exclamationmark.bubble",
                                         text: "You already own this. Contact us for help.")
                } else {
                    buyImage = image
                    buyTitle = title
                    buyPoints = builderPointsBuy
                    buyPrice = 499.99
                    
                    showBuySheet = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                        sheetID.toggle()
                    }
                }
            } else if type == 12 {
                buyImage = image
                buyTitle = title
                buyPoints = bbPointsBuy
                buyPrice = 19.99
                
                showBuySheet = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                    sheetID.toggle()
                }
            } else if type == 13 {
                if owned {
                    popRoot.presentAlert(image: "exclamationmark.bubble",
                                         text: "You already own this. Contact us for help.")
                } else {
                    buyImage = image
                    buyTitle = title
                    buyPoints = nikeBuilderPointsBuy
                    buyPrice = 699.99
                    
                    showBuySheet = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                        sheetID.toggle()
                    }
                }
            } else if type == 14 {
                buyImage = image
                buyTitle = title
                buyPoints = nikeAccountPointsBuy
                buyPrice = 24.99
                
                showBuySheet = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                    sheetID.toggle()
                }
            } else if type == 15 {
                if owned {
                    popRoot.presentAlert(image: "exclamationmark.bubble",
                                         text: "You already own this. Contact us for help.")
                } else {
                    buyImage = image
                    buyTitle = title
                    buyPoints = pokemonBuilderPointsBuy
                    buyPrice = 469.99
                    
                    showBuySheet = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                        sheetID.toggle()
                    }
                }
            } else if type == 16 {
                buyImage = image
                buyTitle = title
                buyPoints = pokemonAccountPointsBuy
                buyPrice = 19.99
                
                showBuySheet = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                    sheetID.toggle()
                }
            } else if type == 17 {
                buyImage = image
                buyTitle = title
                buyPoints = popmartAccountPointsBuy
                buyPrice = 19.99
                
                showBuySheet = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                    sheetID.toggle()
                }
            } else if type == 18 {
                if owned {
                    popRoot.presentAlert(image: "exclamationmark.bubble",
                                         text: "You already own this. Contact us for help.")
                } else {
                    buyImage = image
                    buyTitle = title
                    buyPoints = costcoBuilderPointsBuy
                    buyPrice = 469.99
                    
                    showBuySheet = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                        sheetID.toggle()
                    }
                }
            } else if type == 19 {
                buyImage = image
                buyTitle = title
                buyPoints = costcoAccountPointsBuy
                buyPrice = 19.99
                
                showBuySheet = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                    sheetID.toggle()
                }
            } else if type == 20 {
                if owned {
                    popRoot.presentAlert(image: "exclamationmark.bubble",
                                         text: "You already own this. Contact us for help.")
                } else {
                    buyImage = image
                    buyTitle = title
                    buyPoints = uberBuilderPointsBuy
                    buyPrice = 469.99
                    
                    showBuySheet = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                        sheetID.toggle()
                    }
                }
            } else if type == 21 {
                buyImage = image
                buyTitle = title
                buyPoints = uberAccountPointsBuy
                buyPrice = 19.99
                
                showBuySheet = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                    sheetID.toggle()
                }
            }
        }
        .padding(.horizontal, 12)
    }
    func getSold(image: String) -> Int? {
        if let item = popRoot.soldQuantities {
            if image == "CsvLite" {
                return item.CsvLite
            } else if image == "CsvPro" {
                return item.CsvPro
            } else if image == "WealthIcon" {
                return item.WealthIcon
            } else if image == "aiLogo" {
                return item.aiLogo
            } else if image == "forwardLite" {
                return item.forwardLite
            } else if image == "forwardPro" {
                return item.forwardPro
            } else if image == "builder" {
                return item.builder
            } else if image == "variantScraper" {
                return item.variantScraper
            } else if image == "qApp" {
                return item.qApp
            } else if image == "qDiscord" {
                return item.qDiscord
            } else if image == "stockChecker" {
                return item.stockChecker
            } else if image == "pokemonBuilder" {
                return item.pokemonBuilder
            } else if image == "nikeBuilder" {
                return item.nikeBuilder
            } else if image == "costco" {
                return item.costcoBuilder
            } else if image == "uber1" {
                return item.uberBuilder
            }
        }
        
        return nil
    }
}

protocol MessagessViewDelegate {
    func messageCompletion (result: MessageComposeResult)
}

class MessagesViewController: UIViewController, MFMessageComposeViewControllerDelegate {
    var delegate: MessagessViewDelegate?
    var recipients: [String]?
    var body: String?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func displayMessageInterface() {
        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = self

        // Configure the fields of the interface.
        composeVC.recipients = self.recipients ?? []
        composeVC.body = body ?? ""

        // Present the view controller modally.
        if MFMessageComposeViewController.canSendText() {
            self.present(composeVC, animated: true, completion: nil)
        } else {
            self.delegate?.messageCompletion(result: MessageComposeResult.failed)
        }
    }

    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true)
        self.delegate?.messageCompletion(result: result)
    }
}

struct MessageUIView: UIViewControllerRepresentable {
    // To be able to dismiss itself after successfully finishing with the MessagesUI
    @Environment(\.presentationMode) var presentationMode
    @Binding var recipients: [String]
    @Binding var body: String
    var completion: ((_ result: MessageComposeResult) -> Void)

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> MessagesViewController {
        let controller = MessagesViewController()
        controller.delegate = context.coordinator
        controller.recipients = recipients
        controller.body = body
        return controller
    }

    func updateUIViewController(_ uiViewController: MessagesViewController, context: Context) {
        uiViewController.recipients = recipients
        uiViewController.displayMessageInterface()
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, MessagessViewDelegate {
        var parent: MessageUIView

        init(_ controller: MessageUIView) {
            self.parent = controller
        }

        func messageCompletion(result: MessageComposeResult) {
            self.parent.presentationMode.wrappedValue.dismiss()
            self.parent.completion(result)
        }
    }
}

let wealthAioPoints = ["A heavy duty automation tool, made simple."]

let wealthAccountsPoints = ["All the accounts you need."]

let wealthScalePoints = [
    "Scale your Wealth setup with ease.",
    "Control upto 6 Instances from your iPhone.",
    "The best AIO Scale tool available now"
]

let wealthProxyPoints = ["Fastest ISP/Residential proxy provider.",
                         "Instant delivery with 24/7 uptime.",
                         "Hosted in a private pool of 50+ million IPs.",
                         "Cheap prices, click to learn more."
]

let wealthServerPoints = ["Wealth Servers offer 24/7 reliability.",
                         "Cutting-edge AMD EPYC 2022 processors.",
                         "Unlimited bandwidth for seamless operations."
]

let aiProfilePoints = ["Build Instant Profiles with Wealth AI.",
                       "Automated delivery to your Wealth AIO server.",
                       "Upto 500 unique profiles created in seconds."
]

let forwardProPoints = ["Forward Discord messages from unlimited channels.",
                        "Supports 13 top bot brands.",
                        "Auto-tags in Success and DM's users."]

let forwardLitePoints = ["Forward Discord messages to Success Channel.",
                         "Tags and DM's users with manual setup.",
                         "Supports 9 top bot brands."]

let csvProPoints = ["Scrape unlimited Discord channels to make a CSV.",
                    "Channels support any bot type.",
                    "Supports 13 major bot brands."]

let csvLitePoints = ["Scrape Discord for checkouts to make a CSV.",
                     "Each Channel supports 1 bot type.",
                     "Supports 9 major bot brands."]

let stockPoints = ["Monitor Shopify sites for inventory updates.",
                   "Automated Discord stock alerts."]

let variantPoints = ["Scrape Shopify sites to get variants for speed.",
                     "New site support added regularly."]

let inAppQPoints = ["In-App Queue checker helps you start tasks on time.",
                    "Track up to 20 queues in one place with 1 click."]

let discordQPoints = ["Track Shopify queues via Discord.",
                      "Fast automated updates keep you informed."]

let builderPoints = [
    "Build infinite Best Buy accounts.",
    "Automate account creation in seconds.",
    "Supports IMAP, Catchall, and more!"
]

let bbPoints = [
    "You get a bundle of 50 BB accounts",
    "Clean accounts instantly created for you.",
    "Supports IMAP, Catchall, and more!"
]

let bbPointsBuy = [
    "Obtain a list of 50 clean Best Buy accounts in minutes.",
    "Specify how you want your accounts built (email list, catch-all, or random).",
    "You can even provide us with an email list to use.",
    "We will immediately begin creating your accounts.",
    "100% guaranteed to work with no issues."
]

let builderPointsBuy = [
    "Build infinite Best Buy accounts in minutes from your computer.",
    "Provide your own emails for account generation, such as IMAP emails, or use a catch-all domain.",
    "Optionally use randomly generated emails for your accounts.",
    "This service works flawlessly on any computer.",
    "Includes proxy support for account creation.",
    "Adjust build speed based on your computer's capabilities.",
    "Lifetime maintenance and support provided by our development team."
]

let forwardProPointsBuy = [
    "Forward AIO Discord checkout messages from unlimited channels in any server to an ACO success channel.",
    "Auto-tags users based on profile names in success messages.",
    "Automatically matches Discord users based on profile names to send direct messages for checkouts (includes order number and link).",
    "Lifetime maintenance and support by our development team.",
    "No downtime, hosted on your own servers.",
    "Easy setup with a full tutorial, usually takes 10 minutes.",
    "Customizable Discord embed colors, titles, and images.",
    "Historically, this bot has forwarded almost every checkout webhook.",
    "Fast Mode toggle to support high checkout volumes during big releases.",
    "Supports 14 top bot brands, including Wealth AIO, Valor, Cybersole, Alpine, Makebot, Swft 3, Refract (Prism), Stellar, Hahya, Nexar, Bookie Bandit, NSB, Enven, and Taranius."
]

let forwardLitePointsBuy = [
    "Forward AIO Discord checkout messages from 10 channels to an ACO success channel.",
    "Tags users based on profile names in success messages (requires manual setup).",
    "Sends Discord direct messages for checkouts (requires manual setup).",
    "Lifetime maintenance and support by our development team.",
    "No downtime, hosted on your own servers.",
    "Easy setup with a full tutorial, usually takes 10 minutes.",
    "Customizable Discord embed colors, titles, and images.",
    "Historically, this bot has forwarded almost every checkout webhook.",
    "Fast Mode toggle to support high checkout volumes during big releases.",
    "Supports 10 top bot brands, including Wealth AIO, Valor, Cybersole, Alpine, Makebot, Swft 3, Refract (Prism), Stellar, Hahya, and Taranius."
]

let csvProPointsBuy = [
    "Scrape unlimited Discord channels for AIO Discord checkout messages to generate a CSV file with order details.",
    "Each channel can include up to 14 different types of AIO solutions. This product automatically classifies the message type to scrape the correct order details.",
    "Scrape as many channels as you want, easily customizable with a JSON file.",
    "Interactive bot that asks how many days to scrape.",
    "Eliminates the need to manually go through Discord channels to create lists or calculate PAS fees.",
    "The outputted CSV file contains columns for: Message Time, Message Channel, Order Number, Order Link, Profile Used, Size, Product Name, Site, and Discord User UID.",
    "Supports 14 top bot brands, including Wealth AIO, Valor, Cybersole, Alpine, Makebot, Swft 3, Refract (Prism), Stellar, Hahya, Nexar, Bookie Bandit, NSB, Enven, and Taranius.",
    "Lifetime maintenance and support by our development team."
]

let csvLitePointsBuy = [
    "Scrape up to 10 Discord channels for AIO Discord checkout messages to generate a CSV file with order details.",
    "Each channel can include only one type of bot webhook (no overlap).",
    "Interactive bot that asks how many days to scrape.",
    "Eliminates the need to manually go through Discord channels to create lists or calculate PAS fees.",
    "The outputted CSV file contains columns for: Message Time, Message Channel, Order Number, Order Link, Profile Used, Size, Product Name, Site, and Discord User UID.",
    "Supports 10 top bot brands, including Wealth AIO, Valor, Cybersole, Alpine, Makebot, Swft 3, Refract (Prism), Stellar, Hahya, and Taranius.",
    "Lifetime maintenance and support by our development team."
]

let aiProfilePointsBuy = [
    "Generate up to 500 instant profiles with Wealth AI.",
    "Automated delivery to your Wealth AIO server, plus the ability to export profiles anywhere.",
    "Answer a few short questions to customize your profiles.",
    "Our AI is trained to 'jig' your profiles in three different modes: no jig, moderate jig, and heavy jig.",
    "Never spend time creating profiles again—this tool lets you build unique profiles in seconds.",
    "Enjoy lifetime maintenance and support from our development team."
]

let stockCheckerPointsBuy = [
    "Monitors Shopify sites for inventory updates.",
    "Sends Discord webhook messages to keep you informed.",
    "This tool is easily customizable to fit your needs.",
    "This software scrapes stock inventory counts for live items on Shopify.",
    "A small number of sites are not supported.",
    "Lifetime maintenance and support provided by our development team."
]

let variantPointsBuy = [
    "Scrapes Shopify sites to get variants quickly.",
    "Sends automated Discord webhook messages to your channels.",
    "This tool is easily customizable and can be used as an item monitor.",
    "All Shopify sites supported!",
    "Items must be loaded for this software to work.",
    "Lifetime maintenance and support provided by our development team."
]

let inAppQPointsBuy = [
    "In-app queue checker helps you start tasks on time.",
    "Open up to 20 queue monitors at the same time from the Wealth iOS app!",
    "User-friendly UI displays live queue times.",
    "Track up to 20 queues in one place with one click.",
    "Never miss another drop because of long queues.",
    "Lifetime maintenance and support provided by our development team."
]

let discordQPointsBuy = [
    "Tracks Shopify queues via Discord.",
    "This software sends fast Discord webhook alerts for the sites you pick.",
    "Supports all Shopify stores!",
    "Track as many queues as you want simultaneously.",
    "Fast, automated updates keep you informed.",
    "Never miss another drop because of long queues.",
    "Lifetime maintenance and support provided by our development team."
]

let nikeBuilderPoints = [
    "Build infinite Nike accounts.",
    "Automate account creation in seconds.",
    "Supports IMAP, Catchall, and more!"
]

let nikeAccountPoints = [
    "You get a bundle of 50 Nike accounts",
    "Clean accounts instantly created for you.",
    "Supports IMAP, Catchall, and more!"
]

let nikeAccountPointsBuy = [
    "Obtain a list of 50 clean Nike accounts in minutes.",
    "Specify how you want your accounts built (email list, catch-all, or random).",
    "You can even provide us with an email list to use.",
    "We will immediately begin creating your accounts.",
    "100% guaranteed to work with no issues."
]

let nikeBuilderPointsBuy = [
    "Build infinite Nike accounts in minutes from your computer.",
    "Provide your own emails for account generation, such as IMAP emails, or use a catch-all domain.",
    "Optionally use randomly generated emails for your accounts.",
    "This service works flawlessly on any computer.",
    "Includes proxy support for account creation.",
    "Adjust build speed based on your computer's capabilities.",
    "Lifetime maintenance and support provided by our development team."
]

let pokemonBuilderPoints = [
    "Build infinite Pokemon accounts.",
    "Automate account creation in seconds.",
    "Supports Emails, Catchall, and more!"
]

let pokemonAccountPoints = [
    "You get a bundle of 50 Pokemon accounts",
    "Clean accounts instantly created for you."
]

let pokemonAccountPointsBuy = [
    "Obtain a list of 50 clean Pokemon accounts in minutes.",
    "Specify how you want your accounts built (email list, catch-all, or random).",
    "You can even provide us with an email list to use.",
    "We will immediately begin creating your accounts.",
    "100% guaranteed to work with no issues."
]

let pokemonBuilderPointsBuy = [
    "Build infinite Pokemon accounts in minutes from your computer.",
    "Provide your own emails for account generation, such as iCloud HME, or use a catch-all domain.",
    "Optionally use randomly generated emails for your accounts.",
    "This service works flawlessly on any computer.",
    "Includes proxy support for account creation.",
    "Adjust build speed based on your computer's capabilities.",
    "Lifetime maintenance and support provided by our development team."
]

let popmartAccountPoints = [
    "You get a bundle of 50 Popmart accounts",
    "Clean accounts instantly created for you."
]

let popmartAccountPointsBuy = [
    "Obtain a list of 50 clean Popmart accounts in minutes.",
    "Specify how you want your accounts built (email list, catch-all, or random).",
    "You can even provide us with an email list to use.",
    "We will immediately begin creating your accounts.",
    "100% guaranteed to work with no issues."
]

let costcoBuilderPoints = [
    "Build infinite Costco accounts.",
    "Automate account creation in seconds."
]

let costcoAccountPoints = [
    "You get a bundle of 50 Costco accounts",
    "Clean accounts instantly created for you."
]

let costcoAccountPointsBuy = [
    "Obtain a list of 50 clean Costco accounts in minutes.",
    "Specify how you want your accounts built (email list, catch-all, or random).",
    "You can even provide us with an email list to use.",
    "We will immediately begin creating your accounts.",
    "100% guaranteed to work with no issues."
]

let costcoBuilderPointsBuy = [
    "Build infinite Costco accounts in minutes from your computer.",
    "Provide your own emails for account generation, such as IMAP emails, or use a catch-all domain.",
    "Optionally use randomly generated emails for your accounts.",
    "This service works flawlessly on any computer.",
    "Includes proxy support for account creation.",
    "Adjust build speed based on your computer's capabilities.",
    "Lifetime maintenance and support provided by our development team."
]

let uberBuilderPoints = [
    "Build infinite UberEats accounts.",
    "Automate account creation in seconds."
]

let uberAccountPoints = [
    "You get a bundle of 50 UberEats accounts",
    "Clean accounts instantly created for you."
]

let uberAccountPointsBuy = [
    "Obtain a list of 50 clean UberEats accounts in minutes.",
    "Specify how you want your accounts built (email list or catch-all).",
    "You can even provide us with an email list to use.",
    "We will immediately begin creating your accounts.",
    "100% guaranteed to work with no issues."
]

let uberBuilderPointsBuy = [
    "Build infinite UberEats accounts in minutes from your computer.",
    "Provide your own emails for account generation, such as IMAP emails, or use a catch-all domain.",
    "Optionally use randomly generated emails for your accounts.",
    "This service works flawlessly on any computer.",
    "Includes proxy support for account creation.",
    "Adjust build speed based on your computer's capabilities.",
    "Lifetime maintenance and support provided by our development team."
]
