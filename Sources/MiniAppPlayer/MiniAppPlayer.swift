import SwiftUI

public struct MiniAppPlayer {
    public init() {
    }
    
    public func openMiniApp(miniAppDeepLink: String) -> some View {
        MiniAppLoader(miniAppDeepLink: miniAppDeepLink);
    }
}
