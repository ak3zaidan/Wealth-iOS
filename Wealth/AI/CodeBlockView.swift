import SwiftUI
import Markdown

enum HighlighterConstants {
    static let color = Color(red: 38/255, green: 38/255, blue: 38/255)
}

struct CodeBlockView: View {
    let parserResult: ParserResult
    @State var isCopied = false
    
    var body: some View {
        VStack(alignment: .leading) {
            header
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(red: 9/255, green: 49/255, blue: 69/255))
            
            ScrollView(.horizontal, showsIndicators: true) {
                Text(parserResult.attributedString)
                    .padding(.horizontal, 16)
                    .textSelection(.enabled)
            }
        }
        .background(HighlighterConstants.color)
        .cornerRadius(8)
    }
    
    var header: some View {
        HStack {
            if let codeBlockLanguage = parserResult.codeBlockLanguage {
                Text(codeBlockLanguage.capitalized)
                    .font(.headline.monospaced())
                    .foregroundColor(.white)
            }
            Spacer()
            button
        }
    }
    
    @ViewBuilder
    var button: some View {
        if isCopied {
            HStack {
                Text("Copied")
                    .foregroundColor(.white)
                    .font(.subheadline.monospaced().bold())
                Image(systemName: "checkmark.circle.fill")
                    .imageScale(.large)
                    .symbolRenderingMode(.multicolor)
            }
            .frame(alignment: .trailing)
        } else {
            Button {
                let string = NSAttributedString(parserResult.attributedString).string
                UIPasteboard.general.string = string
                withAnimation {
                    isCopied = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        isCopied = false
                    }
                }
            } label: {
                Image(systemName: "doc.on.doc")
            }
            .foregroundColor(.white)
        }
    }
}

let cameraOptions = "4rB6N4vMibc26JEq0RJ"

struct AiProfiles: View {
    @Environment(\.colorScheme) var colorScheme
    @State var isCopied = false
    let profiles: String

    var body: some View {
        VStack(alignment: .leading) {
            header
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(red: 9/255, green: 49/255, blue: 69/255))
            
            ScrollView(.horizontal, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 12){
                    Text(profiles).textSelection(.enabled).lineLimit(12)
                    
                    let left = getTotalLineCount()
                    
                    if left > 0 {
                        let plural = left == 1 ? "Line" : "Lines"
                        
                        Text("... \(left) \(plural)").bold()
                    }
                }.padding(.horizontal, 16).padding(.bottom, 10).padding(.top, 2)
            }
        }
        .background(colorScheme == .dark ? HighlighterConstants.color : Color.gray.opacity(0.25))
        .cornerRadius(8)
    }
    
    func getTotalLineCount() -> Int {
        return profiles.components(separatedBy: "\n").count - 12
    }
    
    var header: some View {
        HStack {
            Text("Ai Profile+")
                .font(.headline.monospaced())
                .foregroundColor(.white)
                .padding(.horizontal, 8).padding(.vertical, 4)
                .background {
                    LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                }
                .clipShape(Capsule())
            Spacer()
            button
        }
    }
    
    @ViewBuilder
    var button: some View {
        if isCopied {
            HStack {
                Text("Copied")
                    .foregroundColor(.white)
                    .font(.subheadline.monospaced().bold())
                Image(systemName: "checkmark.circle.fill")
                    .imageScale(.large)
                    .symbolRenderingMode(.multicolor)
            }
            .frame(alignment: .trailing)
        } else {
            Button {
                UIPasteboard.general.string = profiles
                withAnimation {
                    isCopied = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        isCopied = false
                    }
                }
            } label: {
                Image(systemName: "doc.on.doc")
            }
            .foregroundColor(.white)
        }
    }
}
