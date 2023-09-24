@attached(member, names: named(init))
public macro ImplicitInit(
    accessLevel: String = "public"
) = #externalMacro(module: "SupportMacrosPlugin", type: "ImplicitInitMacro")

@attached(peer, names: arbitrary)
@attached(accessor)
public macro SwiftUIEnvironment() = #externalMacro(module: "SupportMacrosPlugin", type: "SwiftUIEnvironmentMacro")
