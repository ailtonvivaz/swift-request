@attached(peer)
public macro GET(_ path: String = "") = #externalMacro(module: "SwiftRequestMacros", type: "MethodMacro")

@attached(peer)
public macro POST(_ path: String = "") = #externalMacro(module: "SwiftRequestMacros", type: "MethodMacro")

@attached(peer)
public macro PUT(_ path: String = "") = #externalMacro(module: "SwiftRequestMacros", type: "MethodMacro")

@attached(peer)
public macro PATCH(_ path: String = "") = #externalMacro(module: "SwiftRequestMacros", type: "MethodMacro")

@attached(peer)
public macro DELETE(_ path: String = "") = #externalMacro(module: "SwiftRequestMacros", type: "MethodMacro")

@attached(peer)
public macro OPTIONS(_ path: String = "") = #externalMacro(module: "SwiftRequestMacros", type: "MethodMacro")

@attached(peer)
public macro HEAD(_ path: String = "") = #externalMacro(module: "SwiftRequestMacros", type: "MethodMacro")
