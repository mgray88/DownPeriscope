//
//  DownPeriscopeTests.swift
//  DownPeriscopeTests
//
//  Created by Mike Gray on 2/3/23.
//

@testable import DownPeriscopeLib
import Nimble
import RxBlocking
import RxSwift
import XCTest

final class DownPeriscopeTests: XCTestCase {

    var sut: Periscope!
    var mockRepository: MockRepository!

    override func setUpWithError() throws {
        mockRepository = MockRepository()
        sut = Periscope(repo: mockRepository)
    }

    override func tearDownWithError() throws {
        sut = nil
        mockRepository = nil
    }

    func testValidateURLSuccess() throws {
        // Given
        let url = "http://speedtest.ftp.otenet.gr/files/test100k.db"

        // When
        let valid = sut.validate(source: url)

        // Then
        expect {
            let file = try valid.toBlocking().single()
            expect(file.source.absoluteString) == url
        }.toNot(throwError())
    }

    func testValidateInvalidURL() throws {
        // Given
        let url = "this is an invalid url"

        // When
        let valid = sut.validate(source: url)

        // Then
        expect {
            try valid.toBlocking().single()
        }.to(throwError(PeriscopeError.invalidURL))
    }

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
