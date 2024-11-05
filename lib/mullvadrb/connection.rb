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
          status = status.split("\n")
                         .sort
                         .reject { |a| a == 'Connected' }
                         .prepend(I18n.t(:connected))
                         .push("\n")
                         .join("\n")
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
