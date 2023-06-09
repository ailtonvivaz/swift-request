@attached(member, names: named(baseURL), named(session), named(init(baseURL:session:)))
@attached(conformance)
public macro Service(_ route: String? = nil) = #externalMacro(module: "SwiftRequestMacros", type: "ServiceMacro")

public protocol Service {}

@attached(peer, names: overloaded)
public macro GET<T: Decodable>(_ path: String, headers: [String: any CustomStringConvertible] = [:]) = #externalMacro(module: "SwiftRequestMacros", type: "GetRequestMacro")

@attached(peer, names: overloaded)
public macro POST<T: Decodable>(_ path: String, headers: [String: any CustomStringConvertible] = [:], body: T) = #externalMacro(module: "SwiftRequestMacros", type: "PostRequestMacro")

@attached(peer, names: overloaded)
public macro PUT<T: Decodable>(_ path: String, headers: [String: any CustomStringConvertible] = [:], body: T) = #externalMacro(module: "SwiftRequestMacros", type: "PutRequestMacro")

@attached(peer, names: overloaded)
public macro PATCH<T: Decodable>(_ path: String, headers: [String: any CustomStringConvertible] = [:], body: T) = #externalMacro(module: "SwiftRequestMacros", type: "PatchRequestMacro")

@attached(peer, names: overloaded)
public macro DELETE<T: Decodable>(_ path: String, headers: [String: any CustomStringConvertible] = [:]) = #externalMacro(module: "SwiftRequestMacros", type: "DeleteRequestMacro")
