import SwiftUI
import Foundation

struct MiniAppLoader: View {
    @State var miniAppPlayerInput: MiniAppPlayerInput?
    @State private var isLoading = false
    
    let miniAppDeepLink: String;
    
    init (miniAppDeepLink: String){
        self.miniAppDeepLink = miniAppDeepLink
    }

    
    func loadMiniAppInput() async {
        do {
            miniAppPlayerInput = try await MiniAppPlayerService().getMiniAppInput(miniAppDeepLink: self.miniAppDeepLink)
        } catch {
            print("loadMiniAppData.getMiniAppPlayerInput.error: ", error)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack{
                if let safeMiniAppInput = miniAppPlayerInput {
                    NavigationLink(destination: MiniAppPlayerComponent(miniAppPlayerInput: safeMiniAppInput), isActive: $isLoading) {
                        Text("Loading miniapp...")
                    }
                }
            }.onAppear {
                Task {
                    await loadMiniAppInput()
                    isLoading = true
                }
            }
        }
        .padding()
    }
}
