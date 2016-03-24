# Apache-Vulns
Pentest Scripts for Apache Vulnerabilities.


1. **apacheScan.py**
  * The purpose of this script is to enable pentesters to quickly check which CVE-IDs apply to a particular Apache version. apacheScan comes with a text file which contains all CVE-IDs taken from [https://httpd.apache.org] (https://httpd.apache.org). The python script simply retrieves the CVE-IDs that apply to the given Apache version from the apache_CVE.txt file.
  * TODO:
   - Add option to check which versions are affected by a particular CVE-ID.
    -https://help.github.com/articles/basic-writing-and-formatting-syntax/
2. **apacheCookieLeakage.sh**
  * This script checks for [CVE-2012-0053] (http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2012-0053). Apache HTTP Server 2.2.x through 2.2.21 does not properly restrict header information which allows remote attackers to obtain the values of HTTPOnly cookies via vectors involving a (1) long or (2) malformed header in conjunction with crafted web script. 

