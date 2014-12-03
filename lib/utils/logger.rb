require 'pathname'
require 'fileutils'
module Utils
  module Logger
    def self.included(base, logger_file_name_method = nil)
      base.class_attribute :logger_file
      base.logger_file = "#{base.name.underscore.gsub(/[\/_]/, '-')}.log"
    end

    def logger
      @logger ||= begin
        path = Pathname.new("#{Rails.root}/log/#{self.logger_file}")
        FileUtils.mkdir_p(path.dirname)
        logger = ::Logger.new(path)
        logger.formatter = ::Logger::Formatter.new
        logger.datetime_format = "%Y-%m-%d %H:%M:%S"
        logger
      end
    end

  end
end
