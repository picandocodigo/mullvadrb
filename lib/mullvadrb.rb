# frozen_string_literal: true

require 'i18n'
require 'tty-prompt'
require 'mullvadrb/account'
require 'mullvadrb/command_manager'
require 'mullvadrb/connection'
require 'mullvadrb/servers'
require 'yaml'

module Mullvadrb
  I18n.load_path += Dir["#{File.expand_path('../config/locales', __dir__)}/*.yml"]

  # Main object instantiated, saves backend, i18n if set, and persists.
  class Main
    include Mullvadrb::CommandManager
    CONFIG_FILE = File.expand_path('~/.local/share/mullvadrb/mullvadrb.yml').freeze

    def initialize
      # To determine if we're using WireGuard or mullvad cli, attempt to load a pre-saved
      # configuration or prompt the user which one to use:
      load_config
      @backend ||= ask_backend
      puts I18n.t(:backend_using, backend: @backend)
      I18n.locale = @locale || I18n.default_locale
      save_config!
      puts Mullvadrb::Connection.status
    end

    def ask_backend
      backend = TTY::Prompt.new.select(I18n.t(:backend_which), cycle: true) do |menu|
        menu.choice name: I18n.t(:backend_wg), value: 'wg'
        menu.choice name: I18n.t(:backend_mullvad), value: 'mullvad'
      end
      @wg = (backend == 'wg')
      require 'mullvadrb/wg_manager' if @wg
      backend
    end

    def languages
      language = TTY::Prompt.new.select(I18n.t(:language_which), cycle: true) do |menu|
        menu.choice name: I18n.t(:language_en), value: 'en'
        menu.choice name: I18n.t(:language_es), value: 'es'
      end
      @locale = language.to_sym
      I18n.locale = @locale
      save_config!
    end

    def load_config
      return unless File.exist?(CONFIG_FILE)

      config_file = YAML.load(File.read(CONFIG_FILE))
      @backend = config_file[:backend]
      @locale = config_file[:locale]
      @wg = (@backend == 'wg')
      load_servers unless @wg
      require 'mullvadrb/wg_manager' if @wg
    end

    def save_config!
      dir = File.expand_path('~/.local/share/mullvadrb/')
      system 'mkdir', '-p', dir unless File.exist?(dir)
      config = {
        backend: @backend,
        locale: @locale || I18n.locale
      }
      File.open(CONFIG_FILE, 'w+') do |f|
        f.write(config.to_yaml)
      end
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
        exit if selection == 'exit'

        case selection
        when 'status', 'disconnect', 'country', 'specific', 'random'
          send(selection)
        when 'backend'
          ask_backend
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
