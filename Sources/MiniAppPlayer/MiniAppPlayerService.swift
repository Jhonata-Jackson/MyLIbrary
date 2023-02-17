import Foundation

struct MiniAppDataExtras: Codable {
    var cid: String
}

struct MiniAppDataState: Codable {
    var view: String
    var extras: MiniAppDataExtras
    var miniAppBootstrapUrl: String
    var developerEmail: String;
    var publicKey: String;
    var title: String;
    var slug: String;
}

struct MiniAppDataOnShareApi: Codable {
    var state: MiniAppDataState?
    var url: String?
}

struct MiniAppPlayerInput: Codable, Hashable {
    var uri: String
    var albCookie: String?
}

struct ShareIdModel: Hashable {
    var id: String
}

enum FindMiniAppDataError: Error {
    case InvalidUrl
    case InvalidCid
}

private enum MiniAppEndpoints: String {
    case Workspace = "https://miniapps.hml.amedigital.com/share-api/share"
    case Published = "https://miniapps.hml.amedigital.com/miniapp-manager-api/o/mini-apps/"
}

class MiniAppPlayerService {
        
    func findMiniAppData(url: String) async throws -> MiniAppDataOnShareApi {
        
        guard let url = URL(string: url) else {
            throw FindMiniAppDataError.InvalidUrl
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decodedData = try JSONDecoder().decode(MiniAppDataOnShareApi.self, from: data)
        
        return decodedData
    }
    
    func getMiniAppInput(miniAppDeepLink: String) async throws -> MiniAppPlayerInput{
        
        if(miniAppDeepLink.contains("/share")) {
            print(">>> isWorkspace")
            let miniAppWorkspaceInput = try await self.getWorkspaceMiniAppInput(miniAppDeepLink: miniAppDeepLink)
            return MiniAppPlayerInput(uri: miniAppWorkspaceInput.uri, albCookie: miniAppWorkspaceInput.albCookie)
        } else {
            print(">>> isPublished")
            let miniAppPublishedInput = try await self.getPublishedMiniAppInput(miniAppDeepLink: miniAppDeepLink)
            return MiniAppPlayerInput(uri: miniAppPublishedInput.uri)
        }
    }
    
    func getWorkspaceMiniAppInput(miniAppDeepLink: String) async throws -> MiniAppPlayerInput {
        
        let shareId = miniAppDeepLink.components(separatedBy: "share/")[1].components(separatedBy: "?environment")[0]
        let url = "\(MiniAppEndpoints.Workspace.rawValue)/\(shareId)"
        
        let miniAppDataOnServer = try await self.findMiniAppData(url: url)
        let bootstrapUrl = miniAppDataOnServer.state?.miniAppBootstrapUrl
        
        guard let cid = miniAppDataOnServer.state?.extras.cid else {
            throw FindMiniAppDataError.InvalidCid
        }
        
        // Processo de decode do cid para pegar o albCookie
        let cidUrlDecoded = cid.removingPercentEncoding!;
        let base64Encoded = Data(base64Encoded: cidUrlDecoded)!
        let albCookie = String(data: base64Encoded, encoding: .utf8)!
        
        return MiniAppPlayerInput(uri: bootstrapUrl!, albCookie: albCookie)
    }
    
    func getPublishedMiniAppInput(miniAppDeepLink: String) async throws -> MiniAppPlayerInput {
        
        let slug = miniAppDeepLink.components(separatedBy: "open/")[1]
        let url = "\(MiniAppEndpoints.Published.rawValue)/\(slug)"
        
        let miniAppDataOnServer = try await self.findMiniAppData(url: url)
        return MiniAppPlayerInput(uri: miniAppDataOnServer.url!)
    }
}
