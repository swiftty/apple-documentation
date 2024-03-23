SWIFT_PACKAGE := swift package --package-path AppleDocumentationPackage --build-path DerivedData/apple-documentation/SourcePackages

.PHONY: project
project:
	@$(SWIFT_PACKAGE) plugin --allow-writing-to-directory . xcodegen

.PHONY: format
format:
	@$(SWIFT_PACKAGE) plugin --allow-writing-to-directory . swiftlint --fix
