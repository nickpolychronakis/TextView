// Created by Nick Polychronakis with ❤️
// All rights reserved.

import SwiftUI


// MARK: macOS

#if os(macOS)
public struct TextView: NSViewRepresentable {
    public init(text: Binding<String>, textViewIsEditing: Binding<Bool>, regexController: [RegExResults]) {
        self._text = text
        self._textViewIsEditing = textViewIsEditing
        self.regexController = regexController
    }
    
    var regexController: [RegExResults]
    @Binding var text: String
    @Binding var textViewIsEditing: Bool
    
    private let yellowAttr = [NSAttributedString.Key.backgroundColor: NSColor.yellow]
    private let orangeAttr: [NSAttributedString.Key : Any] = [
        NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
        NSAttributedString.Key.underlineColor: NSColor.red
    ]
    
    public func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        guard let textView = scrollView.documentView as? NSTextView else {
            fatalError("Έπρεπε να είναι οπωσδήποτε το textView == NSTextView")
        }
        
        textView.delegate = context.coordinator
        return scrollView
    }
    
    public func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }
        if textView.string != text {
            textView.string = text
        } else {
            // Αφαιρώ όλα τα προηγούμενα attributes
            textView.textStorage?.enumerateAttributes(in: NSRange(location: 0, length: textView.attributedString().length)) { (attributes, range, pointer) in
                for attribute in attributes {
                    textView.textStorage?.removeAttribute(attribute.key, range: range)
                }
            }
        }
        
        // κάνω το χρώμα του text να αλλάζει ανάλογα με το darkmode
        textView.textColor = NSColor.labelColor
        
        // Προσθέτω attributes που επιθυμώ ανάλογα με το αποτέλεσμα
        for result in regexController {
            // FIXME: Να μπεί έλεγχος ότι το result.range δεν είναι μεγαλύτερο απο το range του text του textView.
            if result.isFullMatch {
                textView.textStorage?.setAttributes(yellowAttr, range: result.range)
                // Δημιουργεί ένα animation όταν βρεθεί το fullMatch
                if textViewIsEditing == false {
                    // Για λόγους πόρων συστήματος έβαλα περιορισμούς στο πότε θα γίνεται το animation
                    if result.match.utf16.count > 2  && regexController.count < 10 {
                        textView.showFindIndicator(for: result.range)
                    }
                }
            } else {
                textView.textStorage?.addAttributes(orangeAttr, range: result.range)
            }
        }
        
        textView.font = NSFont.preferredFont(forTextStyle: .body)
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, textViewIsEditing: $textViewIsEditing)
    }
     
    public class Coordinator: NSObject, NSTextViewDelegate {
        var text: Binding<String>
        var textViewIsEditing: Binding<Bool>
     
        init(text: Binding<String>, textViewIsEditing: Binding<Bool>) {
            self.text = text
            self.textViewIsEditing = textViewIsEditing
        }
        
        public func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            self.text.wrappedValue = textView.string
        }
        
        public func textDidBeginEditing(_ notification: Notification) {
//            guard let editor = notification.object as? NSTextView else { return }
            textViewIsEditing.wrappedValue = true
        }
        
        public func textDidEndEditing(_ notification: Notification) {
//             guard let editor = notification.object as? NSTextView else { return }
            textViewIsEditing.wrappedValue = false
         }
    }
}



// MARK: iOS

#else
public struct TextView: UIViewRepresentable {
    
    public init(text: Binding<String>, textViewIsEditing: Binding<Bool>, regexController: [RegExResults]) {
        self._text = text
        self._textViewIsEditing = textViewIsEditing
        self.regexController = regexController
    }
    
    var regexController: [RegExResults]
    @Binding var text: String
    @Binding var textViewIsEditing: Bool
    
    private let yellowAttr = [NSAttributedString.Key.backgroundColor: UIColor.yellow]
    private let orangeAttr: [NSAttributedString.Key : Any] = [
        NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
        NSAttributedString.Key.underlineColor: UIColor.red
    ]
    
    public func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        return textView
    }
    
    public func updateUIView(_ textView: UITextView, context: Context) {
        if textView.text != text {
            textView.attributedText = NSMutableAttributedString(string: text)
        } else {
            // Αφαιρώ όλα τα προηγούμενα attributes
            textView.textStorage.enumerateAttributes(in: NSRange(location: 0, length: textView.attributedText.length)) { (attributes, range, pointer) in
                for attribute in attributes {
                    textView.textStorage.removeAttribute(attribute.key, range: range)
                }
            }
        }
        
        // κάνω το χρώμα του text να αλλάζει ανάλογα με το darkmode
        textView.textColor = UIColor.label
        
        // Προσθέτω attributes που επιθυμώ ανάλογα με το αποτέλεσμα
        for result in regexController {
            // FIXME: Να μπεί έλεγχος ότι το result.range δεν είναι μεγαλύτερο απο το range του text του textView.
            if result.isFullMatch {
                textView.textStorage.setAttributes(yellowAttr, range: result.range)
            } else {
                textView.textStorage.addAttributes(orangeAttr, range: result.range)
            }
        }
        
        textView.font = UIFont.preferredFont(forTextStyle: .body)
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, textViewIsEditing: $textViewIsEditing)
    }
     
    public class Coordinator: NSObject, UITextViewDelegate {
        var text: Binding<String>
        var textViewIsEditing: Binding<Bool>

     
        init(text: Binding<String>, textViewIsEditing: Binding<Bool>) {
            self.text = text
            self.textViewIsEditing = textViewIsEditing
        }
     
        public func textViewDidChange(_ textView: UITextView) {
            self.text.wrappedValue = textView.text
        }
        
        public func textViewDidBeginEditing(_ textView: UITextView) {
            textViewIsEditing.wrappedValue = true
        }
        
        public func textViewDidEndEditing(_ textView: UITextView) {
            textViewIsEditing.wrappedValue = false
        }
    }
}
#endif




// MARK: CONTROLLER
public class RegexController: ObservableObject {
    /// Το κείμενο του Regex
    @Published var regExText: String = "" {
        willSet {
            results = regExResults(regExText: newValue, targetText: targetText, caseSensitive: caseSensitive)
        }
    }
    /// Το κείμενο που θα ψαξει το Regex
    @Published var targetText = ""{
        willSet {
            results = regExResults(regExText: regExText, targetText: newValue, caseSensitive: caseSensitive)
        }
    }
    /// Η λίστα με τα αποτελέσματα απο την εύρεση του Regex
    @Published var results = [RegExResults]()
    /// Αν θα αναζητά αποτελέσματα που ταιριάζουν τα κεφαλαία-μικρά ή όχι.
    @AppStorage("caseSensitive") var caseSensitive: Bool = false {
        willSet {
            results = regExResults(regExText: regExText, targetText: targetText, caseSensitive: newValue)
        }
    }
    
    // MARK: REGEX FUNCTION
    private func regExResults(regExText: String, targetText: String, caseSensitive: Bool) -> [RegExResults] {
        // μηδενίζω τα αποτελέσματα
        var results: [RegExResults] = []
        // τα options του regular expression
        var regexOptions: NSRegularExpression.Options = []
        // προσθέτω το option αν για την αναζήτηση θα υπολογίζονται η διαφορά κεφαλαίων-μικρών ή όχι.
        if !caseSensitive { regexOptions.insert(.caseInsensitive) }
        do {
            // δημιουργία του regex
            let reg = try NSRegularExpression(pattern: regExText, options: regexOptions)
            // εκτέλεση του regex
            let regMatches = reg.matches(in: targetText, options: [], range: NSRange(location: 0, length: targetText.utf16.count))
            for match in regMatches {
                // αν βρέθηκε κάποιο αποτέλεσμα
                if let wholeRange = Range(match.range(at: 0), in: targetText) {
                    let tempFullmatch = String(targetText[wholeRange])
                    results.append(RegExResults(match: tempFullmatch, isFullMatch: true, range: match.range(at: 0)))
                    
                    // αν υπάρχουν group για το συγκεκριμένο match
                    for i in 1..<match.numberOfRanges {
                        // βρίσκω το range για το κάθε group
                        if let wholeRange = Range(match.range(at: i), in: targetText) {
                            // το μετατρέπω σε string
                            let tempGroup = String(targetText[wholeRange])
                            if tempGroup != "" {
                                // και αν δεν είναι κενό το προσθέτω στα αποτελεσματα των group
                                results.append(RegExResults(match: tempGroup, isFullMatch: false, range: match.range(at: i)))
                            }
                        }
                    }
                }
            }
        } catch {
            // σε περίπτωση σφάλματος μηδενίζω το array
            results = []
        }
        return results
    }
    
}



// MARK: RegExResults
/// Θα αποθηκεύει τα αποτελέσματα απο την εύρεση του Regex
public struct RegExResults: Hashable {
    // το αποτέλεσμα
    let match: String
    // αν είναι το πλήρες αποτέλεσμα ή κάποιο απο τα capture του regex που όρισε ο χρήστης με παρένθεση.
    let isFullMatch: Bool
    // το range που βρίσκεται το αποτέλεσμα
    let range: NSRange
}
