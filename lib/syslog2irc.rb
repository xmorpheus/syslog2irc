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

  IRC_HOST      = '42.x23.nu'
  IRC_PORT      = 6667
  IRC_CHANNEL   = '#isp6log'
  IRC_NICK      = 'isp6logbot'
  IRC_REALNAME  = 'oBot v0.1'
  SYSLOG_PORT   = 1514

  class SendSyslog
    include Cinch::Plugin

    listen_to :syslog
    def listen(m, log)
      Channel(IRC_CHANNEL).send log
    end
  end

  bot = Cinch::Bot.new do
    configure do |c|
      c.server    = IRC_HOST
      c.channels  = [IRC_CHANNEL]
      c.nick      = IRC_NICK
      c.port      = IRC_PORT
      c.realname  = IRC_REALNAME
      c.plugins.plugins = [SendSyslog]
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
          @data, @meta = @listener.recvfrom(9000)
          @parsed = SyslogProtocol.parse(@data, @meta[2])
          puts @data
          puts "foo"
          host = StringIrc.new(Resolv.getname(@meta[2]).to_s).bold.to_s
          message = @parsed.content

          @bot.handlers.dispatch(:syslog, nil, "#{host} - #{message}") if !Obscenity.profane?(message)
        rescue
          @bot.handlers.dispatch(:syslog, nil, 'syslog exception')
        end
      end
    end
  end

  Thread.new { SyslogListener.new(bot, SYSLOG_PORT).start }
  bot.start
end
