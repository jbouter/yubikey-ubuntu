#!/bin/bash

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin

session=$(loginctl | grep -v 'tty' | awk '/$username/ { print $1 }')

loginctl lock-session $session 
