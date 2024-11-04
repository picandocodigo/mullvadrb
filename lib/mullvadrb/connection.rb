module Mullvadrb
  #
  # Manage Mullvad connect, disconnect and status
  #
  module Connection
    class << self
      def connect
        puts `mullvad connect`
        if $?.success?
          puts '☎ Connecting...'
        else
          puts 'Error connecting'
        end
      end

      def disconnect
        puts `mullvad disconnect`
        if $?.success?
          puts '🔌 Pulling the plug'
        else
          puts 'Error disconnecting'
          puts 'Maybe the connection wasn\'t active? 🤨'
        end
        sleep 2
        status
      end

      def status
        status = `mullvad status -v`
        if status.start_with?('Disconnected')
          status.gsub!('Disconnected', "\n⚠ 🚨  DISCONNECTED  🚨 c⚠")
                .gsub!(/$/, "\n")
        elsif status.start_with?('Connected')
          status = status.split("\n")
                         .sort
                         .reject { |a| a == 'Connected' }
                         .prepend("📡 Connected ✅ \n")
                         .push("\n")
                         .join("\n")
        elsif status.start_with?('Connecting')
          status = status.split("\n")
                         .sort
                         .reject { |a| a == 'Connecting' }
                         .prepend("📞 Connecting ☎ \n")
                         .push("\n")
                         .join("\n")
        end
        status
      end
    end
  end
end
