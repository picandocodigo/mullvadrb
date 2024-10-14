module Mullvad
  #
  # Initialize a Connection class to manage which file to use and connect, disconnect, check
  # connection status, etc.
  #
  class Connection
    attr_accessor :file

    def initialize(file)
      @file = file
    end

    def connect
      puts "Attempting to connect to #{@file}"
      system("wg-quick up #{@file}")
    end

    def disconnect
      if system("wg-quick down #{@file}")
        puts '🔌 Successfully pulled the plug'
        @connected = false
      else
        puts 'Error disconnecting'
        puts 'Maybe the connection wasn\'t active? 🤨'
      end
    end
  end
end
