module System
  module SystemDependent
    def self.included(base)
      base.extend(ClassMethods) unless base == Kernel
    end

    module ClassMethods
      SYSTEM_REGEX_MAPPING = {
          windows: /mswin|mingw/,
          mac: /darwin/,
          darwin9: /darwin9/,
          linux: /linux/,
          freebsd: /freebsd/
      }.freeze

      def system_dependent_method(method, osname)
        re = system_regexp_for_name osname
        define_method(method) do |*args|
          yield(*args) if host_os =~ re
        end
      end

      def system_dependent_cases(method, normalizer:, os_actions:, default: nil)
        os_actions = normalize_os_actions(os_actions)
        define_method(method) do
          os_actions.each do |re, block|
            next unless host_os =~ re

            result = block.call
            return convert_value(result, normalizer)
          end

          default
        end
      end

      private

      def system_regexp_for_name(osname)
        return if osname.nil?
        re = SYSTEM_REGEX_MAPPING[normalize_system_name osname]
        re || raise("No regexp for system: #{osname}")
      end

      def normalize_system_name(osname)
        osname = osname.to_sym if osname.is_a? String
        osname
      end

      def normalize_os_actions(os_actions)
        os_actions = os_actions.to_a if os_actions.respond_to? :to_a
        os_actions.map { |k, v| [system_regexp_for_name(k), v] }
            .map { |k, v| [k, as_action(v)] }
      end

      def as_action(value)
        return value if value.is_a? Proc
        -> { `#{value}` }
      end

      def convert_value(value, convert)
        return value if convert.nil?
        return convert.call(result) if convert.respond_to? :call
        value.send(convert)
      rescue
        raise 'Can only handle converters of type: Nil, Proc, Symbol or String'
      end
    end

    def system_name
      RbConfig::CONFIG['host_os']
    end

    ClassMethods::SYSTEM_REGEX_MAPPING.each do |oskey, osregex|
      define_method("#{oskey}?") do
        host_os =~ osregex
      end
    end

    def wmi_instance
      raise 'Not windows.' unless windows?
      return @__wmi_instance if @__wmi_instance

      require 'win32ole'
      @__wmi_instance ||= WIN32OLE.connect('winmgmts://')
    end

    alias host_os system_name
    alias osx? mac?
  end
end
