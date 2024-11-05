# frozen_string_literal: true

require 'i18n'
require 'tty-prompt'
require 'mullvadrb/account'
require 'mullvadrb/command_manager'
require 'mullvadrb/connection'
require 'mullvadrb/servers'

module Mullvadrb
  I18n.load_path += Dir["#{File.expand_path('../config/locales', __dir__)}/*.yml"]

  class Main
    include Mullvadrb::CommandManager
    CONFIG_FILE = File.expand_path('~/.local/share/mullvadrb/backend.conf').freeze

    def initialize
      # To determine if we're using WireGuard or mullvad cli, attempt to load a pre-saved
      # configuration or prompt the user which one to use:
      backend = load_config || ask_backend_and_save
      puts I18n.t(:backend_using, backend: backend)
      puts Mullvadrb::Connection.status
    end

    def ask_backend_and_save
      backend = TTY::Prompt.new.select(I18n.t(:backend_which), cycle: true) do |menu|
        menu.choice name: I18n.t(:backend_wg), value: 'wg'
        menu.choice name: I18n.t(:backend_mullvad), value: 'mullvad'
      end
      @wg = (backend == 'wg')
      require 'mullvadrb/wg_manager' if @wg
      dir = File.expand_path('~/.local/share/mullvadrb/')
      system 'mkdir', '-p', dir unless File.exist?(dir)
      File.open(CONFIG_FILE, 'w+') { |f| f.write(backend) }
    end

    def languages
      language = TTY::Prompt.new.select(I18n.t(:language_which), cycle: true) do |menu|
        menu.choice name: I18n.t(:language_en), value: 'en'
        menu.choice name: I18n.t(:language_es), value: 'es'
      end
      I18n.locale = language.to_sym
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
      choices.merge!({ "❌ #{I18n.t(:exit)}" => 'exit' })
      TTY::Prompt.new.select(I18n.t(:main_menu), choices, cycle: true, per_page: 12)
    end

    def common_menu_choices
      {
        "📡 #{I18n.t(:status)}" => 'status',
        "🎰 #{I18n.t(:random)}" => 'random',
        "#{['🌏', '🌎', '🌍'].sample} #{I18n.t(:choose_country)}" => 'country',
        "🗺 #{I18n.t(:choose_specific)}" => 'specific',
        "🔌 #{I18n.t(:disconnect)}" => 'disconnect',
        "⚙ #{I18n.t(:change_backend)}" => 'backend',
        "🗣 #{I18n.t(:languages)}" => 'languages'
      }
    end

    def mullvad_cli_choices
      {
        "🗃 #{I18n.t(:update_servers)}" => 'update_servers',
        "🔑 #{I18n.t(:login)}" => 'account_login',
        "📁 #{I18n.t(:account_info)}" => 'account_info',
        "🖥 #{I18n.t(:devices)}" => 'account_devices'
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
            TTY::Prompt.new.ask(I18n.t(:please_enter_acct))
          )
        when 'account_info'
          Mullvadrb::Account.info
        when 'account_devices'
          Mullvadrb::Account.devices
        when 'languages'
          languages
        end
      rescue SystemExit, Interrupt
        abort("\n\nTioraidh!\n")
      end
    end
  end
end

Mullvadrb::Main.new.run
