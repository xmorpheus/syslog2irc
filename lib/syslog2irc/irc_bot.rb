module Syslog2irc
  class IrcBot
    def initialize( host,
                    port = 6667,
                    channel,
                    nick = 'syslog2irc',
                    realname = 'oBot v0.1',
                    messages_per_second = 1,
                    server_queue_size = 10)
      raise 'not configured' if host.nil? || channel.nil?
      @bot = Cinch::Bot.new do
        configure do |c|
          c.server              = host
          c.channels            = [channel]
          c.nick                = nick
          c.port                = port
          c.realname            = realname
          c.messages_per_second = messages_per_second
          c.server_queue_size   = server_queue_size
          c.plugins.plugins     = [SendSyslog]
          c.plugins.options     = { SendSyslog => { channel: channel } }
        end
      end
    end

    def self.start
      @bot.start
    end

    def self.bot
      @bot
    end
  end
end
