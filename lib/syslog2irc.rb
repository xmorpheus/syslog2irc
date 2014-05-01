require "syslog2irc/version"

module Syslog2irc

  require 'cinch'
  require 'syslog_protocol'
  require 'socket'
  require 'io/wait'
  require 'syslog'
  require 'string-irc'
  require 'resolv'
  require 'obscenity'

  IRC_HOST            = 'your_irc_server'
  IRC_PORT            = 6667
  IRC_CHANNEL         = '#your_path'
  IRC_NICK            = 'syslog2irc'
  IRC_REALNAME        = 'oBot v0.1'
  SYSLOG_PORT         = 1514
  MESSAGES_PER_SECOND = 2
  SERVER_QUEUE_SIZE   = 20

  class SendSyslog
    include Cinch::Plugin

    listen_to :syslog
    def listen(m, log)
      Channel(IRC_CHANNEL).send log
    end
  end

  bot = Cinch::Bot.new do
    configure do |c|
      c.server              = IRC_HOST
      c.channels            = [IRC_CHANNEL]
      c.nick                = IRC_NICK
      c.port                = IRC_PORT
      c.realname            = IRC_REALNAME
      c.plugins.plugins     = [SendSyslog]
      c.messages_per_second = MESSAGES_PER_SECOND
      c.server_queue_size   = SERVER_QUEUE_SIZE
    end
  end

  Obscenity.configure do |config|
    config.blacklist   = ["ignore_me"]
    config.replacement = :stars
  end

  class SyslogListener
    def initialize(bot, port)
      @bot  = bot
      @listener = UDPSocket.new
      @listener.bind("0.0.0.0", port)
    end

    def start
      loop do
        begin
          data, meta = @listener.recvfrom(9000)
          parsed = SyslogProtocol.parse(data, meta[2])
          next if Obscenity.profane?(parsed.content)

          host = Resolv.getname(meta[2]).to_s #StringIrc.new(Resolv.getname(meta[2]).to_s).bold.to_s

          message = "#{parsed.severity_name} #{host} - #{parsed.content}"
          case parsed.severity_name
          when 'notice'
            message = StringIrc.new(message).light_blue
          when 'info'
            message = StringIrc.new(message).blue
          when 'warn'
            message = StringIrc.new(message).yellow
          when 'error', 'alert', 'crit'
            message = StringIrc.new(message).red
          else
            message = StringIrc.new(message).green
          end

          @bot.handlers.dispatch(:syslog, nil, message.to_s)
        rescue
          @bot.handlers.dispatch(:syslog, nil, 'syslog exception')
        end
      end
    end
  end

  Thread.new { SyslogListener.new(bot, SYSLOG_PORT).start }
  bot.start
end
