#!/usr/bin/env bash
#
# platform_check.sh
# Copyright (C) 2021 Toran Sahu <toran.sahu@yahoo.com>
#
# Distributed under terms of the MIT license.
#


case "$(uname -s)" in

   Darwin)
     echo 'macos'
     export X_PLATFORM=macos
     ;;

   Linux)
     echo 'linux'
     export X_PLATFORM=linux
     ;;

   CYGWIN*|MINGW32*|MSYS*|MINGW*)
     echo 'windows'
     export X_PLATFORM=windows
     ;;

   # Add here more strings to compare
   # See correspondence table at the bottom of this answer

   *)
     echo 'other' 
     ;;
esac
