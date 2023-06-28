import Foundation

public class URLSessionServiceExecutor: ServiceExecutor {
    private let session: URLSession
    
    public init(_ session: URLSession = .shared) {
        self.session = session
    }
    
    public func execute(_ request: Request) async throws -> (Data, HTTPURLResponse) {
        let urlRequest = try request.asURLRequest()
        let (data, response) = try await session.data(for: urlRequest) as! (Data, HTTPURLResponse)
        guard (200..<300).contains(response.statusCode) else {
            throw HTTPResponseError(data: data, response: response)
        }
        return (data, response)
    }
}
