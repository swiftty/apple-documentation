import Testing
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacrosGenericTestSupport

import SupportMacrosPlugin

func assertMacroExpansion(
    _ originalSource: String,
    expandedSource: String,
    diagnostics: [DiagnosticSpec] = [],
    macros: [String: any Macro.Type],
    conformsTo conformances: [TypeSyntax] = [],
    testModuleName: String = "TestModule",
    testFileName: String = "test.swift",
    indentationWidth: Trivia = .spaces(4),
    fileID: StaticString = #fileID, filePath: StaticString = #filePath,
    file: StaticString = #file, line: UInt = #line, column: UInt = #column
) {
    assertMacroExpansion(
        originalSource, expandedSource: expandedSource,
        diagnostics: diagnostics,
        macroSpecs: macros.mapValues { value in
            MacroSpec(type: value, conformances: conformances)
        },
        testModuleName: testModuleName, testFileName: testFileName,
        indentationWidth: indentationWidth
    ) { spec in
        Issue.record(
            .init(rawValue: spec.message),
            sourceLocation: .init(
                fileID: String(describing: fileID), filePath: String(describing: filePath),
                line: Int(line), column: Int(column)
            )
        )
    }
}

struct ImplicitInitTests {
    let testMacors: [String: any Macro.Type] = [
        "ImplicitInit": ImplicitInitMacro.self
    ]

    @Test
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
            macros: testMacors
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
            macros: testMacors
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
            macros: testMacors
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
            macros: testMacors
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
            macros: testMacors
        )
    }
}
