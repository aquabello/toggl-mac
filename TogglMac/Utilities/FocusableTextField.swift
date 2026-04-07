import SwiftUI
import AppKit

// MARK: - Custom NSTextField that guarantees focus on click

private class ClickableTextField: NSTextField {
    override func mouseDown(with event: NSEvent) {
        print("[FocusableTextField] mouseDown triggered")
        super.mouseDown(with: event)
        if let window = self.window {
            print("[FocusableTextField] window exists, making first responder")
            window.makeFirstResponder(self)
        } else {
            print("[FocusableTextField] ERROR: no window!")
        }
    }

    override var acceptsFirstResponder: Bool {
        print("[FocusableTextField] acceptsFirstResponder called -> true")
        return true
    }

    override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        print("[FocusableTextField] becomeFirstResponder -> \(result)")
        if let editor = currentEditor() {
            editor.selectedRange = NSRange(location: stringValue.count, length: 0)
        }
        return result
    }

    override var intrinsicContentSize: NSSize {
        var size = super.intrinsicContentSize
        size.height = max(size.height, 22)
        return size
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        print("[FocusableTextField] viewDidMoveToWindow, window=\(window != nil), frame=\(frame), isEditable=\(isEditable), isHidden=\(isHidden), alphaValue=\(alphaValue)")
    }
}

// MARK: - SwiftUI Wrapper

struct FocusableTextField: NSViewRepresentable {
    let placeholder: String
    @Binding var text: String
    var font: NSFont = .systemFont(ofSize: 14)
    var textColor: NSColor = .white
    var placeholderColor: NSColor = NSColor(white: 0.35, alpha: 1.0)
    var onSubmit: (() -> Void)?
    var autoFocus: Bool = false

    func makeNSView(context: Context) -> NSTextField {
        let textField = ClickableTextField()
        textField.delegate = context.coordinator
        textField.stringValue = text

        textField.isEditable = true
        textField.isSelectable = true
        textField.isBezeled = false
        textField.isBordered = false
        textField.focusRingType = .none
        textField.drawsBackground = true
        textField.backgroundColor = .clear
        textField.font = font
        textField.textColor = textColor
        textField.usesSingleLineMode = true
        textField.maximumNumberOfLines = 1

        textField.placeholderAttributedString = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: placeholderColor,
                .font: font
            ]
        )

        if let cell = textField.cell as? NSTextFieldCell {
            cell.isScrollable = true
            cell.wraps = false
        }

        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        print("[FocusableTextField] makeNSView created, placeholder=\(placeholder), autoFocus=\(autoFocus)")

        if autoFocus {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if let window = textField.window {
                    window.makeFirstResponder(textField)
                    print("[FocusableTextField] autoFocus applied")
                } else {
                    print("[FocusableTextField] autoFocus FAILED: no window")
                }
            }
        }

        return textField
    }

    func updateNSView(_ textField: NSTextField, context: Context) {
        if textField.currentEditor() == nil && textField.stringValue != text {
            textField.stringValue = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, NSTextFieldDelegate {
        var parent: FocusableTextField

        init(_ parent: FocusableTextField) {
            self.parent = parent
        }

        func controlTextDidChange(_ obj: Notification) {
            guard let textField = obj.object as? NSTextField else { return }
            parent.text = textField.stringValue
        }

        func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            if commandSelector == #selector(NSResponder.insertNewline(_:)) {
                parent.onSubmit?()
                return true
            }
            return false
        }
    }
}
