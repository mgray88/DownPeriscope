//
//  DownloadableFile.swift
//  DownPeriscope
//
//  Created by Mike Gray on 2/4/23.
//

import Foundation

// Struct which represents a file to be downloaded,
// its destination, size, and overall progress
public struct PeriscopeFile {
    internal init(
        source: URL,
        destination: URL? = nil,
        size: Int64 = 0,
        progress: Progress? = nil,
        resumeData: Data? = nil
    ) {
        self.source = source
        self.destination = destination
        self.size = size
        self.progress = progress
        self.resumeData = resumeData
    }

    public let source: URL
    public internal(set) var destination: URL?
    public internal(set) var size: Int64
    public internal(set) var progress: Progress?

    public let resumeData: Data?

    internal mutating func setDestination(_ url: URL?) {
        self.destination = url
    }

    internal mutating func setProgress(_ progress: Progress) {
        self.progress = progress
        self.size = progress.totalUnitCount
    }
}

extension PeriscopeFile: CustomStringConvertible {
    public var description: String {
        return "\(source) -> \(String(describing: destination))"
    }
}

extension PeriscopeFile: CustomDebugStringConvertible {
    public var debugDescription: String {
        """
        [Source]: \(source)
        [Destination]: \(String(describing: destination))
        [Size]: \(size)
        [Progress]: \(String(describing: progress))
        [ResumeData]: \(resumeData != nil)
        """
    }
}
