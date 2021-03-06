Puppet::Type.type(:firewall).provide :ip6tables, :parent => :iptables, :source => :iptables do
  @doc = "Ip6tables type provider"

  has_feature :iptables
  has_feature :rate_limiting
  has_feature :snat
  has_feature :dnat
  has_feature :interface_match
  has_feature :icmp_match
  has_feature :owner
  has_feature :state_match
  has_feature :reject_type
  has_feature :log_level
  has_feature :log_prefix
  has_feature :mark
  has_feature :tcp_flags
  has_feature :pkttype

  optional_commands({
    :iptables      => '/sbin/ip6tables',
    :iptables_save => '/sbin/ip6tables-save',
  })

  @resource_map = {
    :burst => "--limit-burst",
    :destination => "-d",
    :dport => "--dports",
    :icmp => "--icmpv6-type",
    :gid => "--gid-owner",
    :iniface => "-i",
    :jump => "-j",
    :limit => "--limit",
    :log_level => "--log-level",
    :log_prefix => "--log-prefix",
    :name => "--comment",
    :outiface => "-o",
    :port => '--ports',
    :proto => "-p",
    :reject => "--reject-with",
    :source => "-s",
    :state => "--state",
    :sport => "--sports",
    :table => "-t",
    :todest => "--to-destination",
    :toports => "--to-ports",
    :tosource => "--to-source",
    :uid => "--uid-owner",
    :pkttype => "--pkt-type"
  }

  # This is the order of resources as they appear in iptables-save output,
  # we need it to properly parse and apply rules, if the order of resource
  # changes between puppet runs, the changed rules will be re-applied again.
  # This order can be determined by going through iptables source code or just tweaking and trying manually
  @resource_list = [:table, :source, :destination, :iniface, :outiface,
    :proto, :gid, :uid, :sport, :dport, :port, :pkttype, :name, :state, :icmp, :limit, :burst, :jump,
    :todest, :tosource, :toports, :log_level, :log_prefix, :reject]

  @singular_ports = {
    :dport => '--dport',
    :sport => '--sport',
    :port  => '--port',
  }

  @resource_modules = {
    :name      => :comment,
    :state     => :state,
    :icmp_type => :icmp_type,
    :port      => lambda { |v|
      return :multiport if v.to_a.length > 1
    },
    :dport     => lambda { |v|
      return :multiport if v.to_a.length > 1
    },
    :sport     => lambda { |v|
      return :multiport if v.to_a.length > 1
    },
    :gid       => :owner,
    :uid       => :owner,
    :pkttype   => :pkttype,
    :tcp_flags => :tcp,
  }

  @resources_by_arg = @resource_map.invert.merge(@singular_ports.invert)

end
