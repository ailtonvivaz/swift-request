import Foundation

public protocol ServiceExecutor {
    func execute(_ request: Request) async throws -> (Data, HTTPURLResponse)
}

extension ServiceExecutor {
    public func callAsFunction<Output: Decodable>(_ request: Request) async throws -> Output {
        let (output, _): (Output, _) = try await self(request)
        return output
    }
    
    public func callAsFunction<Output: Decodable>(_ request: Request) async throws -> (Output, HTTPURLResponse) {
        let (data, response): (Data, HTTPURLResponse) = try await self.execute(request)
        let output = try JSONDecoder().decode(Output.self, from: data)
        return (output, response)
    }
    
    public func callAsFunction(_ request: Request) async throws -> Data {
        let (data, _) = try await self(request)
        return data
    }
    
    public func callAsFunction(_ request: Request) async throws -> (Data, HTTPURLResponse) {
        return try await execute(request)
    }
}
