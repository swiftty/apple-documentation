SWIFT = swift$(1) --package-path AppleDocumentationPackage --build-path DerivedData/apple-documentation/SourcePackages

XCODE_PROJECT := apple-documentation.xcodeproj
XCUSERDATA_DIR := $(XCODE_PROJECT)/project.xcworkspace/xcuserdata/$$(whoami).xcuserdatad
XCSHAREDDATA_DIR := $(XCODE_PROJECT)/project.xcworkspace/xcshareddata

.PHONY: project
project:
	@$(call SWIFT, package) plugin --allow-writing-to-directory . xcodegen

	@mkdir -p $(XCUSERDATA_DIR)
	@cp -f $(XCSHAREDDATA_DIR)/WorkspaceSettings.xcsettings $(XCUSERDATA_DIR)/WorkspaceSettings.xcsettings

.PHONY: format
format:
	@$(call SWIFT, package) plugin --allow-writing-to-directory . swiftlint --fix

.PHONY: unittest
unittest:
	$(call SWIFT, test)

.PHONY: resolve
resolve:
	cp -f $(XCSHAREDDATA_DIR)/swiftpm/Package.resolved AppleDocumentationPackage/Package.resolved
	$(call SWIFT, package) resolve
	cp -f AppleDocumentationPackage/Package.resolved $(XCSHAREDDATA_DIR)/swiftpm/Package.resolved
