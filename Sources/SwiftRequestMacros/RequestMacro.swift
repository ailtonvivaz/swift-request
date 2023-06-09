import SwiftSyntax
import SwiftSyntaxMacros
import RegexBuilder
import Foundation
import SwiftDiagnostics

public class RequestMacro: PeerMacro {
    class var httpMethod: String { fatalError() }
    
    static var diagnostics : RequestDiagnostics { RequestDiagnostics(method: httpMethod) }
    
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // Require attached to a function
        guard let funcDecl = declaration.as(FunctionDeclSyntax.self) else {
            context.diagnose(diagnostics.justFunction(node: Syntax(node)))
            return []
        }
        
        // Require a private function
        guard funcDecl.modifiers?.count == 1 && funcDecl.modifiers?.first?.as(DeclModifierSyntax.self)?.name.text == "private" else {
            context.diagnose(diagnostics.justPrivate(node: Syntax(fromProtocol: funcDecl.modifiers ?? funcDecl.funcKeyword)))
            return []
        }
        
        let (path, outputType, pathParams, defaultHeaders) = try getRequestParameters(for: node, in: context)
        
        // Generate the new function call
        let parameterList = funcDecl.signature.input.parameterList
        
        let newParameterList = FunctionParameterListSyntax(parameterList.map { param in
            var newParam = param
            newParam.attributes = newParam.attributes?.removingFirst()
            return newParam
        })
        
        let newCall: ExprSyntax = "\(funcDecl.identifier)(\(newParameterList))"
        
        let functionParameters = FunctionParameters(from: parameterList)
        
        let endpointDecl = try generateEndpointExpr(from: functionParameters, path: path, pathParams: pathParams, in: context)
        let queryParamsDecl = generateQueryParamsDecl(from: functionParameters)
        let urlDecl = generateUrlDecl(endpoint: endpointDecl, queryParams: queryParamsDecl)
        let requestDecl = generateRequestDecl()
        
        let headersExpr = generateHeadersDecl(from: functionParameters, defaultHeaders: defaultHeaders)
        let bodyExpr = generateBodyDecl(from: functionParameters)
        
        let allDeclarations: [DeclSyntax] = [
            urlDecl,
            requestDecl,
            headersExpr,
            bodyExpr
        ].compactMap { $0 }
        
        let allDeclarationsExpr: DeclSyntax = """
        \(raw: allDeclarations.map { expr in
            """
            \(expr)
            """
        }.joined(separator: "\n"))
        """
        
        let callExpr = generateCallDecl(of: outputType)
        
        let newFunc: DeclSyntax = """
        func \(newCall) async throws -> (\(outputType), HTTPURLResponse) {
            \(allDeclarationsExpr)
            \(callExpr)
        }
        """
        
        return [newFunc]
    }
    
    private static func generateRequestDecl() -> DeclSyntax {
        """
        var request = URLRequest(url: url)
        request.httpMethod = "\(raw: httpMethod)"
        """
    }
    
    private static func generateCallDecl(of outputType: TypeSyntax) -> DeclSyntax {
        let requestCall: DeclSyntax = """
        let (data, response) = try await session.data(for: request) as! (Data, HTTPURLResponse)
        guard (200..<300).contains(response.statusCode) else {
            throw HTTPResponseError(data: data, response: response)
        }
        """
        
        let returnData: DeclSyntax = if outputType.description != "Data" {
            """
            \(requestCall)
            let decoder = JSONDecoder()
            return (try decoder.decode(\(outputType).self, from: data), response)
            """
        } else {
            """
            \(requestCall)
            return (data, response)
            """
        }
        
        return returnData
    }
    
    private static func generateBodyDecl(from parameters: FunctionParameters) -> DeclSyntax? {
        if let body = parameters.getBody() {
            """
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(\(raw: body.name))
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            """
        } else {
            nil
        }
    }
    
    private static func generateHeadersDecl(from parameters: FunctionParameters, defaultHeaders: ExprSyntax?) -> DeclSyntax? {
        let headers = parameters.getHeaders().map { param in
            let key = param.attribute.arguments.first?.value ?? param.name
            return (key: key, value: param.name, optional: param.optional)
        }
        
        if headers.isEmpty {
            return nil
        }
        
        var expressions: [String] = []
        
        if let defaultHeaders {
            expressions.append("""
                let defaultHeaders: [String: (any CustomStringConvertible)?] = \(defaultHeaders)
                defaultHeaders.forEach { request.setValue($0.value?.description, forHTTPHeaderField: $0.key) }
                """
            )
        }
        
        expressions.append(contentsOf: headers.map { (key, value, optional) -> String in
            let setExpr = """
            headers["\(key)"] = \(value).description
            """
            if optional {
                return """
                if let \(value) {
                    \(setExpr)
                }
                """
            } else {
                return setExpr
            }
        })
        
        let headerExprs: DeclSyntax = """
        \(raw: expressions.joined(separator: "\n"))
        """
        
        return headerExprs
    }
    
    private static func generateUrlDecl(
        endpoint endpointExpr: ExprSyntax,
        queryParams queryParamsDecl: DeclSyntax?
    ) -> DeclSyntax {
        return if let queryParamsDecl {
            """
            let urlWithPath = \(endpointExpr)
            var urlComponents = URLComponents(url: urlWithPath, resolvingAgainstBaseURL: false)!
            var queryItems: [URLQueryItem] = []
            \(queryParamsDecl)
            urlComponents.queryItems = queryItems
            let url = urlComponents.url!
            """
        } else {
            """
            let url = \(endpointExpr)
            """
        }
    }
    
    private static func generateQueryParamsDecl(from parameters: FunctionParameters) -> DeclSyntax? {
        let queryParams = parameters.getQueryParams().map { param in
            let key = param.attribute.arguments.first?.value ?? param.name
            return (key: key, value: param.name, optional: param.optional)
        }
        
        if queryParams.isEmpty {
            return nil
        }
        
        let queryParamExpr: DeclSyntax = """
        \(raw: queryParams.map { (key, value, optional) -> String in
            let appendExpr = """
            queryItems.append(URLQueryItem(name: "\(key)", value: \(value).description))
            """
            if optional {
                return """
                if let \(value) {
                    \(appendExpr)
                }
                """
            } else {
                return appendExpr
            }
        }.joined(separator: "\n"))
        """
        
        return queryParamExpr
    }
    
    private static func generateEndpointExpr(
        from parameters: FunctionParameters,
        path: TokenSyntax,
        pathParams: [String],
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        let argumentsPathParams: [(name: String, argument: String)] = parameters.getPathParams().map { pathParam in
            let name = pathParam.attribute.arguments.first?.value ?? pathParam.name
            return (name: name, argument: pathParam.name)
        }
        
        // Required matching path params
        guard pathParams.count == argumentsPathParams.count,
              Set(pathParams) == Set(argumentsPathParams.map(\.name)) else {
            context.diagnose(diagnostics.pathRequired(node: Syntax(path)))
            throw MacroExpansionError()
        }
        
        // Replace path params in path with arguments
        let pathString = argumentsPathParams.reduce(path.text) { path, pathParam in
            path.replacingOccurrences(of: "{\(pathParam.name)}", with: "\\(\(pathParam.argument))")
        }
        
        return """
        baseURL.appendingPathComponent("\(raw: pathString)")
        """
    }
    
    private static func getRequestParameters(
        for node: AttributeSyntax,
        in context: some MacroExpansionContext
    ) throws -> (path: TokenSyntax, outputType: TypeSyntax, pathParams: [String], defaultsHeaders: ExprSyntax?) {
        // Require a type as a generic argument
        guard let outputType = node.attributeName.as(SimpleTypeIdentifierSyntax.self)?.genericArgumentClause?.arguments.first?.argumentType else {
            context.diagnose(RequestMacro.diagnostics.outputTypeRequired(node: Syntax(node)))
            throw MacroExpansionError()
        }
        
        // Require a path without interpolation
        guard let path = node.argument?.as(TupleExprElementListSyntax.self)?.first?.expression.as(StringLiteralExprSyntax.self)?.segments.first?.as(StringSegmentSyntax.self)?.content else {
            context.diagnose(diagnostics.pathRequired(node: Syntax(node)))
            throw MacroExpansionError()
        }
        
        // Extract path params
        let pathParams = path.text
            .split(separator: "/")
            .filter { $0.hasPrefix("{") && $0.hasSuffix("}") }
            .map { $0.dropFirst().dropLast() }
            .map(String.init)
        
        // Require unique path params
        guard Set(pathParams).count == pathParams.count else {
            context.diagnose(diagnostics.uniquePathParams(node: Syntax(node)))
            throw MacroExpansionError()
        }
        
        // Get the optional defaults headers
        let defaultHeadersExpr = getExpr(for: "headers", in: node)
        
        return (path, outputType, pathParams, defaultHeadersExpr)
    }
    
    private static func getExpr(for argument: String, in node: AttributeSyntax) -> ExprSyntax? {
        node.argument?
            .as(TupleExprElementListSyntax.self)?
            .first(where: {
                $0.as(TupleExprElementSyntax.self)?.label?.text == argument
            })?.expression
    }
    
}

public final class GetRequestMacro: RequestMacro {
    override class var httpMethod: String { "GET" }
}

public final class PostRequestMacro: RequestMacro {
    override class var httpMethod: String { "POST" }
}

public final class PutRequestMacro: RequestMacro {
    override class var httpMethod: String { "PUT" }
}

public final class PatchRequestMacro: RequestMacro {
    override class var httpMethod: String { "PATCH" }
}

public final class DeleteRequestMacro: RequestMacro {
    override class var httpMethod: String { "DELETE" }
}
