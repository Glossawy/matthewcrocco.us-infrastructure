require_relative './system_dependent'

module System
  module ResourceAccess
    include SystemDependent

    cpu_count_actions = [
      [:darwin9, 'hwprefs cpu_count'],
      [:mac, `which hwprefs`.empty? ? 'sysctl -n hw.ncpu' : 'hwprefs thread_count'],
      [:linux, 'cat /proc/cpuinfo | grep processor | wc -l'],
      [:freebsd, 'sysctl -n hw.ncpu'],
      [:windows, lambda do
        cpuinfo = wmi_instance.ExecQuery('select NumberOfLogicalProcessors from Win32_Processor')
        cpuinfo.to_enum.collect(&:NumberOfLogicalProcessors).reduce(:+)
      end]
    ]

    memory_actions = {
      mac: 'sysctl -n hw.memsize',
      # KB to B since conversion handles B to MB
      linux: -> { %x(grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//') * 1024 },
      freebsd: 'sysctl -n hw.memsize',
      windows: lambda do
        memory_capacities = wmi_instance.ExecQuery('select Capacity from Win32_PhysicalMemory')
        capacities = memory_capacities.to_enum.map(&:Capacity).map(&:to_i)
        capacities.reduce(:+)
      end
    }

    system_dependent_cases :system_cpu_count_slow,
                           normalizer: :to_i,
                           default: 1,
                           os_actions: cpu_count_actions

    def cpu_count
      require 'etc'
      Etc.nprocessors
    rescue
      system_cpu_count_slow
    end

    system_dependent_cases :system_memory,
                           normalizer: ->(x) { bytes_to_mb x.to_i },
                           default: 1024,
                           os_actions: memory_actions

    private

    def bytes_to_mb(bytes)
      bytes / 1024 / 1024
    end
  end
end