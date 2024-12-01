import SwiftUI

struct InfoSheet: View {
    @State private var tabs: [TabModel2] = [
        .init(id: "General"),
        .init(id: "Task"),
        .init(id: "Profile"),
        .init(id: "Proxy"),
        .init(id: "Account"),
    ]
    @State private var activeTab: String = "General"
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            TabView(selection: $activeTab) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 15){
                        general()
                        Color.clear.frame(height: 100)
                    }.padding(.horizontal).safeAreaPadding(.top, 130)
                }
                .scrollIndicators(.hidden).tag("General")
                .frame(width: size.width, height: size.height)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 15){
                        task()
                        Color.clear.frame(height: 100)
                    }.padding(.horizontal).safeAreaPadding(.top, 130)
                }
                .scrollIndicators(.hidden).tag("Task")
                .frame(width: size.width, height: size.height)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 15){
                        profile()
                        Color.clear.frame(height: 100)
                    }.padding(.horizontal).safeAreaPadding(.top, 130)
                }
                .scrollIndicators(.hidden).tag("Profile")
                .frame(width: size.width, height: size.height)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 15){
                        proxy()
                    }.padding(.horizontal).safeAreaPadding(.top, 130)
                }
                .scrollIndicators(.hidden).tag("Proxy")
                .frame(width: size.width, height: size.height)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 15){
                        account()
                    }.padding(.horizontal).safeAreaPadding(.top, 130)
                }
                .scrollIndicators(.hidden).tag("Account")
                .frame(width: size.width, height: size.height)
            }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .background {
            backColor()
        }
        .overlay(alignment: .top) {
            headerView()
        }
        .presentationDetents([.large])
        .presentationCornerRadius(30)
        .presentationDragIndicator(.hidden)
    }
    @ViewBuilder
    func general() -> some View {
        VStack(alignment: .leading, spacing: 15){
            HStack {
                Text("Setup").font(.title).bold().underline()
                Spacer()
            }
            
            (Text("- ").foregroundStyle(.blue).bold()
             + Text("Start off by creating a Wealth AIO membership ")
             + Text("here.").foregroundStyle(.blue).bold()
             + Text(" You should use your app login to sign into the dashboard.")
            )
            .font(.subheadline)
            .onTapGesture {
                if let url = URL(string: "https://wealthaio.com") {
                    DispatchQueue.main.async {
                        UIApplication.shared.open(url, completionHandler: nil)
                    }
                }
            }
            
            (Text("- ").foregroundStyle(.blue).bold()
             + Text("After creating a AIO membership, download the correct file from the dashboard based on your operating system. We recommend purchasing a Wealth Server to host our software; this will improve uptime and boost the software's performance.")
            )
            .font(.subheadline)
            
            (Text("- ").foregroundStyle(.blue).bold()
             + Text("Once downloaded you will see an executable file named 'Wealth' along with 5 folders and 3 text files. To run the software simply click on the executable file and wait for it to start.")
            )
            .font(.subheadline)
            
            (Text("- ").foregroundStyle(.blue).bold()
             + Text("Among the 3 text files, you will see `SuccessHook` and `FailureHook`. These are simply Discord channels that the software will message in to report checkouts or failures. These files are optional but we recommend adding in a webhook to each. You can create a webhook by going to 'Channel Settings' then 'Integrations'. Once you generate a webhook url, insert it between the quotes in the text file.")
            )
            .font(.subheadline)
            
            (Text("- ").foregroundStyle(.blue).bold()
             + Text("The file 'CapSolverKey' is required if you plan to use any Shopify site. You can generate a key from the Cap Solver dashboard. Additionally you must have a positive balance for the key to work. We recommend adding $10 to your balance.")
            )
            .font(.subheadline)
            
            
            (Text("- ").foregroundStyle(.blue).bold()
             + Text("If you ever plan on using the Nike module then you MUST include IMAP credentials in the 'IMAP.json' file. These IMAP credntials should correlate to the Nike accounts you are using. If you are not using the Nike module then just keep the username and password empty strings in the json file.")
            )
            .font(.subheadline)
            
            (Text("- ").foregroundStyle(.blue).bold()
             + Text("If you have the base Wealth membership with 1 instance then do not modify the 'Nickname.json' file. Please keep the nickname as 'Base' and the 'id' as 1")
            )
            .font(.subheadline)
        }
        .padding(10)
        .background(Color.gray.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        
        VStack(alignment: .leading, spacing: 15){
            HStack {
                Text("Intro").font(.title).bold().underline()
                Spacer()
            }
            
            (Text("- ").foregroundStyle(.blue).bold()
             + Text("The folder 'task' stores your task rules. This defines what products you want to buy, from which sites, and so on. Each task file MUST go into this directory as a .csv file. This file should NOT contain any sensitive info as it will be uploaded to our cloud. Note: task files are only read once when the software is turned on. You can use option '10' to tell the software to re-read the task folder; however the software will only look at NEW files in this folder.")
            )
            .font(.subheadline)
            
            (Text("- ").foregroundStyle(.blue).bold()
             + Text("The folder 'taskTemp' stores temporary task files (.csv) that are not yet complete. This is a good spot to define task files if you do not have product input, this will allow you to quickly insert task input (once available) and then drag the temporary file to the main 'task' folder. Content in this folder will not be read by our software.")
            )
            .font(.subheadline)
            
            (Text("- ").foregroundStyle(.blue).bold()
             + Text("The folder 'profile' includes your personal information such as name, address, and card info. Profile files MUST go into this folder as .csv files. This will give our software the necessary data to purchase products on your behalf. This data will NEVER leave your device or be uploaded to our cloud. However the 'profileName' field will be stored in a database to allow Wealth iOS to do things like task creation.")
            )
            .font(.subheadline)
            
            (Text("- ").foregroundStyle(.blue).bold()
             + Text("The folder 'proxy' includes ISP/Residential proxies that you provide. This enables our software to pass geo-restrictions. These files should be text files. Each file should contain only 1 proxy on each line. ")
             + Text("We highly recommend using Wealth Proxies.").foregroundStyle(.blue).bold()
            )
            .font(.subheadline)
            .onTapGesture {
                if let url = URL(string: "https://discord.com/channels/1270754041684820132/1272181760230162443") {
                    DispatchQueue.main.async {
                        UIApplication.shared.open(url)
                    }
                }
            }
            
            (Text("- ").foregroundStyle(.blue).bold()
             + Text("The folder 'account' includes accounts you create for websites. These files should be text files and include 1 account per line. Each account must be in the format 'email:password'. We never store/export your account passwords anywhere and they will remain on your machine.")
            )
            .font(.subheadline)
        }
        .padding(10)
        .background(Color.gray.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12)).padding(.top, 15)
        
        VStack(alignment: .leading, spacing: 15){
            HStack {
                Text("Running the Software").font(.title).bold().underline()
                Spacer()
            }
            
            (Text("- ").foregroundStyle(.blue).bold()
             + Text("Simply click on the 'wealth' executable file to start the software. If successful you will see a 'Welcome back' message. To stop the software please use option 11. Never close the software by clicking 'X' on the terminal.")
            )
            .font(.subheadline)
            
            (Text("- ").foregroundStyle(.red).bold()
             + Text("If you encounter a message which reads 'Max Sessions...' then please reset your Wealth session from our website dashboard or from your Wealth iOS app settings.")
            )
            .font(.subheadline)
        }
        .padding(10)
        .background(Color.gray.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12)).padding(.top, 15)
    }
    @ViewBuilder
    func task() -> some View {
        VStack(alignment: .leading, spacing: 15){
            HStack {
                Text("Task Rules").font(.title).bold().underline()
                Spacer()
            }
            (Text("- ").foregroundStyle(.blue).bold()
             + Text("Each task group is a unique .csv file in the 'task' folder.")
            )
            .font(.subheadline)
            
            (Text("- ").foregroundStyle(.blue).bold()
             + Text("You can start the same task group multiple times, starting a task group the first time will normally start it. However starting it again and again will create duplicate task groups/files.")
            )
            .font(.subheadline)
            
            (Text("- ").foregroundStyle(.blue).bold()
             + Text("Each task group should be for only 1 unique website.")
            )
            .font(.subheadline)
            
            (Text("- ").foregroundStyle(.blue).bold()
             + Text("DO NOT include commas in any of the task fields, only use commas to seperate the task fields. Including commas in task fields will cause errors as the bot will not know how to parse your tasks.")
            )
            .font(.subheadline)
        }
        .padding(10)
        .background(Color.gray.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        
        VStack(alignment: .leading, spacing: 15){
            HStack {
                Text("Task Fields").font(.title).bold().underline()
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 5){
                (Text("- ").bold()
                 + Text("profileGroup").fontWeight(.heavy)
                )
                .font(.subheadline).foregroundStyle(.blue)
                
                Text("(string) Name of file in `profile` folder to use. (Don't include .csv extension)")
                    .font(.subheadline).padding(.leading, 8)
            }
            VStack(alignment: .leading, spacing: 5){
                (Text("- ").bold()
                 + Text("profileName: 2 options").fontWeight(.heavy)
                )
                .font(.subheadline).foregroundStyle(.blue)
                
                Text("- 'All' keyword: A task is created for every profile inside the assosiated profileGroup")
                    .font(.subheadline).padding(.leading, 8)
                Text("- Using a specific profile name creates 1 profile.")
                    .font(.subheadline).padding(.leading, 8)
            }
            VStack(alignment: .leading, spacing: 5){
                (Text("- ").bold()
                 + Text("proxyGroup: 2 options").fontWeight(.heavy)
                )
                .font(.subheadline).foregroundStyle(.blue)
                
                Text("- (string) Name of file in `proxy` folder to use. (Don't include .txt extension)")
                    .font(.subheadline).padding(.leading, 8)
                Text("- 'na': no proxy will be used, the local host will be used to make all requests (not recommended)")
                    .font(.subheadline).padding(.leading, 8)
            }
            VStack(alignment: .leading, spacing: 5){
                (Text("- ").bold()
                 + Text("accountGroup").fontWeight(.heavy)
                )
                .font(.subheadline).foregroundStyle(.blue)
                
                Text("Keep this empty if your not using accounts. If you would like to use accounts for your tasks, then the account file you insert into this field MUST include an entry (email) that corresponds to a profile (email) from the task's Profile group. If an account email does not match up to a profile email then the task will default to Guest checkout.")
                    .font(.subheadline).padding(.leading, 8)
            }
            VStack(alignment: .leading, spacing: 5){
                (Text("- ").bold()
                 + Text("input: 3 categories (You cannot mix input types)").fontWeight(.heavy)
                )
                .font(.subheadline).foregroundStyle(.blue)
                
                Text("- URL: full url of the item")
                    .font(.subheadline).padding(.leading, 8)
                Text("- Variants: (only numbers) (space seperated). When entering multiple variants for a single input, such as: '99999999 44444444 555555555' then 3 tasks will be made for this input, because there are 3 unique variants.")
                    .font(.subheadline).padding(.leading, 8)
                Text("- Keywords: You can use '-' to remove items from the search. For example 'Jordan -bogo' will search for items that contain 'Jordan' but not 'bogo'")
                    .font(.subheadline).padding(.leading, 8)
            }
            VStack(alignment: .leading, spacing: 5){
                (Text("- ").bold()
                 + Text("size: 2 options").fontWeight(.heavy)
                )
                .font(.subheadline).foregroundStyle(.blue)
                
                Text("- Random: size = 'Random' all sizes will be purchased, each task will be assigned to a random size")
                    .font(.subheadline).padding(.leading, 8)
                Text("- Using specific sizing (space seperated, case in-sensitive). Example: size = 'M L XL xxl'")
                    .font(.subheadline).padding(.leading, 8)
            }
            VStack(alignment: .leading, spacing: 5){
                (Text("- ").bold()
                 + Text("color: 2 options").fontWeight(.heavy)
                )
                .font(.subheadline).foregroundStyle(.blue)
                
                Text("- Random: color = 'Random' all colors will be purchased, each task will be assigned to a random color")
                    .font(.subheadline).padding(.leading, 8)
                Text("- Using a specific color (space seperated, case in-sensitive). Example: color = 'blue BLACK'")
                    .font(.subheadline).padding(.leading, 8)
            }
            VStack(alignment: .leading, spacing: 5){
                (Text("- ").bold()
                 + Text("site").fontWeight(.heavy)
                )
                .font(.subheadline).foregroundStyle(.blue)
                
                Text("(string url) that represents the base url for the target site. EX: www.mywebsite.com")
                    .font(.subheadline).padding(.leading, 8)
            }
            VStack(alignment: .leading, spacing: 5){
                (Text("- ").bold()
                 + Text("mode: 7 options").fontWeight(.heavy)
                )
                .font(.subheadline).foregroundStyle(.blue)
                
                (Text("- Preload: ").foregroundStyle(.red)
                + Text("The item has not yet released. expect a queue and protection.")
                 ).font(.subheadline).padding(.leading, 8)
                
                (Text("- Wait: ").foregroundStyle(.red)
                + Text("This kicks off tasks after a checkpoint goes up. Great in cases such where checkpoint is put up at the same time as release")
                ).font(.subheadline).padding(.leading, 8)
                
                (Text("- Normal: ").foregroundStyle(.red)
                + Text("Item currently available for purchase, possible protection, safe checkout flow (can be OOS)")
                ).font(.subheadline).padding(.leading, 8)
                
                (Text("- Fast: ").foregroundStyle(.red)
                + Text("Item currently available for purchase, no protection, fast checkout flow (can be OOS)")
                ).font(.subheadline).padding(.leading, 8)
                 
                (Text("- Flow: ").foregroundStyle(.red)
                + Text("Item is up on website (can be OOS)")
                ).font(.subheadline).padding(.leading, 8)
                 
                (Text("- Raffle: ").foregroundStyle(.red)
                + Text("Item is releasing through a raffle")
                ).font(.subheadline).padding(.leading, 8)
                  
                (Text("- Shockdrop: ").foregroundStyle(.red)
                + Text("Item randomly released with a raffle")
                ).font(.subheadline).padding(.leading, 8)
            }
            VStack(alignment: .leading, spacing: 5){
                (Text("- ").bold()
                 + Text("cartQuantity").fontWeight(.heavy)
                )
                .font(.subheadline).foregroundStyle(.blue)
                
                Text("(Positive Integer) The amount of units to add to cart per checkout. Defaults to 1. If this value is set to something greater than 1, then the bot will attempt to purchase `cartQuantity` units. If only 1 item remains in stock, but cartQty is set to 3 then the bot will checkout the one unit remaining.")
                    .font(.subheadline).padding(.leading, 8)
            }
            VStack(alignment: .leading, spacing: 5){
                (Text("- ").bold()
                 + Text("delay").fontWeight(.heavy)
                )
                .font(.subheadline).foregroundStyle(.blue)
                
                Text("(Positive Integer Millisecond) The interval in ms between each retry/monitor request. Default value is 3500 which represents 3.5 seconds")
                    .font(.subheadline).padding(.leading, 8)
            }
            VStack(alignment: .leading, spacing: 5){
                (Text("- ").bold()
                 + Text("Discount").fontWeight(.heavy)
                )
                .font(.subheadline).foregroundStyle(.blue)
                
                Text("Discount code for task to be applied during checkout. If no code then leave empty")
                    .font(.subheadline).padding(.leading, 8)
            }
            VStack(alignment: .leading, spacing: 5){
                (Text("- ").bold()
                 + Text("Max Buy Price").fontWeight(.heavy)
                )
                .font(.subheadline).foregroundStyle(.blue)
                
                Text("(positive whole number greater than 0) that represents the max item to buy each unit at. For example if this value is set to $150 then it will only buy the target item if it is $150 or less. If you do not want to have a max buy price keep this value at its default which is 99999.")
                    .font(.subheadline).padding(.leading, 8)
            }
            VStack(alignment: .leading, spacing: 5){
                (Text("- ").bold()
                 + Text("Max Buy Quantity").fontWeight(.heavy)
                )
                .font(.subheadline).foregroundStyle(.blue)
                
                Text("(positive whole number greater than 0): that represents the maximum number of units to check out. If the bot checks out `Max Buy Quantity` units, it will only attempt to shut down that task group. There is no guarentee that other tasks will not checkout. For example if `Max Buy Quantity` units are checked out at the same time task x submits its order, then its impossible to prevent task x from also checking out. Although the bot may still check out some extra units it will help prevent large over-checkouts. Although every task row will have its own `Max Buy Quantity` value, only the very first task's `Max Buy Quantity` will be considered for the whole task group. So if the very first row in your task file has **20** for this value, then the entire task group will attempt to terminate after 20 checkouts. If you want to ignore this value then keep it as the default, which is 20000")
                    .font(.subheadline).padding(.leading, 8)
            }
        }
        .padding(10)
        .background(Color.gray.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    @ViewBuilder
    func profile() -> some View {
        VStack(alignment: .leading, spacing: 15){
            HStack {
                Text("Profile Rules").font(.title).bold().underline()
                Spacer()
            }
            
            (Text("- ").foregroundStyle(.blue).bold()
             + Text("Each profile file should go in the 'profile' folder which should only contain .csv profile documents")
            )
            .font(.subheadline)
            (Text("- ").foregroundStyle(.blue).bold()
             + Text("Credit Card Exp Month must be in format: 'MM'")
            )
            .font(.subheadline)
            (Text("- ").foregroundStyle(.blue).bold()
             + Text("Credit Card Exp Yeear must be in format: 'YY'")
            )
            .font(.subheadline)
            (Text("- ").foregroundStyle(.blue).bold()
             + Text("Don't use the full state named such as 'Oregon', instead used the capitilized prefix such as 'OR'")
            )
            .font(.subheadline)
            (Text("- ").foregroundStyle(.blue).bold()
             + Text("Don't use your countries full name such as 'United States', instead use the capitilized prefix such as 'US'")
            )
            .font(.subheadline)
            (Text("- ").foregroundStyle(.blue).bold()
             + Text("The last 8 fields that begin with 'billing' are optional. Leave these as 'na' to use the same billing as shipping.")
            )
            .font(.subheadline)
            (Text("- ").foregroundStyle(.blue).bold()
             + Text("DO NOT include commas in any of the profile fields, only use commas to seperate the profile fields. Including commas in profile fields will cause errors as the bot will not know how to parse your profile.")
            )
            .font(.subheadline)
        }
        .padding(10)
        .background(Color.gray.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        
        VStack(alignment: .leading, spacing: 15){
            HStack {
                Text("Ai Profile +").font(.title).bold().underline()
                Spacer()
            }
            
            (Text("- ").foregroundStyle(.blue).bold()
             + Text("After you purchase this product from the 'Tools' page, you can access it by navigating to the 'AI' tab. Clicking on the purple button will open the profile builder.")
            )
            .font(.subheadline)

            (Text("- ").foregroundStyle(.blue).bold()
             + Text("The term 'Jigging' refers to the process of adding random values to your profile information while maintaining the true values each component corresponds to. For example, the address '5734 XYZ Street' becomes 'RBG 5734 XYZ St'."))
            .font(.subheadline)

            (Text("- ").foregroundStyle(.blue).bold()
             + Text("It is recommended to use a wide range of unique information across all your profiles. Options such as 'Normal Jig' or 'Heavy Jig' can help decrease your order cancellation rate.")
            )
            .font(.subheadline)

            (Text("- ").foregroundStyle(.blue).bold()
             + Text("We recommend creating an Extend account. Extend is an online service that allows users to create thousands of Virtual Credit Cards (VCCs). This helps make each profile more unique. Virtual cards are linked to your main credit cards, so while your profile information will contain unique credit card information, all charges will be forwarded to your main credit cards. Extend only supports American Express. Before using the 'Extend' option, ensure you have valid Extend Card accounts set up.")
            )
            .font(.subheadline)

            (Text("- ").foregroundStyle(.blue).bold()
             + Text("Once you are done filling out the form, click the submit button at the bottom. Please give Wealth AI a few seconds to generate your profiles (2-3 seconds). If you are using existing Extend VCCs, then this process will usually take 5-10 seconds. However, if the profile builder is creating new VCCs, then the process can take anywhere from a few seconds to a minute, depending on the number of cards being created.")
            )
            .font(.subheadline)
        }
        .padding(10)
        .background(Color.gray.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    @ViewBuilder
    func proxy() -> some View {
        VStack(alignment: .leading, spacing: 15){
            HStack {
                Text("Proxy Rules").font(.title).bold().underline()
                Spacer()
            }
            
            (Text("- ").foregroundStyle(.blue).bold()
             + Text("Each proxy file should go in the 'proxy' folder which should only contain .txt documents")
            )
            .font(.subheadline)
            (Text("- ").foregroundStyle(.blue).bold()
             + Text("Each proxy should be in the format: 'IP Address:Port:Username:Password'")
            )
            .font(.subheadline)
            (Text("- ").foregroundStyle(.blue).bold()
             + Text("Each line should only have 1 proxy")
            )
            .font(.subheadline)
            (Text("- ").foregroundStyle(.blue).bold()
             + Text("Do not include 'http://' or 'https://' as the prefix of the IP segment")
            )
            .font(.subheadline)
        }
        .padding(10)
        .background(Color.gray.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    @ViewBuilder
    func account() -> some View {
        VStack(alignment: .leading, spacing: 15){
            HStack {
                Text("Account Rules").font(.title).bold().underline()
                Spacer()
            }
            
            (Text("- ").foregroundStyle(.blue).bold()
             + Text("Account files are text files (.txt) and should go in the 'account' folder.")
            )
            .font(.subheadline)
            (Text("- ").foregroundStyle(.blue).bold()
             + Text("Each file should contain 1 entry on each line in the format: '<email>:<password>'")
            )
            .font(.subheadline)
            (Text("- ").foregroundStyle(.blue).bold()
             + Text("To use accounts for your tasks then the Profile Email for the task MUST match an account email inside the provided `accountGroup`.")
            )
            .font(.subheadline)
            
            VStack(alignment: .leading, spacing: 5){
                (Text("- ").bold()
                 + Text("Example account file").fontWeight(.heavy)
                )
                .font(.subheadline).foregroundStyle(.blue)
                
                Text("thomas@gmail.com:password1")
                    .font(.subheadline).padding(.leading, 8)
                Text("jack123@gmail.com:password2")
                    .font(.subheadline).padding(.leading, 8)
                Text("John32@gmail.com:password3")
                    .font(.subheadline).padding(.leading, 8)
            }
        }
        .padding(10)
        .background(Color.gray.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    @ViewBuilder
    func headerView() -> some View {
        VStack(spacing: 8){
            HStack {
                Spacer()
                VStack(spacing: 3){
                    Image(colorScheme == .dark ? "wealthLogoWhite" : "wealthLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 45)
                    Text("Guide").font(.caption).fontWeight(.semibold)
                }
                Spacer()
            }
            
            CustomTabBar()
        }
        .padding(.top, 10)
        .background {
            TransparentBlurView(removeAllFilters: true).blur(radius: 14, opaque: true)
        }
    }
    @ViewBuilder
    func CustomTabBar() -> some View {
        HStack {
            ForEach($tabs, id: \.id) { $tab in
                Button(action: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    withAnimation(.easeInOut(duration: 0.12)) {
                        activeTab = tab.id
                    }
                }) {
                    HStack {
                        Spacer()
                        Text(tab.id)
                            .fontWeight(.bold)
                            .font(.caption)
                            .padding(.vertical, 10)
                            .foregroundStyle(activeTab == tab.id ? Color.primary : .gray)
                            .contentShape(.rect)
                        Spacer()
                    }
                }.buttonStyle(.plain)
            }
        }
        .overlay(alignment: .bottom) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle().fill(.gray.opacity(0.3)).frame(height: 1)

                    HStack {

                        let index = self.tabs.firstIndex(where: { $0.id == activeTab }) ?? 0
                        
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.blue).frame(width: geo.size.width / 5.0, height: 3)
                            .offset(x: CGFloat(index) * (geo.size.width / 5.0))
                        
                    }.animation(.easeInOut(duration: 0.12), value: activeTab)
                }
            }.offset(y: 33)
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
