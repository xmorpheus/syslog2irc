require "syslog2irc/version"

module Syslog2irc

  require 'syslog_protocol'
  require 'socket'
  require 'io/wait'
  require 'syslog'
  require 'string-irc'
  require 'resolv'
  require 'obscenity'

  IRC_HOST = 'your_irc_server'
  IRC_PORT = 6667
  IRC_CHANNEL = '#your_path'
  IRC_NICK = 'syslog2irc'
  IRC_REALNAME = 'oBot v0.1'

  Obscenity.configure do |config|
    config.blacklist   = ["ignore_me"]
    config.replacement = :stars
  end

  Thread.new do

    puts "Opening TCPSocket on #{IRC_HOST}:#{IRC_PORT}"
    @socket = TCPSocket.open(IRC_HOST, IRC_PORT)
    @socket.puts("NICK #{IRC_NICK}")
    @socket.puts("USER #{IRC_NICK} 8 * : #{IRC_REALNAME}")
    @socket.puts("JOIN #{IRC_CHANNEL}")

    while true

      sb = @socket.gets
      puts sb
      case sb
        when /^PING :(.+)$/i
          @socket.puts("PONG :#{$1}")
          puts "--> PONG #{$1}"
      end


    end

  end
  
  @listener = UDPSocket.new
  @listener.bind("0.0.0.0", "1514")
  while true do
    begin
      @data, @meta = @listener.recvfrom(9000)
      @parsed = SyslogProtocol.parse(@data, @meta[2])

      host = StringIrc.new(Resolv.getname(@meta[2]).to_s).bold.to_s
      message = @parsed.content
    
      @socket.puts("PRIVMSG #{IRC_CHANNEL} #{host} - #{message}") if !Obscenity.profane?(message)
    rescue
      @socket.puts("PRIVMSG #{IRC_CHANNEL} syslog exception")
    end
  end

end
