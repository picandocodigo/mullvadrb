module Mullvadrb
  module CommandManager
    def connect
      if @wg
        Mullvadrb::WgManager.connect
      else
        Mullvadrb::Connection.connect
      end
    end

    def disconnect
      if @wg
        Mullvadrb::WgManager.disconnect
      else
        Mullvadrb::Connection.disconnect
      end
    end

    def status
      if @wg
        puts Mullvadrb::WgManager.status
      else
        puts Mullvadrb::Connection.status
      end
    end

    def random
      if @wg
        Mullvadrb::WgManager.random
      else
        Mullvadrb::Servers.random
        Mullvadrb::Connection.connect
      end
    end

    def country
      if @wg
        Mullvadrb::WgManager.country
      else
        Mullvadrb::Servers.select_country
        Mullvadrb::Connection.connect
      end
    end

    def specific
      if @wg
        Mullvadrb::WgManager.specific
      else
        Mullvadrb::Servers.select_specific
        Mullvadrb::Connection.connect
      end
    end

    def lan
      puts `mullvad lan set allow`
      puts
    end
  end
end
