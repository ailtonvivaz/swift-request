@attached(member, names: named(baseURL), named(session), named(init(baseURL:session:)))
@attached(conformance)
public macro Service() = #externalMacro(module: "SwiftRequestMacros", type: "ServiceMacro")

@attached(member, names: named(baseURL), named(session), named(init(baseURL:session:)))
@attached(conformance)
public macro Service(resource: String) = #externalMacro(module: "SwiftRequestMacros", type: "ServiceMacro")

@attached(peer, names: overloaded)
public macro GET<T: Decodable>(_ path: String, headers: [String: any CustomStringConvertible] = [:]) = #externalMacro(module: "SwiftRequestMacros", type: "GetRequestMacro")

@attached(peer, names: overloaded)
public macro POST<T: Decodable>(_ path: String, headers: [String: any CustomStringConvertible] = [:]) = #externalMacro(module: "SwiftRequestMacros", type: "PostRequestMacro")

@attached(peer, names: overloaded)
public macro PUT<T: Decodable>(_ path: String, headers: [String: any CustomStringConvertible] = [:]) = #externalMacro(module: "SwiftRequestMacros", type: "PutRequestMacro")

@attached(peer, names: overloaded)
public macro PATCH<T: Decodable>(_ path: String, headers: [String: any CustomStringConvertible] = [:]) = #externalMacro(module: "SwiftRequestMacros", type: "PatchRequestMacro")

@attached(peer, names: overloaded)
public macro DELETE<T: Decodable>(_ path: String, headers: [String: any CustomStringConvertible] = [:]) = #externalMacro(module: "SwiftRequestMacros", type: "DeleteRequestMacro")

@attached(peer, names: overloaded)
public macro OPTIONS<T: Decodable>(_ path: String, headers: [String: any CustomStringConvertible] = [:]) = #externalMacro(module: "SwiftRequestMacros", type: "OptionsRequestMacro")

@attached(peer, names: overloaded)
public macro HEAD<T: Decodable>(_ path: String, headers: [String: any CustomStringConvertible] = [:]) = #externalMacro(module: "SwiftRequestMacros", type: "HeadRequestMacro")
