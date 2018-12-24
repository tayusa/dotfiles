#!/usr/bin/env bash

set -euCo pipefail

function get_volume() {
  pactl list sinks | grep 'Volume' | grep -o '[0-9]*%' | head -1
}

function get_muted() {
  pactl list sinks \
    | grep 'Mute' | sed 's/[[:space:]]//g' | cut -d: -f2 | head -1
}

function get_sinks() {
  pactl list sinks short | cut -f1 | sed 1d
}

function sync_volume() {
  get_sinks | xargs -I{} pactl set-sink-volume {} $(get_volume)
}

function sync_muted() {
  local -rA state=( ['yes']=1 ['no']=0 )
  get_sinks | xargs -I{} pactl set-sink-mute {} ${state[$(get_muted)]}
}

function main() {
  which pactl &> /dev/null || return 1

  case ${1:-show} in
    'up' )
      pactl set-sink-volume 0 +5% && sync_volume
    ;;
    'down' )
      pactl set-sink-volume 0 -5% && sync_volume
    ;;
    'mute' )
      pactl set-sink-mute 0 toggle && sync_muted
    ;;
    'set' )
      [[ $2 =~ ^[0-9]+$ ]] \
        || { echo 'set [0-9]*'; return 1; }
      pactl set-sink-volume 0 "$2%" && sync_volume
    ;;
    'show' )
      echo "volume: $(get_volume), muted: $(get_muted)"
      return 0
    ;;
  esac

  pkill -SIGRTMIN+1 i3blocks
  tmux refresh -S
}

main $@
