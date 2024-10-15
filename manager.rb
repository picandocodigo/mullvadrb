module Mullvad
  # Main module in charge of connection
  module Manager
    # Default path, copy the files here from /etc/wireguard (in general)
    PATH = '/etc/wireguard'
    FILES = `sudo find /etc/wireguard/ -name *.conf`.split
    CONFIG = 'mullvad.dump'

    CONNECTIONS = FILES.map { |f| f.split('/').last }.uniq.map do |file|
      country = ISO3166::Country.find_country_by_alpha2(file[0..1].upcase)
      name = "#{country.common_name} #{country.emoji_flag}"
      { value: file, name: name }
    end.sort_by { |c| c[:name] }

    class << self
      # Select a random VPN connection
      def random
        FILES.sample
      end

      # Choose by country
      def country
        countries = CONNECTIONS.map { |c| { value: c[:value][0..1], name: c[:name] } }.uniq
        country = TTY::Prompt.new.select('Select country', countries, cycle: true, per_page: 30, filter: true)
        FILES.select { |a| a.split('/').last.start_with?(country) }.sample
      end

      # Select a specific connection
      def specific
        connections = CONNECTIONS.map { |c| { name: "#{c[:value]} #{c[:name]}", value: c[:value] } }
        TTY::Prompt.new.select('Select configuration file', connections, cycle: true, per_page: 30, filter: true)
      end

      # Check status
      def status
        status = `curl -s https://am.i.mullvad.net/connected`
        regexp = /\(server ([a-z]{2})[a-z\-0-9]+\)/
        # Add country name to the server if we are connected
        if (match = status.match(regexp))
          country = CONNECTIONS.find { |c| c[:value][0..1] == match[1] }[:name]
          status = status.gsub(regexp, "in #{country} \\0")
        end
        status
      end

      def connected?
        status.match?('You are connected')
      end

      def load_connection
        Marshal.load(File.read(CONFIG))
      end

      def save_connection
        File.open(CONFIG, 'wb') do |f|
          f.write(Marshal.dump(@connection))
        end
      end

      def connect(selection)
        connection_file = Mullvad::Manager.send(selection).split('/').last
        if connected?
          @connection = load_connection
          puts "Disconnecting from #{@connection.file}"
          @connection.disconnect
        end
        file = "#{PATH}/#{connection_file}"
        @connection = Mullvad::Connection.new(file)
        @connection.connect
        save_connection
      end

      def disconnect
        @connection = load_connection
        if @connection
          @connection.disconnect
        else
          puts 'No active connection available'
        end
      end
    end
  end
end
