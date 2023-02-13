//
// Created by Mike on 4/5/21.
// Copyright (c) 2021 Takeout Central. All rights reserved.
//

import Nimble
import RxBlocking

extension BlockingObservable {
    public func complete() throws {
        let results = materialize()
        switch results {
        case let .completed(elements):
            expect(elements).to(beEmpty())

        case let .failed(_, error):
            throw error
        }
    }
}
