# frozen_string_literal: true

require 'tty-prompt'
require 'mullvadrb/account'
require 'mullvadrb/command_manager'
require 'mullvadrb/connection'
require 'mullvadrb/servers'

module Mullvadrb
  class Main
    include Mullvadrb::CommandManager
    CONFIG_FILE = File.expand_path('~/.local/share/mullvadrb/backend.conf').freeze

    def initialize
      # To determine if we're using WireGuard or mullvad cli, attempt to load a pre-saved
      # configuration or prompt the user which one to use:
      backend = load_config || ask_backend_and_save
      puts "Using #{backend} backend"
      puts Mullvadrb::Connection.status
    end

    def ask_backend_and_save
      backend = TTY::Prompt.new.select('Which cli backend would you like to use?', cycle: true) do |menu|
        menu.choice name: 'WireGuard - wg (needs sudo powers)', value: 'wg'
        menu.choice name: 'Mullvad - mullvad', value: 'mullvad'
      end
      @wg = (backend == 'wg')
      require 'mullvadrb/wg_manager' if @wg
      dir = File.expand_path('~/.local/share/mullvadrb/')
      system 'mkdir', '-p', dir unless File.exist?(dir)
      File.open(CONFIG_FILE, 'w+') { |f| f.write(backend) }
    end

    def load_config
      return unless File.exist?(CONFIG_FILE)

      backend = File.read(CONFIG_FILE)
      @wg = (backend == 'wg')
      load_servers unless @wg
      require 'mullvadrb/wg_manager' if @wg
      backend
    end

    def load_servers
      @servers = Mullvadrb::Servers.servers
    end

    def main_menu
      choices = common_menu_choices
      choices.merge!(mullvad_cli_choices) unless @wg
      choices.merge!({ '❌ Exit' => 'exit' })
      TTY::Prompt.new.select('Main Menu', choices, cycle: true, per_page: 12)
    end

    def common_menu_choices
      {
        '📡 Status' => 'status',
        '🎰 Random' => 'random',
        "#{['🌏', '🌎', '🌍'].sample} Choose country" => 'country',
        '🗺 Choose specific' => 'specific',
        '🔌 Disconnect' => 'disconnect',
        '⚙ Change backend' => 'backend'
      }
    end

    def mullvad_cli_choices
      {
        '🗃 Update Servers' => 'update_servers',
        '🔑 Log in' => 'account_login',
        '📁 Account info' => 'account_info',
        '🖥 Devices' => 'account_devices'
      }
    end

    def run
      loop do
        selection = main_menu
        puts "\e[H\e[2J"
        case selection
        when 'status', 'disconnect', 'country', 'specific', 'random'
          send(selection)
        when 'exit'
          abort('Tioraidh!')
        when 'backend'
          ask_backend_and_save
        # Only when using mullvad cli and not wg:
        when 'update_servers'
          Mullvadrb::Servers.update
        when 'account_login'
          Mullvadrb::Account.login(
            TTY::Prompt.new.ask('Please enter your account number:')
          )
        when 'account_info'
          Mullvadrb::Account.info
        when 'account_devices'
          Mullvadrb::Account.devices
        end
      rescue SystemExit, Interrupt
        puts
        exit
      end
    end
  end
end

Mullvadrb::Main.new.run
