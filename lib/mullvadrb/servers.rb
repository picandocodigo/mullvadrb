module Mullvadrb
  module Servers
    class << self
      SERVERS_FILE = File.expand_path('~/.local/share/mullvadrb/servers.dump').freeze

      def update
        `mullvad relay update`
        data = `mullvad relay list`
        country, city, info, flag = nil

        # Remove empty lines, and OpenVPN lines
        server_data = data.split("\n").compact.reject(&:empty?)
        # Each line is either a country, a city or a server
        servers = server_data.reject { |a| a.include?('ovpn') }.map do |line|
          if line.start_with?("\t\t")
            info = line.gsub("\t\t", '')
            { country: country, city: city, info: info, flag: flag, value: info.split(' ').first }
          elsif line.start_with?("\t")
            city = line.gsub("\t", '').split('(').first.strip
            next
          else
            regexp = /\(([a-z]{2})\)/ # Country (xx) - Country name + code and group code
            flag = line.match(regexp)[1]
                    .upcase
                    .codepoints
                    .map { |c| (c + 127_397).chr('utf-8') }.join
            country = line.gsub(regexp, '').strip
            next
          end
        end.compact

        save_servers(servers)
        puts I18n.t(:servers_updated)
        puts
      end

      def select_country
        servers = @servers
        country = TTY::Prompt.new.select(I18n.t(:select_country), countries(servers), cycle: true, per_page: 10, filter: true, symbols: { marker: '🛫' })
        connection = servers.select do |s|
          s[:country] == country
        end.sample
        puts `mullvad relay set location #{connection[:value]}`
      end

      def random
        server = all_connections.sample
        puts I18n.t(:connecting_to, server: server[:name])
        puts `mullvad relay set location #{server[:value]}`
      end

      def select_specific
        connections = all_connections
        server = TTY::Prompt.new.select(
          I18n.t(:select_server),
          connections,
          cycle: true,
          per_page: 10,
          filter: true,
          symbols: { marker: '🛫' }
        )
        puts `mullvad relay set location #{server}`
      end

      def servers
        @servers ||= load_servers
      end

      private

      def countries(servers)
        servers.uniq { |s| s[:country] }.map do |server|
          {
            name: "#{server[:flag]} #{server[:country]}",
            value: server[:country]
          }
        end
      end

      def all_connections
        servers.map do |server|
          {
            name: "#{server[:flag]} #{server[:country]} - #{server[:city]}: #{server[:info]}",
            value: server[:value]
          }
        end
      end

      def emoji_from_code(code)
        code.upcase
            .codepoints
            .map { |c| (c + 127_397).chr('utf-8') }.join
      end

      def load_servers
        servers = File.expand_path(SERVERS_FILE)
        if File.file?(servers)
          Marshal.load(File.read(servers))
        else
          update
        end
      end

      def save_servers(servers)
        File.open(SERVERS_FILE, 'w+') do |f|
          f.write(Marshal.dump(servers))
        end
      end
    end
  end
end
