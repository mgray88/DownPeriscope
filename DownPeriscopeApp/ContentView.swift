//
//  ContentView.swift
//  DownPeriscope
//
//  Created by Mike Gray on 2/3/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject
    var viewModel: ViewModel

    @State
    private var text: String = ""

    @State
    private var showErrors: Bool = false

    @State
    private var showAlert: Bool = false

    @State
    private var isDownloading: Bool = false

    private var isValidURL: Bool {
        if let url = try? URL(text, strategy: .url) {
            return url.host?.isEmpty == false
        }
        return false
    }

    @State
    var progress: Double = 0

    private var title: AttributedString {
        var title = AttributedString("Down Periscope")
        title.font = .largeTitle
        return title
    }

    var body: some View {
        VStack {
            Text(title)
            Form {
                HStack {
                    TextField("URL:", text: $text)
                        .disabled(isDownloading)
                    Button {
                        if !text.isEmpty && isValidURL {
                            let saveUrl = savePanel()
                            print(saveUrl)
                        } else {
                            showAlert = true
                            showErrors = true
                        }
                    } label: {
                        Text("Download")
                    }
                    .disabled(isDownloading)
                }
                ZStack(alignment: .leading) {
                    Text("Invalid URL")
                        .foregroundColor(.red)
                        .opacity((showErrors && !isValidURL) ? 1 : 0)

                    ProgressView(value: progress, total: 100)
                        .progressViewStyle(.linear)
                        .opacity(isDownloading ? 1 : 0)
                }
            }
            .alert("Invalid URL", isPresented: $showAlert) {
                Button {
                    showAlert = false
                } label: {
                    Text("Ok")
                }

            }
        }
        .padding()
    }

    func savePanel() -> URL? {
        let savePanel = NSSavePanel()
        savePanel.title = "Select download location"
        let response = savePanel.runModal()
        return response == .OK ? savePanel.url : nil
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
