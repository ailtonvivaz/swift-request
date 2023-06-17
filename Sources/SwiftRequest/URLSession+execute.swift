import Foundation

extension URLSession {
    public func execute<Output: Decodable>(_ request: Request) async throws -> Output {
        let (output, _): (Output, _) = try await self.execute(request)
        return output
    }
    
    public func execute<Output: Decodable>(_ request: Request) async throws -> (Output, HTTPURLResponse) {
        let (data, response) = try await self.execute(request)
        let output = try JSONDecoder().decode(Output.self, from: data)
        return (output, response)
    }
    
    public func execute(_ request: Request) async throws -> Data {
        let (data, _) = try await self.execute(request)
        return data
    }
    
    public func execute(_ request: Request) async throws -> (Data, HTTPURLResponse) {
        let urlRequest = try request.getURLRequest()
        let (data, response) = try await URLSession.shared.data(for: urlRequest) as! (Data, HTTPURLResponse)
        guard (200..<300).contains(response.statusCode) else {
            throw HTTPResponseError(data: data, response: response)
        }
        return (data, response)
    }
}
