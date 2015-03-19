class Settings < Settingslogic
  source "#{Rails.root}/config/settings/base.yml"

  namespace Rails.env

  Dir["#{Rails.root}/config/settings/*.yml"].each do |file|
    Settings.merge!(Settings.new(file)) unless file.eql?("#{Rails.root}/config/settings/base.yml")
  end

  load!
end
