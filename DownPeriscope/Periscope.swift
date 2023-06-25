//
//  Periscope.swift
//  DownPeriscope
//
//  Created by Mike Gray on 2/12/23.
//

import Dispatch
import Foundation
import RxSwift

public enum PeriscopeError: Error {
    case noConnection
    case invalidURL
    case notFound
    case downloadError(underlying: Error?)
}

extension PeriscopeError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .noConnection:
            return "The network is currently unavailable"

        case .invalidURL:
            return "The specified resource is not a valid URL"

        case .notFound:
            return "The specified resource was not found"

        case .downloadError(let underlying):
            var error = "The specified resource failed to download"
            if let underlying {
                error += ":\n" + underlying.localizedDescription
            }
            return error
        }
    }
}

public class Periscope {

    private let repo: Repository
    private let queue: DispatchQueue
    private let disposeBag = DisposeBag()
    private let dispatchQueueScheduler: ImmediateSchedulerType

    public init(
        repo: Repository = DefaultRepository(),
        queue: DispatchQueue = .global(qos: .default)
    ) {
        self.repo = repo
        self.queue = queue
        self.dispatchQueueScheduler = SerialDispatchQueueScheduler(
            queue: queue,
            internalSerialQueueName: "is.digital.Periscope"
        )
    }

    /// Validate that a given source string can be parsed as a valid URL, and that the
    /// resource the URL points to exists
    /// - Parameter source: A valid resource to download
    /// - Returns: An instance of ``PeriscopeFile`` for use with ``download(file:to:)``
    public func validate(source: String) -> Observable<PeriscopeFile> {
        return Observable.deferred {
            guard let url = URL(string: source) else {
                return .error(PeriscopeError.invalidURL)
            }

            return .just(PeriscopeFile(source: url))
        }
        .subscribe(on: dispatchQueueScheduler)
        .observe(on: dispatchQueueScheduler)
    }

    /// If an incomplete download is detected, returns a ``PeriscopeFile`` for use with
    /// ``download(file:to:)``
    /// - Returns: A new ``PeriscopeFile`` element, or `Maybe.completed`
    public func restart() -> Maybe<PeriscopeFile> {
        return Maybe.create { [repo] observer in
            if let source = repo.incompleteDownload {
                observer(.success(PeriscopeFile(source: source)))
            } else {
                observer(.completed)
            }
            return Disposables.create()
        }
        .subscribe(on: dispatchQueueScheduler)
        .observe(on: dispatchQueueScheduler)
    }

    /// Download a given file. Optionally download to a specific destination, otherwise will be
    /// downloaded to the current working directory
    ///
    /// - Parameters:
    ///   - file: A valid ``PeriscopeFile`` to download
    ///   - destination: Optional destination for downloaded file
    /// - Returns: A stream of ``PeriscopeFile`` elements, with updated `progress` values
    public func download(file: PeriscopeFile, to destination: String? = nil) -> Observable<PeriscopeFile> {
        var toDownload = file

        if let destination {
            let dest = URL(filePath: destination, relativeTo: URL.currentDirectory())
            toDownload.setDestination(dest)
        } else {
            let destination = URL.currentDirectory().appending(component: toDownload.source.lastPathComponent)
            toDownload.setDestination(destination)
        }
        return repo.download(file: toDownload)
            .catch { error in
                return .error(PeriscopeError.downloadError(underlying: error))
            }
            .subscribe(on: dispatchQueueScheduler)
            .observe(on: dispatchQueueScheduler)
    }
}

extension Periscope {
    public func validate(source: String) -> Bool {
        queue.sync {
            self.validate(source: source)
                .subscribe()

            return true
        }
    }
}
