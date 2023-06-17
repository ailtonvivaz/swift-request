import SwiftRequest
import Foundation

@Service(resource: "sample")
protocol SampleService {
    @POST("hello/{id}/{limit}")
    func hello(@Path id: String?, @Path limit: Int) async throws -> [Int]
}
