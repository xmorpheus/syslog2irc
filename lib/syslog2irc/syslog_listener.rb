module Syslog2irc
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
end
