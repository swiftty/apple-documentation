@attached(member, names: named(init))
public macro ImplicitInit(
    accessLevel: String = "public"
) = #externalMacro(module: "SupportMacrosPlugin", type: "ImplicitInitMacro")
