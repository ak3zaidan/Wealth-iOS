import SwiftUI

struct ProfileManager: View {
    @Environment(TaskViewModel.self) private var viewModel
    @EnvironmentObject var auth: AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @State var deleteRequests = [String]()
    @State var jigRequests = [String]()
    @State var jigConfirmed = [String]()
        
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 10){
                
                Color.clear.frame(height: 10)
                
                aiProfile()
                    .scrollTransition { content, phase in
                        content
                            .scaleEffect(phase == .identity ? 1 : 0.65)
                            .blur(radius: phase == .identity ? 0 : 10)
                    }
                
                if let profiles = viewModel.profiles {
                    if profiles.isEmpty {
                        VStack(spacing: 12){
                            Text("Nothing yet...").font(.largeTitle).bold()
                            Text("Profile files will appear here.").font(.caption).foregroundStyle(.gray)
                        }.padding(.top, 150)
                    } else {
                        ForEach(profiles) { file in
                            profilesRowView(file: file)
                                .scrollTransition { content, phase in
                                    content
                                        .scaleEffect(phase == .identity ? 1 : 0.65)
                                        .blur(radius: phase == .identity ? 0 : 10)
                                }
                        }
                    }
                } else {
                    VStack(spacing: 10){
                        ForEach(0..<5) { _ in
                            FeedLoadingView()
                                .scrollTransition { content, phase in
                                    content
                                        .scaleEffect(phase == .identity ? 1 : 0.65)
                                        .blur(radius: phase == .identity ? 0 : 10)
                                }
                        }
                    }.shimmering().transition(.scale.combined(with: .opacity)).padding(.top)
                }
                
                Color.clear.frame(height: 60)
            }
        }
        .safeAreaPadding(.top, 40 + top_Inset())
        .scrollIndicators(.hidden)
        .background(content: {
            backColor()
        })
        .overlay(alignment: .top) {
            headerView()
        }
        .ignoresSafeArea()
        .presentationDetents([.large])
        .presentationCornerRadius(30)
        .presentationDragIndicator(.hidden)
        .onChange(of: viewModel.didJig) { _, _ in
            withAnimation(.easeInOut(duration: 0.2)){
                jigConfirmed = jigRequests
                jigRequests = []
            }
        }
    }
    @ViewBuilder
    func aiProfile() -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4){
                if (auth.currentUser?.unlockedTools ?? []).contains("Ai Profile+") {
                    Text("You own Ai Profile+")
                        .font(.headline).fontWeight(.heavy)
                    Text("Build profiles from the Ai page!")
                        .font(.caption).foregroundStyle(.gray).lineLimit(1).minimumScaleFactor(0.8)
                } else {
                    Text("Get Ai Profile+")
                        .font(.headline).fontWeight(.heavy)
                    Text("Purchase from the Tools page to build profiles.")
                        .font(.caption).foregroundStyle(.gray).lineLimit(1).minimumScaleFactor(0.8)
                }
            }
            Spacer()
            Image("aiLogo")
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .contentShape(RoundedRectangle(cornerRadius: 14))
                .shadow(radius: 3)
        }
        .padding(10)
        .background(content: {
            TransparentBlurView(removeAllFilters: true)
                .blur(radius: 14, opaque: true)
                .background(colorScheme == .dark ? .black.opacity(0.4) : .white.opacity(0.4))
        })
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .overlay(content: {
            RoundedRectangle(cornerRadius: 12)
                .stroke(lineWidth: 1).opacity(0.2)
        })
        .padding(.horizontal, 12)
    }
    @ViewBuilder
    func profilesRowView(file: ProfileFile) -> some View {
        VStack {
            HStack {

                Image("WealthIcon")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 30, height: 30)
                    .clipShape(Circle()).contentShape(Circle())
                    .shadow(color: .gray, radius: 3)
                
                Text(file.name).font(.headline).bold()
                
                Spacer()
                
                if (auth.currentUser?.ownedInstances ?? 0) > 0 {
                    Text("Instance \(file.instance)")
                        .font(.subheadline)
                        .padding(.horizontal, 11).padding(.vertical, 4)
                        .background(content: {
                            TransparentBlurView(removeAllFilters: true)
                                .blur(radius: 14, opaque: true)
                                .background(colorScheme == .dark ? .black.opacity(0.4) : .white.opacity(0.4))
                        })
                        .clipShape(Capsule())
                        .shadow(color: .gray, radius: 2)
                }
                
                Menu {
                    if let id = file.id, !jigRequests.contains(id) && !deleteRequests.contains(id) && !jigConfirmed.contains(id) {
                        Text("Jigs Name, Phone, Address")
                        
                        Button(role: .destructive){
                            let data = [
                                "name": file.name
                            ] as [String : Any]
                            
                            TaskService().newRequest(type: "\(file.instance)jigProfile", data: data)
                            
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                            
                            withAnimation(.easeInOut(duration: 0.2)){
                                jigRequests.append(id)
                            }
                        } label: {
                            Label("Jig Profiles", systemImage: "shuffle")
                        }
                        Divider()
                    }
                    
                    if let id = file.id, !deleteRequests.contains(id) {
                        Button(role: .destructive){
                            let data = [
                                "name": file.name,
                                "docId": id,
                            ] as [String : Any]
                            
                            TaskService().newRequest(type: "\(file.instance)deleteProfile", data: data)
                            
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                            
                            withAnimation(.easeInOut(duration: 0.2)){
                                deleteRequests.append(id)
                                jigRequests.removeAll(where: { $0 == id })
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        Divider()
                    }
                    
                    Button {
                        let data = [
                            "name": file.name,
                        ] as [String : Any]
                        
                        TaskService().newRequest(type: "\(file.instance)duplicateProfile", data: data)
                        
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    } label: {
                        Label("Duplicate", systemImage: "plus")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.subheadline)
                        .padding(11)
                        .background(content: {
                            TransparentBlurView(removeAllFilters: true)
                                .blur(radius: 14, opaque: true)
                                .background(colorScheme == .dark ? .black.opacity(0.4) : .white.opacity(0.4))
                        })
                        .clipShape(Circle())
                        .shadow(color: .gray, radius: 2)
                }.buttonStyle(.plain)
            }
            
            if !file.profiles.isEmpty {
                VStack(alignment: .leading){
                    
                    Text(file.profiles.joined(separator: ", "))
                        .font(.subheadline).lineLimit(2).fontWeight(.light)
                    
                    let total = (file.left ?? 0) + file.profiles.count
                    let word = total == 1 ? "Profile" : "Profiles"
                    
                    HStack {
                        Text("\(total) Total \(word)")
                        Spacer()
                    }
                }
                .padding(10)
                .background(Color.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .contentShape(RoundedRectangle(cornerRadius: 12))
            } else if let left = file.left, left > 0 {
                HStack {
                    Spacer()
                    
                    Text("This file has \(left) \(left == 1 ? "Profile" : "Profiles")")
                        .padding(.vertical).foregroundStyle(.gray)
                    
                    Spacer()
                }
                .padding(10).padding(.horizontal)
                .background(Color.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .contentShape(RoundedRectangle(cornerRadius: 12))
            } else {
                HStack {
                    Spacer()
                    
                    Text("This file is empty.")
                        .padding(.vertical).foregroundStyle(.gray).bold()
                    
                    Spacer()
                }
                .padding(10).padding(.horizontal)
                .background(Color.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .contentShape(RoundedRectangle(cornerRadius: 12))
            }
            
            if deleteRequests.contains(file.id ?? "") {
                HStack {
                    Text("Deletion requested!").font(.subheadline).foregroundStyle(.red)
                    
                    Spacer()
                }
            }
            if jigConfirmed.contains(file.id ?? "") {
                HStack {
                    Text("Jig Confirmed!").font(.subheadline).foregroundStyle(.green)
                    
                    Spacer()
                }
            } else if jigRequests.contains(file.id ?? "") {
                HStack {
                    Text("Jig requested!").font(.subheadline).foregroundStyle(.blue)
                    
                    Spacer()
                }
            }
        }
        .padding(13)
        .background(content: {
            TransparentBlurView(removeAllFilters: true)
                .blur(radius: 14, opaque: true)
                .background(colorScheme == .dark ? .black.opacity(0.4) : .white.opacity(0.4))
        })
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .overlay(content: {
            RoundedRectangle(cornerRadius: 12)
                .stroke(.blue, lineWidth: 1).opacity(0.4)
        })
        .padding(.horizontal, 12)
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
                    Text("Profile Manager").font(.caption).fontWeight(.semibold)
                }
                Spacer()
            }
            HStack {
                Spacer()
                
                Button {
                    dismiss()
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    ZStack {
                        Rectangle().frame(width: 40, height: 50)
                            .foregroundStyle(.gray).opacity(0.001)
                        Image(systemName: "xmark").font(.title3).bold()
                    }
                }.buttonStyle(.plain)
            }
        }
        .padding(.top, 20).padding(.horizontal).padding(.bottom, 10)
        .background {
            TransparentBlurView(removeAllFilters: true).blur(radius: 14, opaque: true)
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

struct AccountManager: View {
    @Environment(TaskViewModel.self) private var viewModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @State var deleteRequests = [String]()
    let showInstance: Bool
        
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 10){
                
                Color.clear.frame(height: 10)
                
                if let accounts = viewModel.accounts {
                    if accounts.isEmpty {
                        VStack(spacing: 12){
                            Text("Nothing yet...").font(.largeTitle).bold()
                            Text("Account files will appear here.").font(.caption).foregroundStyle(.gray)
                        }.padding(.top, 150)
                    } else {
                        ForEach(accounts) { file in
                            accountRowView(file: file)
                                .scrollTransition { content, phase in
                                    content
                                        .scaleEffect(phase == .identity ? 1 : 0.65)
                                        .blur(radius: phase == .identity ? 0 : 10)
                                }
                        }
                    }
                } else {
                    VStack(spacing: 10){
                        ForEach(0..<5) { _ in
                            FeedLoadingView()
                                .scrollTransition { content, phase in
                                    content
                                        .scaleEffect(phase == .identity ? 1 : 0.65)
                                        .blur(radius: phase == .identity ? 0 : 10)
                                }
                        }
                    }.shimmering().transition(.scale.combined(with: .opacity)).padding(.top)
                }
                
                Color.clear.frame(height: 60)
            }
        }
        .safeAreaPadding(.top, 40 + top_Inset())
        .scrollIndicators(.hidden)
        .background(content: {
            backColor()
        })
        .overlay(alignment: .top) {
            headerView()
        }
        .ignoresSafeArea()
        .presentationDetents([.large])
        .presentationCornerRadius(30)
        .presentationDragIndicator(.hidden)
    }
    @ViewBuilder
    func accountRowView(file: AccountFile) -> some View {
        VStack {
            HStack {

                Image("WealthIcon")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 30, height: 30)
                    .clipShape(Circle()).contentShape(Circle())
                    .shadow(color: .gray, radius: 3)
                
                Text(file.name).font(.headline).bold()
                
                Spacer()
                
                if showInstance {
                    Text("Instance \(file.instance)")
                        .font(.subheadline)
                        .padding(.horizontal, 11).padding(.vertical, 4)
                        .background(content: {
                            TransparentBlurView(removeAllFilters: true)
                                .blur(radius: 14, opaque: true)
                                .background(colorScheme == .dark ? .black.opacity(0.4) : .white.opacity(0.4))
                        })
                        .clipShape(Capsule())
                        .shadow(color: .gray, radius: 2)
                }
                
                Menu {
                    if let id = file.id, !deleteRequests.contains(file.id ?? "") {
                        Button(role: .destructive){
                            let data = [
                                "name": file.name,
                                "docId": id,
                            ] as [String : Any]
                            
                            TaskService().newRequest(type: "\(file.instance)deleteAccount", data: data)
                            
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                            
                            withAnimation(.easeInOut(duration: 0.2)){
                                deleteRequests.append(id)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        Divider()
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.subheadline)
                        .padding(11)
                        .background(content: {
                            TransparentBlurView(removeAllFilters: true)
                                .blur(radius: 14, opaque: true)
                                .background(colorScheme == .dark ? .black.opacity(0.4) : .white.opacity(0.4))
                        })
                        .clipShape(Circle())
                        .shadow(color: .gray, radius: 2)
                }.buttonStyle(.plain)
            }
            
            if !file.accounts.isEmpty {
                VStack(alignment: .leading){
                    
                    Text(file.accounts.joined(separator: ", "))
                        .font(.subheadline).lineLimit(2).fontWeight(.light)
                    
                    let total = (file.left ?? 0) + file.accounts.count
                    let word = total == 1 ? "Account" : "Accounts"
                    
                    HStack {
                        Text("\(total) Total \(word)")
                        Spacer()
                    }
                }
                .padding(10)
                .background(Color.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .contentShape(RoundedRectangle(cornerRadius: 12))
            } else if let left = file.left, left > 0 {
                HStack {
                    Spacer()
                    
                    Text("This file has \(left) \(left == 1 ? "Account" : "Accounts")")
                        .padding(.vertical).foregroundStyle(.gray)
                    
                    Spacer()
                }
                .padding(10).padding(.horizontal)
                .background(Color.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .contentShape(RoundedRectangle(cornerRadius: 12))
            } else {
                HStack {
                    Spacer()
                    
                    Text("This file is empty.")
                        .padding(.vertical).foregroundStyle(.gray).bold()
                    
                    Spacer()
                }
                .padding(10).padding(.horizontal)
                .background(Color.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .contentShape(RoundedRectangle(cornerRadius: 12))
            }
            
            if deleteRequests.contains(file.id ?? "") {
                HStack {
                    Text("Deletion requested!").font(.subheadline).foregroundStyle(.red)
                    
                    Spacer()
                }
            }
        }
        .padding(13)
        .background(content: {
            TransparentBlurView(removeAllFilters: true)
                .blur(radius: 14, opaque: true)
                .background(colorScheme == .dark ? .black.opacity(0.4) : .white.opacity(0.4))
        })
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .overlay(content: {
            RoundedRectangle(cornerRadius: 12)
                .stroke(.blue, lineWidth: 1).opacity(0.4)
        })
        .padding(.horizontal, 12)
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
                    Text("Account Manager").font(.caption).fontWeight(.semibold)
                }
                Spacer()
            }
            HStack {
                Spacer()
                
                Button {
                    dismiss()
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    ZStack {
                        Rectangle().frame(width: 40, height: 50)
                            .foregroundStyle(.gray).opacity(0.001)
                        Image(systemName: "xmark").font(.title3).bold()
                    }
                }.buttonStyle(.plain)
            }
        }
        .padding(.top, 20).padding(.horizontal).padding(.bottom, 10)
        .background {
            TransparentBlurView(removeAllFilters: true).blur(radius: 14, opaque: true)
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
