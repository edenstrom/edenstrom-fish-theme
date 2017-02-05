# You can override some default right prompt options in your config.fish:
#     set -g theme_date_format "+%a %H:%M"

function __cmd_duration -S -d 'Show command duration'
  set -l ITALIC_ON (tput sitm)
  set -l ITALIC_OFF (tput ritm)

  # Minumum duration is 0.01s
  [ "$CMD_DURATION" -lt 10 ]; and set CMD_DURATION 10

  if [ "$CMD_DURATION" -lt 5000 ]
    set TEST (math "scale=2;$CMD_DURATION/1000")

    if [ "$CMD_DURATION" -lt 1000 ]
      echo -n "0"
    end

    echo -n $ITALIC_ON"$TEST"'s'$ITALIC_OFF
  else if [ "$CMD_DURATION" -lt 60000 ]
    math "scale=1;$CMD_DURATION/1000" | sed 's/\\.0$//'
    echo -n 's'
  else if [ "$CMD_DURATION" -lt 3600000 ]
    set_color $fish_color_error
    math "scale=1;$CMD_DURATION/60000" | sed 's/\\.0$//'
    echo -n 'm'
  else
    set_color $fish_color_error
    math "scale=2;$CMD_DURATION/3600000" | sed 's/\\.0$//'
    echo -n 'h'
  end

  set_color $fish_color_normal
  set_color $fish_color_autosuggestion

  
end

function fish_right_prompt -d 'Show the duration of the command in the right prompt'
  set_color white

  __cmd_duration
  set_color normal
end
