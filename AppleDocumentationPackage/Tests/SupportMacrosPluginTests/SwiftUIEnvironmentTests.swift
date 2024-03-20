// swiftlint:disable function_body_length

import XCTest
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacrosTestSupport

import SupportMacrosPlugin

class SwiftUIEnvironmentTests: XCTestCase {
    let testMacors: [String: Macro.Type] = [
        "SwiftUIEnvironment": SwiftUIEnvironmentMacro.self
    ]

    func testBasic() throws {
        assertMacroExpansion(
            """
            extension EnvironmentValues {
                @SwiftUIEnvironment var references: [Technology.Identifier: TechnologyDetail.Reference] = [:]
            }
            """,
            expandedSource:
            """
            extension EnvironmentValues {
                var references: [Technology.Identifier: TechnologyDetail.Reference] {
                    get {
                        self [Key_references.self]
                    }
                    set {
                        self [Key_references.self] = newValue
                    }
                }

                private struct Key_references: SwiftUI.EnvironmentKey {
                    static var defaultValue: [Technology.Identifier: TechnologyDetail.Reference] {
                        return [:]
                    }
                }
            }
            """,
            macros: testMacors
        )
        assertMacroExpansion(
            """
            extension EnvironmentValues {
                @SwiftUIEnvironment var uiFont: UIFont? = nil
            }
            """,
            expandedSource:
            """
            extension EnvironmentValues {
                var uiFont: UIFont? {
                    get {
                        self [Key_uiFont.self]
                    }
                    set {
                        self [Key_uiFont.self] = newValue
                    }
                }

                private struct Key_uiFont: SwiftUI.EnvironmentKey {
                    static var defaultValue: UIFont? {
                        return nil
                    }
                }
            }
            """,
            macros: testMacors
        )
        assertMacroExpansion(
            """
            extension EnvironmentValues {
                @SwiftUIEnvironment var references: [Technology.Identifier: TechnologyDetail.Reference] = [:]

                @SwiftUIEnvironment var uiFont: UIFont? = nil
            }
            """,
            expandedSource:
            """
            extension EnvironmentValues {
                var references: [Technology.Identifier: TechnologyDetail.Reference] {
                    get {
                        self [Key_references.self]
                    }
                    set {
                        self [Key_references.self] = newValue
                    }
                }

                private struct Key_references: SwiftUI.EnvironmentKey {
                    static var defaultValue: [Technology.Identifier: TechnologyDetail.Reference] {
                        return [:]
                    }
                }

                var uiFont: UIFont? {
                    get {
                        self [Key_uiFont.self]
                    }
                    set {
                        self [Key_uiFont.self] = newValue
                    }
                }

                private struct Key_uiFont: SwiftUI.EnvironmentKey {
                    static var defaultValue: UIFont? {
                        return nil
                    }
                }
            }
            """,
            macros: testMacors
        )

    }
}

// swiftlint:enable function_body_length
