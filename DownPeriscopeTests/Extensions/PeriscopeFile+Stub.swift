//
//  PeriscopeFile+Stub.swift
//  DownPeriscopeTests
//
//  Created by Mike Gray on 2/12/23.
//

@testable import DownPeriscopeLib

extension PeriscopeFile {
    static var stub: PeriscopeFile {
        PeriscopeFile(source: .temporaryDirectory)
    }
}
