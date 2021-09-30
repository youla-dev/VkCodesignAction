# VkCodesignAction
Fastlane action for xcarchive codesign via mail.ru codesign machine by vk certificate

================

# Available Fastlane actions

## [get_project_info](fastlane/actions/vk_codesign.rb)

Codesign xcarchive via mail.ru codesign machine by vk certificate

```Ruby
lane :appstore do
    import_from_git(
      url: "git@github.com:youla-dev/VkCodesignAction.git", # The URL of the repository to import the Fastfile from.
      branch: "HEAD", # The branch to checkout on the repository.
      version: "~> 1.0.0" # The version to checkout on the repository. Optimistic match operator can be used to select the latest version within constraints.
    )
    clear_derived_data
    gym(
      workspace: "ProjectName.xcworkspace",
      configuration: "Release",
      scheme: "Production",
      export_method: "app-store",
      skip_codesigning: true, 
      skip_package_ipa: true,
      skip_profile_detection: true,
    )
    xcarchive_zip_path = "fastlane/xcodebuild.zip"
    zip(
      path: lane_context[SharedValues::XCODEBUILD_ARCHIVE],
      output_path: xcarchive_zip_path
    )

    cert_path = Pathname.new("/Path_To_Cert/cert.crt").expand_path.realpath.to_s
    key_path = Pathname.new("/Path_To_Key/key.key").expand_path.realpath.to_s
    vk_codesign(
      cert_path: cert_path,
      key_path: key_path,
      endpoint: "https://api_endpoint",
      xcarchive_zip_path: xcarchive_zip_path,
      output_path: ipa_path
    )

    result_ipa_path = Pathname.new("../#{ipa_path}").expand_path.realpath.to_s
    pilot(
        ipa: result_ipa_path
    )
  end
```
