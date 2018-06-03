# butter | 03.06.2018
# By daelvn
# Functions for butter files

LIBBUTTER_LOGI="tput sgr0"
LIBBUTTER_LOGK="tput setaf 2"
LIBBUTTER_LOGW="tput setaf 3"
LIBBUTTER_LOGE="tput setaf 1"

# Locals #
_libbutter_log () {
  # $1 : mode
  # $2 : marker
  # $3 : message
  $1
  tput bold
  echo "$2"
  tput sgr0
  $1
  echo "  $3"
  tput sgr0
}

# #@i: text
libbutter_log_i () {
  _libbutter_log "$LIBBUTTER_LOGI" "$1" "$2"
}

# #@e: text
libbutter_log_e () {
  _libbutter_log "$LIBBUTTER_LOGE" "$1" "$2"
}

# #@w: text
libbutter_log_w () {
  _libbutter_log "$LIBBUTTER_LOGW" "$1" "$2"
}

# #@k: text
libbutter_log_k () {
  _libbutter_log "$LIBBUTTER_LOGK" "$1" "$2"
}
