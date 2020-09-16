module Fastlane
  module Actions
    class DownloadLocalizationsAction < Action
      def self.run(params)
	require 'google/apis/sheets_v4'
      	require 'googleauth'
	require 'googleauth/stores/file_token_store'
	require 'fileutils'

        protected_keys = ["key", "description"]
        credentials_file = ".credentials.json"
        token_file = ".token.yaml"

        if Dir[credentials_file].first.nil?
          UI.error("credentials file missing. Download it from:\n https://developers.google.com/sheets/api/quickstart/ruby")
          return
        end

        service = Google::Apis::SheetsV4::SheetsService.new
        service.client_options.application_name = 'App Localize'
        service.authorization = self.authorize(credentials_file, token_file)

        # get this parameters via command line arguments
        spreadsheet_id = params[:spreadsheet_id]
        spreadsheet_name = params[:sheet_name]
        type = params[:platform] # one of ios|android
        root_folder = params[:target_folder]
        file_name = params[:file_name]
        allowed_languages = params[:languages]
        default_language = params[:default_language]

        response = service.get_spreadsheet_values(spreadsheet_id, spreadsheet_name)
        sheet_data = response.values

        headers = sheet_data.first
        languages = headers.select { |key| key.length == 2 }
        unless allowed_languages.nil?
          languages = languages.select { |key| allowed_languages.include? key }
        end

        #remove header row
        rows = sheet_data.drop(1)



        languages.each_with_index do |language, index|
          is_default_language = default_language == language || languages.count == 1
          file_content = self.file_prefix(type)
          file_path = self.get_file_path(root_folder, language, file_name, type, is_default_language)
          file = Dir[file_path].first

          if file.nil?
            UI.error("File with name: \"#{file_name}\" for language \"#{language}\" does not exist! Please create it first!")
            next
          end

          UI.message("Generating file for language \"#{language}\"")

          rows.each do |row|
            key = row.first
            value = row[index + 1]

            description = nil
            if row.count == headers.count
              description = row.last
            end

            if value.nil? || value.empty?
              file_content += "\n"
              next
            end

            if description != nil
              file_content += self.build_comment(description, type)
            end
            file_content += self.build_row(key, value, type)
          end
          file_content += self.file_suffix(type)
          File.write(file, file_content)
        end
      end

      def self.authorize(credentials_file, token_file)
          base_url = 'urn:ietf:wg:oauth:2.0:oob'
          client_id = Google::Auth::ClientId.from_file(credentials_file)
          token_store = Google::Auth::Stores::FileTokenStore.new(file: token_file)
          authorizer = Google::Auth::UserAuthorizer.new(client_id, Google::Apis::SheetsV4::AUTH_SPREADSHEETS_READONLY, token_store)
          user_id = 'default'
          credentials = authorizer.get_credentials(user_id)
          if credentials.nil?
            url = authorizer.get_authorization_url(base_url: base_url)
            text = 'Open the following URL in the browser and enter the ' \
                 "resulting code after authorization:\n" + url
            code = UI.input(text)
            credentials = authorizer.get_and_store_credentials_from_code(
              user_id: user_id, code: code, base_url: base_url
            )
          end
          credentials
        end

        def self.build_row(key, value, type)
          if type == "ios"
            return self.build_ios_row(key, value)
          else
            return self.build_android_row(key, value)
          end
        end

        def self.build_ios_row(key, value)
          value.gsub! "\n", "\\n"
          value.gsub! "\"", "\\\""
          value.gsub!(/\%[0-9]\$s/) { |s| s.gsub! 's', '@'}
          value.gsub! '%s', '%@'
          return "\"" + key + "\" = \"" + value + "\";\n"
        end

        def self.build_android_row(key, value)
          value.gsub! "&", "&amp;"
          value.gsub! "\n", "\\n"
          value.gsub! "'", %q(\\\')
          value.gsub! "\"", "\\\""
          value.gsub! "...", "…"
          return "    <string name=\"" + key + "\">" + value + "</string>\n"
        end

        def self.build_comment(comment, type)
          if type == "ios"
            return "// #{comment}\n"
          else
            return "    <!-- #{comment} -->\n"
          end
        end

        def self.get_file_path(root_folder, language, file_name, type, is_default_language)
          if type == "ios"
            return "#{root_folder}/**/#{language}.lproj/#{file_name}.strings"
          else
            language_suffix = is_default_language ? "" : "-#{language}"
            return "#{root_folder}/**/values#{language_suffix}/#{file_name}.xml"
          end
        end

        def self.file_prefix(type)
          if type == "ios"
            return ""
          else
            return "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<resources>\n"
          end
        end

        def self.file_suffix(type)
          if type == "ios"
            return ""
          else
            return "</resources>\n"
          end
        end



      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Pull localizable strings from Google Sheets"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :spreadsheet_id,
                                       description: "Spreadsheet ID",
                                       verify_block: proc do |value|
                                          UI.user_error! "No Spreadsheet ID given, find it in the url of your Google Sheet" unless (value and not value.empty?)
                                       end),
          FastlaneCore::ConfigItem.new(key: :sheet_name,
                                       description: "Sheet name",
                                       verify_block: proc do |value|
                                          UI.user_error! "No Sheet name given" unless (value and not value.empty?)
                                       end),
          FastlaneCore::ConfigItem.new(key: :platform,
                                       description: "Platform",
                                       verify_block: proc do |value|
                                          UI.user_error! "platform has to be either ios or android" unless ["ios", "android"].include? value
                                       end),
          FastlaneCore::ConfigItem.new(key: :target_folder,
                                       description: "Target folder",
                                       verify_block: proc do |value|
                                          UI.user_error! "No target folder name given" unless (value and not value.empty?)
                                       end),
            FastlaneCore::ConfigItem.new(key: :file_name,
                                       description: "File name",
                                       verify_block: proc do |value|
                                          UI.user_error! "No file name given" unless (value and not value.empty?)
                                       end),
            FastlaneCore::ConfigItem.new(key: :languages,
                                       description: "Languages to download",
                                       optional: true,
                                       is_string: false,
                                       verify_block: proc do |value|
                                          UI.user_error! "Language codes should be passed as array" unless value.kind_of? Array
                                       end),
          FastlaneCore::ConfigItem.new(key: :default_language,
                                       description: "Default language",
                                       optional: true,
                                       verify_block: proc do |value|
                                          UI.user_error! "No default language given" unless (value and not value.empty?)
                                       end)
        ]
      end

      def self.authors
        "martindaum"
      end

      def self.is_supported?(platform)
        [:ios, :android].include? platform
      end
    end
  end
end
