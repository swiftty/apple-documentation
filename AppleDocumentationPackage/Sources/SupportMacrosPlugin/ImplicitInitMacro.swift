import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct ImplicitInitMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
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
        let variables: [(name: PatternSyntax, type: TypeSyntax)] = members.compactMap { member in
            guard let variable = member.decl.as(VariableDeclSyntax.self),
                  let name = variable.bindings.first?.pattern,
                  let type = variable.bindings.first?.typeAnnotation?.type else { return nil }
            return (name.trimmed, type.trimmed)
        }

        let arguments = FunctionParameterListSyntax {
            for variable in variables {
                FunctionParameterSyntax("\(variable.name): \(variable.type)")
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
