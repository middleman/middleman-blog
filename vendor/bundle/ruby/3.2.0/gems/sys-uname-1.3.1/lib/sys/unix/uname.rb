# frozen_string_literal: true

require 'ffi'
require 'rbconfig'

# The Sys module serves as a namespace only.
module Sys
  # The Uname class encapsulates information about the system.
  class Uname
    extend FFI::Library
    ffi_lib FFI::Library::LIBC

    # Error raised if the uname() function fails.
    class Error < StandardError; end

    # :stopdoc

    # Buffer size for uname struct char arrays
    case RbConfig::CONFIG['host_os']
      when /linux/i
        BUFSIZE = 65
      when /bsd|dragonfly/i
        BUFSIZE = 32
      else
        BUFSIZE = 256
    end

    attach_function :uname_c, :uname, [:pointer], :int
    private_class_method :uname_c

    begin
      attach_function :sysctl, %i[pointer uint pointer pointer pointer size_t], :int
      private_class_method :sysctl

      CTL_HW   = 6   # Generic hardware/cpu
      HW_MODEL = 2   # Specific machine model
    rescue FFI::NotFoundError
      # Ignore. Not suppored.
    end

    begin
      attach_function :sysinfo, %i[int pointer long], :long
      private_class_method :sysinfo

      SI_SYSNAME      = 1   # OS name
      SI_HOSTNAME     = 2   # Node name
      SI_RELEASE      = 3   # Operating system release
      SI_VERSION      = 4   # Version field of utsname
      SI_MACHINE      = 5   # Machine type
      SI_ARCHITECTURE = 6   # Instruction set architecture
      SI_HW_SERIAL    = 7   # Hardware serial number
      SI_HW_PROVIDER  = 8   # Hardware manufacturer
      SI_SRPC_DOMAIN  = 9   # Secure RPC domain
      SI_PLATFORM     = 513 # Platform identifier
      SI_ISALIST      = 514 # Supported isalist
      SI_DHCP_CACHE   = 515 # Kernel cached DHCPACK
    rescue FFI::NotFoundError
      # Ignore. Not suppored.
    end

    # FFI class passed to the underlying C uname function.
    class UnameFFIStruct < FFI::Struct
      members = [
        :sysname,  [:char, BUFSIZE],
        :nodename, [:char, BUFSIZE],
        :release,  [:char, BUFSIZE],
        :version,  [:char, BUFSIZE],
        :machine,  [:char, BUFSIZE]
      ]

      members.push(:domainname, [:char, BUFSIZE]) if RbConfig::CONFIG['host_os'] =~ /linux/i
      members.push(:__id_number, [:char, BUFSIZE]) if RbConfig::CONFIG['host_os'] =~ /hpux/i

      layout(*members)
    end

    fields = %w[
      sysname
      nodename
      release
      version
      machine
    ]

    fields.push('domainname') if RbConfig::CONFIG['host_os'] =~ /linux/i
    fields.push('id_number') if RbConfig::CONFIG['host_os'] =~ /hpux/i
    fields.push('model') if RbConfig::CONFIG['host_os'] =~ /darwin|bsd|dragonfly/i

    private_constant :UnameFFIStruct

    # :startdoc:

    UnameStruct = Struct.new('UnameStruct', *fields)

    # Returns a struct that contains the sysname, nodename, machine, version
    # and release of your system.
    #
    # On OS X and BSD platforms it will also include the model.
    #
    # On HP-UX, it will also include the id_number.
    #
    # Example:
    #
    #   require 'sys/uname'
    #
    #   p Sys::Uname.uname
    #
    def self.uname
      utsname = UnameFFIStruct.new

      raise Error, 'uname() function call failed' if uname_c(utsname) < 0

      struct = UnameStruct.new
      struct[:sysname]  = utsname[:sysname].to_s
      struct[:nodename] = utsname[:nodename].to_s
      struct[:release]  = utsname[:release].to_s
      struct[:version]  = utsname[:version].to_s
      struct[:machine]  = utsname[:machine].to_s

      struct[:model] = get_model() if RbConfig::CONFIG['host_os'] =~ /darwin|bsd|dragonfly/i
      struct[:id_number] = utsname[:__id_number].to_s if RbConfig::CONFIG['host_os'] =~ /hpux/i
      struct[:domainname] = utsname[:domainname].to_s if RbConfig::CONFIG['host_os'] =~ /linux/i

      # Let's add a members method that works for testing and compatibility
      if struct.members.nil?
        struct.instance_eval <<-RUBY, __FILE__, __LINE__ + 1
          def members
            @table.keys.map(&:to_s)
          end
        RUBY
      end

      struct.freeze
    end

    # Returns the name of this implementation of the operating system.
    #
    # Example:
    #
    #  Uname.sysname # => 'Darwin'
    #
    def self.sysname
      uname.sysname
    end

    # Returns the name of this node within the communications network to
    # which this node is attached, if any. This is often, but not
    # necessarily, the same as the host name.
    #
    # Example:
    #
    #  Uname.nodename # => 'your_host.foo.com'
    #
    def self.nodename
      uname.nodename
    end

    # Returns the current release level of your operating system.
    #
    # Example:
    #
    #  Uname.release # => '2.2.16-3'
    #
    def self.release
      uname.release
    end

    # Returns the current version level of your operating system.
    #
    # Example:
    #
    #  Uname.version # => '5.9'
    #
    def self.version
      uname.version
    end

    # Returns the machine hardware type.
    #
    # Example:
    #
    #  Uname.machine # => 'i686'
    #
    def self.machine
      uname.machine
    end

    if defined? :sysctl
      # Returns the model type.
      #
      # Example:
      #
      #  Uname.model # => 'MacBookPro5,3'
      #
      def self.model
        uname.model
      end
    end

    if defined? :sysinfo
      # The  basic instruction  set  architecture  of  the current
      # system, e.g. sparc, i386, etc.
      #
      def self.architecture
        uname.architecture
      end

      # The specific model of the hardware platform, e.g Sun-Blade-1500, etc.
      #
      def self.platform
        uname.platform
      end

      # The string consisting of the ASCII hexidecimal encoding of the name
      # of the interface configured by boot(1M) followed by the DHCPACK reply
      # from the server.
      #
      def self.dhcp_cache
        uname.dhcp_cache
      end

      # The variant instruction set architectures executable on the
      # current system.
      #
      def self.isa_list
        uname.isa_list
      end

      # The ASCII representation of the hardware-specific serial number
      # of the physical machine on which the function is executed.
      #
      def self.hw_serial
        uname.hw_serial.to_i
      end

      # The name of the of the hardware provider.
      #
      def self.hw_provider
        uname.hw_provider
      end

      # The Secure Remote Procedure Call domain name.
      #
      def self.srpc_domain
        uname.srpc_domain
      end
    end

    private

    # Returns the model for systems that define sysctl().
    #
    def self.get_model
      buf  = 0.chr * BUFSIZE
      mib  = FFI::MemoryPointer.new(:int, 2).write_array_of_int([CTL_HW, HW_MODEL])
      size = FFI::MemoryPointer.new(:long, 1).write_int(buf.size)

      sysctl(mib, 2, buf, size, nil, 0)

      buf.strip
    end

    private_class_method :get_model
  end
end
