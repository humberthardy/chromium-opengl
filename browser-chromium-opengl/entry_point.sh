#!/bin/bash
#export GEOMETRY="$SCREEN_WIDTH""x""$SCREEN_HEIGHT""x""$SCREEN_DEPTH"

export GEOMETRY="${SCREEN_WIDTH}x${SCREEN_HEIGHT}"
mkdir -p ~/.vnc 
#x11vnc -storepasswd ${VNC_PASS:-secret} ~/.vnc/passwd

# start xvfb
#sudo Xvfb $DISPLAY -screen 0 $GEOMETRY -ac +extension RANDR > /dev/null 2>&1 &


#vncpasswd ${VNC_PASS:-secret}

echo "set vnc password '${VNC_PASS:-secret}'"

echo "${VNC_PASS:-secret}\n" | vncpasswd -f > ~/.vnc/passwd
chmod 600 ~/.vnc/passwd

echo "Start vncserver on display $DISPLAY"
vncserver $DISPLAY -geometry $GEOMETRY -noxstartup  > /dev/null 2>&1  &

/app/audio_stream.sh > /tmp/audio_stream.log 2>&1  &

echo "Set proxy if needed ${PROXY_HOST}"

if [[ -n "$PROXY_HOST" ]]; then
    # resolve to ip now, if possiblei
    echo "Proxy host is ${PROXY_HOST}"
    IP=$(host $PROXY_HOST | head -n 1 | cut -d ' ' -f 4)
    if (( $? == 0 )); then
        export PROXY_HOST=$IP
        echo "IP: $IP"
    fi
    echo "http_proxy ${PROXY_HOST}:{$PROXY_PORT}"
    export http_proxy=http://$PROXY_HOST:$PROXY_PORT
    export https_proxy=http://$PROXY_HOST:$PROXY_PORT
fi

#wget -O /dev/null "http://set.pywb.proxy/setts?ts=$TS"

function shutdown {
  kill -s SIGTERM $NODE_PID
  wait $NODE_PID
}
echo "Disable any terminals"
# disable any terms
sudo chmod a-x /usr/bin/*term
sudo chmod a-x /bin/*term

# Run browser here
echo "Starting browser, command is $@"
eval "$@" &
  
# start controller app
#python /app/browser_app.py &

#autocutsel -s PRIMARY -fork &

# start vnc
#x11vnc -forever -ncache_cr -xdamage -usepw -shared -rfbport 5900 -display $DISPLAY > /dev/null 2>&1 &


TIMEOUT_PARAM=""
# add idle-timeout if var set
if [[ -n "$IDLE_TIMEOUT" ]]; then
    TIMEOUT_PARAM="--idle-timeout $IDLE_TIMEOUT"
fi

# run websockify
/opt/websockify/run $TIMEOUT_PARAM 6080 localhost:5901  > /tmp/websockify.log 2>&1 &

NODE_PID=$!

trap shutdown SIGTERM SIGINT
for i in $(seq 1 10)
do
  xdpyinfo -display $DISPLAY >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    break
  fi
  echo Waiting xvfb...
  sleep 0.5
done

echo "Wait for $NODE_PID"
ps aux
wait $NODE_PID
