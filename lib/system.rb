Dir[File.expand_path('../system/**/*.rb', __FILE__)].each { |f| require f }

module Kernel
  include System::SystemDependent
end

module System
  extend System::ResourceAccess

  class << self
    def validate_plugins!
      return unless defined?(Vagrant)
      return if missing_plugins.empty?
      needed = missing_plugins
      raise "Missing plugins. Please run `powershell scripts\\install-plugins.ps1`. #{needed}" if windows?
      raise "Missing plugins. Please run `bash scripts/install-plugins.sh`. #{needed}"
    end

    def plugins
      @plugins ||= read_plugins
    end

    def missing_plugins
      return [] unless defined?(Vagrant)
      plugins.reject { |plugin| Vagrant.has_plugin? plugin }
    end

    def plugins_path
      File.expand_path('../../plugins', __FILE__)
    end

    private

    def read_plugins
      content = File.read(plugins_path)
      content.lines.map(&:strip).reject(&:empty?)
    end
  end
end
