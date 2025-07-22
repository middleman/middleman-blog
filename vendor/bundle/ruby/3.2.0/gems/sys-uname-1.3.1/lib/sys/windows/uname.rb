# frozen_string_literal: true

require 'socket'
require 'time'
require 'win32ole'

# The Sys module provides a namespace only.
module Sys
  # The Uname class encapsulates uname (platform) information.
  class Uname
    # This is the error raised if any of the Sys::Uname methods should fail.
    class Error < StandardError; end

    fields = %w[
      boot_device
      build_number
      build_type
      caption
      code_set
      country_code
      creation_class_name
      cscreation_class_name
      csd_version
      cs_name
      current_time_zone
      debug
      description
      distributed
      encryption_level
      foreground_application_boost
      free_physical_memory
      free_space_in_paging_files
      free_virtual_memory
      install_date
      last_bootup_time
      local_date_time
      locale
      manufacturer
      max_number_of_processes
      max_process_memory_size
      name
      number_of_licensed_users
      number_of_processes
      number_of_users
      organization
      os_language
      os_product_suite
      os_type
      other_type_description
      plus_product_id
      plus_version_number
      primary
      product_type
      quantum_length
      quantum_type
      registered_user
      serial_number
      service_pack_major_version
      service_pack_minor_version
      size_stored_in_paging_files
      status
      suite_mask
      system_device
      system_directory
      system_drive
      total_swap_space_size
      total_virtual_memory_size
      total_visible_memory_size
      version
      windows_directory
    ]

    # The UnameStruct is used to store platform information for some methods.
    UnameStruct = Struct.new('UnameStruct', *fields)

    # Returns the version plus patch information of the operating system,
    # separated by a hyphen, e.g. "2915-Service Pack 2".
    #--
    # The instance name is unpredictable, so we have to resort to using
    # the 'InstancesOf' method to get the data we need, rather than
    # including it as part of the connection.
    #
    def self.version(host = Socket.gethostname)
      cs = "winmgmts://#{host}/root/cimv2"
      begin
        wmi = WIN32OLE.connect(cs)
      rescue WIN32OLERuntimeError => err
        raise Error, err
      else
        ole = wmi.InstancesOf('Win32_OperatingSystem').ItemIndex(0)
        str = "#{ole.Version} #{ole.BuildNumber}-"
        "#{str}#{ole.ServicePackMajorVersion}"
      end
    end

    # Returns the operating system name, e.g. "Microsoft Windows XP Home"
    #
    def self.sysname(host = Socket.gethostname)
      cs = 'winmgmts:{impersonationLevel=impersonate,(security)}'
      cs += "//#{host}/root/cimv2"
      begin
        wmi = WIN32OLE.connect(cs)
      rescue WIN32OLERuntimeError => err
        raise Error, err
      else
        wmi.InstancesOf('Win32_OperatingSystem').ItemIndex(0).Caption.strip
      end
    end

    # Returns the nodename.  This is usually, but not necessarily, the
    # same as the system's hostname.
    #
    def self.nodename(host = Socket.gethostname)
      cs = 'winmgmts:{impersonationLevel=impersonate,(security)}'
      cs += "//#{host}/root/cimv2"
      begin
        wmi = WIN32OLE.connect(cs)
      rescue WIN32OLERuntimeError => err
        raise Error, err
      else
        wmi.InstancesOf('Win32_OperatingSystem').ItemIndex(0).CSName
      end
    end

    # Returns the CPU architecture, e.g. "x86"
    #
    def self.architecture(cpu_num = 0, host = Socket.gethostname)
      cs = 'winmgmts:{impersonationLevel=impersonate,(security)}'
      cs += "//#{host}/root/cimv2:Win32_Processor='cpu#{cpu_num}'"
      begin
        wmi = WIN32OLE.connect(cs)
      rescue WIN32OLERuntimeError => err
        raise Error, err
      else
        case wmi.Architecture
          when 0
            'x86'
          when 1
            'mips'
          when 2
            'alpha'
          when 3
            'powerpc'
          when 6
            'ia64'
          when 9
            'x86_64'
          else
            'unknown'
        end
      end
    end

    # Returns the machine hardware type.  e.g. "i686".
    #--
    # This may or may not return the expected value because some CPU types
    # were unknown to the OS when the OS was originally released.  It
    # appears that MS doesn't necessarily patch this, either.
    #
    def self.machine(cpu_num = 0, host = Socket.gethostname)
      cs = 'winmgmts:{impersonationLevel=impersonate,(security)}'
      cs += "//#{host}/root/cimv2:Win32_Processor='cpu#{cpu_num}'"
      begin
        wmi = WIN32OLE.connect(cs)
      rescue WIN32OLERuntimeError => err
        raise Error, err
      else
        # Convert a family number into the equivalent string
        case wmi.Family
          when 1
            'Other'
          when 3
            '8086'
          when 4
            '80286'
          when 5
            '80386'
          when 6
            '80486'
          when 7
            '8087'
          when 8
            '80287'
          when 9
            '80387'
          when 10
            '80487'
          when 11
            'Pentium brand'
          when 12
            'Pentium Pro'
          when 13
            'Pentium II'
          when 14
            'Pentium processor with MMX technology'
          when 15
            'Celeron'
          when 16
            'Pentium II Xeon'
          when 17
            'Pentium III'
          when 18
            'M1 Family'
          when 19
            'M2 Family'
          when 24
            'K5 Family'
          when 25
            'K6 Family'
          when 26
            'K6-2'
          when 27
            'K6-3'
          when 28
            'AMD Athlon Processor Family'
          when 29
            'AMD Duron Processor'
          when 30
            'AMD2900 Family'
          when 31
            'K6-2+'
          when 32
            'Power PC Family'
          when 33
            'Power PC 601'
          when 34
            'Power PC 603'
          when 35
            'Power PC 603+'
          when 36
            'Power PC 604'
          when 37
            'Power PC 620'
          when 38
            'Power PC X704'
          when 39
            'Power PC 750'
          when 48
            'Alpha Family'
          when 49
            'Alpha 21064'
          when 50
            'Alpha 21066'
          when 51
            'Alpha 21164'
          when 52
            'Alpha 21164PC'
          when 53
            'Alpha 21164a'
          when 54
            'Alpha 21264'
          when 55
            'Alpha 21364'
          when 64
            'MIPS Family'
          when 65
            'MIPS R4000'
          when 66
            'MIPS R4200'
          when 67
            'MIPS R4400'
          when 68
            'MIPS R4600'
          when 69
            'MIPS R10000'
          when 80
            'SPARC Family'
          when 81
            'SuperSPARC'
          when 82
            'microSPARC II'
          when 83
            'microSPARC IIep'
          when 84
            'UltraSPARC'
          when 85
            'UltraSPARC II'
          when 86
            'UltraSPARC IIi'
          when 87
            'UltraSPARC III'
          when 88
            'UltraSPARC IIIi'
          when 96
            '68040'
          when 97
            '68xxx Family'
          when 98
            '68000'
          when 99
            '68010'
          when 100
            '68020'
          when 101
            '68030'
          when 112
            'Hobbit Family'
          when 120
            'Crusoe TM5000 Family'
          when 121
            'Crusoe TM3000 Family'
          when 122
            'Efficeon TM8000 Family'
          when 128
            'Weitek'
          when 130
            'Itanium Processor'
          when 131
            'AMD Athlon 64 Processor Family'
          when 132
            'AMD Opteron Processor Family'
          when 144
            'PA-RISC Family'
          when 145
            'PA-RISC 8500'
          when 146
            'PA-RISC 8000'
          when 147
            'PA-RISC 7300LC'
          when 148
            'PA-RISC 7200'
          when 149
            'PA-RISC 7100LC'
          when 150
            'PA-RISC 7100'
          when 160
            'V30 Family'
          when 176
            'Pentium III Xeon'
          when 177
            'Pentium III Processor with Intel SpeedStep Technology'
          when 178
            'Pentium 4'
          when 179
            'Intel Xeon'
          when 180
            'AS400 Family'
          when 181
            'Intel Xeon processor MP'
          when 182
            'AMD AthlonXP Family'
          when 183
            'AMD AthlonMP Family'
          when 184
            'Intel Itanium 2'
          when 185
            'AMD Opteron Family'
          when 190
            'K7'
          when 198
            'Intel Core i7-2760QM'
          when 200
            'IBM390 Family'
          when 201
            'G4'
          when 202
            'G5'
          when 203
            'G6'
          when 204
            'z/Architecture Base'
          when 250
            'i860'
          when 251
            'i960'
          when 260
            'SH-3'
          when 261
            'SH-4'
          when 280
            'ARM'
          when 281
            'StrongARM'
          when 300
            '6x86'
          when 301
            'MediaGX'
          when 302
            'MII'
          when 320
            'WinChip'
          when 350
            'DSP'
          when 500
            'Video Processor'
          else
            'Unknown'
        end
      end
    end

    # Returns the release number, e.g. 5.1.2600.
    #
    def self.release(host = Socket.gethostname)
      cs = "winmgmts://#{host}/root/cimv2"
      begin
        wmi = WIN32OLE.connect(cs)
      rescue WIN32OLERuntimeError => err
        raise Error, err
      else
        wmi.InstancesOf('Win32_OperatingSystem').ItemIndex(0).Version
      end
    end

    # Returns a struct of type UnameStruct that contains sysname, nodename,
    # machine, version, and release, as well as a plethora of other fields.
    # Please see the MSDN documentation for what each of these fields mean.
    #
    def self.uname(host = Socket.gethostname)
      cs = "winmgmts://#{host}/root/cimv2"
      begin
        wmi = WIN32OLE.connect(cs)
      rescue WIN32OLERuntimeError => err
        raise Error, err
      else
        os = wmi.InstancesOf('Win32_OperatingSystem').ItemIndex(0)

        UnameStruct.new(
          os.BootDevice,
          os.BuildNumber,
          os.BuildType,
          os.Caption,
          os.CodeSet,
          os.CountryCode,
          os.CreationClassName,
          os.CSCreationClassName,
          os.CSDVersion,
          os.CSName,
          os.CurrentTimeZone,
          os.Debug,
          os.Description,
          os.Distributed,
          os.EncryptionLevel,
          os.ForegroundApplicationBoost,
          convert(os.FreePhysicalMemory),
          convert(os.FreeSpaceInPagingFiles),
          convert(os.FreeVirtualMemory),
          parse_ms_date(os.InstallDate),
          parse_ms_date(os.LastBootUpTime),
          parse_ms_date(os.LocalDateTime),
          os.Locale,
          os.Manufacturer,
          os.MaxNumberOfProcesses,
          convert(os.MaxProcessMemorySize),
          os.Name,
          os.NumberOfLicensedUsers,
          os.NumberOfProcesses,
          os.NumberOfUsers,
          os.Organization,
          os.OSLanguage,
          os.OSProductSuite,
          os.OSType,
          os.OtherTypeDescription,
          os.PlusProductID,
          os.PlusVersionNumber,
          os.Primary,
          os.ProductType,
          os.respond_to?(:QuantumLength) ? os.QuantumLength : nil,
          os.respond_to?(:QuantumType) ? os.QuantumType : nil,
          os.RegisteredUser,
          os.SerialNumber,
          os.ServicePackMajorVersion,
          os.ServicePackMinorVersion,
          convert(os.SizeStoredInPagingFiles),
          os.Status,
          os.SuiteMask,
          os.SystemDevice,
          os.SystemDirectory,
          os.SystemDrive,
          convert(os.TotalSwapSpaceSize),
          convert(os.TotalVirtualMemorySize),
          convert(os.TotalVisibleMemorySize),
          os.Version,
          os.WindowsDirectory
        )
      end
    end

    # Converts a string in the format '20040703074625.015625-360' into a
    # Ruby Time object.
    #
    def self.parse_ms_date(str)
      return if str.nil?
      Time.parse(str.split('.')[0])
    end

    private_class_method :parse_ms_date

    # There is a bug in win32ole where uint64 types are returned as a
    # String rather than a Fixnum/Bignum.  This deals with that for now.
    #
    def self.convert(str)
      return nil if str.nil? # Don't turn nil into 0
      str.to_i
    end

    private_class_method :convert
  end
end
