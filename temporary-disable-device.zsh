#!/usr/bin/zsh
setopt EXTENDED_GLOB

device="$(zenity --title="Select Device" --width=600 --height=500 --list --column="DEVICES" "${(f)$(xinput --list | ruby -e 'print ARGF.each.map {|i| i =~ /[^A-Za-z]*([A-za-z1-9 ]+[a-zA-Z0-9])\s*id=(\d+)/; "#$2 #$1\n" }.join.chomp')}"| perl -ne '/\d+/; print $&;')"

disable_forever() {
  zenity --question --width=200 --text="Really turn off device $device?" && xinput set-int-prop $device "Device Enabled" 8 0
}

if (( $? == 0 )) && [[ -n $device ]]
then
  action="$(zenity --list --column="ACTION" "turn on" "turn off (timeout)" "turn off (dialog)" "turn off (uncondition)")"
  if (( $? == 0 )) && [[ -n $action ]]
  then
    case "$action" in
    "turn off (timeout)")
      backtime="$(zenity --title="Back time" --entry --text="Back after sec")"
      if [[ "$backtime" == [0-9]## ]]
      then
        xinput set-int-prop $device "Device Enabled" 8 0
        sleep $backtime
        xinput set-int-prop $device "Device Enabled" 8 1
      else
        disable_forever
      fi
      ;;
    "turn off (uncondition)")
      disable_forever
      ;;
    "turn off (dialog)")
      xinput set-int-prop $device "Device Enabled" 8 0
      zenity --info --title="Disabled Device" --text="Now the device is disabled. Press OK to re-enable device." --width=200
      ;&
    "turn on")
      xinput set-int-prop $device "Device Enabled" 8 1
      ;;
    esac
  else
    exit 1
  fi
else
  exit 1
fi
