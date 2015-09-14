_This is the **SwiftShell 2.0** branch. Use [master](https://github.com/kareman/SwiftShell/tree/master) for SwiftShell 1._

# SwiftShell

An OS X Framework for command line scripting in Swift. 

## Usage


## Installation

- In the Terminal, go to where you want to download SwiftShell.
- Run

        git clone https://github.com/kareman/SwiftShell.git
        cd SwiftShell
        git checkout SwiftShell2

- Copy/link `Misc/swiftshell` to your bin folder or anywhere in your PATH.
- To install the framework itself, either:
  - run `xcodebuild install` from the project's root folder. This will install the SwiftShell framework in ~/Library/Frameworks.
  - _or_ run `xcodebuild` and copy the resulting framework from the build folder to your library folder of choice. If that is not "~/Library/Frameworks", "/Library/Frameworks" or a folder mentioned in the $DYLD_FRAMEWORK_PATH environment variable then you need to add your folder to $DYLD_FRAMEWORK_PATH.

## License

Released under the MIT License (MIT), http://opensource.org/licenses/MIT

Some files are covered by other licences, see [included works](Misc/Included%20Works).

Kåre Morstøl, [NotTooBad Software](http://nottoobadsoftware.com)
