#!/usr/bin/sh
##init


echo checking if python is installed
if [ ! -f /usr/bin/python3 ]; then
 echo python is not installed bruh
 exit
else
 echo python installed...
 if [ ! -f /usr/bin/jd ]; then
  echo jd is not installed....
 else
  echo jd is installed...
 fi
fi 
echo passed!

echo checking if virtualenv is installed 
if [ ! -f /usr/bin/pip ]; then
 echo pip not installed...
 exit
else 
 echo pip is installed...
 python -m virtualenv
 if [ $? -eq 2 ]; then
  echo virtualenv module is installed
 else
  echo installing virtual env....
  python -m pip virtualenv 
 fi
fi
echo passed!

if [ ! -d ./env/ ]; then
echo env not set yet, setting it up now....
 python -m virtualenv env
 . ./env/bin/activate
 echo first time setup now....
 python -m qbzremake.py -r
else
 . ./env/bin/activate
fi

##env shit
first () {
clear
dateTime=$(date +"%Y-%m-%d")

echo "input qobuz url here:";
read;
python qbzremake.py dl --no-db "${REPLY}"
## Error checking
if [ ! $? -eq 0 ]; then
 clear 
 echo something happened pls retry...
 first
else
 echo yes 0
fi
foldername=$(ls './Qobuz Downloads'/)
echo "$foldername" > foldername.txt
base64=$(base64 foldername.txt)
mv -f "./Qobuz Downloads/$foldername" "./"
zip -r "./pending_upload/$base64.zip" "$foldername"
#7za a -t7z -p$base64 "./pending_upload/temp.7z" "$foldername"
mv -f "./pending_upload/$base64.zip" "./final/"
mv -f "./$foldername" "uncompressed"

##curl -F "file=@test.txt" https://api.bayfiles.com/upload
##curl --upload-file "./pending_upload/$base64.7z" https://transfer.sh/$base64.7z
curl -F"file=@./final/$base64.zip" https://api.bayfiles.com/upload > pending_url.txt
finalURL=$(cat pending_url.txt | jq -r .data.file.url.short)
base64URL=$(echo "$finalURL" | base64)
clear
echo ================================================
echo "Link: $finalURL" 
echo "Base64: $base64URL"
echo ================================================

echo "$foldername - $dateTime" >> final_urls.txt
echo "$finalURL ~ $base64URL" >> final_urls.txt
echo ================================================ >> final_urls.txt
read -p "Press Enter to download another one.."
clear
first
}

##lol
first