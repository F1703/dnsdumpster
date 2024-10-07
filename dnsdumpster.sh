#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RESET='\033[0m' 


flag_a=0
flag_m=0
flag_n=0
flag_ip=0
data=()

if [[ ! -f "/usr/bin/xlsx2csv" ]] ; then
    echo -e "${YELLOW}[+] Please install: xlsx2csv \nsudo apt install -y xlsx2csv${RESET}"
    exit     
fi 

show_help() {
    echo "Usage: $0 [-d] [-a] [-m] [-n] [-h]"
    echo "Options:"
    echo "  -d  domain.com"
    echo "  -a  Host Records (A) (default)"
    echo "  -m  MX Records"
    echo "  -n  DNS Servers"
    echo "  -i  IP Address"
    echo "  -h  Display this help message"
}



flag_domain=0
mydomain=0
while getopts ":amnih:d:" opt; do
    case $opt in
        d)
            mydomain="$OPTARG"
            flag_domain=1 
            ;;
        a)
            flag_a=1
            ;;
        m)
            flag_m=1
            ;;
        n)
            flag_n=1
            ;;
        i)
            flag_ip=1
            ;;
        h)
            show_help
            exit 0
            ;;
        \?)
            flag_a=1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            ;;
    esac
done

tmp=/tmp/tmpdnsd/$mydomain
cookies=$tmp/cookiesdnsd.txt
domain=https://dnsdumpster.com
targetip=$mydomain
mkdir $tmp -p 2>/dev/null 


download() {
    curl -s -c $cookies -X GET "https://dnsdumpster.com" > $tmp/index.html 
    csrfmiddlewaretoken=$(cat $tmp/index.html | grep -oP '(?<=name="csrfmiddlewaretoken" value=")[^"]+' | head -1 | xargs)
    user=free

    curl -s -b $cookies -X POST 'https://dnsdumpster.com/' \
    -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' \
    -H 'content-type: application/x-www-form-urlencoded' \
    -H 'origin: https://dnsdumpster.com' \
    -H 'referer: https://dnsdumpster.com/' \
    -H 'user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36' \
    --data-raw 'csrfmiddlewaretoken='$csrfmiddlewaretoken'&targetip='$targetip'&user=free' > $tmp/index.download.html

    xlsx=$(cat $tmp/index.download.html | grep -oP '(?<=href=")[^"]+' | grep .xlsx | xargs)

    if [[ $(echo "$xlsx" | wc -c)  -gt 2 ]] ; then 
        curl -s -b $cookies -X GET "$domain$xlsx"  -o $tmp/file.xlsx
    fi 
    
    xlsx2csv -e -d=',' $tmp/file.xlsx > $tmp/csv.csv
}


if [ $flag_domain -eq 0 ] ; then 
    show_help
    exit 0
fi 

if [ $flag_a -eq 0 ] && [ $flag_m -eq 0 ] && [ $flag_n -eq 0 ]; then
    flag_a=1
fi 

if [[ ! -f "$tmp/csv.csv" ]] ; then 
    download
fi 

output_file="output_$mydomain.txt"
rm -fr $output_file 

if [ $flag_a -eq 1 ]; then
    if [ $flag_ip -eq 1 ] ; then 
        cat $tmp/csv.csv  | grep ',A,' | awk -F ',' '{print $1" , "$2 }' >> $output_file
    else 
        cat $tmp/csv.csv  | grep ',A,' | awk -F ',' '{print $1 }' >> $output_file
    fi 
fi
if [ $flag_m -eq 1 ]; then
    if [ $flag_ip -eq 1 ] ; then 
        cat $tmp/csv.csv  | grep ',MX,' | awk -F ',' '{print $1" , "$2 }' >> $output_file
    else 
        cat $tmp/csv.csv  | grep ',MX,' | awk -F ',' '{print $1 }' >> $output_file
    fi 
fi
if [ $flag_n -eq 1 ]; then
    if [ $flag_ip -eq 1 ] ; then 
        cat $tmp/csv.csv  | grep ',NS,' | awk -F ',' '{print $1" , "$2 }' >> $output_file
    else 
        cat $tmp/csv.csv  | grep ',NS,' | awk -F ',' '{print $1 }' >> $output_file
    fi 
fi
 
cat $output_file
exit 

