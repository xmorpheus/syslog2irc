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

          #puts "Blacklisted: #{parsed.content}\n" if Obscenity.profane?(parsed.content) # uncomment to see blacklisted message on cli
          next if Obscenity.profane?(parsed.content)
          next if Obscenity.profane?(parsed.tag)

          begin
            host = Resolv.getname(meta[2]).to_s
	        rescue
            host = meta[2].to_s
          end

          #puts parsed.inspect

          message = "#{StringIrc.new(parsed.severity_name.upcase).bold.to_s} #{StringIrc.new(host).bold.to_s} - #{parsed.tag if parsed.tag != 'unknown'} #{parsed.content}"
          case parsed.severity_name
          when 'notice'
            message = StringIrc.new(message).light_blue
          when 'info'
            message = StringIrc.new(message).blue
          when 'warn'
            message = StringIrc.new(message).yellow
          when 'error', 'alert', 'crit', 'err'
            message = StringIrc.new(message).red
          else
            message = StringIrc.new(message).green
          end

          @bot.handlers.dispatch(:syslog, nil, message.to_s)
        rescue Exception => ex
	        puts ex.message
  	      puts ex.backtrace.join("\n")
          @bot.handlers.dispatch(:syslog, nil, 'syslog exception')
          raise ex
        end
      end
    end
  end
end
