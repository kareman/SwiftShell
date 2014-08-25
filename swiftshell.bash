#!/bin/bash

#  swiftshell.bash
#  SwiftShell
#
#  Created by Kåre Morstøl on 24/08/14.
#  Copyright (c) 2014 NotTooBad Software. All rights reserved.

# The folders where Swift can find the frameworks it imports as modules.
# SwiftShell.framework must be in one of these.
FRAMEWORKS_PATH=$DYLD_FRAMEWORK_PATH:~/Library/Frameworks:/Library/Frameworks

# Add a : to the beginning if not already there
if [[ $FRAMEWORKS_PATH != :* ]] 
then
    FRAMEWORKS_PATH=:$FRAMEWORKS_PATH
fi

# Swift needs folders one at a time, so we replace : with " -F "
SWIFT_FRAMEWORK_ARGUMENTS=${FRAMEWORKS_PATH//:/ -F }

# Pass Swift all the arguments, the first of which is the Swift file to run.
xcrun swift $SWIFT_FRAMEWORK_ARGUMENTS $@
