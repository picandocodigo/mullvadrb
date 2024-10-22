# frozen_string_literal: true

require 'tty-prompt'
require 'mullvadrb/account'
require 'mullvadrb/connection'
require 'mullvadrb/servers'

include Mullvadrb::Servers
@servers = load_servers

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

puts Mullvadrb::Connection.status

loop do
  selection = main_menu
  puts "\e[H\e[2J"
  case selection
  when 'status'
    puts Mullvadrb::Connection.status
  when 'disconnect'
    Mullvadrb::Connection.disconnect
  when 'country'
    select_country
    Mullvadrb::Connection.connect
  when 'specific'
    Mullvadrb::Servers.select_specific
    Mullvadrb::Connection.connect
  when 'random'
    random
    Mullvadrb::Connection.connect
  when 'update_servers'
    update
  when 'account_login'
    Mullvadrb::Account.login(
      TTY::Prompt.new.ask('Please enter your account number:')
    )
  when 'account_info'
    Mullvadrb::Account.info
  when 'account_devices'
    Mullvadrb::Account.devices
  when 'exit'
    abort('Tioraidh!')
  end
rescue SystemExit, Interrupt
  puts
  exit
end
