import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct SwiftRequestPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ServiceMacro.self,
        GetRequestMacro.self,
        PostRequestMacro.self,
        PutRequestMacro.self,
        PatchRequestMacro.self,
        DeleteRequestMacro.self
    ]
}
