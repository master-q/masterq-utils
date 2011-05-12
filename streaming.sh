#!/bin/zsh

FIFO="/tmp/stream-$USER.ogv"
LOCK="/tmp/streaming.lock"
# FPS="60"
OUTDEV="/dev/video0"
INDEV="/dev/video1"

usage() {
    cat << EOF
Usage: $0 [-o outdev] [-h]

  -o outdev     The output video device of vloopback
  -h            Show this help
EOF
  exit $1
}

while test $# -gt 0; do
    case "$1" in
        -o)
            OUTDEV="$2"
            shift; shift
            ;;
        -h)
            usage 1
            ;;
        *)
            break
            ;;
    esac
done

if [ -f $LOCK ]; then
    echo "Running $0 now."
    exit 1
fi

[ -p $FIFO ] || mkfifo $FIFO

lsmod | grep -q vloopback || sudo modprobe vloopback

if [ -f /dev/$OUTDEV ]; then
    echo "no such video device: $OUTDEV"
    exit 1
fi

WININFO=`xwininfo`
# WIN_ID=`echo $WININFO | sed -e 's/.* Window id: \(0x[0-9a-f]*\) .*/\1/'`
# WIDTH=`echo $WININFO | sed -e 's/.* Width: \([0-9]*\) .*/\1/'`
# HEIGHT=`echo $WININFO | sed -e 's/.* Height: \([0-9]*\) .*/\1/'`
# WIDTH=`expr $WIDTH - $WIDTH % 2`
WIN_ID=$(echo $WININFO | awk '/Window id:/ {print $4}')
WIDTH=$(echo $WININFO | awk '/Width:/ {print $2}')
HEIGHT=`echo $(($WIDTH / 1.333)) | cut -d '.' -f 1`
WIDTH=$(($WIDTH + $WIDTH % 2))
HEIGHT=$(($HEIGHT + $HEIGHT % 2))
# SIZE="${WIDTH}x${HEIGHT}"
# SIZE="512x384"
# SIZE="320x240"
SIZE="640x480"

# for mirror live.
# recordmydesktop -x 1 -y 1 --width 512 --height 384 --no-cursor --no-frame --no-sound --on-the-fly-encoding --v_bitrate 2000000 --overwrite -o $FIFO &
ffmpeg -i $FIFO -f yuv4mpegpipe -s $SIZE -an -aspect 4:3 -sameq - | \
       mjpegtools_yuv_to_v4l $OUTDEV &
recordmydesktop --windowid $WIN_ID \
                --no-cursor --no-frame --no-sound \
                --on-the-fly-encoding --v_bitrate 2000000 --overwrite -o $FIFO
# sleep 5 &

killall recordmydesktop
rm -f $FIFO
rm -f $LOCK
