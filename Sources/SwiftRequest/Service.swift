import Foundation

open class Service {
    public let baseURL: URL
    public let executor: ServiceExecutor
    
    public init(baseURL: URL, executor: ServiceExecutor = URLSessionServiceExecutor()) {
        self.baseURL = baseURL
        self.executor = executor
    }
    
    convenience public init(baseURL: String, executor: ServiceExecutor = URLSessionServiceExecutor()) {
        guard let baseURL = URL(string: baseURL) else {
            fatalError("Invalid baseURL")
        }
        
        self.init(baseURL: baseURL, executor: executor)
    }
    
    convenience public init(baseURL: URL, session: URLSession) {
        self.init(baseURL: baseURL, executor: URLSessionServiceExecutor(session))
    }
    
    convenience public init(baseURL: String, session: URLSession) {
        self.init(baseURL: baseURL, executor: URLSessionServiceExecutor(session))
    }
}
