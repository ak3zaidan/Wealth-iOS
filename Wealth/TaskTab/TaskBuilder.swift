import SwiftUI

struct TaskBuilder: View {
    @Environment(TaskViewModel.self) private var viewModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @State var showSitePicker = false
    @State var toggleGlitch = false
    @State var appeared = false
    @State var showAdvanced = false
    @State var lockName: Bool
    @State var Original: BotTask
    
    @FocusState var fileNameEditing
    @FocusState var countEditing
    @FocusState var inputEditing
    @FocusState var sizeEditing
    @FocusState var colorEditing
    @FocusState var cartQuantityEditing
    @FocusState var delayEditing
    @FocusState var maxBuyPriceEditing
    @FocusState var maxBuyQuantityEditing
    @FocusState var discountCodeEditing
    
    @State var site: String
    @State var mode: String
    @State var fileName: String
    @State var count = "1"
    @State var input: String
    @State var profileGroup: String
    @State var profileName: String
    @State var proxyGroup: String
    @State var accountGroup: String
    @State var size: String
    @State var color: String
    // advanced
    @State var cartQuantity: String
    @State var delay: String
    @State var maxBuyPrice: String
    @State var maxBuyQuantity: String
    @State var discountCode: String

    @Binding var lock: Bool
    @Binding var action: TaskAction
    @Binding var setShippingLock: Bool
    let done: ((BotTask, String, Int)) -> Void
    
    init(presetName: String?, setup: BotTask, lock: Binding<Bool>, action: Binding<TaskAction>, setShippingLock: Binding<Bool>, done: @escaping ((BotTask, String, Int)) -> Void) {
        self._profileGroup = State(initialValue: setup.profileGroup)
        self._profileName = State(initialValue: setup.profileName)
        self._proxyGroup = State(initialValue: setup.proxyGroup)
        self._accountGroup = State(initialValue: setup.accountGroup)
        self._input = State(initialValue: setup.input)
        self._size = State(initialValue: setup.size)
        self._color = State(initialValue: setup.color)
        self._site = State(initialValue: setup.site)
        self._mode = State(initialValue: setup.mode)
        self._cartQuantity = State(initialValue: String(setup.cartQuantity))
        self._delay = State(initialValue: String(setup.delay))
        self._discountCode = State(initialValue: setup.discountCode)
        self._maxBuyPrice = State(initialValue: String(setup.maxBuyPrice))
        self._maxBuyQuantity = State(initialValue: String(setup.maxBuyQuantity))
        
        self._lock = lock
        self._action = action
        self._setShippingLock = setShippingLock
        self.done = done
        
        if let presetName {
            self._fileName = State(initialValue: presetName)
            self._lockName = State(initialValue: true)
        } else {
            self._fileName = State(initialValue: "")
            self._lockName = State(initialValue: false)
        }
        
        self._Original = State(initialValue: setup)
    }
    
    var body: some View {
        
        let status = !site.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        ZStack {
            SelectSiteExtension(showSitePicker: $showSitePicker, baseUrl: $site)
                .onChange(of: site) { _, _ in
                    let scope = GetSiteName()
                    
                    if scope == "Pokemon" || scope == "Popmart" {
                        self.color = "Random"
                        self.size = "Random"
                    }
                }
            
            if status {
                VStack {
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack {
                                HStack(spacing: 12){
                                    TextField("", text: $fileName)
                                        .lineLimit(1)
                                        .focused($fileNameEditing)
                                        .frame(height: 57)
                                        .padding(.top, 8)
                                        .overlay(alignment: .leading, content: {
                                            Text("Group Name").font(.system(size: 18)).fontWeight(.light)
                                                .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
                                                .opacity(fileNameEditing ? 0.8 : 0.5)
                                                .offset(y: fileName.isEmpty && !fileNameEditing ? 0.0 : -21.0)
                                                .scaleEffect(fileName.isEmpty && !fileNameEditing ? 1.0 : 0.8, anchor: .leading)
                                                .animation(.easeInOut(duration: 0.2), value: fileNameEditing)
                                                .onTapGesture {
                                                    fileNameEditing = true
                                                }
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
                                                .stroke(colorScheme == .dark ? Color.white : Color.black ,lineWidth: 1)
                                                .opacity(fileNameEditing ? 0.8 : 0.5)
                                        })
                                        .disabled(lockName)
                                    
                                    if action == .Add || action == .Create {
                                        TextField("", text: $count)
                                            .lineLimit(1).keyboardType(.numberPad)
                                            .focused($countEditing)
                                            .frame(height: 57)
                                            .padding(.top, 8)
                                            .overlay(alignment: .leading, content: {
                                                Text("Task Count").font(.system(size: 18)).fontWeight(.light)
                                                    .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
                                                    .opacity(countEditing ? 0.8 : 0.5)
                                                    .offset(y: count.isEmpty && !countEditing ? 0.0 : -21.0)
                                                    .scaleEffect(count.isEmpty && !countEditing ? 1.0 : 0.8, anchor: .leading)
                                                    .animation(.easeInOut(duration: 0.2), value: countEditing)
                                                    .onTapGesture {
                                                        countEditing = true
                                                    }
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
                                                    .stroke(colorScheme == .dark ? Color.white : Color.black ,lineWidth: 1)
                                                    .opacity(countEditing ? 0.8 : 0.5)
                                            })
                                    }
                                }
                                
                                TextField("", text: $input, axis: .vertical)
                                    .focused($inputEditing)
                                    .frame(minHeight: 57).lineLimit(6)
                                    .padding(.top, 6).padding(.bottom, 6)
                                    .overlay(alignment: .topLeading, content: {
                                        Text("Input \(GetInputType())").font(.system(size: 18)).fontWeight(.light)
                                            .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
                                            .opacity(inputEditing ? 1.0 : 0.8)
                                            .offset(y: input.isEmpty && !inputEditing ? 22.0 : -26.0)
                                            .scaleEffect(input.isEmpty && !inputEditing ? 1.0 : 0.8, anchor: .leading)
                                            .animation(.easeInOut(duration: 0.2), value: inputEditing)
                                            .onTapGesture {
                                                inputEditing = true
                                            }
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
                                            .stroke(colorScheme == .dark ? Color.white : Color.black ,lineWidth: 1)
                                            .opacity(inputEditing ? 0.8 : 0.5)
                                    })
                                    .padding(.top).padding(.top, 10)
                                
                                VStack(spacing: 12){
                                    HStack(spacing: 12){
                                        Menu {
                                            Text("Required!")
                                            Divider()
                                            ForEach(viewModel.profiles ?? []) { element in
                                                Button {
                                                    self.profileGroup = element.name
                                                } label: {
                                                    Label("I\(element.instance). \(element.name)",
                                                          systemImage: "person.icloud")
                                                }
                                            }
                                        } label: {
                                            HStack {
                                                Spacer()
                                                if profileGroup.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                                    Text("Profile Group")
                                                        .font(.body).italic().lineLimit(1)
                                                } else {
                                                    Text(self.profileGroup)
                                                        .font(.body).lineLimit(1).bold()
                                                }
                                                Spacer()
                                            }
                                            .lineLimit(1).frame(height: 57)
                                            .background {
                                                TransparentBlurView(removeAllFilters: true)
                                                    .blur(radius: 10, opaque: true)
                                                    .background(colorScheme == .dark ? .black.opacity(0.5) : .white.opacity(0.5))
                                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                            }
                                            .overlay(content: {
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(colorScheme == .dark ? Color.white : Color.black ,lineWidth: 1)
                                                    .opacity(0.5)
                                            })
                                        }.buttonStyle(.plain)
                                        Menu {
                                            Button {
                                                self.profileName = "All"
                                            } label: {
                                                Label("All", systemImage: "text.badge.checkmark")
                                            }
                                            Divider()
                                            ForEach(GetValidProfiles(), id: \.self) { element in
                                                Button {
                                                    self.profileName = element
                                                } label: {
                                                    Label(element, systemImage: "person")
                                                }
                                            }
                                        } label: {
                                            HStack {
                                                Spacer()
                                                if profileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                                    Text("Profile Name")
                                                        .font(.body).italic().lineLimit(1)
                                                } else {
                                                    Text(self.profileName)
                                                        .font(.body).lineLimit(1).bold()
                                                }
                                                Spacer()
                                            }
                                            .lineLimit(1).frame(height: 57)
                                            .background {
                                                TransparentBlurView(removeAllFilters: true)
                                                    .blur(radius: 10, opaque: true)
                                                    .background(colorScheme == .dark ? .black.opacity(0.5) : .white.opacity(0.5))
                                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                            }
                                            .overlay(content: {
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(colorScheme == .dark ? Color.white : Color.black ,lineWidth: 1)
                                                    .opacity(0.5)
                                            })
                                        }.buttonStyle(.plain)
                                    }
                                    HStack(spacing: 12){
                                        Menu {
                                            Button {
                                                self.proxyGroup = ""
                                            } label: {
                                                Label("Local Host", systemImage: "house.badge.wifi")
                                            }
                                            Divider()
                                            ForEach(viewModel.proxies ?? []) { element in
                                                Button {
                                                    self.proxyGroup = element.name
                                                } label: {
                                                    Label("I\(element.instance). \(element.name)", systemImage: "wifi")
                                                }
                                            }
                                        } label: {
                                            HStack {
                                                Spacer()
                                                if proxyGroup.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                                    Text("Proxy Group")
                                                        .font(.body).italic().lineLimit(1)
                                                } else {
                                                    Text(self.proxyGroup)
                                                        .font(.body).lineLimit(1).bold()
                                                }
                                                Spacer()
                                            }
                                            .lineLimit(1).frame(height: 57)
                                            .background {
                                                TransparentBlurView(removeAllFilters: true)
                                                    .blur(radius: 10, opaque: true)
                                                    .background(colorScheme == .dark ? .black.opacity(0.5) : .white.opacity(0.5))
                                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                            }
                                            .overlay(content: {
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(colorScheme == .dark ? Color.white : Color.black ,lineWidth: 1)
                                                    .opacity(0.5)
                                            })
                                        }.buttonStyle(.plain)
                                        Menu {
                                            Button {
                                                self.accountGroup = ""
                                            } label: {
                                                Label("None", systemImage: "person.slash")
                                            }
                                            Divider()
                                            ForEach(viewModel.accounts ?? []) { element in
                                                Button {
                                                    self.accountGroup = element.name
                                                } label: {
                                                    Label("I\(element.instance). \(element.name)",
                                                          systemImage: "person.fill")
                                                }
                                            }
                                        } label: {
                                            HStack {
                                                Spacer()
                                                if accountGroup.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                                    Text("Account Group")
                                                        .font(.body).italic().lineLimit(1)
                                                } else {
                                                    Text(self.accountGroup)
                                                        .font(.body).lineLimit(1).bold()
                                                }
                                                Spacer()
                                            }
                                            .lineLimit(1).frame(height: 57)
                                            .background {
                                                TransparentBlurView(removeAllFilters: true)
                                                    .blur(radius: 10, opaque: true)
                                                    .background(colorScheme == .dark ? .black.opacity(0.5) : .white.opacity(0.5))
                                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                            }
                                            .overlay(content: {
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(colorScheme == .dark ? Color.white : Color.black ,lineWidth: 1)
                                                    .opacity(0.5)
                                            })
                                        }.buttonStyle(.plain)
                                    }
                                }
                                .padding(12)
                                .background(Color.gray.opacity(0.4))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .padding(.vertical)
                                
                                TextField("", text: $size)
                                    .lineLimit(1)
                                    .focused($sizeEditing)
                                    .frame(height: 57)
                                    .padding(.top, 8)
                                    .overlay(alignment: .leading, content: {
                                        Text("Sizes (space seperated)").font(.system(size: 18)).fontWeight(.light)
                                            .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
                                            .opacity(sizeEditing ? 0.8 : 0.5)
                                            .offset(y: size.isEmpty && !sizeEditing ? 0.0 : -21.0)
                                            .scaleEffect(size.isEmpty && !sizeEditing ? 1.0 : 0.8, anchor: .leading)
                                            .animation(.easeInOut(duration: 0.2), value: sizeEditing)
                                            .onTapGesture {
                                                sizeEditing = true
                                            }
                                    })
                                    .padding(.horizontal).padding(.trailing, 50)
                                    .background {
                                        TransparentBlurView(removeAllFilters: true)
                                            .blur(radius: 10, opaque: true)
                                            .background(colorScheme == .dark ? .black.opacity(0.5) : .white.opacity(0.5))
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                    .overlay(content: {
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(colorScheme == .dark ? Color.white : Color.black ,lineWidth: 1)
                                            .opacity(sizeEditing ? 0.8 : 0.5)
                                    })
                                    .overlay(alignment: .trailing) {
                                        Menu {
                                            Button {
                                                withAnimation(.easeInOut(duration: 0.2)){
                                                    self.size = "Random"
                                                }
                                            } label: {
                                                Label("Random", systemImage: "shuffle")
                                            }
                                            Divider()
                                            ForEach(combinedSizes, id: \.self) { element in
                                                Button {
                                                    withAnimation(.easeInOut(duration: 0.2)){
                                                        if self.size.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                                            self.size = element
                                                        } else if size.lowercased() == "random" {
                                                            self.size = element
                                                        } else if size.hasSuffix(" ") {
                                                            self.size += element
                                                        } else {
                                                            self.size += " " + element
                                                        }
                                                    }
                                                } label: {
                                                    Label(element, systemImage: "")
                                                }
                                            }
                                        } label: {
                                            Image(systemName: "plus")
                                                .font(.headline)
                                                .padding(10)
                                                .background(Color.blue)
                                                .clipShape(Circle())
                                                .shadow(color: .gray, radius: 2)
                                        }.buttonStyle(.plain).padding(.trailing, 10)
                                    }
                                
                                let isPopmart: Bool = GetSiteName() == "Popmart"
                                                                
                                TextField("", text: $color)
                                    .lineLimit(1)
                                    .focused($colorEditing)
                                    .frame(height: 57)
                                    .padding(.top, 8)
                                    .overlay(alignment: .leading, content: {
                                        Text(isPopmart ? "Ship Price (Cents, Optional)" : "Colors (space seperated)")
                                            .font(.system(size: 18)).fontWeight(.light)
                                            .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
                                            .opacity(colorEditing ? 0.8 : 0.5)
                                            .offset(y: color.isEmpty && !colorEditing ? 0.0 : -21.0)
                                            .scaleEffect(color.isEmpty && !colorEditing ? 1.0 : 0.8, anchor: .leading)
                                            .animation(.easeInOut(duration: 0.2), value: colorEditing)
                                            .onTapGesture {
                                                colorEditing = true
                                            }
                                    })
                                    .padding(.horizontal).padding(.trailing, 50)
                                    .background {
                                        TransparentBlurView(removeAllFilters: true)
                                            .blur(radius: 10, opaque: true)
                                            .background(colorScheme == .dark ? .black.opacity(0.5) : .white.opacity(0.5))
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                    .overlay(content: {
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(colorScheme == .dark ? Color.white : Color.black ,lineWidth: 1)
                                            .opacity(colorEditing ? 0.8 : 0.5)
                                    })
                                    .overlay(alignment: .trailing) {
                                        Menu {
                                            if isPopmart {
                                                Button {
                                                    self.color = "Random"
                                                } label: {
                                                    Label("Not Sure", systemImage: "questionmark")
                                                }
                                                Divider()
                                                Button {
                                                    self.color = "495"
                                                } label: {
                                                    Label("$4.95", systemImage: "dollarsign")
                                                }
                                                Button {
                                                    self.color = "795"
                                                } label: {
                                                    Label("$7.95", systemImage: "dollarsign")
                                                }
                                            } else {
                                                Button {
                                                    self.color = "Random"
                                                } label: {
                                                    Label("Random", systemImage: "shuffle")
                                                }
                                                Divider()
                                                ForEach(allColors, id: \.self) { element in
                                                    Button {
                                                        if self.color.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                                            self.color = element
                                                        } else if color.lowercased() == "random" {
                                                            self.color = element
                                                        } else if color.hasSuffix(" ") {
                                                            self.color += element
                                                        } else {
                                                            self.color += " " + element
                                                        }
                                                    } label: {
                                                        Label(element, systemImage: "")
                                                    }
                                                }
                                            }
                                        } label: {
                                            Image(systemName: "plus")
                                                .font(.headline)
                                                .padding(10)
                                                .background(Color.blue)
                                                .clipShape(Circle())
                                                .shadow(color: .gray, radius: 2)
                                        }.buttonStyle(.plain).padding(.trailing, 10)
                                    }
                                
                                VStack {
                                    HStack {
                                        Text("Advanced").font(.headline).bold()
                                        Spacer()
                                        Image(systemName: showAdvanced ? "chevron.up" : "chevron.down")
                                            .symbolEffect(.rotate, options: .speed(3), value: showAdvanced)
                                            .font(.headline).bold()
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        withAnimation(.easeInOut(duration: 0.2)){
                                            showAdvanced.toggle()
                                        }
                                    }
                                    
                                    if showAdvanced {
                                        HStack(spacing: 12){
                                            TextField("", text: $cartQuantity)
                                                .lineLimit(1).keyboardType(.numberPad)
                                                .focused($cartQuantityEditing)
                                                .frame(height: 57)
                                                .padding(.top, 8)
                                                .overlay(alignment: .leading, content: {
                                                    Text("Cart Quantity").font(.system(size: 18)).fontWeight(.light)
                                                        .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
                                                        .opacity(cartQuantityEditing ? 0.8 : 0.5)
                                                        .offset(y: cartQuantity.isEmpty && !cartQuantityEditing ? 0.0 : -21.0)
                                                        .scaleEffect(cartQuantity.isEmpty && !cartQuantityEditing ? 1.0 : 0.8, anchor: .leading)
                                                        .animation(.easeInOut(duration: 0.2), value: cartQuantityEditing)
                                                        .onTapGesture {
                                                            cartQuantityEditing = true
                                                        }
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
                                                        .stroke(colorScheme == .dark ? Color.white : Color.black ,lineWidth: 1)
                                                        .opacity(cartQuantityEditing ? 0.8 : 0.5)
                                                })
                                            
                                            TextField("", text: $delay)
                                                .lineLimit(1).keyboardType(.numberPad)
                                                .focused($delayEditing)
                                                .frame(height: 57)
                                                .padding(.top, 8)
                                                .overlay(alignment: .leading, content: {
                                                    Text("Delay (ms)").font(.system(size: 18)).fontWeight(.light)
                                                        .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
                                                        .opacity(delayEditing ? 0.8 : 0.5)
                                                        .offset(y: delay.isEmpty && !delayEditing ? 0.0 : -21.0)
                                                        .scaleEffect(delay.isEmpty && !delayEditing ? 1.0 : 0.8, anchor: .leading)
                                                        .animation(.easeInOut(duration: 0.2), value: delayEditing)
                                                        .onTapGesture {
                                                            delayEditing = true
                                                        }
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
                                                        .stroke(colorScheme == .dark ? Color.white : Color.black ,lineWidth: 1)
                                                        .opacity(delayEditing ? 0.8 : 0.5)
                                                })
                                        }
                                        HStack(spacing: 12){
                                            TextField("", text: $maxBuyPrice)
                                                .lineLimit(1).keyboardType(.numberPad)
                                                .focused($maxBuyPriceEditing)
                                                .frame(height: 57)
                                                .padding(.top, 8)
                                                .overlay(alignment: .leading, content: {
                                                    Text("MaxBuy $").font(.system(size: 18)).fontWeight(.light)
                                                        .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
                                                        .opacity(maxBuyPriceEditing ? 0.8 : 0.5)
                                                        .offset(y: maxBuyPrice.isEmpty && !maxBuyPriceEditing ? 0.0 : -21.0)
                                                        .scaleEffect(maxBuyPrice.isEmpty && !maxBuyPriceEditing ? 1.0 : 0.8, anchor: .leading)
                                                        .animation(.easeInOut(duration: 0.2), value: maxBuyPriceEditing)
                                                        .onTapGesture {
                                                            maxBuyPriceEditing = true
                                                        }
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
                                                        .stroke(colorScheme == .dark ? Color.white : Color.black ,lineWidth: 1)
                                                        .opacity(maxBuyPriceEditing ? 0.8 : 0.5)
                                                })
                                            
                                            TextField("", text: $maxBuyQuantity)
                                                .lineLimit(1).keyboardType(.numberPad)
                                                .focused($maxBuyQuantityEditing)
                                                .frame(height: 57)
                                                .padding(.top, 8)
                                                .overlay(alignment: .leading, content: {
                                                    Text("MaxBuy Qty").font(.system(size: 18)).fontWeight(.light)
                                                        .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
                                                        .opacity(maxBuyQuantityEditing ? 0.8 : 0.5)
                                                        .offset(y: maxBuyQuantity.isEmpty && !maxBuyQuantityEditing ? 0.0 : -21.0)
                                                        .scaleEffect(maxBuyQuantity.isEmpty && !maxBuyQuantityEditing ? 1.0 : 0.8, anchor: .leading)
                                                        .animation(.easeInOut(duration: 0.2), value: maxBuyQuantityEditing)
                                                        .onTapGesture {
                                                            maxBuyQuantityEditing = true
                                                        }
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
                                                        .stroke(colorScheme == .dark ? Color.white : Color.black ,lineWidth: 1)
                                                        .opacity(maxBuyQuantityEditing ? 0.8 : 0.5)
                                                })
                                        }
                                        
                                        TextField("", text: $discountCode)
                                            .lineLimit(1)
                                            .focused($discountCodeEditing)
                                            .frame(height: 57)
                                            .padding(.top, 8)
                                            .overlay(alignment: .leading, content: {
                                                Text("Discount Code").font(.system(size: 18)).fontWeight(.light)
                                                    .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
                                                    .opacity(discountCodeEditing ? 0.8 : 0.5)
                                                    .offset(y: discountCode.isEmpty && !discountCodeEditing ? 0.0 : -21.0)
                                                    .scaleEffect(discountCode.isEmpty && !discountCodeEditing ? 1.0 : 0.8, anchor: .leading)
                                                    .animation(.easeInOut(duration: 0.2), value: discountCodeEditing)
                                                    .onTapGesture {
                                                        discountCodeEditing = true
                                                    }
                                            })
                                            .padding(.horizontal).padding(.trailing, 50)
                                            .background {
                                                TransparentBlurView(removeAllFilters: true)
                                                    .blur(radius: 10, opaque: true)
                                                    .background(colorScheme == .dark ? .black.opacity(0.5) : .white.opacity(0.5))
                                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                            }
                                            .overlay(content: {
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(colorScheme == .dark ? Color.white : Color.black ,lineWidth: 1)
                                                    .opacity(discountCodeEditing ? 0.8 : 0.5)
                                            })
                                    }
                                }
                                .padding(12)
                                .background(Color.gray.opacity(0.4))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .padding(.top)
                                .onChange(of: sizeEditing) { _, new in
                                    if new {
                                        withAnimation(.easeInOut(duration: 0.3)){
                                            showAdvanced = false
                                            proxy.scrollTo("bottomScroll", anchor: .top)
                                        }
                                    }
                                }
                                .onChange(of: colorEditing) { _, new in
                                    if new {
                                        withAnimation(.easeInOut(duration: 0.3)){
                                            showAdvanced = false
                                            proxy.scrollTo("bottomScroll", anchor: .top)
                                        }
                                    }
                                }
                                .onChange(of: cartQuantityEditing) { _, new in
                                    if new {
                                        withAnimation(.easeInOut(duration: 0.3)){
                                            proxy.scrollTo("bottomScroll", anchor: .bottom)
                                        }
                                    }
                                }
                                .onChange(of: delayEditing) { _, new in
                                    if new {
                                        withAnimation(.easeInOut(duration: 0.3)){
                                            proxy.scrollTo("bottomScroll", anchor: .bottom)
                                        }
                                    }
                                }
                                .onChange(of: maxBuyPriceEditing) { _, new in
                                    if new {
                                        withAnimation(.easeInOut(duration: 0.3)){
                                            proxy.scrollTo("bottomScroll", anchor: .bottom)
                                        }
                                    }
                                }
                                .onChange(of: maxBuyQuantityEditing) { _, new in
                                    if new {
                                        withAnimation(.easeInOut(duration: 0.3)){
                                            proxy.scrollTo("bottomScroll", anchor: .bottom)
                                        }
                                    }
                                }
                                .onChange(of: discountCodeEditing) { _, new in
                                    if new {
                                        withAnimation(.easeInOut(duration: 0.3)){
                                            proxy.scrollTo("bottomScroll", anchor: .bottom)
                                        }
                                    }
                                }
                                
                                Color.clear.frame(height: 300).id("bottomScroll")
                                
                            }.safeAreaPadding(.top, 90).padding(.horizontal, 12)
                        }.scrollIndicators(.hidden).scrollDismissesKeyboard(.immediately)
                    }
                    
                    Button {
                        if getStatus().isEmpty {
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                            
                            let finalProxy: String = (proxyGroup.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) ? "na" : proxyGroup
                            
                            let finalInput: String = self.input.replacingOccurrences(of: "\n", with: " ")
                            
                            if action == .Edit {
                                let current = BotTask(
                                    profileGroup: profileGroup.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Original.profileGroup : profileGroup,
                                    profileName: profileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Original.profileName : profileName,
                                    proxyGroup: finalProxy,
                                    accountGroup: accountGroup,
                                    input: finalInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Original.input : finalInput,
                                    size: size.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Original.size : size,
                                    color: color.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Original.color : color,
                                    site: site,
                                    mode: GetCurrentMode(options: GetModes()),
                                    cartQuantity: Int(cartQuantity) ?? 1,
                                    delay: Int(delay) ?? 3500,
                                    discountCode: discountCode,
                                    maxBuyPrice: Int(maxBuyPrice) ?? 99999,
                                    maxBuyQuantity: Int(maxBuyQuantity) ?? 99999
                                )
                                
                                let result: (BotTask, String, Int) = (current, fileName, (Int(count) ?? 1))
                                
                                done(result)
                            } else {
                                let current = BotTask(profileGroup: profileGroup, profileName: profileName, proxyGroup: finalProxy, accountGroup: accountGroup, input: finalInput, size: size, color: color, site: site, mode: GetCurrentMode(options: GetModes()), cartQuantity: Int(cartQuantity) ?? 1, delay: Int(delay) ?? 3500, discountCode: discountCode, maxBuyPrice: Int(maxBuyPrice) ?? 99999, maxBuyQuantity: Int(maxBuyQuantity) ?? 99999)
                                
                                let result: (BotTask, String, Int) = (current, fileName, (Int(count) ?? 1))
                                
                                done(result)
                            }
                            
                            dismiss()
                        } else {
                            UINotificationFeedbackGenerator().notificationOccurred(.error)
                        }
                    } label: {
                        ZStack {
                            let status = getStatus()
                            
                            RoundedRectangle(cornerRadius: 12)
                                .frame(height: 45).foregroundStyle(status.isEmpty ? Color.blue : Color.gray)
                                .shadow(color: .gray, radius: 3)
                            
                            let message = taskCountMessage()
                            
                            if !status.isEmpty {
                                Text(status).font(.subheadline).bold()
                            } else if action != .Edit && !message.isEmpty {
                                Text(message)
                                    .font(.headline).bold()
                            } else {
                                Text(action == .Add ? "Add Tasks" : action == .Edit ? "Edit Tasks" : "Create Group")
                                    .font(.headline).bold()
                            }
                        }.padding(.horizontal, 12)
                    }.buttonStyle(.plain).padding(.bottom, 45)
                }.transition(.scale(scale: 0.7, anchor: .center))
            } else {
                VStack(spacing: 0){
                    Image("wealthLogo")
                        .resizable().scaledToFit()
                        .frame(width: 150.0, height: 150.0).padding(.top, 80)

                    GlitchEffect(trigger: $toggleGlitch, text: "Wealth")
                        .font(.title2).bold()
                        .foregroundStyle(.black)
                        .offset(y: -5).transition(.move(edge: .top).combined(with: .opacity))
                        .padding(.bottom, 80)
                                        
                    HStack {
                        Spacer()
                        Text("Click Anywhere to Start").font(.title3).bold()
                        Spacer()
                    }
                    
                    Spacer()
                }.transition(.opacity)
            }
        }
        .ignoresSafeArea(edges: .bottom).padding(.top, 5)
        .presentationDetents([.large]).presentationCornerRadius(30)
        .background {
            backColor()
                .overlay {
                    if !status {
                        Color.gray.opacity(0.001)
                            .onTapGesture {
                                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                                showSitePicker = true
                            }
                    }
                }
        }
        .overlay(alignment: .top){
            if status {
                headerView().transition(.move(edge: .top))
            }
        }
        .onAppear {
            appeared = true
            glitchTogg()
        }
        .onDisappear {
            appeared = false
        }
    }
    func taskCountMessage() -> String {
        var inputCount = 1
        var profileCount = 1
        
        if isVariant(input) {
            inputCount = extractUniqueVariants(input).count
        }
        
        if self.profileName == "All" {
            for i in 0..<(viewModel.profiles?.count ?? 0) {
                if let profile = viewModel.profiles?[i], profile.name == self.profileGroup {
                    profileCount = profile.profiles.count + (profile.left ?? 0)
                    break
                }
            }
        }
        
        let totalCreate = inputCount * profileCount * (Int(self.count) ?? 1)
        
        if totalCreate == 1 {
            if action == .Add {
                return "Add 1 task"
            } else {
                return "Create 1 task"
            }
        } else {
            if action == .Add {
                return "Add \(totalCreate) tasks"
            } else {
                return "Create \(totalCreate) tasks"
            }
        }
    }
    func getStatus() -> String {
        
        if action == .Add {
            if count.isEmpty {
                return "Enter a task count"
            }
            if input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return "Enter a task input"
            } else if input.contains(",") {
                return "Input cannot contain commas"
            }
            if profileGroup.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return "Pick a profile group"
            }
            if profileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return "Pick a profile"
            }
            if size.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return "Pick task sizes"
            } else if size.contains(",") {
                return "Size cannot contain commas"
            }
            if color.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return "Pick task colors"
            } else if color.contains(",") {
                return "Color cannot contain commas"
            }
        } else if action == .Create {
            if fileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return "Enter a task group name"
            } else if !isAlphanumeric(fileName) {
                return "Fix Group Name format"
            } else if (viewModel.tasks ?? []).contains(where: { $0.name.lowercased() == fileName.lowercased() }) {
                return "This group name already exists"
            }
            
            if count.isEmpty {
                return "Enter a task count"
            }
            if input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return "Enter a task input"
            } else if input.contains(",") {
                return "Input cannot contain commas"
            }
            if profileGroup.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return "Pick a profile group"
            }
            if profileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return "Pick a profile"
            }
            if size.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return "Pick task sizes"
            } else if size.contains(",") {
                return "Size cannot contain commas"
            }
            if color.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return "Pick task colors"
            } else if color.contains(",") {
                return "Color cannot contain commas"
            }
            if cartQuantity.isEmpty {
                return "Enter a cart quantity"
            }
            if delay.isEmpty {
                return "Enter a task delay"
            }
        } else if action == .Edit {
            let current = BotTask(profileGroup: profileGroup, profileName: profileName, proxyGroup: proxyGroup, accountGroup: accountGroup, input: input, size: size, color: color, site: site, mode: GetCurrentMode(options: GetModes()), cartQuantity: Int(cartQuantity) ?? 1, delay: Int(delay) ?? 3500, discountCode: discountCode, maxBuyPrice: Int(maxBuyPrice) ?? 99999, maxBuyQuantity: Int(maxBuyQuantity) ?? 99999)
            
            if current == Original {
                return "No edits to apply"
            }
        }
        
        return ""
    }
    func GetValidProfiles() -> [String] {
        var valid = [String]()
        
        for i in 0..<(viewModel.profiles?.count ?? 0) {
            if let profile = viewModel.profiles?[i], profile.name == self.profileGroup {
                valid = profile.profiles
                break
            }
        }
        
        return valid
    }
    func glitchTogg() {
        Task { toggleGlitch.toggle() }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if appeared && site.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                glitchTogg()
            }
        }
    }
    func GetCurrentMode(options: [Modes]) -> String {
        let current = self.mode.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        for i in 0..<options.count {
            if options[i].rawValue.lowercased() == current || options[i].rawValue.lowercased().contains(current) {
                return options[i].rawValue
            }
        }
        
        if options.contains(Modes.Raffle) {
            return Modes.Raffle.rawValue
        }
        
        return Modes.Normal.rawValue
    }
    func GetModes() -> [Modes] {
        let scope = GetSiteName()
        
        if scope == "Pokemon" {
            return [Modes.Normal, Modes.SetShipping]
        } else if scope == "Popmart" {
            return [Modes.Normal, Modes.Fast, Modes.Wait,
                    Modes.NormalManual, Modes.FastManual, Modes.WaitManual,
                    Modes.SetShipping]
        } else if scope == "Nike" {
            return [Modes.Flow, Modes.Raffle]
        } else {
            return [Modes.Fast, Modes.Normal, Modes.Preload, Modes.Wait]
        }
    }
    func GetSiteName() -> String {
        let name = site.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        if name.contains("pokemon") {
            return "Pokemon"
        } else if name.contains("popmart") {
            return "Popmart"
        } else if name.contains("nike") {
            return "Nike"
        } else {
            if let name = allSites.first(where: { $0.value == site })?.key {
                return name
            }
            
            return "Custom Shopify"
        }
    }
    func GetInputType() -> String {
        let name = site.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        if name.contains("pokemon") {
            return "(URL, Keyword)"
        } else if name.contains("popmart") {
            return "(URL, SPU, pop/#)"
        } else if name.contains("nike") {
            return "(SKU)"
        } else {
            return "(Variant, URL, Keyword, SKU)"
        }
    }
    @ViewBuilder
    func headerView() -> some View {
        ZStack {
            HStack {
                Spacer()
                
                VStack(spacing: 0){
                    let name = GetSiteName()
                    
                    if name == "Custom Shopify" {
                        Text(name)
                            .font(.title3).fontWeight(.heavy).italic().lineLimit(1).minimumScaleFactor(0.8)
                            .frame(height: 32).frame(maxWidth: 170)
                    } else {
                        Text(name)
                            .font(.title3).fontWeight(.heavy).lineLimit(1).minimumScaleFactor(0.8)
                            .frame(height: 32).frame(maxWidth: 170)
                    }
                    
                    Text(site).font(.caption).fontWeight(.semibold).foregroundStyle(.blue).lineLimit(1)
                }
                .onTapGesture {
                    if lock || setShippingLock {
                        UINotificationFeedbackGenerator().notificationOccurred(.error)
                    } else {
                        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                        showSitePicker = true
                    }
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
                        Image(systemName: "xmark").font(.title3).bold()
                    }
                }.buttonStyle(.plain)
                
                Spacer()
                
                let modes = GetModes()
                
                if setShippingLock {
                    Text("SetShipping")
                        .font(.subheadline).bold()
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Color.gray.gradient.opacity(0.3))
                        .clipShape(Capsule())
                        .shadow(color: .gray, radius: 3)
                } else if modes.count == 1 {
                    Text("Normal")
                        .font(.subheadline).bold()
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Color.gray.gradient.opacity(0.3))
                        .clipShape(Capsule())
                        .shadow(color: .gray, radius: 3)
                } else {
                    Menu {
                        ForEach(modes, id: \.rawValue) { element in
                            Button {
                                self.mode = element.rawValue
                            } label: {
                                Label(element.rawValue, systemImage: "")
                            }
                        }
                    } label: {
                        Text(GetCurrentMode(options: modes))
                            .font(.subheadline).bold()
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background(Color.gray.gradient.opacity(0.3))
                            .clipShape(Capsule())
                            .shadow(color: .gray, radius: 3)
                    }.buttonStyle(.plain)
                }
            }
        }
        .padding(.top, 10).padding(.horizontal).padding(.bottom, 10)
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
        }
        .ignoresSafeArea()
    }
}

struct SelectSiteExtension: View {
    @Binding var showSitePicker: Bool
    @Binding var baseUrl: String
    
    var body: some View {
        VStack {
            
        }
        .sheet(isPresented: $showSitePicker, content: {
            SelectSiteSheet(maxSelect: 1) { result in
                if let first = result.first?.1 {
                    if baseUrl.isEmpty {
                        withAnimation(.easeInOut(duration: 0.3)){
                            baseUrl = first
                        }
                    } else {
                        baseUrl = first
                    }
                }
            }
        })
    }
}

func isVariant(_ input: String) -> Bool {
    let components = input.components(separatedBy: .whitespacesAndNewlines)
    
    for component in components {
        if component.isEmpty {
            continue
        }
        
        for character in component {
            if !character.isNumber {
                return false
            }
        }
    }
    
    return true
}

func extractUniqueVariants(_ input: String) -> [String] {
    let components = input.components(separatedBy: .whitespacesAndNewlines)
    
    let nonEmptyComponents = components.filter { !$0.isEmpty }
    
    return Array(Set(nonEmptyComponents))
}

func isAlphanumeric(_ string: String) -> Bool {
    return string.allSatisfy { $0.isLetter || $0.isNumber }
}
