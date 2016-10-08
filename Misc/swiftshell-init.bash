#!/usr/bin/env bash

# Create a Swift Package Manager executable project structure and an Xcode project.

set -e

NAME=$1

mkdir $NAME
cd $NAME

swift package init --type executable

cat >> Package.swift <<_EOF_

package.dependencies.append(.Package(url: "https://github.com/kareman/SwiftShell.git", majorVersion: 3))
_EOF_

swift build

# Uncomment to automatically place a symbolic link to the compiled executable in a folder in your $PATH. 
#ln -s `pwd`/.build/debug/$NAME <A FOLDER IN YOUR $PATH>/$NAME

swift package generate-xcodeproj
open $NAME.xcodeproj/
