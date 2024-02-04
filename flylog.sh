#!/bin/bash

getLog() {

    PS3="------------- "$'\n'"Enter the number: "

    appname=()
    appstatus=()
    apps=$(fly app list)

    appname+=($(echo "$apps" | awk '{print $1}'))
    appstatus+=($(echo "$apps" | awk '{print $3}'))

    unset appname[0]
    unset appstatus[0]

    select app in ${appname[@]}; do
        if [ -z "$app" ]; then
            echo "Invalid app name"
            break
        fi
        echo "Processing..."

        if [ "${appstatus[$REPLY]}" == "pending" ]; then
            echo "App is still pending"
            break
        fi
        fly logs -a $app
        break
    done
}

getLog
