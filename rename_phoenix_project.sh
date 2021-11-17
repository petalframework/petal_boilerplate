#!/bin/bash

# How to run:
# Modify the variables below to your new app name. Then in the terminal run:
# > sh rename_phoenix_project.sh

set -e

CURRENT_NAME="PetalBoiletplate"
CURRENT_OTP="petal_boilerplate"

# TODO: MODIFY THESE TWO VARIABLES BEFORE RUNNING THE SCRIPT
NEW_NAME="YourAppName"
NEW_OTP="your_app_name"

ack -l $CURRENT_NAME --ignore-file=is:rename_phoenix_project.sh | xargs sed -i '' -e "s/$CURRENT_NAME/$NEW_NAME/g"
ack -l $CURRENT_OTP --ignore-file=is:rename_phoenix_project.sh | xargs sed -i '' -e "s/$CURRENT_OTP/$NEW_OTP/g"

git mv lib/$CURRENT_OTP lib/$NEW_OTP
git mv lib/$CURRENT_OTP.ex lib/$NEW_OTP.ex
git mv lib/${CURRENT_OTP}_web lib/${NEW_OTP}_web
git mv lib/${CURRENT_OTP}_web.ex lib/${NEW_OTP}_web.ex
git mv test/${CURRENT_OTP}_web test/${NEW_OTP}_web
