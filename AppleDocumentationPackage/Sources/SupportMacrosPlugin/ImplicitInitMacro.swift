import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct ImplicitInitMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        var accessLevel = "public"
        if let accessLevelSyntax = node.arguments?
            .as(LabeledExprListSyntax.self)?
            .first(where: { $0.label?.trimmed.description == "accessLevel" })?
            .expression.as(StringLiteralExprSyntax.self) {
            let value = accessLevelSyntax.segments.trimmed

            accessLevel = "\(value)"
        }
        if let structDecl = declaration.as(StructDeclSyntax.self) {
            return try [DeclSyntax(generateInit(members: structDecl.memberBlock.members, accessLevel: accessLevel))]
        }

        throw Error.cannotApplicable
    }

    private static func generateInit(
        members: MemberBlockItemListSyntax,
        accessLevel: String?
    ) throws -> InitializerDeclSyntax {
        // swiftlint:disable:next large_tuple
        typealias Variable = (name: PatternSyntax, type: TypeSyntax, initializer: ExprSyntax?)

        let variables: [Variable] = members.compactMap { member in
            guard let variable = member.decl.as(VariableDeclSyntax.self)?.bindings.first,
                  let type = variable.typeAnnotation?.type else { return nil }
            return (variable.pattern.trimmed, type.trimmed, variable.initializer?.value)
        }

        let arguments = FunctionParameterListSyntax {
            for variable in variables {
                let optionalInitializer: () -> ExprSyntax? = {
                    variable.type.description.hasSuffix("?") ? "nil" : nil
                }
                if let initializer = variable.initializer ?? optionalInitializer() {
                    FunctionParameterSyntax("\(variable.name): \(variable.type) = \(initializer)")
                } else {
                    FunctionParameterSyntax("\(variable.name): \(variable.type)")
                }
            }
        }

        return try InitializerDeclSyntax("\(raw: accessLevel ?? "") init(\(arguments))") {
            for variable in variables {
                ExprSyntax("self.\(variable.name) = \(variable.name)")
            }
        }
    }
}

extension ImplicitInitMacro {
    enum Error: Swift.Error {
        case cannotApplicable
    }
}
