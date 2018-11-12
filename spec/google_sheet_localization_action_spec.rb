describe Fastlane::Actions::GoogleSheetLocalizationAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The google_sheet_localization plugin is working!")

      Fastlane::Actions::GoogleSheetLocalizationAction.run(nil)
    end
  end
end
