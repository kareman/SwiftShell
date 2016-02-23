
.PHONY: build test clean

build: 	
	@xcodebuild | egrep '^(/.+:[0-9+:[0-9]+:.(error|warning):|fatal|===)' -

test: build
	@xcodebuild test -scheme SwiftShell | egrep -v '^Test Suite|^Test Case|^\t Executed '
	
	@echo "=== RUN SwiftShell TEST SCRIPTS (SwiftShellTests/Scripts/runtests.bash) ==="
	@cd ./Tests/Scripts/ && ./runtests.bash 
	@echo

clean:
	-rm -rf build
	-rm -rf .build

