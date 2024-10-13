import SwiftUI

/// A SwiftUI TagTextView implementation that supports both scrolling and auto-sizing layouts
public struct TagTextView: View {
    @Environment(\.layoutDirection) private var layoutDirection

    @Binding private var text: NSAttributedString
    @Binding private var isEmpty: Bool
    @Binding private var tags: [TagModel]

    @State private var calculatedHeight: CGFloat = 44

    private var onEditingChanged: (() -> Void)?
    private var shouldEditInRange: ((Range<String.Index>, String) -> Bool)?
    private var onCommit: (() -> Void)?
    private var onDidBeginEditing: (() -> Void)?
    private var onDidEndEditing: (() -> Void)?
    
    private var didChangedTagSearchString: ((String, Bool) -> Void)?
    private var didInsertTag: ((TagModel) -> Void)?
    private var didRemoveTag: ((TagModel) -> Void)?
    private var didSelectTag: ((TagModel) -> Void)?
    private var didChangedTags: (([TagModel]) -> Void)?

    var placeholderView: AnyView?
    var foregroundColor: UIColor = .label
    var autocapitalization: UITextAutocapitalizationType = .sentences
    var multilineTextAlignment: TextAlignment = .leading
    var font: UIFont = .preferredFont(forTextStyle: .body)
    var returnKeyType: UIReturnKeyType?
    var clearsOnInsertion: Bool = false
    var autocorrection: UITextAutocorrectionType = .default
    var truncationMode: NSLineBreakMode = .byTruncatingTail
    var isEditable: Bool = true
    var isSelectable: Bool = true
    var scrollingBehavior: ScrollingBehavior = .disable
    var enablesReturnKeyAutomatically: Bool?
    var autoDetectionTypes: UIDataDetectorTypes = []
    var allowRichText: Bool
    
    var mentionSymbol: String = UITagTextView.Constants.Defaults.mentionSymbol
    var mentionForegroundColor: UIColor = UITagTextView.Constants.Defaults.mentionColor
    var mentionFont: UIFont = UITagTextView.Constants.Defaults.mentionFont
    
    var hashTagSymbol: String = UITagTextView.Constants.Defaults.hashTagSymbol
    var hashTagForegroundColor: UIColor = UITagTextView.Constants.Defaults.hashTagColor
    var hashTagFont: UIFont = UITagTextView.Constants.Defaults.hashTagFont

    // ******************************* MARK: - Initialization and Setup
    
    /// Makes a new TextView with the specified configuration
    /// - Parameters:
    ///   - text: A binding to the text
    ///   - shouldEditInRange: A closure that's called before an edit it applied, allowing the consumer to prevent the change
    ///   - onEditingChanged: A closure that's called after an edit has been applied
    ///   - onCommit: If this is provided, the field will automatically lose focus when the return key is pressed
    public init(_ text: Binding<String>,
                tags: Binding<[TagModel]>,
                shouldEditInRange: ((Range<String.Index>, String) -> Bool)? = nil,
                onEditingChanged: (() -> Void)? = nil,
                onCommit: (() -> Void)? = nil,
                onDidBeginEditing: (() -> Void)? = nil,
                onDidEndEditing: (() -> Void)? = nil,
                didChangedTagSearchString: ((String, Bool) -> Void)? = nil,
                didInsertTag: ((TagModel) -> Void)? = nil,
                didRemoveTag: ((TagModel) -> Void)? = nil,
                didSelectTag: ((TagModel) -> Void)? = nil,
                didChangedTags: (([TagModel]) -> Void)? = nil) {
        _text = Binding(
            get: { NSAttributedString(string: text.wrappedValue) },
            set: {
                if text.wrappedValue != $0.string {
                    text.wrappedValue = $0.string
                }
            }
        )

        _isEmpty = Binding(
            get: { text.wrappedValue.isEmpty },
            set: { _ in }
        )
        
        self._tags = tags
        self.onCommit = onCommit
        self.shouldEditInRange = shouldEditInRange
        self.onEditingChanged = onEditingChanged
        self.onDidBeginEditing = onDidBeginEditing
        self.onDidEndEditing = onDidEndEditing
        
        self.didChangedTagSearchString = didChangedTagSearchString
        self.didInsertTag = didInsertTag
        self.didRemoveTag = didRemoveTag
        self.didSelectTag = didSelectTag
        self.didChangedTags = didChangedTags

        allowRichText = false
    }

    /// Makes a new TextView that supports `NSAttributedString`
    /// - Parameters:
    ///   - text: A binding to the attributed text
    ///   - onEditingChanged: A closure that's called after an edit has been applied
    ///   - onCommit: If this is provided, the field will automatically lose focus when the return key is pressed
    public init(_ text: Binding<NSAttributedString>,
                tags: Binding<[TagModel]>,
                onEditingChanged: (() -> Void)? = nil,
                onCommit: (() -> Void)? = nil,
                onDidBeginEditing: (() -> Void)? = nil,
                onDidEndEditing: (() -> Void)? = nil,
                didChangedTagSearchString: ((String, Bool) -> Void)? = nil,
                didInsertTag: ((TagModel) -> Void)? = nil,
                didRemoveTag: ((TagModel) -> Void)? = nil,
                didSelectTag: ((TagModel) -> Void)? = nil,
                didChangedTags: (([TagModel]) -> Void)? = nil) {
        _text = text
        _isEmpty = Binding(
            get: { text.wrappedValue.string.isEmpty },
            set: { _ in }
        )
        
        self._tags = tags
        
        self.onCommit = onCommit
        self.onEditingChanged = onEditingChanged
        self.onDidBeginEditing = onDidBeginEditing
        self.onDidEndEditing = onDidEndEditing
        
        self.didChangedTagSearchString = didChangedTagSearchString
        self.didInsertTag = didInsertTag
        self.didRemoveTag = didRemoveTag
        self.didSelectTag = didSelectTag
        self.didChangedTags = didChangedTags

        allowRichText = true
    }

    public var body: some View {
        Representable(
            text: $text,
            tags: $tags,
            calculatedHeight: $calculatedHeight,
            foregroundColor: foregroundColor,
            autocapitalization: autocapitalization,
            multilineTextAlignment: multilineTextAlignment,
            font: font,
            returnKeyType: returnKeyType,
            clearsOnInsertion: clearsOnInsertion,
            autocorrection: autocorrection,
            truncationMode: truncationMode,
            isEditable: isEditable,
            isSelectable: isSelectable,
            scrollingBehavior: scrollingBehavior,
            enablesReturnKeyAutomatically: enablesReturnKeyAutomatically,
            autoDetectionTypes: autoDetectionTypes,
            allowsRichText: allowRichText,
            mentionSymbol: mentionSymbol,
            mentionForegroundColor: mentionForegroundColor,
            mentionFont: mentionFont,
            hashTagSymbol: hashTagSymbol,
            hashTagForegroundColor: hashTagForegroundColor,
            hashTagFont: hashTagFont,
            onEditingChanged: onEditingChanged,
            shouldEditInRange: shouldEditInRange,
            onCommit: onCommit,
            onDidBeginEditing: onDidBeginEditing,
            onDidEndEditing: onDidEndEditing,
            didChangedTagSearchString: didChangedTagSearchString,
            didInsertTag: didInsertTag,
            didRemoveTag: didRemoveTag,
            didSelectTag: didSelectTag,
            didChangedTags: didChangedTags
        )
        .frame(
            minHeight: scrollingBehavior.viewMinHeight(forTextHeight: calculatedHeight),
            maxHeight: scrollingBehavior.viewMaxHeight(forTextHeight: calculatedHeight)
        )
        .background(
            placeholderView?
                .foregroundColor(Color(.placeholderText))
                .multilineTextAlignment(multilineTextAlignment)
                .font(Font(font))
                .padding(.horizontal, scrollingBehavior.horizontalPadding)
                .padding(.vertical, scrollingBehavior.verticalPadding)
                .opacity(isEmpty ? 1 : 0),
            alignment: .topLeading
        )
    }
}

// ******************************* MARK: - SwiftUI Preview Data

#if DEBUG
struct TextView_Previews: PreviewProvider {
    struct RoundedTextView: View {
        @State private var text: NSAttributedString = .init()
        @State private var tags: [TagModel] = []

        var body: some View {
            VStack(alignment: .leading) {
                TagTextView(
                    $text,
                    tags: $tags
                )
                .padding(.leading, 25)

                GeometryReader { _ in
                    TagTextView($text,
                                tags: $tags)
                        .placeholder("Enter some text")
                        .padding(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 1)
                                .foregroundColor(Color(.placeholderText))
                        )
                        .padding()
                }
                .background(Color(.systemBackground).edgesIgnoringSafeArea(.all))

                Button {
                    text = NSAttributedString(string: "This is interesting", attributes: [
                        .font: UIFont.preferredFont(forTextStyle: .headline)
                    ])
                } label: {
                    Spacer()
                    Text("Interesting?")
                    Spacer()
                }
                .padding()
            }
        }
    }
    
    static var previews: some View {
        RoundedTextView()
    }
}
#endif
