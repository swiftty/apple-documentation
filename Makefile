SWIFT_PACKAGE := swift package --package-path AppleDocumentationPackage

.PHONY: project
project:
	@$(SWIFT_PACKAGE) plugin --allow-writing-to-directory . xcodegen