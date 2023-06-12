import Foundation

public protocol Service {
    init(baseURL: URL, session: URLSession)
}

extension Service {
    public init(baseURL: URL, session: URLSession = .shared) {
        self.init(baseURL: baseURL, session: session)
    }
    
    public init(baseURL: String, session: URLSession = .shared) {
        guard let baseURL = URL(string: baseURL) else {
            fatalError("Invalid baseURL")
        }
        
        self.init(baseURL: baseURL, session: session)
    }
}
