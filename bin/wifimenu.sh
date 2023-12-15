#!/usr/bin/env bash

# Starts a scan of available broadcasting SSIDs
# nmcli dev wifi rescan
notify-send "Getting list of available Wi-Fi networks..."
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

FIELDS=SSID,SECURITY
POSITION=0



LIST=$(nmcli --fields "$FIELDS" device wifi list | sed '/^--/d' | sed 1d)
# echo "${LIST[@]}"

#LIST=$(nmcli --fields "SSID, SECURITY" device wifi list | sed 1d | sed 's/  */ /g' | sed -E "s/WPA*.?\S/ /g" | sed "s/^--/ /g" | sed "s/  //g" | sed "/--/d")
# echo "${LIST[@]}"


# Gives a list of known connections so we can parse it later
KNOWNCON=$(nmcli connection show)
# Really janky way of telling if there is currently a connection
CONSTATE=$(nmcli -fields WIFI g)

# CURRSSID=$(LANGUAGE=C nmcli -t -f active,ssid dev wifi | awk -F: '$1 ~ /^yes/ {print $2}')

# if [[ ! -z $CURRSSID ]]; then
# 	HIGHLINE=$(echo  "$(echo "$LIST" | awk -F "[  ]{2,}" '{print $1}' | grep -Fxn -m 1 "$CURRSSID" | awk -F ":" '{print $1}') + 1")
# fi


if [[ "$CONSTATE" =~ "enabled" ]]; then
	TOGGLE="Disable Wifi 󰖪"
elif [[ "$CONSTATE" =~ "disabled" ]]; then
	TOGGLE="Enable Wifi "
fi



CHENTRY=$(echo -e "$TOGGLE\n$LIST" | uniq -u | rofi -dmenu -p " Wi-Fi: " -theme "$HOME/.config/rofi/config.rasi")
#echo "$CHENTRY"
CHSSID=$(echo "$CHENTRY" | sed  's/\s\{2,\}/\|/g' | awk -F "|" '{print $1}')
#echo "$CHSSID"

if [ "$CHENTRY" = "Enable Wifi " ]; then
	nmcli radio wifi on && notify-send "Enable Wifi"

elif [ "$CHENTRY" = "Disable Wifi 󰖪" ]; then
	nmcli radio wifi off && notify-send "Disable Wifi"

else

	ccess_message="You are now connected to the Wi-Fi network \"$CHSSID\"."
	# If the connection is already in use, then this will still be able to get the SSID
	if [ "$CHSSID" = "*" ]; then
		CHSSID=$(echo "$CHENTRY" | sed  's/\s\{2,\}/\|/g' | awk -F "|" '{print $3}')
	fi

	# Parses the list of preconfigured connections to see if it already contains the chosen SSID. This speeds up the connection process
	if [[ $(echo "$KNOWNCON" | grep "$CHSSID") = "$CHSSID" ]]; then
		nmcli con up "$CHSSID" | grep "successfully" && notify-send "Connection Established" "$success_message"
	else
		if [[ "$CHENTRY" =~ "WPA2" ]] || [[ "$CHENTRY" =~ "WEP" ]]; then
			WIFIPASS=$(echo "if connection is stored, hit enter" | rofi -dmenu -p "password: " -theme "$HOME/.config/rofi/wifi-password.rasi" )
		fi
		nmcli dev wifi con "$CHSSID" password "$WIFIPASS" |grep "successfully" && notify-send "Connection Established" "$success_message"
	fi

fi