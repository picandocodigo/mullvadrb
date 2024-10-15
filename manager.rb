module Mullvad
  # Main module in charge of connection
  module Manager
    # Default path, copy the files here from /etc/wireguard (in general)
    PATH = '/etc/wireguard'
    FILES = `sudo find /etc/wireguard/ -name *.conf`.split
    CONFIG = 'mullvad.dump'
    COUNTRIES = [
      { value: 'al', name: 'Albania 🇦🇱' },
      { value: 'au', name: 'Australia 🇦🇺' },
      { value: 'at', name: 'Austria 🇦🇹' },
      { value: 'be', name: 'Belgium 🇧🇪' },
      { value: 'br', name: 'Brazil 🇧🇷' },
      { value: 'bg', name: 'Bulgaria 🇧🇬' },
      { value: 'ca', name: 'Canada 🇨🇦' },
      { value: 'co', name: 'Colombia 🇨🇴' },
      { value: 'hr', name: 'Croatia 🇭🇷' },
      { value: 'cz', name: 'Czech Republic 🇨🇿' },
      { value: 'dk', name: 'Denmark 🇩🇰' },
      { value: 'ee', name: 'Estonia 🇪🇪' },
      { value: 'fi', name: 'Finland 🇫🇮' },
      { value: 'fr', name: 'France 🇫🇷' },
      { value: 'de', name: 'Germany 🇩🇪' },
      { value: 'gr', name: 'Greece 🇬🇷' },
      { value: 'hk', name: 'Hong Kong 🇭🇰' },
      { value: 'hu', name: 'Hungary 🇭🇺' },
      { value: 'ie', name: 'Ireland 🇮🇪' },
      { value: 'it', name: 'Italy 🇮🇹' },
      { value: 'jp', name: 'Japan 🇯🇵' },
      { value: 'nl', name: 'Netherlands 🇳🇱' },
      { value: 'nz', name: 'New Zealand 🇳🇿' },
      { value: 'no', name: 'Norway 🇳🇴' },
      { value: 'pl', name: 'Poland 🇵🇱' },
      { value: 'pt', name: 'Portugal 🇵🇹' },
      { value: 'ro', name: 'Romania 🇷🇴' },
      { value: 'rs', name: 'Serbia 🇷🇸' },
      { value: 'sg', name: 'Singapore 🇸🇬' },
      { value: 'sk', name: 'Slovakia 🇸🇰' },
      { value: 'za', name: 'South Africa 🇿🇦' },
      { value: 'es', name: 'Spain 🇪🇸' },
      { value: 'se', name: 'Sweden 🇸🇪' },
      { value: 'ch', name: 'Switzerland 🇨🇭' },
      { value: 'gb', name: 'United Kingdom 🇬🇧' },
      { value: 'ua', name: 'Ukraine 🇺🇦' },
      { value: 'us', name: 'USA 🇺🇸' }
    ].freeze

    class << self
      # Select a random VPN connection
      def random
        FILES.sample
      end

      # Choose by country
      def country
        country = TTY::Prompt.new.select('Select country', COUNTRIES, cycle: true, per_page: 20, filter: true)
        FILES.select { |a| a.split('/').last.start_with?(country) }.sample
      end

      # Select a specific connection
      def specific
        countries = FILES.map do |c|
          {
            name: c.split('/').last,
            value: c
          }
        end
        TTY::Prompt.new.select('Select configuration file', countries, cycle: true, per_page: 20)
      end

      # Check status
      def status
        status = `curl -s https://am.i.mullvad.net/connected`
        regexp = /\(server ([a-z]{2})[a-z\-0-9]+\)/
        # Add country name to the server if we are connected
        if (match = status.match(regexp))
          country = COUNTRIES.find { |c| c[:value] == match[1] }[:name]
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
