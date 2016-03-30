## How to contribute

Issues and suggestions [are always welcome](https://github.com/kareman/SwiftShell/issues/new).

If you want to make changes yourself please follow the standard [pull request guidelines](http://help.github.com/pull-requests/). In short: fork, create topic branch, one commit per atomic change, make sure all unit tests pass, run `make test` to make sure all the script tests still pass, and create the pull request.

If it's a sizeable change or will break backwards compatibility it's probably best if you create an issue first so we can discuss the changes beforehand.

#### Testing

- Unit tests are awesome. Please create new ones to test the changes you make.
- If you make changes to the public API feel free to add a new test script to [/Tests/Scripts](https://github.com/kareman/SwiftShell/tree/master/Tests/Scripts) and write a test for that script in [/Tests/Scripts/runtests.bash](https://github.com/kareman/SwiftShell/blob/master/Tests/Scripts/runtests.bash).
