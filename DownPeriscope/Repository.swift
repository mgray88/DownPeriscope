//
//  Repository.swift
//  DownPeriscope
//
//  Created by Mike Gray on 2/4/23.
//

import Alamofire
import Foundation
import RxSwift

enum DataError: Error {
    case invalidSourceURL
    case downloadFailed(underlying: Error?)
}

extension DataError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidSourceURL:
            return ""

        case .downloadFailed(underlying: let error):
            if let error {
                return error.localizedDescription
            }
            return "Unknown download failure"
        }
    }
}

/// Interface for downloading a file from a valid URL
public protocol Repository {
    /// Download a given file
    /// - Parameter file: A valid ``PeriscopeFile`` returned from ``validate(url:)``
    /// - Returns: Continuous updates with ``PeriscopeFile.progress`` updated
    func download(file: PeriscopeFile) -> Observable<PeriscopeFile>

    /// Get the URL of an incomplete download if it did not complete successfully
    var incompleteDownload: URL? { get }
}

private let InProgressKey = "inProgressSource"

public class DefaultRepository: Repository {

    private let userDefaults: UserDefaults
    private let alamofire: Session

    private var inProgressFile: PeriscopeFile? = nil {
        didSet {
            if let inProgressFile {
                userDefaults.set(inProgressFile.source, forKey: InProgressKey)
            } else {
                userDefaults.removeObject(forKey: InProgressKey)
            }
        }
    }

    public init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
        self.alamofire = Alamofire.Session.default

        if let source = userDefaults.url(forKey: InProgressKey) {
            inProgressFile = PeriscopeFile(source: source)
        }
    }

    public var incompleteDownload: URL? {
        inProgressFile?.source
    }
    
    public func download(file: PeriscopeFile) -> Observable<PeriscopeFile> {
        return Observable.create { [weak self] observer in
            guard let self else { return Disposables.create() }
            self.inProgressFile = file
            let request = self.alamofire
                .download(self.inProgressFile!.source, to: { [weak self] temporaryURL, response in
                    return (
                        self?.inProgressFile?.destination ?? temporaryURL,
                        [.removePreviousFile, .createIntermediateDirectories]
                    )
                })
                .downloadProgress(queue: .global()) { [weak self] progress in
                    guard let self else { return }
                    self.inProgressFile?.setProgress(progress)
                    observer.onNext(self.inProgressFile!)
                }
                .validate(statusCode: 200..<300)
                .response(queue: .global(qos: .userInitiated)) { [weak self] response in
                    guard let self else { return }
                    switch response.result {
                    case .success:
                        if var file = self.inProgressFile {
                            if file.destination == nil {
                                file.setDestination(response.fileURL)
                            }
                            observer.onNext(file)
                        }
                        self.inProgressFile = nil
                        observer.onCompleted()

                    case .failure(let error):
                        if let temp = response.fileURL {
                            print(temp)
                            try? FileManager.default.removeItem(at: temp)
                        }
                        observer.onError(DataError.downloadFailed(underlying: error))
                    }
                }
            return Disposables.create {
                request.cancel()
            }
        }
    }
}

extension String {
    func toDouble() -> Double? {
        Double(self)
    }
}
