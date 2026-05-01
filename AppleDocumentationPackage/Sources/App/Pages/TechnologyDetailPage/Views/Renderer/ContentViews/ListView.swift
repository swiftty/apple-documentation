import SwiftUI
import AppleDocumentation
import UIComponent

struct OrderedListView<Content: View>: View {
    let items: [[DocumentData.ListItem]]
    @ViewBuilder let content: (BlockContent, AttributedText.Attributes) -> Content

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(items.indexed()) { item in
                HStack(alignment: .firstTextBaseline) {
                    Text("\(item.index + 1).")
                    VStack(alignment: .leading) {
                        ForEach(item.element.indexed()) { subItem in
                            content(subItem.element.block, subItem.element.attributes)
                        }
                    }
                }
            }
        }
    }
}

struct UnorderedListView<Content: View>: View {
    let items: [[DocumentData.ListItem]]
    @ViewBuilder let content: (BlockContent, AttributedText.Attributes) -> Content

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(items.indexed()) { item in
                HStack(alignment: .firstTextBaseline) {
                    Text("•")
                    VStack(alignment: .leading) {
                        ForEach(item.element.indexed()) { subItem in
                            content(subItem.element.block, subItem.element.attributes)
                        }
                    }
                }
            }
        }
    }
}
