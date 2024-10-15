# frozen_string_literal: true

require 'tty-prompt'
require_relative 'connection'
require_relative 'manager'

def main_menu
  TTY::Prompt.new.select('Select', cycle: true) do |menu|
    menu.choice name: '🤪 Random', value: 'random'
    menu.choice name: '🌐 Choose country', value: 'country'
    menu.choice name: '🌆 Choose specific', value: 'specific'
    menu.choice name: '📡 Status', value: 'status'
    menu.choice name: '🔌 Disconnect', value: 'disconnect'
    menu.choice name: '❌ Exit', value: 'exit'
  end
end

while true do
  begin
    selection = main_menu
    puts "\e[H\e[2J"
    case selection
    when 'status'
      status = Mullvad::Manager.status
      if status.match?('You are connected')
        puts "📡 #{status}"
      else
        puts "❌ #{status}"
      end
    when 'disconnect'
      Mullvad::Manager.disconnect
    when 'exit'
      abort('Tioraidh!')
    when 'country', 'specific', 'random'
      Mullvad::Manager.connect(selection)
    end
  rescue SystemExit, Interrupt
    puts
    exit
  end
end
