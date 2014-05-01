require 'cinch'
require 'syslog'
require 'syslog_protocol'
require 'string-irc'
require 'socket'
require 'resolv'
require 'obscenity'

require 'syslog2irc/version'
require 'syslog2irc/irc_bot'
require 'syslog2irc/send_Syslog'
require 'syslog2irc/syslog_listener'


module Syslog2irc
  IRC_HOST            = 'your_irc_server'
  IRC_PORT            = 6667
  IRC_CHANNEL         = '#your_path'
  IRC_NICK            = 'syslog2irc'
  IRC_REALNAME        = 'oBot v0.1'
  SYSLOG_PORT         = 1514
  MESSAGES_PER_SECOND = 2
  SERVER_QUEUE_SIZE   = 20

  Obscenity.configure do |config|
    config.blacklist   = ["ignore_me"]
    config.replacement = :stars
  end

  Thread.new { SyslogListener.new(IrcBot.bot, SYSLOG_PORT).start }
  IrcBot.start
end
