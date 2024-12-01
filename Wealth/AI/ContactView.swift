import SwiftUI

struct ContactView: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var popRoot: PopToRoot
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @State var reason = ""
    @FocusState var isEditing
    @State var desc = ""
    @FocusState var isDescEditing
    
    var body: some View {
        ZStack {
            backColor()
            VStack(spacing: 40){
                HStack(alignment: .top){
                    VStack(alignment: .leading){
                        Text("Contact Us").font(.title).bold()
                        Text("We respond by email within 1-2 days.")
                            .font(.subheadline).foregroundStyle(.gray)
                    }
                    Spacer()
                    
                    let status = !reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !desc.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        if status {
                            UserService().uploadQuestion(email: auth.currentUser?.email ?? "", reason: reason, desc: desc)
                            popRoot.presentAlert(image: "checkmark", text: "We received your inquiry!")
                        }
                        dismiss()
                    } label: {
                        Text(status ? "Send" : "Cancel")
                            .font(.subheadline)
                            .padding(.horizontal, 10).padding(.vertical, 4)
                            .background(status ? Color.blue : Color.gray)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }.buttonStyle(.plain)
                }.padding(.bottom, 30)
                
                TextField("", text: $reason)
                    .lineLimit(1)
                    .focused($isEditing)
                    .frame(height: 57)
                    .padding(.top, 8)
                    .overlay(alignment: .leading, content: {
                        Text("Contact Reason").font(.system(size: 18)).fontWeight(.light)
                            .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
                            .opacity(isEditing ? 0.8 : 0.5)
                            .offset(y: reason.isEmpty && !isEditing ? 0.0 : -21.0)
                            .scaleEffect(reason.isEmpty && !isEditing ? 1.0 : 0.8, anchor: .leading)
                            .animation(.easeInOut(duration: 0.2), value: isEditing)
                            .onTapGesture {
                                isEditing = true
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
                            .opacity(isEditing ? 0.8 : 0.5)
                    })
                    
                TextField("", text: $desc, axis: .vertical)
                    .focused($isDescEditing)
                    .frame(minHeight: 57)
                    .padding(.top, 6).padding(.bottom, 6)
                    .overlay(alignment: .topLeading, content: {
                        Text("Description").font(.system(size: 18)).fontWeight(.light)
                            .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
                            .opacity(isDescEditing ? 0.8 : 0.5)
                            .offset(y: desc.isEmpty && !isDescEditing ? 20.0 : -26.0)
                            .scaleEffect(desc.isEmpty && !isDescEditing ? 1.0 : 0.8, anchor: .leading)
                            .animation(.easeInOut(duration: 0.2), value: isDescEditing)
                            .onTapGesture {
                                isDescEditing = true
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
                            .opacity(isDescEditing ? 0.8 : 0.5)
                    })
                
                Spacer()
            }
            .padding(.top).padding(.horizontal)
        }
        .ignoresSafeArea()
        .presentationDetents([.large])
        .presentationCornerRadius(30)
        .presentationDragIndicator(.visible)
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
