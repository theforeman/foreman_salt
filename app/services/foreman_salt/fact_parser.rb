module ForemanSalt
  class FactParser < ::FactParser
    attr_reader :facts

    def operatingsystem
      os = Operatingsystem.where(os_hash).first_or_initialize
      if os.new_record?
        os.deduce_family
        os.release_name = facts[:lsb_distrib_codename]
        os.save
      end
      os if os.persisted?
    end

    def architecture
      name = facts[:osarch]
      name = 'x86_64' if name == 'amd64'
      Architecture.find_or_create_by_name name unless name.blank?
    end

    def environment
      # Don't touch the Puppet environment field
    end

    def model
      name = facts[:productname]
      Model.find_or_create_by_name(name.strip) unless name.blank?
    end

    def domain
      name = facts[:domain]
      Domain.find_or_create_by_name(name)unless name.blank?
    end

    def ip
      return @ip if @ip
      ip = facts.find { |fact, value| fact =~ /^fqdn_ip4/ && value && value != '127.0.0.1' }
      @ip = ip[1] if ip[1] =~ Net::Validations::IP_REGEXP
    end

    def primary_interface
      interface = interfaces.find { |_, value| value[:ipaddress] == ip }
      interface[0] if interface
    end

    def mac
      interface = interfaces.find { |_, value| value[:ipaddress] == ip }
      mac = interface[1][:macaddress] if interface
      mac if Net::Validations.valid_mac?(mac)
    end

    def ipmi_interface
      nil
    end

    def interfaces
      interfaces = {}

      facts.each do |fact, value|
        next unless value && fact.to_s =~ /^ip_interfaces/
        (_, interface, number) = fact.split(FactName::SEPARATOR)

        interface_name = if number == '0' || number.nil?
                           interface
                         else
                           "#{interface}.#{number}"
                         end

        if !interface.blank? && interface != 'lo' && value =~ Net::Validations::IP_REGEXP
          interfaces[interface_name] = {} if interfaces[interface_name].blank?
          interfaces[interface_name].merge!(:ipaddress => value, :macaddress => macs[interface])
        end
      end

      interfaces
    end

    def support_interfaces_parsing?
      true
    end

    private

    def os_hash
      (_, major, minor) = /(\d+)\.?(\d+)?\.?(\d+)?/.match(facts[:osrelease]).to_a
      { :name => facts[:os], :major => major, :minor => minor }
    end

    def macs
      unless @macs
        @macs = {}
        facts.each do |fact, value|
          next unless value && fact.to_s =~ /^hwaddr_interfaces/
          data = fact.split(FactName::SEPARATOR)
          interface = data[1]
          @macs[interface] = value if Net::Validations.valid_mac?(value)
        end
      end
      @macs
    end
  end
end
