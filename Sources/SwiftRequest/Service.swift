import Foundation

public protocol Service {
    init(baseURL: URL, session: URLSession)
}

extension Service {
    public init(baseURL: URL) {
        self.init(baseURL: baseURL, session: .shared)
    }
}
