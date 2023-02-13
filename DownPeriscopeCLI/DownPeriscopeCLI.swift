//
//  main.swift
//  DownPeriscopeCLI
//
//  Created by Mike Gray on 2/4/23.
//

import ArgumentParser
import DownPeriscopeLib
import Foundation
import RxSwift

var disposable: Disposable?

@main
public struct DownPeriscopeCLI: ParsableCommand {
    public static let version = "1.0.0"

    public static let configuration = CommandConfiguration(
        commandName: "down",
        version: Self.version
    )

    @Argument
    public var url: String?

    @Option(name: [.long, .short])
    public var destination: String? = nil

    public init() {
    }

    public func run() throws {
        let periscope = Periscope()
        let semaphore = DispatchSemaphore(value: 0)
        Trap.handle(signal: .interrupt) {sig in
            disposable?.dispose()
        }

        let continuation: Observable<PeriscopeFile>
        if let url {
            continuation = periscope.validate(source: url)
        } else {
            continuation = periscope.restart().asObservable()
                .ifEmpty(
                    switchTo: .error(CleanExit.message("No arguments provided"))
                )
                .map { previous in
                    print("Attempt to restart previous download?")
                    if booleanPrompt(previous.source.absoluteString) {
                        return previous
                    } else {
                        throw ExitCode.success
                    }
                }
        }

        var progressBar = ProgressBar(configuration: [
            ProgressPercent(),
            ProgressBarLine(),
            ProgressTimeEstimates()
        ])
        disposable = continuation
            .flatMap({ file in
                periscope.download(file: file, to: destination)
            })
            .reduce(nil, accumulator: { (_: PeriscopeFile?, file: PeriscopeFile) in
                progressBar.count = Int(file.progress?.totalUnitCount ?? 0)
                progressBar.setValue(Int(file.progress?.completedUnitCount ?? 0))
                return file
            })
            .subscribe(on: SerialDispatchQueueScheduler(qos: .userInitiated))
            .observe(on: SerialDispatchQueueScheduler(qos: .userInitiated))
            .unwrap()
            .subscribe(
                onNext: { file in
                    print("Successfully downloaded to:")
                    print(file.destination!.absoluteString)
                },
                onError: { error in
                    DownPeriscopeCLI.exit(withError: error)
                },
                onCompleted: {
                    semaphore.signal()
                },
                onDisposed: {
                    semaphore.signal()
                }
            )

        semaphore.wait()
    }

    private func prompt(_ prompt: String) -> String {
        print(prompt, terminator: "\n(y/n) ")
        return readLine()!
    }

    private func booleanPrompt(_ string: String) -> Bool {
        return prompt(string) == "y"
    }
}

extension ObservableType {
    public func unwrap<Result>() -> Observable<Result> where Element == Result? {
        self.map { element in
            if let result = element {
                return result
            }
            throw ExitCode.failure
        }
    }
}
