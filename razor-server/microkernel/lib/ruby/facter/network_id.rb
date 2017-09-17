require 'ipaddr'


NETWORKS={
  'dev'      => IPAddr.new('172.16.61.0/24'),
  'test'     => IPAddr.new('172.16.62.0/24'),
  'prod'     => IPAddr.new('10.24.0.0/16'),
  'infra'    => IPAddr.new('192.168.50.0/24'),
  'razor'    => IPAddr.new('192.168.51.0/24'),
  'razor'    => IPAddr.new('10.0.2.0/24'),
  'loopback' => IPAddr.new('127.0.0.0/24')
}

def find_netblock_id(ip)
  NETWORKS.find { | name, netblock |
    netblock.include?(ip)
  }.first # find returns an array but we only care about the first match
rescue => e
  # we don't want to throw an error if there are no matches
end

Facter.add(:network_id) do
  setcode do
    find_netblock_id(Facter.value(:ipaddress))
  end
end

Facter.add(:network_ids) do
  setcode do
    network_ids_hash = {}

    Facter.value(:interfaces).split(',').each do |interface|
      ipaddress = Facter.value("ipaddress_#{interface}")
      netblock  = find_netblock_id(ipaddress)

      network_ids_hash[interface] = netblock ? netblock : 'unknown'
    end

    network_ids_hash
  end
end
