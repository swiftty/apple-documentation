import SwiftUI
import AppleDocumentation
import UIComponent

struct ParagraphView: View {
    let paragraph: DocumentData.ParagraphItem
    let headingLevel: Int?

    var body: some View {
        Text { next in
            for text in paragraph.texts {
                next(text)
            }
        }
        .headingLevel(headingLevel)
    }
}
