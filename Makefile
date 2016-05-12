BUILDCLEANER := xcpretty
TESTCLEANER := xcpretty
ifeq (,$(shell command -v xcpretty))
	BUILDCLEANER := egrep '^(/.+:[0-9+:[0-9]+:.(error|warning):|fatal|===)'
	TESTCLEANER := egrep -v '^Test Suite|^Test Case|^\t Executed'
endif

.PHONY: build test clean

build: 
	@xcodebuild TOOLCHAINS=swift | ${BUILDCLEANER}

test: build
	@xcodebuild TOOLCHAINS=swift -scheme SwiftShell test | ${TESTCLEANER}
	
	@echo
	@echo "=== RUN SwiftShell TEST SCRIPTS (SwiftShellTests/Scripts/runtests.bash) ==="
	@cd ./Tests/Scripts/ && ./runtests.bash 
	@echo

clean:
	-rm -rf build
	-rm -rf .build

