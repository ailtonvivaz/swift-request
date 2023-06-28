import Foundation
import Alamofire
import SwiftRequest

class AlamofireServiceExecutor: ServiceExecutor {
    let session: Session
    
    struct Error: Swift.Error {
        let response: DataResponse<Data, AFError>
    }
    
    init(_ session: Session = .default) {
        self.session = session
    }
    
    func execute(_ request: SwiftRequest.Request) async throws -> (Data, HTTPURLResponse) {
        let task = session.request(request).serializingData()
        let response = await task.response
        
        if let data = response.data, let urlResponse = response.response {
            return (data, urlResponse)
        }
        
        if let error = response.error {
            throw error
        }
        
        throw Error(response: response)
    }
}

extension SwiftRequest.Request: URLRequestConvertible {}
