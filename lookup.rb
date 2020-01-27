def get_command_line_argument
  
  if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end

domain = get_command_line_argument


dns_raw = File.readlines("zone")

def parse_dns(dns_raw)
  dns_records = {}
  dns_raw.reject { |info| info.empty? }.map { |info| info.split(",") }.map { |entry_array| entry_array.map { |record| record.strip } }.each { |data| dns_records[data[1]] = { :type => data[0], :value => data[2] } }
  return dns_records
end
  
def resolve(dns_records, lookup_chain,domain)
  if !dns_records.keys.include?domain
    puts "record not found for #{domain}"
    return lookup_chain
  elsif dns_records[domain][:type] == "A"
    lookup_chain.push(dns_records[domain][:value])
    return lookup_chain
  elsif dns_records[domain][:type] == "CNAME"
    lookup_chain.push(dns_records[domain][:value])
    resolve(dns_records, lookup_chain, dns_records[domain][:value])
  end
end
dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")

