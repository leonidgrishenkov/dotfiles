 # APP="$1"
 WINDOW_ID=$(yabai -m query --windows | jq --arg APP "$1" '.[] | select(.app == $APP) | .id')

 yabai -m window $WINDOW_ID --resize abs:1500:1370
