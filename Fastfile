# This file contains the fastlane.tools configuration
# You can find the documentation at https://docs.fastlane.tools
#
# For a list of all available actions, check out
#
#     https://docs.fastlane.tools/actions
#
# For a list of all available plugins, check out
#
#     https://docs.fastlane.tools/plugins/available-plugins
#

# Uncomment the line if you want fastlane to automatically update itself
# update_fastlane

default_platform(:ios)

platform :ios do  
  lane :localize do
  	desc "Download localizable from a Google Spreadsheet"
  	download_localizations(spreadsheet_id: "1i5CleqSzWv9e4Tfwgw5DVumI6CPjnBb3VvBxZcQGHrE",
  		sheet_name: "Strings",
  		platform: "ios",
  		target_folder: "Example",
  		file_name: "Localizable",
  		languages: ["en", "de])
  end
end
