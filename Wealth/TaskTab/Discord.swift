import SwiftUI
import WebKit
import Foundation

struct DiscordWebView: UIViewRepresentable {
    @Binding var username: String
    @Binding var id: String
    @Binding var isLoggedIn: Bool

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: DiscordWebView
        weak var webView: WKWebView?
        var timer: Timer?
        var added = false

        init(parent: DiscordWebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            self.webView = webView
            webView.configuration.userContentController.removeAllUserScripts()
            webView.configuration.userContentController.removeAllScriptMessageHandlers()
            startPollingAccount(in: webView)
        }

        func startPollingAccount(in webView: WKWebView) {
            timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
                webView.evaluateJavaScript("document.location.href") { (result, _) in
                    if let urlString = result as? String, urlString != "https://discord.com/login" {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            self?.parent.isLoggedIn = true
                        }
                        self?.extractMultiAccountStore(webView: webView)
                    }
                }
            }
        }

        func extractMultiAccountStore(webView: WKWebView) {
            let jsScript = """
            var iframe = document.createElement('iframe');
            iframe.style.display = 'none';
            iframe.onload = function() {
                var storage = {};
                var iframeLocalStorage = iframe.contentWindow.localStorage;
                for (var i = 0; i < iframeLocalStorage.length; i++) {
                    var key = iframeLocalStorage.key(i);
                    var value = iframeLocalStorage.getItem(key);
                    storage[key] = value;
                }
                document.body.removeChild(iframe);
                window.webkit.messageHandlers.AuthDiscord.postMessage(JSON.stringify(storage));
            };
            iframe.src = 'about:blank';
            document.body.appendChild(iframe);
            """
            
            if !added {
                added = true
                webView.configuration.userContentController.add(self, name: "AuthDiscord")
            }
            webView.evaluateJavaScript(jsScript)
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "AuthDiscord", let jsonString = message.body as? String {
                self.parseMultiAccountStore(jsonString)
            }
        }

        func parseMultiAccountStore(_ jsonString: String) {
            if let jsonData = jsonString.data(using: .utf8) {
                do {
                    if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
                       let multiAccountStore = json["MultiAccountStore"] as? String {
                        
                        if let multiAccountData = multiAccountStore.data(using: .utf8),
                           let multiAccountJson = try JSONSerialization.jsonObject(with: multiAccountData, options: []) as? [String: Any],
                           let state = multiAccountJson["_state"] as? [String: Any],
                           let users = state["users"] as? [[String: Any]],
                           let firstUser = users.first {
                            
                            let username = firstUser["username"] as? String
                            let id = firstUser["id"] as? String

                            if let username, let id, !username.isEmpty && !id.isEmpty {
                                self.parent.username = username
                                self.parent.id = id
                            }
                            
                            timer?.invalidate()
                            if webView != nil {
                                webView?.configuration.userContentController.removeAllUserScripts()
                                webView?.configuration.userContentController.removeAllScriptMessageHandlers()
                            }
                        }
                    }
                } catch {
                    print("Error parsing JSON: \(error)")
                }
            }
        }

        deinit {
            timer?.invalidate()
            if webView != nil {
                webView?.configuration.userContentController.removeAllUserScripts()
                webView?.configuration.userContentController.removeAllScriptMessageHandlers()
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: URL(string: "https://discord.com/login")!))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}
}
