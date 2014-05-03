# Syslog2irc

Simple Syslog to IRC Gateway with message filtering

## Installation
 
1. `$ git clone https://github.com/xmorpheus/syslog2irc.git`
2. Change to the syslog2irc directory
3. Change into the config directory
4. `$ copy config-default.yml config.yml`
5. `$ copy blacklist-default.yml blacklist.yml`
6. Edit configuration `$ $EDITOR config.yml`
7. Setup IPTables to direct syslog traffic to a port > 1024 `$ iptables -t nat -A PREROUTING -p udp --dport 514 -j REDIRECT --to-port 1514`

## Usage

`$ ./bin/syslog2irc`

## Contributing

1. Fork it ( http://github.com/<my-github-username>/syslog2irc/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
