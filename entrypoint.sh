#!/bin/bash

for file in `ls *.pcap | sort`; 
do
    echo "====> Running zeek against provided pcap file - ${file}"
    zeek -r $file local
    dir_store=`basename ${file} .pcap`
    echo "====> Moving extracted data to ${dir_store} directory..."
    mkdir -p ${dir_store}
    mv *.log ${dir_store}/
done
