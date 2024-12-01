import SwiftUI

struct ScaleInfoView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15){
                general()
                Color.clear.frame(height: 100)
            }.padding(.horizontal).safeAreaPadding(.top, 90)
        }
        .scrollIndicators(.hidden)
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
    func headerView() -> some View {
        VStack(spacing: 8){
            HStack {
                Spacer()
                VStack(spacing: 3){
                    Image(colorScheme == .dark ? "wealthLogoWhite" : "wealthLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 45)
                    Text("Wealth Scale").font(.caption).fontWeight(.semibold)
                }
                Spacer()
            }
        }
        .padding(.vertical, 10)
        .background {
            TransparentBlurView(removeAllFilters: true).blur(radius: 14, opaque: true)
        }
    }
    @ViewBuilder
    func general() -> some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("General").font(.title).bold().underline()
                Spacer()
            }
            
            (Text("- ").foregroundStyle(.blue).bold()
             + Text("This feature lets you deploy up to 6 Wealth AIO instances on different servers for more synchronized computing—i.e., more tasks. Instances above the Base instance (the main instance you get from a normal membership) are not meant to be individual bots that you use separately or give to other people.")
            )
            .font(.subheadline)
            
            (Text("- ").foregroundStyle(.blue).bold()
             + Text("These additional instances all synchronize to the same iPhone device. Although you can sign in from any iPhone to access your Wealth Servers, only 1 iPhone is allowed at a time to connect to all servers. This rule is enforced.")
            )
            .font(.subheadline)
            
            (Text("- ").foregroundStyle(.blue).bold()
             + Text("Deploy each instance on a different server/computer. Deploying more than one Wealth instance on the same device does not benefit you in any way and may cause issues.")
            )
            .font(.subheadline)
        }
        .padding(10)
        .background(Color.gray.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Subscription Info").font(.title).bold().underline()
                Spacer()
            }

            (Text("- ").foregroundStyle(.blue).bold()
             + Text("By using `Wealth Scale`, you will incur two monthly charges: one for the base membership and another for additional instances."))
            .font(.subheadline)

            (Text("- ").foregroundStyle(.blue).bold()
             + Text("You are allowed to add instances even if you already have some. For example, if you have three instances and want another, you can change your instance count to '4' in the dashboard."))
            .font(.subheadline)

            (Text("- ").foregroundStyle(.blue).bold()
             + Text("If you increase the number of instances, you will be charged a one-time fee covering the period from the current time until your instance billing cycle ends. Additionally, future billing cycles will update to reflect the total cost of the new instance count."))
            .font(.subheadline)

            (Text("- ").foregroundStyle(.blue).bold()
             + Text("For example, if your billing cycle is scheduled to restart on the 1st of every month, and you add instances on the 15th of the month, then you will be charged a one-time fee which is 50 percent of the added cost. This simplifies the process by maintaining a single billing cycle for Wealth Scale. This fractional charge is a one-time fee meant to cover the cost of the instances until the next cycle."))
            .font(.subheadline)
        }
        .padding(10)
        .background(Color.gray.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.top, 15)
        
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Setup").font(.title).bold().underline()
                Spacer()
            }
            
            (Text("- ").foregroundStyle(.blue).bold()
             + Text("After starting a Wealth Scale Instance subscription, download each instance on a different server. You can download instances on various computer types.")
            )
            .font(.subheadline)
            
            (Text("- ").foregroundStyle(.blue).bold()
             + Text("Your CapSolver API key only needs to be entered into one instance. Wealth will automatically propagate the key to all other instances. If no instances have this key set, then fill out the `CapSolverKey.txt` file.")
            )
            .font(.subheadline)
            
            (Text("- ").foregroundStyle(.blue).bold()
             + Text("Similarly, your Success and Failure Discord Webhooks only need to be entered into one instance. Wealth will automatically propagate the webhooks to all other instances. If no instances have webhooks set, then fill out the `SuccessHook.txt` and `FailureHook.txt` files.")
            )
            .font(.subheadline)
            
            (Text("- ").foregroundStyle(.blue)
             + Text("For each instance, you must do the following:")
            )
            .font(.subheadline).fontWeight(.heavy)
            
            (Text("1. ").foregroundStyle(.blue).bold()
             + Text("Enter your Bot Key into the `BotKey.txt` file for each instance. Use the same key for every instance.")
            )
            .font(.subheadline)
            
            (Text("2. ").foregroundStyle(.blue).bold()
             + Text("If you plan on using the Nike module, then you must fill out the 'IMAP.json' file with the correct IMAP credentials for EVERY instance. You are allowed to use different IMAP credentials for each instance.")
            )
            .font(.subheadline)
            
            (Text("3. ").foregroundStyle(.blue).bold()
             + Text("This step is very important, and this is where you will modify 'Nickname.json' for every instance. Your original Wealth AIO instance should keep the default (nickname = 'Base' and id = 1) in the 'Nickname.json' file. You must modify every other instance in the following way:")
            )
            .font(.subheadline)
            
            (Text("4. ").foregroundStyle(.blue).bold()
             + Text("Each instance should have a UNIQUE nickname, for example, your base instance will have 'Base' and if you are using three more instances, then you can name them 'Charlie', 'Alpha', and 'Beta'.")
            )
            .font(.subheadline)
            
            (Text("5. ").foregroundStyle(.blue).bold()
             + Text("You MUST make the nicknames unique; this will allow our software to work smoothly and give you the ability to perform various in-app functions, like searching for orders based on Instance Nickname.")
            )
            .font(.subheadline)
            
            (Text("6. ").foregroundStyle(.blue).bold()
             + Text("Similarly, the 'id' entry MUST be a UNIQUE integer. This is the most IMPORTANT part. Follow this id format across all your instances:")
            )
            .font(.subheadline)
            
            VStack(alignment: .leading, spacing: 5) {
                (Text("- ").foregroundStyle(.red).bold()
                 + Text("The original instance should have ('id' = 1)")
                )
                .font(.subheadline)
                
                (Text("- ").foregroundStyle(.red).bold()
                 + Text("The next instance should have ('id' = 2)")
                )
                .font(.subheadline)
                
                (Text("- ").foregroundStyle(.red).bold()
                 + Text("The next instance should have ('id' = 3)")
                )
                .font(.subheadline)
                
                (Text("- ").foregroundStyle(.red).bold()
                 + Text("The next instance should have ('id' = 4)")
                )
                .font(.subheadline)
                
                (Text("- ").foregroundStyle(.red).bold()
                 + Text("The next instance should have ('id' = 5)")
                )
                .font(.subheadline)
                
                (Text("- ").foregroundStyle(.red).bold()
                 + Text("The next instance should have ('id' = 6)")
                )
                .font(.subheadline)
            }.padding(.leading, 10)
            
            (Text("- ").foregroundStyle(.blue).bold()
             + Text("All instances are identical, so it doesn’t matter which ones get which id. As long as no two instances have the same id and they go in order from 1 through 6 (or however many you have), then you are good.")
            )
            .font(.subheadline)
            
            (Text("- ").foregroundStyle(.blue).bold()
             + Text("Never edit or change the nicknames/ids of the instances after setting them the first time. Just pick a nickname and id, and stick to that.")
            )
            .font(.subheadline)
        }
        .padding(10)
        .background(Color.gray.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12)).padding(.top, 15)
        
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Running").font(.title).bold().underline()
                Spacer()
            }

            (Text("- ").foregroundStyle(.blue).bold()
             + Text("It does not matter in what order you start the instances; this app will show you the status of every server from the Task tab (Center page).")
            )
            .font(.subheadline)

            (Text("- ").foregroundStyle(.blue).bold()
             + Text("Common actions like 'Reset Server Session' or 'Update AIO' will perform the action across all instances, or you can navigate to the Instance Manager and perform the action on a specific instance.")
            )
            .font(.subheadline)

            (Text("- ").foregroundStyle(.blue).bold()
             + Text("You can have the same Task Group name across multiple instances. For example, Instance 1 (Base Instance) can have a task group named 'supreme' and Instance 2 can also have a task group named 'supreme'. This rule applies the same to profile, proxy, and account groups.")
            )
            .font(.subheadline)

            (Text("- ").foregroundStyle(.blue)
             + Text("(Important) Task groups that begin with the 'auto' keyword (Example: 'autoPokemon') will have the following effect:")
            )
            .font(.subheadline).fontWeight(.heavy)

            (Text("1. ").foregroundStyle(.blue).bold()
             + Text("All task groups from any instance that share the same Task Group Name and begin with 'auto' will alert each other to start. This may be useful if an item is not live and you do not want to run the same task group across each instance just to monitor the item. This saves resources as only one instance needs to monitor an item, and it also makes it easier for you to have synchronized task groups across multiple instances that work together.")
            )
            .font(.subheadline)

            (Text("2. ").foregroundStyle(.blue).bold()
             + Text("This feature is intended when task groups on different instances are targeting the same item.")
            )
            .font(.subheadline)

            (Text("3. ").foregroundStyle(.blue).bold()
             + Text("This feature will have different effects on different sites; please refer to the official guide to learn more.")
            )
            .font(.subheadline)
        }
        .padding(10)
        .background(Color.gray.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12)).padding(.top, 15)
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
