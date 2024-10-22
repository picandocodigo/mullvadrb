# frozen_string_literal: true

require 'tty-prompt'
require_relative 'account'
require_relative 'connection'
require_relative 'servers'

def main_menu
  TTY::Prompt.new.select('Select', cycle: true, per_page: 10) do |menu|
    menu.choice name: '📡 Status', value: 'status'
    menu.choice name: '🎰 Random', value: 'random'
    menu.choice name: "#{['🌏', '🌎', '🌍'].sample} Choose country", value: 'country'
    menu.choice name: '🗺 Choose specific', value: 'specific'
    menu.choice name: '🔌 Disconnect', value: 'disconnect'
    menu.choice name: '🗃 Update Servers', value: 'update_servers'
    menu.choice name: '🔑 Log in', value: 'account_login'
    menu.choice name: '📁 Account info', value: 'account_info'
    menu.choice name: '🖥 Devices', value: 'account_devices'
    menu.choice name: '❌ Exit', value: 'exit'
  end
end

puts Mullvad::Connection.status

loop do
  selection = main_menu
  puts "\e[H\e[2J"
  case selection
  when 'status'
    puts Mullvad::Connection.status
  when 'disconnect'
    Mullvad::Connection.disconnect
  when 'country'
    Mullvad::Servers.select_country
    Mullvad::Connection.connect
  when 'specific'
    Mullvad::Servers.select_specific
    Mullvad::Connection.connect
  when 'random'
    Mullvad::Servers.random
    Mullvad::Connection.connect
  when 'update_servers'
    Mullvad::Servers.update
  when 'account_login'
    Mullvad::Account.login(
      TTY::Prompt.new.ask('Please enter your account number:')
    )
  when 'account_info'
    Mullvad::Account.info
  when 'account_devices'
    Mullvad::Account.devices
  when 'exit'
    abort('Tioraidh!')
  end
rescue SystemExit, Interrupt
  puts
  exit
end
