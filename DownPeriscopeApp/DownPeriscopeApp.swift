//
//  DownPeriscopeAppApp.swift
//  DownPeriscopeApp
//
//  Created by Mike Gray on 2/4/23.
//

import SwiftUI

@main
struct DownPeriscopeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(ViewModel())
        }
    }
}
