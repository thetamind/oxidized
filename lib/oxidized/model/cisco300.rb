class Cisco300 < Oxidized::Model

  prompt /^\r?([\w.@()-]+[#>]\s?)$/
  comment  '! '

  cmd :all do |cfg|
    lines = cfg.each_line.to_a[1..-2]
    lines[0].gsub!(/^\r.*?/,'') if lines.length > 0
    lines.join
  end

  cmd :secret do |cfg|
    cfg.gsub! /^(snmp-server community).*/, '\\1 <configuration removed>'
    cfg.gsub! /username (\S+) privilege (\d+) (\S+).*/, '<secret hidden>'
    cfg
  end

  cmd 'show version' do |cfg|
    comment cfg
  end

  cmd 'show inventory' do |cfg|
    comment cfg
  end

  cmd 'show running-config' do |cfg|
    cfg = cfg.each_line.to_a[0..-1].join
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
    post_login 'terminal datadump' # Disable pager
    post_login 'terminal width 0'
    pre_logout 'exit'
  end

end
