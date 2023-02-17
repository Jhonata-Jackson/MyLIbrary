import SwiftUI
import WebKit
import Foundation

struct MiniAppPlayerComponent: UIViewRepresentable {
    
    let miniAppPlayerInput: MiniAppPlayerInput
   
    func makeUIView(context: Context) -> WKWebView {
    
        let coordinator = makeCoordinator()
        
        let userContentController = WKUserContentController()
        userContentController.add(coordinator, name: "cffBridge")
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        
        let request = URLRequest(url: URL(string: miniAppPlayerInput.uri)!)
        webView.load(request)
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
    }
    
    func makeCoordinator() -> MiniAppWebViewCoordinator {
        MiniAppWebViewCoordinator(self.miniAppPlayerInput)
    }
}

class MiniAppWebViewCoordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
    let miniAppPlayerInput: MiniAppPlayerInput

    init(_ miniAppPlayerInput: MiniAppPlayerInput) {
        self.miniAppPlayerInput = miniAppPlayerInput
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print(">>> start loading webView")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        if(miniAppPlayerInput.albCookie != nil) {
            webView.evaluateJavaScript(getAlbCookieScript())
        }
       
        print(">>> finish loading webView")
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.body)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(error)
    }
    
    func getAlbCookieScript() -> String {
        return """
           let mustReload = document.querySelector("body").innerText === "Ops: tela em branco.";

                       console.log("configurando alb...")

                       if(mustReload){
                           console.debug("document.cookie", "\(miniAppPlayerInput.albCookie!)")
                           document.cookie = "\(miniAppPlayerInput.albCookie!); path=/;";
                           document.cookie = "\(miniAppPlayerInput.albCookie!.replacingOccurrences(of: "AWSALB", with: "AWSALBCORS")); path=/;"
                           window.location.reload(true);
                       }
        """
    }
}
