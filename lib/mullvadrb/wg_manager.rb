require 'countries'

module Mullvadrb
  module WgManager
    # Default path, copy the files here from /etc/wireguard (in general)
    PATH = '/etc/wireguard'
    FILES = `sudo find /etc/wireguard/ -name *.conf`.split
    CONFIG = File.expand_path('~/.local/share/mullvadrb/connection.dump').freeze

    CONNECTIONS = FILES.map { |f| f.split('/').last }.uniq.map do |file|
      country = ISO3166::Country.find_country_by_alpha2(file[0..1].upcase)
      name = "#{country.common_name} #{country.emoji_flag}"
      { value: file, name: name }
    end.sort_by { |c| c[:name] }

    class << self
      # Select a random VPN connection
      def random
        connect(FILES.sample)
      end

      # Choose by country
      def country
        countries = CONNECTIONS.map { |c| { value: c[:value][0..1], name: c[:name] } }.uniq
        country = TTY::Prompt.new.select('Select country', countries, cycle: true, per_page: 30, filter: true)
        connect FILES.select { |a| a.split('/').last.start_with?(country) }.sample
      end

      # Select a specific connection
      def specific
        connections = CONNECTIONS.map { |c| { name: "#{c[:value]} #{c[:name]}", value: c[:value] } }
        connect(
          TTY::Prompt.new.select(
            'Select configuration file',
            connections,
            cycle: true,
            per_page: 30,
            filter: true
          )
        )
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
        connection_file = selection.split('/').last
        current = status
        if current.match?('You are connected')
          server = current.match(/\(server (.*)\)/)[1]
          puts "Disconnecting from #{server}"
          disconnect
        end
        @connection = connection_file
        puts "Attempting to connect to #{@connection}"
        puts system("wg-quick up #{PATH}/#{@connection}")
        save_connection
      end

      def disconnect
        @connection = load_connection
        if @connection
          wg_disconnect
        else
          puts 'No active connection available'
        end
      end

      def wg_disconnect
        if system("wg-quick down #{PATH}/#{@connection}")
          puts "🔌 Successfully pulled the plug from #{@connection}"
        else
          puts 'Error disconnecting'
          puts 'Maybe the connection wasn\'t active? 🤨'
        end
      end
    end
  end
end
