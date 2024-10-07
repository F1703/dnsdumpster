# Unofficial BASH script for dnsdumpster.com

Simple BASH script to download DNS details from https://dnsdumpster.com/

DNSDumpster is a domain research tool to find host related information. It’s HackerTarget.com project.

Provides information about subdomains, DNS servers, MX records, and TXT records.


### Prerequisites

* xlsx2csv  

```
sudo apt install -y xlsx2csv
```

### Install 
Clone the repo
```
git clone git@github.com:F1703/dnsdumpster.git

cd dnsdumpster
```

### Example usage
 
```
./dnsdumpster.sh -h
```

```
Option -h requires an argument.
Usage: ./dnsdumpster.sh [-d] [-a] [-m] [-n] [-h]
Options:
  -d  domain.com
  -a  Host Records (A) (default)
  -m  MX Records
  -n  DNS Servers
  -i  IP Address
  -h  Display this help message
```

### Download Host Records (A)

To download only the Host Records (A) for a domain, use the following command:

```
./dnsdumpster.sh  -d domain.com 
```

### Download Host Records (A) and IP Address

To download both the **Host Records (A)** and the **IP address** for a domain, use the following command:

```
./dnsdumpster.sh -d domain.com  -i 
```


### Limitations
dnsdumspter allow to download 160 domain DNS files from single IP address for 24 hours.

 