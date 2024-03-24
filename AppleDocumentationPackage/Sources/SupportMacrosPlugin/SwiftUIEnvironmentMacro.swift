import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public enum SwiftUIEnvironmentMacro {}

extension SwiftUIEnvironmentMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let variable = declaration.as(VariableDeclSyntax.self)?.bindings.first else {
            throw Error.cannotApplicable
        }
        guard let type = variable.typeAnnotation?.type.trimmed else {
            throw Error.cannotApplicable
        }
        guard let value = variable.initializer?.value else {
            throw Error.cannotApplicable
        }
        let name = variable.pattern.trimmed
        return [
            DeclSyntax(
                try StructDeclSyntax("private struct Key_\(name): SwiftUI.EnvironmentKey") {
                    try VariableDeclSyntax("static var defaultValue: \(type)") {
                        StmtSyntax("return \(value)")
                    }
                }
            )
        ]
    }
}

extension SwiftUIEnvironmentMacro: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let variable = declaration.as(VariableDeclSyntax.self)?.bindings.first else {
            throw Error.cannotApplicable
        }
        let name = variable.pattern.trimmed

        return [
            """
            get { self[Key_\(name).self] }
            """,
            """
            set { self[Key_\(name).self] = newValue }
            """
        ]
    }
}

extension SwiftUIEnvironmentMacro {
    enum Error: Swift.Error {
        case cannotApplicable
    }
}
