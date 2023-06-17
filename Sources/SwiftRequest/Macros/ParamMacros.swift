@attached(member)
public macro Path(_ name: String = "") = #externalMacro(module: "SwiftRequestMacros", type: "ParamMacro")

@attached(member)
public macro QueryParam(_ name: String = "") = #externalMacro(module: "SwiftRequestMacros", type: "ParamMacro")

@attached(member)
public macro Header(_ name: String = "") = #externalMacro(module: "SwiftRequestMacros", type: "ParamMacro")

@attached(member)
public macro FormField(_ name: String = "") = #externalMacro(module: "SwiftRequestMacros", type: "ParamMacro")

@attached(member)
public macro Body() = #externalMacro(module: "SwiftRequestMacros", type: "BodyMacro")
