module Mullvadrb
  # Displays a menu to set DNS blockers
  module DNS
    class << self
      def blockers
        status = cli_status
        selected = selected(status)

        choices = TTY::Prompt.new.multi_select(I18n.t(:dns_blockers_menu)) do |menu|
          menu.default(*selected) unless selected.empty?
          status.each_key do |k|
            menu.choice k.to_sym
          end
        end

        puts `mullvad dns set default #{cli_parameters(choices)}`
      end

      # Sets the parameters as arguments for `mullvad dns set``
      def cli_parameters(choices)
        choices.map do |choice|
          "--block-#{choice.gsub(' ', '-')}"
        end.join(' ')
      end

      # Gets the current status to show ones already selected
      def cli_status
        status = {}
        data = `mullvad dns get`.gsub('Block ', '').split("\n").reject { |a| a.start_with?('Custom') }
        data.map { |a| a.split(':') }.map do |entry|
          status[entry[0]] = convert_to_boolean(entry[1].strip)
        end
        status
      end

      # Get the index of the values that are already set (true). The multi_select uses `menu.default
      # 1, 2, n` to display selected: To mark choice(s) as selected use the default option with
      # either index(s) of the choice(s) starting from 1 or choice name(s) (why I add 1 to i)
      def selected(status)
        status.map.with_index { |(_, v), i| (i + 1) if v == true }.compact
      end

      # Convert string to booleans
      def convert_to_boolean(string)
        !!(string == 'true')
      end
    end
  end
end
