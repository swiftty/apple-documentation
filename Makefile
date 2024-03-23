PACKAGE_DIR := AppleDocumentationPackage
XCODE_PROJECT := apple-documentation.xcodeproj
XCUSERDATA_DIR := $(XCODE_PROJECT)/project.xcworkspace/xcuserdata/$(shell whoami).xcuserdatad
XCSHAREDDATA_DIR := $(XCODE_PROJECT)/project.xcworkspace/xcshareddata

SWIFT = swift$(1) --package-path $(PACKAGE_DIR) --build-path DerivedData/apple-documentation/SourcePackages

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
	cp -f $(XCSHAREDDATA_DIR)/swiftpm/Package.resolved $(PACKAGE_DIR)/Package.resolved
	$(call SWIFT, package) resolve
	cp -f $(PACKAGE_DIR)/Package.resolved $(XCSHAREDDATA_DIR)/swiftpm/Package.resolved
