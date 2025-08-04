require 'countries'

module Mullvadrb
  #
  # Manage Mullvad connect, disconnect and status
  #
  module Connection
    class << self
      def connect
        puts `mullvad connect`
        if $?.success?
          puts I18n.t(:connecting)
        else
          puts I18n.t(:error_connecting)
        end
      end

      def disconnect
        puts `mullvad disconnect`
        if $?.success?
          puts I18n.t(:pulling_the_plug)
        else
          puts I18n.t(:error_disconnecting)
          puts I18n.t(:maybe_connection_inactive)
        end
        sleep 2
        status
      end

      def status
        status = `mullvad status -v`
        if status.start_with?('Disconnected')
          status.gsub!('Disconnected', I18n.t(:disconnected))
                .gsub!(/$/, "\n")
        elsif status.start_with?('Connected')
          status = status.split("\n").reject { |a| a == 'Connected' }
          country_name = status.find { |a| a.match?('Visible location') }.split("\s")[2].gsub(',','')
          country = ISO3166::Country.find_country_by_any_name(country_name)
          status = status.prepend("#{I18n.t(:connected)} to #{country.emoji_flag} #{country.common_name}\n")
                         .push("\n")
                         .join("\n")
        # Blocked: Failure to generate tunnel parameters: Failure to select a matching tunnel relay
        elsif status.start_with?('Blocked')
          status.prepend("\n🚧 ").concat("\n")
        elsif status.start_with?('Connecting')
          status = status.split("\n")
                         .sort
                         .reject { |a| a == 'Connecting' }
                         .prepend(I18n.t(:connecting))
                         .push("\n")
                         .join("\n")
        end
        status
      end
    end
  end
end
