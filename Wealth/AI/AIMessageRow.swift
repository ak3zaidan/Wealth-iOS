import SwiftUI
import Markdown
import Kingfisher

struct MessageRowView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var history: AIHistory
    @EnvironmentObject var vm: ViewModel
    @State var showExportShareSheet = false
    @State var fileURL: URL? = nil
    
    let message: MessageRow
    let retryCallback: (MessageRow) -> Void
    let alert: ((String, String)) -> Void
    let openBuilder: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            
            HStack(alignment: .top){
                ZStack(alignment: .center){
                    Image(systemName: "circle.fill")
                        .resizable().frame(width: 25, height: 25)
                        .foregroundColor(colorScheme == .dark ? Color(UIColor.darkGray) : .black)
                    Image(systemName: "questionmark")
                        .resizable().foregroundColor(.white).frame(width: 7, height: 12)
                    
                    if let image = auth.currentUser?.profileImageUrl {
                        KFImage(URL(string: image))
                            .resizable().aspectRatio(contentMode: .fill)
                            .frame(width: 25, height: 25).clipShape(Circle()).contentShape(Circle())
                    }
                }.offset(x: 2)
                
                VStack {
                    HStack {
                        Text(auth.currentUser?.username ?? "You")
                            .font(.system(size: 14)).padding(.top, 5).foregroundStyle(.gray)
                        Spacer()
                    }
                    
                    if !message.send.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        HStack {
                            Text(message.send.text)
                                .font(.body).textSelection(.enabled).multilineTextAlignment(.leading)
                            Spacer()
                        }.padding(.top, 6)
                    }
                    
                    if vm.hasImage.contains(message.send.text) || history.hasImageSec.contains(message.send.text){
                        HStack {
                            Text("Image added").font(.subheadline).foregroundStyle(.gray)
                            Spacer()
                        }.padding(.top, 4)
                    }
                }
            }
            
            if let response = message.response {
                HStack(alignment: .top){
                    let status = vm.isInteracting || message.isProfileInteracting
                    if status {
                        LottieView(loopMode: .loop, name: "greenAnim").frame(width: 22, height: 25).scaleEffect(0.5)
                    } else {
                        AICircle(width: 20).offset(x: 1)
                    }
                    
                    VStack(alignment: .leading, spacing: 10){
                        Text("Wealth AI").font(.system(size: 14)).foregroundStyle(.gray)
                        
                        if message.isProfileInteracting && !message.vccBuildMessage.isEmpty {
                            Text(message.vccBuildMessage).font(.system(size: 14))
                            
                            Button {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                if let index = vm.messages.firstIndex(where: { $0.id == message.id }) {
                                    if (vm.messages[index].response?.text ?? "").isEmpty {
                                        withAnimation(.easeInOut(duration: 0.2)){
                                            _  = vm.messages.remove(at: index)
                                        }
                                        vm.cancelledJobs.append(vm.messages[index].id.uuidString)
                                    }
                                }
                                vm.isVccBuilding = false
                            } label: {
                                VStack(alignment: .leading, spacing: 3){
                                    Text("Bulk VCC requested, fetch later?")
                                        .font(.system(size: 16)).bold()
                                    Text("Extend is processing, this may take a few min for large amounts. You can cancel until VCCs are created, then use Profile Builder’s “Use existing” option.")
                                        .font(.system(size: 13))
                                }
                                .padding(8).background(.indigo)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(color: .gray, radius: 2)
                            }.buttonStyle(.plain)
                        }
                    }.offset(x: 1, y: status ? 5 : 2)
                    
                    Spacer()
                }.padding(.top, 20).padding(.leading, 3)
                
                HStack {
                    messageRow(rowType: response, responseError: message.responseError)
                    Spacer()
                }.padding(.vertical, 6)
            }
        }
        .padding(.top, 17).padding(.leading, 3).padding(.bottom, 15)
        .sheet(isPresented: $showExportShareSheet) {
            if let fileURL = fileURL {
                ShareSheet(activityItems: [fileURL])
            }
        }
    }
    
    func messageRow(rowType: MessageRowType, responseError: String? = nil) -> some View {
        HStack(alignment: .top, spacing: 24) {
            messageRowContent(rowType: rowType, responseError: responseError)
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    func messageRowContent(rowType: MessageRowType, responseError: String? = nil) -> some View {
        VStack(alignment: .leading) {
            switch rowType {
            case .attributed(let attributedOutput):
                if message.isProfileBuild {
                    VStack(spacing: 10){
                        AiProfiles(profiles: attributedOutput.string)
                        exportProfiles(profiles: attributedOutput.string)
                    }.padding(.horizontal, 8).padding(.top, 10)
                } else {
                    attributedView(results: attributedOutput.results)
                }
            case .rawText(let text):
                if !text.isEmpty {
                    Text(text)
                        .font(.body).padding(.leading, 32)
                        .multilineTextAlignment(.leading).textSelection(.enabled)
                }
            }
            
            if responseError != nil {
                HStack(spacing: 15){
                    Text("Error").foregroundStyle(.red).font(.system(size: 16))
                    Spacer()
                    Button {
                        if !vm.isInteracting {
                            retryCallback(message)
                        }
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10).foregroundStyle(.green).opacity(0.9)
                            HStack(spacing: 2){
                                Image(systemName: "arrow.triangle.2.circlepath").font(.system(size: 14))
                                Text("Regenerate").font(.system(size: 15))
                            }.foregroundStyle(.white)
                        }.frame(width: 120, height: 37)
                    }
                }.padding(.bottom).padding(.leading, 32).padding(.trailing)
            }
            
            if (vm.isInteracting && vm.messages.last?.id == message.id) || message.isProfileInteracting {
                if message.isProfileBuild {
                    HStack {
                        Spacer()
                        LottieView(loopMode: .loop, name: "aiLoad")
                            .scaleEffect(0.7).frame(width: 100, height: 100)
                        Spacer()
                    }.padding(.top, 6)
                } else {
                    DotLoadingView().frame(width: 45, height: 22.5).padding(.leading, 32)
                }
            }
        }
    }
    
    func attributedView(results: [ParserResult]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(results) { parsed in
                if parsed.isCodeBlock {
                    CodeBlockView(parserResult: parsed)
                        .padding(.bottom, 24).padding(.horizontal, 8)
                } else {
                    Text(parsed.attributedString)
                        .font(.body).textSelection(.enabled).padding(.leading, 32)
                }
            }
        }
    }
    
    @ViewBuilder
    func exportProfiles(profiles: String) -> some View {
        HStack(spacing: 14){
            if vm.exportedToServer.contains(message.id.uuidString) {
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    alert(("exclamationmark.bubble.fill", "You already exported these profiles."))
                } label: {
                    HStack(spacing: 5){
                        Image("WealthIcon")
                            .resizable().scaledToFill().frame(width: 25, height: 25)
                            .clipShape(Circle()).contentShape(Circle())
                        Text("AIO export").font(.body)
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                    }
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .background(.ultraThinMaterial).clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: .blue, radius: 1.5)
                }
            } else {
                Menu {
                    if (auth.currentUser?.ownedInstances ?? 0) > 0 && !auth.possibleInstances.isEmpty {
                        ForEach(Array(auth.possibleInstances.enumerated()), id: \.element) { index, instance in
                            Button {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                let name = extractProfileName(message.send.text)
                                ServerSend().sendProfiles(name: name, profiles: profiles, instance: index + 1)
                                alert(("checkmark",
                                       "Profiles sent to \(instance)! If server is offline then simply start it."))
                            } label: {
                                Label(instance, systemImage: "square.and.arrow.up")
                            }
                        }
                        Divider()
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            let name = extractProfileName(message.send.text)
                            for i in 0..<(auth.possibleInstances.count) {
                                ServerSend().sendProfiles(name: name, profiles: profiles, instance: i + 1)
                            }
                            alert(("checkmark", "Profiles sent to AIO servers! If server is offline then simply start it."))
                        } label: {
                            Label("Send to All", systemImage: "square.and.arrow.up")
                        }
                    } else {
                        Text("Confirm profile export.")
                        Divider()
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            let name = extractProfileName(message.send.text)
                            vm.exportedToServer.append(message.id.uuidString)
                            ServerSend().sendProfiles(name: name, profiles: profiles, instance: 1)
                            alert(("checkmark", "Profiles sent to AIO server! If server is offline then simply start it."))
                        } label: {
                            Label("Send", systemImage: "square.and.arrow.up")
                        }
                    }
                } label: {
                    HStack(spacing: 5){
                        Image("WealthIcon")
                            .resizable().scaledToFill().frame(width: 25, height: 25)
                            .clipShape(Circle()).contentShape(Circle())
                        Text("AIO export").font(.body)
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                    }
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .background(.ultraThinMaterial).clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: .blue, radius: 1.5)
                }
                .onAppear {
                    if (auth.currentUser?.ownedInstances ?? 0) > 0 && auth.possibleInstances.isEmpty {
                        DispatchQueue.global(qos: .background).async {
                            CheckoutService().getPossibleInstances { instances in
                                DispatchQueue.main.async {
                                    auth.possibleInstances = instances
                                }
                            }
                        }
                    }
                }
            }

            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                let name = extractProfileName(message.send.text)
                
                if fileURL != nil {
                    showExportShareSheet = true
                } else {
                    if let url = saveToFile(content: profiles, isCSV: false, fileName: name) {
                        fileURL = url
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                            showExportShareSheet = true
                        }
                    }
                }
            } label: {
                HStack(spacing: 5){
                    Image(systemName: "arrowshape.turn.up.right.fill")
                        .font(.body).foregroundStyle(.blue)
                        .frame(width: 25, height: 25)
                        .background(colorScheme == .dark ? .white : .black)
                        .clipShape(Circle())
                    
                    Text("Share").font(.body)
                }
                .padding(.horizontal, 10).padding(.vertical, 6)
                .background(.ultraThinMaterial).clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: .green, radius: 1.5)
            }.buttonStyle(.plain)
            
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                vm.appendVccToExisting = message.id.uuidString
                openBuilder()
            } label: {
                HStack(spacing: 5){
                    Image(systemName: "person.fill.badge.plus")
                        .font(.body).foregroundStyle(.indigo).scaleEffect(0.9)
                        .frame(width: 25, height: 25)
                        .background(colorScheme == .dark ? .white : .black)
                        .clipShape(Circle())
                    
                    Text("Add").font(.body)
                }
                .padding(.horizontal, 10).padding(.vertical, 6)
                .background(.ultraThinMaterial).clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: .orange, radius: 1.5)
            }.buttonStyle(.plain)
            Spacer()
        }
    }
}

struct DotLoadingView: View {
    @State private var showCircle1 = false
    @State private var showCircle2 = false
    @State private var showCircle3 = false
    
    var body: some View {
        HStack {
            Circle()
                .opacity(showCircle1 ? 1 : 0)
            Circle()
                .opacity(showCircle2 ? 1 : 0)
            Circle()
                .opacity(showCircle3 ? 1 : 0)
        }
        .foregroundColor(.gray.opacity(0.5))
        .onAppear { performAnimation() }
    }
    
    func performAnimation() {
        let animation = Animation.easeInOut(duration: 0.4)
        withAnimation(animation) {
            self.showCircle1 = true
            self.showCircle3 = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(animation) {
                self.showCircle2 = true
                self.showCircle1 = false
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(animation) {
                self.showCircle2 = false
                self.showCircle3 = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            self.performAnimation()
        }
    }
}

func extractProfileName(_ text: String) -> String {
    let pattern = "'(.*?)'"
    let regex = try? NSRegularExpression(pattern: pattern)
    let range = NSRange(text.startIndex..<text.endIndex, in: text)
    
    if let match = regex?.firstMatch(in: text, options: [], range: range),
       let matchedRange = Range(match.range(at: 1), in: text) {
        return String(text[matchedRange])
    }
    return "Profiles"
}
