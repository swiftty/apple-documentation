import SwiftUI
import AppleDocumentation
import SupportMacros

extension EnvironmentValues {
    @SwiftUIEnvironment
    var references: [Technology.Identifier: TechnologyDetail.Reference] = [:]

    @SwiftUIEnvironment
    var uiFont: UIFont? = nil  // swiftlint:disable:this redundant_optional_initialization
}

extension NSAttributedString.Key {
    static let inlineContent = NSAttributedString.Key("AppleDoc::InlineContent")
}

struct InlineContentView: View {
    let contents: [InlineContent]

    var body: some View {
        UITextViewRenderer(contents: contents)
            .border(.red)
            .environment(\.uiFont, .systemFont(ofSize: 18, weight: .regular))
    }
}

private struct Cache {
    private var attachments: [InlineContent: NSTextAttachment] = [:]

    mutating func attachment<T: NSTextAttachment>(
        for content: InlineContent, default: () -> T
    ) -> NSTextAttachment {
        if let attachment = attachments[content] as? T {
            return attachment
        }
        let attachment = `default`()
        attachments[content] = attachment
        return attachment
    }
}

private extension [InlineContent] {
    func attributedString(environment: EnvironmentValues, cache: inout Cache) -> NSAttributedString {
        let string = NSMutableAttributedString()
        for content in self {
            content.buildAttributedString(into: string, environment: environment, cache: &cache)
        }

        let foregroundColor = environment.colorScheme == .dark ? UIColor.white : .black
        string.addAttributes([
            .foregroundColor: foregroundColor,
            .font: environment.uiFont ?? .systemFont(ofSize: 16)
        ], range: NSRange(location: 0, length: string.length))
        return string
    }
}

private extension InlineContent {
    // swiftlint:disable:next cyclomatic_complexity
    func buildAttributedString(
        into string: NSMutableAttributedString,
        environment: EnvironmentValues,
        cache: inout Cache
    ) {
        switch self {
        case .text(let text):
            string.append(NSAttributedString(string: text.text, attributes: [:]))

        case .codeVoice(let codeVoice):
            string.append(NSAttributedString(string: codeVoice.code, attributes: [:]))

        case .strong(let strong):
            let text = NSMutableAttributedString()
            for content in strong.contents {
                content.buildAttributedString(into: text, environment: environment, cache: &cache)
            }
            let range = NSRange(location: 0, length: text.length)
            text.addAttributes([:], range: range)
            string.append(text)

        case .reference(let reference):
            guard let ref = environment.references[reference.identifier] else { return }

        case .image(let image):
            guard let ref = environment.references[image.identifier] else { return }

        case .inlineHead(let inlineHead):
            let text = NSMutableAttributedString()
            for content in inlineHead.contents {
                content.buildAttributedString(into: text, environment: environment, cache: &cache)
            }
            let range = NSRange(location: 0, length: text.length)
            text.addAttributes([:], range: range)
            string.append(text)

        case .unknown(let unknown):
            let attachment = cache.attachment(for: self) {
                UnknownAttachment(unknown: unknown)
            }
            string.append(NSAttributedString(attachment: attachment))
        }
    }
}

// MARK: -
private struct UITextViewRenderer: UIViewRepresentable {
    let contents: [InlineContent]

    func makeUIView(context: Context) -> UITextView {
        let view = TextView()
        view.isScrollEnabled = false
        view.isEditable = false
        view.isSelectable = true
        view.textContainerInset = .zero
        view.textContainer.lineFragmentPadding = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = contents.attributedString(
            environment: context.environment,
            cache: &context.coordinator.cache
        )
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UITextView, context: Context) -> CGSize? {
        var size = uiView.systemLayoutSizeFitting(
            CGSize(width: proposal.width ?? 0, height: UIView.noIntrinsicMetric),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        size.width = proposal.width ?? size.width
        print(size, proposal)
        return size
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var cache = Cache()
    }

    private class TextView: UITextView {
        override var intrinsicContentSize: CGSize {
            contentSize
        }
    }
}

private class Attachment<ViewProvider: NSTextAttachmentViewProvider>: NSTextAttachment {
    private var viewProvider: ViewProvider?

    override func viewProvider(
        for parentView: UIView?,
        location: NSTextLocation,
        textContainer: NSTextContainer?
    ) -> NSTextAttachmentViewProvider? {
        if let viewProvider {
            return viewProvider
        }
        let provider = ViewProvider(
            textAttachment: self,
            parentView: parentView,
            textLayoutManager: textContainer?.textLayoutManager,
            location: location
        )
        provider.tracksTextAttachmentViewBounds = true
        viewProvider = provider
        return provider
    }
}

private final class ImageAttachment: Attachment<ImageAttachment.ViewProvider> {
    final class ViewProvider: NSTextAttachmentViewProvider {

    }
}

private final class UnknownAttachment: Attachment<UnknownAttachment.ViewProvider> {
    let unknown: InlineContent.Unknown

    init(unknown: InlineContent.Unknown) {
        self.unknown = unknown
        super.init(data: nil, ofType: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    final class ViewProvider: NSTextAttachmentViewProvider {
        // swiftlint:disable:next force_cast
        var unknown: InlineContent.Unknown { (textAttachment as! UnknownAttachment).unknown }
        private lazy var label: UILabel = {
            let label = UILabel()
            label.text = "unhandled type: \(unknown.type)"
            label.textColor = .white
            label.font = .systemFont(ofSize: 12, weight: .bold)
            return label
        }()
        private lazy var containerView: UIView = {
            let view = UIView()
            view.backgroundColor = .red
            view.layer.cornerCurve = .continuous
            view.layer.cornerRadius = 8

            view.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor, constant: 2),
                label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
                view.trailingAnchor.constraint(equalTo: label.trailingAnchor, constant: 6)
            ])
            return view
        }()

        override func loadView() {
            view = containerView
        }

        override func attachmentBounds(
            for attributes: [NSAttributedString.Key: Any],
            location: NSTextLocation,
            textContainer: NSTextContainer?,
            proposedLineFragment: CGRect,
            position: CGPoint
        ) -> CGRect {
            var size = containerView.systemLayoutSizeFitting(proposedLineFragment.size)
            size.height = proposedLineFragment.height
            return CGRect(origin: .zero, size: size)
        }
    }
}

#Preview {
    struct PreviewContainer: View {
        @State var isOn = false
        var body: some View {
            VStack {
                Toggle(isOn: $isOn, label: {
                    Text("Label")
                })

                InlineContentView(contents: [
                    .text(.init(text: """
                    Construct and manage a graphical, event-driven user interface for your macOS app.
                    """)),
                    .inlineHead(.init(contents: [
                        .text(.init(text: """
                        Construct and manage a graphical, event-driven user interface for your macOS app. \
                        Hello\(isOn ? "?" : "!")
                        """)),
                        .text(.init(text: "🌏")),
                        .text(.init(text: "world")),
                        .unknown(.init(type: "foo")),
                        .text(.init(text: "!!!!"))
                    ]))
                ])
            }
        }
    }

    return PreviewContainer()
}
