import Foundation

public protocol ServiceExecutor {
    func execute(_ request: Request) async throws -> (Data, HTTPURLResponse)
}

extension ServiceExecutor {
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
}
