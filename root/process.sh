#!/bin/bash

writeSocket()
{
  FILES=$(find /easyepg/xml -type f -name "*.xml" -printf "%T@ %p\n" | sort -n | cut -d " " -f 2)

  while read -r FILE; do
    cat ${FILE} | socat - UNIX-CONNECT:/xmltv.sock

    echo "> ${FILE}"
  done <<< "${FILES}"
}

echo "Cleaning up"
rm -rf /easyepg/xml/*

echo "Running easyepg"
cd /easyepg && /bin/bash /easyepg/epg.sh

if [[ -S /xmltv.sock ]]; then
  echo "Writing to xmltv.sock..."

  writeSocket
  sleep 300
  writeSocket
fi

