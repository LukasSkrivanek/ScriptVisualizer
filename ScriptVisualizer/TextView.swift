import SwiftUI

struct TextView: NSViewRepresentable {
    @Binding var text: String
    let coloredStrings: [String]
    func makeNSView(context: Context) -> NSTextView {
        let textView = NSTextView()
        textView.isEditable = true
        textView.backgroundColor = .white
        textView.delegate = context.coordinator // Set the delegate for handling text changes
        return textView
    }
    func updateNSView(_ nsView: NSTextView, context: Context) {
        // Update the text content and apply text attributes
        nsView.string = text
        applyTextAttributes(for: nsView)
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    private func applyTextAttributes(for textView: NSTextView) {
        let attributedString = NSMutableAttributedString(string: textView.string)
        // Iterate through each word in the text
        for word in coloredStrings {
            let pattern = "\\b\(NSRegularExpression.escapedPattern(for: word))\\b" // Match whole word only
            guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
                continue
            }
            let range = NSRange(location: 0, length: attributedString.length)
            let matches = regex.matches(in: attributedString.string, options: [], range: range)

            for match in matches {
                attributedString.addAttribute(.foregroundColor, value: NSColor.red, range: match.range)
            }
        }
        textView.textStorage?.setAttributedString(attributedString)
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: TextView
        init(_ parent: TextView) {
            self.parent = parent
        }
        func textDidChange(_ notification: Notification) {
            // Update the binding with the new text content
            if let textView = notification.object as? NSTextView {
                parent.text = textView.string
                parent.applyTextAttributes(for: textView)
            }
        }
    }
}

