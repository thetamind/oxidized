class Cisco300 < Oxidized::Model

  prompt /^\r?([\w.@()-]+[#>]\s?)$/
  comment  '! '

  # example how to handle pager
  #expect /^\s--More--\s+.*$/ do |data, re|
  #  send ' '
  #  data.sub re, ''
  #end

  # non-preferred way to handle additional PW prompt
  #expect /^[\w.]+>$/ do |data|
  #  send "enable\n"
  #  send vars(:enable) + "\n"
  #  data
  #end

  cmd :all do |cfg|
    #cfg.gsub! /\cH+\s{8}/, ''         # example how to handle pager
    #cfg.gsub! /\cH+/, ''              # example how to handle pager
    cfg.each_line.to_a[1..-2].join
  end

  cmd :secret do |cfg|
    cfg.gsub! /^(snmp-server community).*/, '\\1 <configuration removed>'
    cfg.gsub! /username (\S+) privilege (\d+) (\S+).*/, '<secret hidden>'
    cfg
  end

  cmd 'show version' do |cfg|
    comment cfg.lines.first
  end

  cmd 'show inventory' do |cfg|
    comment cfg
  end

  cmd 'show running-config' do |cfg|
    cfg = cfg.each_line.to_a[3..-1].join
    cfg.gsub! /^Current configuration : [^\n]*\n/, ''
    cfg.sub! /^(ntp clock-period).*/, '! \1'
    cfg.gsub! /^\ tunnel\ mpls\ traffic-eng\ bandwidth[^\n]*\n*(
                  (?:\ [^\n]*\n*)*
                  tunnel\ mpls\ traffic-eng\ auto-bw)/mx, '\1'
    cfg
  end

  cfg :telnet do
    username /^User Name:/
    password /^\r?Password:$/
  end

  cfg :telnet, :ssh do
    username /^User Name:/
    password /^\r?Password:$/
    post_login 'terminal datadump'
    post_login 'terminal width 0'
    # preferred way to handle additional passwords
    if vars :enable
      post_login do
        send "enable\n"
        send vars(:enable) + "\n"
      end
    end
    pre_logout 'exit'
  end

end
