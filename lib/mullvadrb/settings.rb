module Mullvadrb
  module Settings
    CONFIG_FILE = File.expand_path('~/.local/share/mullvadrb/mullvadrb.yml').freeze

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
  end
end
