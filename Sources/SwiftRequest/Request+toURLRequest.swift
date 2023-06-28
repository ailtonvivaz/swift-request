import Foundation

public extension Request {
    func asURLRequest() throws -> URLRequest {
        let url: URL
        if let queryParams {
            var components = URLComponents(url: self.url, resolvingAgainstBaseURL: false)!
            components.queryItems = queryParams.compactMap { key, value in
                guard let value = value else { return nil }
                return URLQueryItem(name: key, value: value.description)
            }
            
            url = components.url!
        } else {
            url = self.url
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = self.method
        
        if let formFields = self.formFields {
            var form = URLComponents()
            form.queryItems = formFields.compactMap { key, value in
                guard let value = value else { return nil }
                return URLQueryItem(name: key, value: value.description)
            }
            
            request.httpBody = form.query?.data(using: .utf8)
        }
        
        if let body {
            if body is Data {
                request.httpBody = body as? Data
            } else {
                request.httpBody = try JSONEncoder().encode(body)
            }
        }
        
        if let headers {
            for (key, value) in headers {
                guard let value = value else { continue }
                request.addValue(value.description, forHTTPHeaderField: key)
            }
        }
        
        return request
    }
}
