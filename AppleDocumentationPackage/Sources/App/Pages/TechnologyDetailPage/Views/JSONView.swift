import SwiftUI
import UIComponent

struct JSONView: View {
    var url: URL

    var body: some View {
        InObservation {
            JSONModel(url: url)
        } content: { model in
            _Body(model: model)
        }
    }

    private struct _Body: View {
        let model: JSONModel

        var body: some View {
            InUIStack {
                model.json
            } loading: { isLoading in
                ProgressView()
                    .progressViewStyle(.circular)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .task {
                        if !isLoading {
                            await model.fetch()
                        }
                    }
            } loaded: { json in
                TextEditor(text: .constant(json ?? ""))
                    .font(.caption)
                    .monospaced()
            } failed: { error in
                Text(String(describing: error))
            }
        }
    }
}

@MainActor
@Observable
private class JSONModel {
    let url: URL

    private(set) var json: WithUIStack<String?> = .init(initialValue: nil)

    init(url: URL) {
        self.url = url
    }

    func fetch() async {
        do {
            let session = URLSession.shared
            let (data, _) = try await session.data(from: url)

            let obj = try JSONSerialization.jsonObject(with: data, options: [])
            let output = try JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
            let string = String(data: output, encoding: .utf8)?
                .replacingOccurrences(of: "\\", with: "")

            json.next(.loaded(string))
        } catch {
            json.next(.failed(error))
        }
    }
}
