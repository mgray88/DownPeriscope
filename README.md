#  Down Periscope

*Super Duper File Downloader!*

### Components
- *DownPeriscopeLib*: Primary functional library for downloading a file
- *DownPeriscopeTests*: Unit tests written against `DownPeriscopeLib`
- *DownPeriscopeCLI*: Command line executable wrapping `DownPeriscopeLib`
- *DownPeriscopeApp*: Preliminary start of a SwiftUI MacOS GUI for `DownPeriscopeLib`
- *DownPeriscopeUITests*: Empty project for writing tests against `DownPeriscopeApp`

## How to build
- From the command line:
- Run `./build` (always verify scripts before running)
- The CLI executable will be output to ```pwd``/bin`, which will be appended to `$PATH`
- Run `./bin/down --help` to see documentation  

## How to test
- Open in Xcode (`xed .`)
- Run tests with the DownPeriscopeTests scheme

## Trade-offs made
- Started out using Alamofire, as I was most familiar with that library for networking. Half way through realized the `Progress` object updated and returned by Alamofire is incomplete. It does not contain information that may be provided by the underlying NSURLSession; `throughput`, `estimatedTimeRemaining`. 

## Library Dependencies
- *Alamofire*: Chosen for familiarity of using it for networking in Swift
- *RxSwift* (includes *RxRelay*): Prefer reactive programming to imperative. Not yet proficient in Combine
- *swift-log*: Standard logging library for Swift code

## CLI Dependencies
- *Swift Argument Parser*: Standard library for writing CLI applications in Swift

## Test Dependencies
- *Nimble*: Fantastic library for writing cleaner testing code

## Struggles
- Xcode build output. How do I specify the location of the executable created by DownPeriscopeCLI
  - Expected the `DSTROOT` set in Xcode to do what it says it does.
  - Instead required using `xcodebuild` and passing a value as command input:
  - `xcodebuild install -scheme DownPeriscopeCLI -configuration Release DSTROOT=/`
- `Observable.asSingle()`
  - Doesn't complete until the source observable completes.
  - So without something like `take(1)`, or `observer.onCompleted()` it just waits... :facepalm:
- `RxSwift` may have been a bad choice. Given the environment of a CLI as a single threaded process, the reactive nature of RxSwift presents a problem. RxSwift is optimal in a multi-threaded environment with a run loop to prevent blocking
  - This particular issue 
  
### Improvements
- Have `Periscope` and `DefaultRepository` better handle their DispatchQueues
- Add blocking functions to `Periscope` that abstract away the RxSwift for ease of use from the command line
- Show throughput as a human readable string (currently B/s)
  
### Distractions (for more fun)
- Use `RunLoop`? Or `Process`? Instead of `Semaphore`
- `ArgumentParser` now supports async/await:
  - https://blog.eidinger.info/develop-a-command-line-tool-using-swift-concurrency
- https://github.com/rensbreur/SwiftTUI
