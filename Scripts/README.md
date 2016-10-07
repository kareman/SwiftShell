## Scripts folder

These scripts demonstrate how to do different tasks in SwiftShell. They also work as integration tests to make sure changes to SwiftShell are backwards compatible with older scripts.

runtests.bash compiles the framework with the Release configuration and uses it to run all the scripts in this folder. It is called from `make test`.
