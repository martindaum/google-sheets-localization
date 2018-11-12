# App localization with Google Spreadsheets

* Create a spreadsheet with following format:
https://docs.google.com/spreadsheets/d/1i5CleqSzWv9e4Tfwgw5DVumI6CPjnBb3VvBxZcQGHrE/edit?usp=sharing

* Use fastlane in your project. 
* Add the plugin to your Gemfile

gem "fastlane-plugin-google_sheet_localization", git: "https://github.com/martindaum/google-sheets-localization.git"

* Copy the lane form the provided fastfile
* Allow API access for Google Sheets:
https://developers.google.com/sheets/api/quickstart/ruby
* Move the credentials.json file to the root folder of your project and rename it to **.credentials.json**
* Add **.credentials.json** and **.token.yaml** to your .gitignore
* Create the strings-files yourself before using the script 

The first time you run this script, it will prompt you to open a link in the browser to create your access token.
