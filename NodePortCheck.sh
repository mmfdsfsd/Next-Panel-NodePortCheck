#!/bin/bash 

source /etc/profile
PATH=/usr/local/bin:$PATH

USERNAME="root"
PASSWORD="********"
HOSTNAME="127.0.0.1"
PORT="3306"
DBNAME="sspanel"
TABLENAME="node"

for line in `cat nodelist.txt | grep -v ^# |grep -v ^$`
do  
    domain=`echo $line | awk 'BEGIN{FS="|"} {print $1}'`
    port=`echo $line | awk 'BEGIN{FS="|"} {print $2}'`
    echo "(sleep 1;) | telnet $domain $port"
    (sleep 1;) | telnet $domain $port > telnet_domain_result.txt
    result=`cat telnet_node_result.txt | grep -B 1 \] | grep [0-9] | awk '{print $3}' | cut -d '.' -f 1,2,3,4`
    echo "$result"
    if [ -n "$result" ]; then
        echo "$domain|$port|" >> telnet_node_checked.txt
		
    else
	
		newport=`expr $port + 1`
        	echo $(date +"%y-%m-%d %H:%M:%S") "$domain:$port Fail! " >> telnet_domain_failed.txt
		echo "$domain|$newport|" >> telnet_node_checked.txt
		
		if [ "$domain" = "test.com" ]; then
		update_sql="update ${TABLENAME} set custom_config = JSON_REPLACE(custom_config,'$.offset_port_node','$newport') where id =1"
		mysql -h${HOSTNAME} -P${PORT} -u${USERNAME} -p${PASSWORD} -D ${DBNAME} -e "${update_sql}"
		fi
		
		
		
    fi
done
	mv  telnet_node_checked.txt  nodelist.txt
	echo "telnet node_port checked over!"
