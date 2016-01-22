
.PHONY: build test clean

build: 	
	xcodebuild | egrep '^(/.+:[0-9+:[0-9]+:.(error|warning):|fatal|===)' -

test: 
	xcodebuild test -scheme SwiftShell | egrep -v '^Test Suite|^Test Case|^\t Executed '
	cd ./SwiftShellTests/Scripts/ && ./runtests.bash 

clean:
	-rm -rf build
