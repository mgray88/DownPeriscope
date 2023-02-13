//
//  ViewModel.swift
//  DownPeriscope
//
//  Created by Mike Gray on 2/4/23.
//

import Combine
import DownPeriscopeLib
import Foundation

class ViewModel: ObservableObject {
    @Published
    var progress: Progress = .init()

    private let repository: Repository

    init(repository: Repository = DefaultRepository()) {
        self.repository = repository
    }
}
