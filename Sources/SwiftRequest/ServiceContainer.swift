import Foundation

public class ServiceContainer {
    let baseURL: URL
    let session: URLSession
    
    public init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }
    
    convenience public init(baseURL: String, session: URLSession = .shared) {
        guard let baseURL = URL(string: baseURL) else {
            fatalError("Invalid baseURL")
        }
        
        self.init(baseURL: baseURL, session: session)
    }
}
