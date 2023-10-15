// swiftlint:disable function_body_length

import XCTest
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacrosTestSupport

import SupportMacrosPlugin

class ImplicitInitTests: XCTestCase {
    let testMacros: [String: Macro.Type] = [
        "ImplicitInit": ImplicitInitMacro.self
    ]

    func testBasic() throws {
        assertMacroExpansion(
            """
            @ImplicitInit struct Foo {
                var value: Int
            }
            """,
            expandedSource:
            """
            struct Foo {
                var value: Int

                public init(value: Int) {
                    self.value = value
                }
            }
            """,
            macros: testMacros
        )

        assertMacroExpansion(
            """
            @ImplicitInit struct Foo {
                var value: Int
                let text: String
            }
            """,
            expandedSource:
            """
            struct Foo {
                var value: Int
                let text: String

                public init(value: Int, text: String) {
                    self.value = value
                    self.text = text
                }
            }
            """,
            macros: testMacros
        )

        assertMacroExpansion(
            #"""
            @ImplicitInit(accessLevel: "private") struct Foo {
                var value: Int
                let text: String
                @Environment(\.foo) var foo
            }
            """#,
            expandedSource:
            #"""
            struct Foo {
                var value: Int
                let text: String
                @Environment(\.foo) var foo

                private init(value: Int, text: String) {
                    self.value = value
                    self.text = text
                }
            }
            """#,
            macros: testMacros
        )

        assertMacroExpansion(
            """
            @ImplicitInit struct Foo {
                var value: Int

                @ImplicitInit struct Bar {
                    var value: String
                }
            }
            """,
            expandedSource:
            """
            struct Foo {
                var value: Int

                struct Bar {
                    var value: String

                    public init(value: String) {
                        self.value = value
                    }
                }

                public init(value: Int) {
                    self.value = value
                }
            }
            """,
            macros: testMacros
        )

        assertMacroExpansion(
            """
            @ImplicitInit struct Foo {
                var value: Int = 10
                var opt: String?
            }
            """,
            expandedSource:
            """
            struct Foo {
                var value: Int = 10
                var opt: String?

                public init(value: Int = 10, opt: String? = nil) {
                    self.value = value
                    self.opt = opt
                }
            }
            """,
            macros: testMacros
        )
    }
}

// swiftlint:enable function_body_length
