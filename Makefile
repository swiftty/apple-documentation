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
	@$(call SWIFT, package) plugin --allow-writing-to-package-directory --allow-writing-to-directory ../ format-source-code

.PHONY: unittest
unittest:
	$(call SWIFT, test)

.PHONY: resolve
resolve:
	$(call SWIFT, package) resolve

.PHONY: init
init:
	$(call SWIFT, package) plugin --allow-writing-to-directory . starter init --project application --project-name apple-documentation --package-path $(PACKAGE_DIR)
