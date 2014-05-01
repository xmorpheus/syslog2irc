require 'cinch'
require 'syslog'
require 'syslog_protocol'
require 'string-irc'
require 'socket'
require 'resolv'
require 'obscenity'
require 'yaml'

require 'syslog2irc/version'
require 'syslog2irc/irc_bot'
require 'syslog2irc/send_syslog'
require 'syslog2irc/syslog_listener'


module Syslog2irc

  settings = YAML::load_file(File.join(__dir__, '../config/config.yml'))

  Obscenity.configure do |config|
    config.blacklist   = ["ignore_me"]
    config.replacement = :stars
  end

  bot = IrcBot.new( settings['irc']['host'],
                    settings['irc']['channel'],
                    settings['irc']['port'],
                    settings['irc']['nick'],
                    settings['irc']['realname'],
                    settings['irc']['mps'],
                    settings['irc']['sqs'])
  Thread.new { SyslogListener.new(bot, settings['syslog']['port']).start }
  bot.start
end
