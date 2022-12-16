#!/bin/bash
export LC_CTYPE=C
export LANG=C

# How to run:
# - Execute the script in terminal: `sh rename_phoenix_project.sh -a your_app_name`

SCRIPT=${0##*/}

GIT="git"
V="-v"

while [ $# -gt 0 ]; do
  case "$1" in
    -a|--app)
      shift
      NEW_OTP="${1// /}"
      if [ -n "$(echo "$NEW_OTP" | sed -n -e '/[A-Z]/p' -e '/^-/p')" ]; then
        echo "Use snake case for the app name (e.g. 'my_app')" && exit 1
      fi
      NEW_NAME="$(echo $NEW_OTP | sed -r 's/(^|_)([a-z])/\U\2/g')"
      ;;
    --no-git)
      GIT="";;
    -q|--quiet)
      unset V;;
    -h|--help)
      echo "Usage: $SCRIPT [-a|--app] app_name [--no-git] [-q|--quiet] [-h|--help]"
      echo
      echo "This script is used to rename files in this boilerplate project."
      echo "  - If this project is not checked into a git repo, use the '--no-git' option"
      echo "  - Pass the '-a' option to specify your OTP application name"
      echo
      echo "Options:"
      echo "  -a|--app app_name   - Use this OTP application name"
      echo "  --no-git            - Use 'mv' command instead of 'git mv'"
      echo "  -q|--quiet          - Suppress verbosity"
      echo "  -h|--help           - Print this help screen"
      exit 1;;
    *)
      echo "Invalid option: $1"
      exit 1;;
  esac
  shift
done

[ -z "$NEW_OTP" -o -z "$NEW_NAME" ] && echo "Missing required '-a' argument!" && exit 1

set -e

CURRENT_NAME="PetalBoilerplate"
CURRENT_OTP="petal_boilerplate"

while true; do
  echo -en "Rename files containing '$CURRENT_OTP' to '$NEW_OTP' [Y/n]: "
  read -r yn
  case "${yn,,}" in
    n) exit 1;;
    y) break;;
  esac
done

function replace() {
  local WORD=$1
  local SED=$2
  local ECHO=$3

  grep -l -r $WORD --exclude=$SCRIPT | xargs sed -i -e "$SED"
  [ -n $V ] && echo "==> $ECHO"
}

replace "$CURRENT_NAME" "s/$CURRENT_NAME/$NEW_NAME/g" "Replaced application name"
replace "$CURRENT_OTP"  "s/$CURRENT_OTP/$NEW_OTP/g"   "Replaced OTP application name"

${GIT} mv $V lib/$CURRENT_OTP lib/$NEW_OTP
${GIT} mv $V lib/$CURRENT_OTP.ex lib/$NEW_OTP.ex
${GIT} mv $V lib/${CURRENT_OTP}_web lib/${NEW_OTP}_web
${GIT} mv $V lib/${CURRENT_OTP}_web.ex lib/${NEW_OTP}_web.ex
${GIT} mv $V test/${CURRENT_OTP}_web test/${NEW_OTP}_web

[ -d test/$CURRENT_OTP ] && ${GIT} mv $V test/$CURRENT_OTP test/$NEW_OTP
