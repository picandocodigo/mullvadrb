module Mullvad
  module Servers
    SERVERS = 'servers.dump'.freeze

    class << self
      def update
        `mullvad relay update`
        data = `mullvad relay list`
        country, city, info, flag, value = nil

        # Each line is either a country, a city or a server
        servers = data.split("\n").compact.reject(&:empty?).map do |s|
          if s.start_with?("\t\t")
            info = s.gsub("\t\t", '')
            { country: country, city: city, info: info, flag: flag, value: info.split(' ').first }
          elsif s.start_with?("\t")
            city = s.gsub("\t", '').split("(").first.strip
            next
          else
            regexp = /\(([a-z]{2})\)/ # Country (xx) - Country name + code and group code
            flag = s.match(regexp)[1]
                    .upcase
                    .codepoints
                    .map { |c| (c + 127397).chr('utf-8') }.join
            country = s.gsub(regexp, '').strip
            next
          end
        end.compact

        save_servers(servers)
        puts '🗃 Server list updated'
        puts
      end

      def select_country
        servers = load_servers
        country = TTY::Prompt.new.select('Select country', countries(servers), cycle: true, per_page: 10, filter: true, symbols: { marker: '🛫' })
        connection = servers.select do |s|
          s[:country] == country
        end.sample
        puts `mullvad relay set location #{connection[:value]}`
      end

      def random
        server = all_connections.sample
        puts "Connecting to #{server[:name]}"
        puts `mullvad relay set location #{server[:value]}`
      end

      def select_specific
        connections = all_connections
        server = TTY::Prompt.new.select(
          'Select configuration file',
          connections,
          cycle: true,
          per_page: 10,
          filter: true,
          symbols: { marker: '🛫' }
        )
        puts `mullvad relay set location #{server}`
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
        load_servers.map do |server|
          {
            name: "#{server[:flag]} #{server[:country]} - #{server[:city]}: #{server[:info]}",
            value: server[:value]
          }
        end
      end

      def emoji_from_code(code)
        code.upcase
            .codepoints
            .map { |c| (c + 127397).chr('utf-8') }.join
      end

      def load_servers
        Marshal.load(File.read(SERVERS))
      end

      def save_servers(servers)
        File.open(SERVERS, 'wb') do |f|
          f.write(Marshal.dump(servers))
        end
      end
    end
  end
end
