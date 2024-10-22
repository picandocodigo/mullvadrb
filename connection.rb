module Mullvad
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
        puts `mullvad status -v`
      end
    end
  end
end
