#!/bin/bash

IFS=$'\n'; 
for line in `cat sirius-question.txt`;
do
    echo "Your voice search (text) is:"
    echo "$line"      

    filename=${line// /.}
    filename=`echo $filename | tr '[:upper:]' '[:lower:]'`

    echo "Sending request to ASR server..."
    resp=`wget -q -U "Mozilla/5.0" --post-file ../inputs/questions/$filename.wav \
                                   --header "Content-Type: audio/vnd.wave; rate=16000" \
                                   -O - "http://localhost:8081/" `
    
    query=`echo $resp | cut -d: -f2`  
    query2=$(echo -n $query | perl -pe's/([^-_.~A-Za-z0-9])/sprintf("%%%02X", ord($1))/seg');

    echo "Sending request to QA server..."
    curl --request GET "http://localhost:8080?query=$query2"

    echo "***********************************************"
done
