#!/usr/bin/env ruby
# 
# Author L
#

pcap_file = ARGV[0]
extract_file = ARGV[1]

unless pcap_file
  abort <<~EOF
    Usage
      Read file list : ./mms_extract_file.rb <pcapfile>
      Extract file   : ./mms_extract_file.rb <pcapfile> <extract_file>
    EOF
  EOF
end

if extract_file
  invokeids = `tshark -r #{pcap_file} -Y 'mms.FileName_item == "#{extract_file}"' -Tfields -e mms.invokeID`.split.join(' ')
  frsmids = `tshark -r #{pcap_file} -Y 'mms.invokeID in {#{invokeids}} && mms.confirmedServiceResponse && mms.frsmID' -Tfields -e mms.frsmID`.split.join(' ')
  invokeids = `tshark -r #{pcap_file} -Y 'mms.fileRead in {#{frsmids}} && mms.confirmedServiceRequest' -Tfields -e mms.invokeID`.split

  invokeids.each do |invokeid|
     hex_data = `tshark -r #{pcap_file} -Y 'mms.invokeID == #{invokeid} && mms.confirmedServiceResponse' -Tfields -e mms.fileData`
     p [hex_data].pack('H*')
  end
else
  system "tshark -r #{pcap_file} -Y mms.FileName_item -Tfields -e mms.FileName_item | sort -u"
end
