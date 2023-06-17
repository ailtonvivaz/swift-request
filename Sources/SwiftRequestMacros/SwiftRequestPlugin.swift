import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct SwiftRequestPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ServiceMacro.self,
        MethodMacro.self,
        ParamMacro.self
    ]
}
