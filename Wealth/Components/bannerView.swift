import SwiftUI

struct bannerView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var popRoot: PopToRoot
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: popRoot.alertImage).font(.title3)
                    .foregroundStyle(.blue)
                Text(popRoot.alertReason)
                Spacer()
            }
            Button(action: {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                withAnimation(.easeInOut(duration: 0.2)){
                    popRoot.showAlert = false
                }
            }, label: {
                HStack {
                    Spacer()
                    Image(systemName: "xmark")
                        .font(.subheadline)
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                    Spacer()
                }
                .frame(width: 30, height: 30)
                .background(Color(red: 5 / 255, green: 176 / 255, blue: 255 / 255))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
            })
        }
        .frame(height: 80)
        .padding(.horizontal, 10)
        .background {
            ZStack {
                if colorScheme == .dark {
                    Color.black
                    Color.blue.opacity(0.15)
                } else {
                    Color.white
                    Color.blue.opacity(0.05)
                }
            }
        }
        .overlay(content: {
            RoundedRectangle(cornerRadius: 15)
                .stroke(.blue, lineWidth: 1.0)
        })
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(radius: 3)
        .padding(.horizontal)
        .onAppear(perform: {
            let id = UUID().uuidString
            popRoot.alertID = id
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if popRoot.alertID == id {
                    withAnimation(.easeInOut(duration: 0.2)){
                        popRoot.showAlert = false
                    }
                }
            }
        })
        .onChange(of: popRoot.alertReason) { _, _ in
            let id = UUID().uuidString
            popRoot.alertID = id
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if popRoot.alertID == id {
                    withAnimation(.easeInOut(duration: 0.2)){
                        popRoot.showAlert = false
                    }
                }
            }
        }
    }
}
