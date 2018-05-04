#!/bin/bash

run_browser jwm -display $DISPLAY &

if [[ -n "$ZPROXY_GET_CA" && -n "$PROXY_HOST" ]]; then
    curl -x "$PROXY_HOST:$PROXY_PORT"  "$PROXY_GET_CA" > /tmp/proxy-ca.pem

    mkdir -p $HOME/.pki/nssdb
    certutil -d $HOME/.pki/nssdb -N
    certutil -d sql:$HOME/.pki/nssdb -A -t "C,," -n "Proxy" -i /tmp/proxy-ca.pem
fi

mkdir ~/.config/
mkdir ~/.config/chromium
mkdir ~/.config/chromium/Default
touch ~/.config/chromium/First\ Run


cat > ~/.config/chromium/Default/Preferences << EOF
{
    "profile": {
        "content_settings": {
            "exceptions": {
                "plugins": {
                      "[*.]ca,*": {
                        "last_modified": "13161895252379464",
                        "setting": 1
                      },
                      "[*.]com,*": {
                        "last_modified": "13161885322052970",
                        "setting": 1
                      },
                      "[*.]tv,*": {
                        "last_modified": "13161885322052970",
                        "setting": 1
                      }
                }
            }
        }
    }
}
EOF


run_browser vglrun chromium-browser --disable-web-security --disable-gpu-sandbox --ignore-certificate-errors --start-fullscreen --no-default-browser-check --disable-popup-blocking --disable-background-networking --disable-client-side-phishing-detection --disable-component-update --safebrowsing-disable-auto-update --app="$URL" &

pid=$!

count=0
wid=""

while [ -z "$wid" ]; do
    wid=$(wmctrl -l |  cut -f 1 -d ' ')
    if [ -n "$wid" ]; then
        echo "Chromium Found"
        break
    fi
    sleep 0.5
    count=$[$count + 1]
    echo "chromium-browser Not Found"
    if [ $count -eq 6 ]; then
        echo "Restarting process"
        kill $(ps -ef | grep "/chromium" | awk '{ print $2 }')
        count=0
    fi
done



