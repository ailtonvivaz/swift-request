import Foundation

public struct Request {
    let url: URL
    let method: String
    let queryParams: Params?
    let headers: Params?
    let formFields: Params?
    let body: (any Encodable)?
    
    public typealias Params = [String: (any CustomStringConvertible)?]
    
    public init(
        url: URL,
        method: String = "GET",
        queryParams: Params? = nil,
        headers: Params? = nil,
        formFields: Params? = nil,
        body: (any Encodable)? = nil
    ) {
        self.url = url
        self.method = method
        self.queryParams = queryParams
        self.headers = headers
        self.formFields = formFields
        self.body = body
    }
}
