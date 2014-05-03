module Syslog2irc
  class SyslogListener
    def initialize(bot, port)
      @bot  = bot
      @listener = UDPSocket.new
      @listener.bind('0.0.0.0', port)
    end

    def start
      loop do
        begin
          data, meta = @listener.recvfrom(9000)
          parsed = SyslogProtocol.parse(data, meta[2])

          next if Obscenity.profane?(parsed.content)
          next if Obscenity.profane?(parsed.tag)

          begin
            host = Resolv.getname(meta[2]).to_s
          rescue
            host = meta[2].to_s
          end

          severity = StringIrc.new(parsed.severity_name.upcase).bold
          hostname = StringIrc.new(host).bold
          tag = parsed.tag if parsed.tag != 'unknown'
          message = "#{severity} #{hostname} - #{tag} #{parsed.content}"
          message = colorfy(parsed.severity_name, message)

          @bot.handlers.dispatch(:syslog, nil, message.to_s)
        rescue => e
          puts "PLAIN: #{data}"
          puts e.message
          puts e.backtrace.join("\n")
          @bot.handlers.dispatch(:syslog, nil, 'syslog exception')
          raise e
        end
      end
    end

    private

    def colorfy(severity, msg)
      case severity
      when 'notice'
        return StringIrc.new(msg).light_blue
      when 'info'
        return StringIrc.new(msg).blue
      when 'warn'
        return StringIrc.new(msg).yellow
      when 'error', 'alert', 'crit', 'err'
        return StringIrc.new(msg).red
      else
        return StringIrc.new(msg).green
      end
    end
  end
end
