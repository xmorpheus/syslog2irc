module Syslog2irc
  class SendSyslog
    include Cinch::Plugin

    def initialize(*)
      @channel = config[:channel] || fail 'Channel not set'
    end

    listen_to :syslog
    def listen(m, log)
      Channel(@channel).send log
    end
  end
end
