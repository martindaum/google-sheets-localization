require 'fastlane/action'
require_relative '../helper/google_sheet_localization_helper'

module Fastlane
  module Actions
    class GoogleSheetLocalizationAction < Action
      def self.run(params)
        UI.message("The google_sheet_localization plugin is working!")
      end

      def self.description
        "Localize apps easily by using Google Sheets API"
      end

      def self.authors
        ["Martin Daum"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "Localize apps easily by using Google Sheets API"
      end

      def self.available_options
        [
          # FastlaneCore::ConfigItem.new(key: :your_option,
          #                         env_name: "GOOGLE_SHEET_LOCALIZATION_YOUR_OPTION",
          #                      description: "A description of your option",
          #                         optional: false,
          #                             type: String)
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
        #
        # [:ios, :mac, :android].include?(platform)
        true
      end
    end
  end
end
