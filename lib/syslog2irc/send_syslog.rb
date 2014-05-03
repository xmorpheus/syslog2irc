module Syslog2irc
  class SendSyslog
    include Cinch::Plugin

    def initialize(*)
      super
      @channel = config[:channel]
    end

    listen_to :syslog
    def listen(_m, log)
      Channel(@channel).send log
    end
  end
end
