//
//  MockRepository.swift
//  DownPeriscopeTests
//
//  Created by Mike Gray on 2/12/23.
//

import DownPeriscopeLib
import Foundation
import RxSwift

final class MockRepository: Repository {

    var downloadResponse: Observable<PeriscopeFile>!
    func download(file: PeriscopeFile) -> Observable<PeriscopeFile> {
        return downloadResponse
    }

    var incompleteDownload: URL?
}
