//
//  Fork.swift
//
//  Created by Mike Gray on 6/9/22.
//

import Darwin
import class Foundation.ProcessInfo

private let RTLD_DEFAULT = UnsafeMutableRawPointer(bitPattern: -2)
private let forkPtr = dlsym(RTLD_DEFAULT, "fork")
typealias ForkType = @convention(c) () -> Int32
let _fork = unsafeBitCast(forkPtr, to: ForkType.self)

@discardableResult
public func forkSync(_ subProcess: () -> Void) -> Int32 {
    let pid = _fork()

    if pid == -1 {
        return EXIT_FAILURE
    } else if pid == 0 {
        subProcess()
        return EXIT_SUCCESS
    } else {
        var status: Int32 = 0
        waitpid(pid, &status, 0)
        return status
    }
}

public func dumpEnv() {
    for env in ProcessInfo.processInfo.environment {
        print("\(env)")
    }
}
