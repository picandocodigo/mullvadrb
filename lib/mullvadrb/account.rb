module Mullvadrb
  module Account
    class << self
      def login(account)
        puts `mullvad account login #{account}`
      end

      def info
        puts `mullvad account get`
      end

      def devices
        puts `mullvad account list-devices`
        puts
      end
    end
  end
end
