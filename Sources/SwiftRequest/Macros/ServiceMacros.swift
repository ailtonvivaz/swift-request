@attached(peer, names: suffixed(Impl))
public macro Service(resource: String) = #externalMacro(module: "SwiftRequestMacros", type: "ServiceMacro")

@attached(peer, names: suffixed(Impl))
public macro Service() = #externalMacro(module: "SwiftRequestMacros", type: "ServiceMacro")
