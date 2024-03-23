SWIFT_PACKAGE := swift package --package-path AppleDocumentationPackage --build-path DerivedData/apple-documentation/SourcePackages
XCODE_PROJECT := apple-documentation.xcodeproj
XCUSERDATA_DIR := $(XCODE_PROJECT)/project.xcworkspace/xcuserdata/$$(whoami).xcuserdatad

.PHONY: project
project:
	@$(SWIFT_PACKAGE) plugin --allow-writing-to-directory . xcodegen

	@mkdir -p $(XCUSERDATA_DIR)
	@ln -sf ../../xcshareddata/WorkspaceSettings.xcsettings $(XCUSERDATA_DIR)/WorkspaceSettings.xcsettings

.PHONY: format
format:
	@$(SWIFT_PACKAGE) plugin --allow-writing-to-directory . swiftlint --fix
