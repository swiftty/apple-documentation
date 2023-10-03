import SwiftUI
import AppleDocumentation
import Nuke
import NukeExtensions
import SupportMacros

extension EnvironmentValues {
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
    var attributes = Attributes()

    private var attachments: [InlineContent: NSTextAttachment] = [:]

    mutating func attachment<T: NSTextAttachment>(
        for content: InlineContent, default: () -> T
    ) -> T {
        if let attachment = attachments[content] as? T {
            return attachment
        }
        let attachment = `default`()
        attachments[content] = attachment
        return attachment
    }

    struct Attributes {
        var fontSize: CGFloat = 17
        var fontWeight: UIFont.Weight = .regular
        var foregroundColor: UIColor = .lightText

        var textAttributes: [NSAttributedString.Key: Any] {
            return [
                .font: UIFont.systemFont(ofSize: fontSize, weight: fontWeight),
                .foregroundColor: foregroundColor
            ]
        }
    }
}

private protocol TextLayoutObserved: AnyObject {
    func invalidateIntrinsicContentSize()
}

private extension [InlineContent] {
    func attributedString(
        environment: EnvironmentValues,
        cache: inout Cache,
        on textLayoutTarget: TextLayoutObserved
    ) -> NSAttributedString {
        let foregroundColor = environment.colorScheme == .dark ? UIColor.white : .black

        let string = NSMutableAttributedString()
        for content in self {
            cache.attributes = .init(
                fontSize: environment.uiFont?.pointSize ?? 16,
                foregroundColor: foregroundColor
            )
            content.buildAttributedString(
                into: string,
                environment: environment,
                cache: &cache,
                on: textLayoutTarget
            )
        }
        return string
    }
}

private extension InlineContent {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func buildAttributedString(
        into string: NSMutableAttributedString,
        environment: EnvironmentValues,
        cache: inout Cache,
        on textLayoutTarget: TextLayoutObserved
    ) {
        switch self {
        case .text(let text):
            string.append(.init(
                string: text.text,
                attributes: cache.attributes.textAttributes
            ))

        case .codeVoice(let codeVoice):
            string.append(.init(
                string: codeVoice.code,
                attributes: cache.attributes.textAttributes
            ))

        case .strong(let strong):
            cache.attributes.fontWeight = .bold
            let text = NSMutableAttributedString()
            for content in strong.contents {
                content.buildAttributedString(
                    into: text,
                    environment: environment,
                    cache: &cache,
                    on: textLayoutTarget
                )
            }
            string.append(text)

        case .emphasis(let emphasis):
            let text = NSMutableAttributedString()
            for content in emphasis.contents {
                content.buildAttributedString(
                    into: text,
                    environment: environment,
                    cache: &cache,
                    on: textLayoutTarget
                )
            }
            string.append(text)

        case .reference(let reference):
            guard let ref = environment.references[reference.identifier] else { return }

            cache.attributes.foregroundColor = .systemBlue

            var attributes = cache.attributes.textAttributes
            attributes[.link] = ref.url

            let text = NSAttributedString(
                string: ref.title ?? ref.fragments.map(\.text).joined(),
                attributes: attributes
            )
            string.append(text)

        case .image(let image):
            guard let ref = environment.references[image.identifier],
                  let url = ref.variants.last?.url else { return }
            let attachment: ImageAttachment = cache.attachment(for: self) {
                ImageAttachment(target: url, targetView: textLayoutTarget)
            }
            string.append(.init(attachment: attachment))

        case .inlineHead(let inlineHead):
            cache.attributes.fontSize += 4

            let text = NSMutableAttributedString()
            for content in inlineHead.contents {
                content.buildAttributedString(
                    into: text,
                    environment: environment,
                    cache: &cache,
                    on: textLayoutTarget
                )
            }
            string.append(text)

        case .unknown(let unknown):
            let attachment = cache.attachment(for: self) {
                UnknownAttachment(target: unknown, targetView: textLayoutTarget)
            }
            string.append(.init(attachment: attachment))
        }
    }
}

// MARK: -
private struct UITextViewRenderer: UIViewRepresentable {
    let contents: [InlineContent]

    func makeUIView(context: Context) -> TextView {
        let view = TextView()
        view.isScrollEnabled = false
        view.isEditable = false
        view.isSelectable = true
        view.textContainerInset = .zero
        view.textContainer.lineFragmentPadding = 0
        view.textContainer.heightTracksTextView = true
        view.setContentHuggingPriority(.required, for: .vertical)
        return view
    }

    func updateUIView(_ uiView: TextView, context: Context) {
        uiView.attributedText = contents.attributedString(
            environment: context.environment,
            cache: &context.coordinator.cache,
            on: uiView
        )
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: TextView, context: Context) -> CGSize? {
        let width: CGFloat = if let width = proposal.width {
            width.isFinite ? width : .greatestFiniteMagnitude
        } else {
            0.0
        }
        var size = uiView.systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.noIntrinsicMetric),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        size.width = width > 0 ? width : size.width
        return size
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var cache = Cache()
    }

    final class TextView: UITextView, TextLayoutObserved {
        override var intrinsicContentSize: CGSize {
            contentSize
        }
    }
}

private class AttachmentViewProvider<Target>: NSTextAttachmentViewProvider {
    let target: Target
    private(set) weak var targetView: TextLayoutObserved?
    private(set) weak var parentView: UIView?

    required init(
        target: Target,
        targetView: TextLayoutObserved?,
        textAttachment: NSTextAttachment,
        parentView: UIView?,
        textLayoutManager: NSTextLayoutManager?,
        location: NSTextLocation
    ) {
        self.target = target
        self.targetView = targetView
        self.parentView = parentView
        super.init(
            textAttachment: textAttachment,
            parentView: parentView,
            textLayoutManager: textLayoutManager,
            location: location
        )
    }
}

private class Attachment<Target, ViewProvider: AttachmentViewProvider<Target>>: NSTextAttachment {
    let target: Target
    weak var targetView: TextLayoutObserved?
    private var viewProvider: ViewProvider?

    init(target: Target, targetView: TextLayoutObserved) {
        self.target = target
        self.targetView = targetView
        super.init(data: nil, ofType: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewProvider(
        for parentView: UIView?,
        location: NSTextLocation,
        textContainer: NSTextContainer?
    ) -> NSTextAttachmentViewProvider? {
        if let viewProvider {
            return viewProvider
        }
        let provider = ViewProvider(
            target: target,
            targetView: targetView,
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

private final class ImageAttachment: Attachment<URL, ImageAttachment.ViewProvider> {
    final class ViewProvider: AttachmentViewProvider<URL> {
        private lazy var imageView = ImageView()
        private var aspectSize: CGSize?
        private weak var task: ImageTask?

        override func loadView() {
            view = imageView
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.layer.borderColor = UIColor.yellow.cgColor
            imageView.layer.borderWidth = 1
        }

        @MainActor
        override func attachmentBounds(
            for attributes: [NSAttributedString.Key: Any],
            location: NSTextLocation,
            textContainer: NSTextContainer?,
            proposedLineFragment: CGRect,
            position: CGPoint
        ) -> CGRect {
            if let aspectSize {
                return CGRect(
                    origin: .zero,
                    size: contentSize(in: proposedLineFragment.width, imageSize: aspectSize)
                )
            }
            if task == nil {
                task = loadImage(with: target, into: imageView) { [weak self] result in
                    switch result {
                    case .success(let response):
                        self?.aspectSize = response.image.size
                        self?.targetView?.invalidateIntrinsicContentSize()

                    case .failure(let error):
                        print(error)
                    }
                }
            }

            return CGRect(
                x: 0, y: 0,
                width: proposedLineFragment.width,
                height: proposedLineFragment.width * 3 / 4
            )
        }

        private func contentSize(in width: CGFloat, imageSize: CGSize) -> CGSize {
            let height = width * imageSize.height / imageSize.width
            return CGSize(width: width, height: height)
        }

        private final class ImageView: UIImageView {}
    }
}

private final class UnknownAttachment: Attachment<InlineContent.Unknown, UnknownAttachment.ViewProvider> {
    final class ViewProvider: AttachmentViewProvider<InlineContent.Unknown> {
        private lazy var label: UILabel = {
            let label = UILabel()
            label.text = "unhandled type: \(target.type)"
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
