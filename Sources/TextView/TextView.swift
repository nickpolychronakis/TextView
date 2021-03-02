// Created by Nick Polychronakis with ❤️
// All rights reserved.

import SwiftUI


#if os(macOS)
// MARK: macOS
public struct TextView: NSViewRepresentable {
    
    public init(text: Binding<String>, textViewIsEditing: Binding<Bool>, searchText: String, caseSensitiveSearch: Bool = false, diacriticSensitiveSearch: Bool = false, searchWithRegexCharacters: Bool = false, hyperlinkDetection: Bool = true) {
        self._text = text
        self._textViewIsEditing = textViewIsEditing
        if !searchText.isEmpty {
            self.regexResults = Regex.results(regExText: "\(searchText)", targetText: text.wrappedValue, caseSensitive: caseSensitiveSearch, diacriticSensitive: diacriticSensitiveSearch, searchWithRegexCharacters: searchWithRegexCharacters)
        } else {
            self.regexResults = []
        }
        self.hyperlinkDetection = hyperlinkDetection
    }
    
    @Binding var text: String
    @Binding var textViewIsEditing: Bool
    let regexResults: [NSTextCheckingResult]
    let hyperlinkDetection: Bool
    
    private let yellowAttr = [
        NSAttributedString.Key.backgroundColor: NSColor.yellow,
        NSAttributedString.Key.foregroundColor: NSColor.black
    ]
    
    public func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        // Πρέπει οποσδήποτε να είναι το textView του τύπου NSTextView
        let textView = scrollView.documentView as! NSTextView
        textView.delegate = context.coordinator
        if hyperlinkDetection {
            // Ενεργοποιώ τα hyperlink
            textView.isAutomaticLinkDetectionEnabled = true
        }
        
        return scrollView
    }
    
    public func updateNSView(_ scrollView: NSScrollView, context: Context) {
        // Πρέπει οποσδήποτε να είναι το textView του τύπου NSTextView
        let textView = scrollView.documentView as! NSTextView
        // Αν έχει άλλάξει το κείμενο προγραμματιστικά μέσω του binding(και όχι αν πληκτρολόγισε ο χρήστης μέσα στο textView), μόνο τότε αλλάζω το κείμενο του textView.
        if textView.string != text {
            // Αφαιρώ όλα τα προηγούμενα yellow background και link attributes
            textView.textStorage?.enumerateAttributes(in: NSRange(location: 0, length: textView.attributedString().length)) { (attributes, range, pointer) in
                if hyperlinkDetection {
                    textView.textStorage?.removeAttribute(NSAttributedString.Key.link, range: range)
                }
                textView.textStorage?.removeAttribute(NSAttributedString.Key.backgroundColor, range: range)
                textView.textStorage?.addAttribute(.foregroundColor, value: NSColor.textColor, range: range)
            }
            textView.string = text
            // Διαπίστωσα ότι δεν χρειάζεται στο macOS αλλαγή του χρώματος (κάνω το χρώμα του text να αλλάζει ανάλογα με το darkmode)
//            textView.textColor = NSColor.textColor
//            textView.font = NSFont.preferredFont(forTextStyle: .body)
            if hyperlinkDetection {
                DispatchQueue.main.async {
                    // Επανέλεγχος των hyperlink
                    // Το έβαλα αναγκαστικά στο dispatch καθώς προκαλεί εκτέλεση του textDidBeginEditing του Coordinator, το οποίο σε συνδιασμό με την μεταβλητή που υπάρχει εκεί, η οποία είναι Binding, προκαλεί πρόβλημα επανυπολογισμού του View την στιγμή που ήδη κάνει update, το οποίο έχει άγνωστες συνέπειες.
                    textView.checkTextInDocument(nil)
                }
            }
        } else {
            // Αφαιρώ όλα τα προηγούμενα yellow background attributes
            textView.textStorage?.enumerateAttributes(in: NSRange(location: 0, length: textView.attributedString().length)) { (attributes, range, pointer) in
                if (attributes[.backgroundColor] as? NSColor) == NSColor.yellow {
                    textView.textStorage?.removeAttribute(NSAttributedString.Key.backgroundColor, range: range)
                    textView.textStorage?.addAttribute(.foregroundColor, value: NSColor.textColor, range: range)
                }
            }
        }
        
        // Προσθέτω attributes που επιθυμώ ανάλογα με το αποτέλεσμα
        for result in regexResults {
            textView.textStorage?.addAttributes(yellowAttr, range: result.range)
                // Δημιουργεί ένα animation όταν βρεθεί το match
                if textViewIsEditing == false {
                    // Για λόγους πόρων συστήματος έβαλα περιορισμούς στο πότε θα γίνεται το animation
                    if result.range.length > 3 && regexResults.count < 10 {
                        textView.showFindIndicator(for: result.range)
                    }
                }
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
     
    public class Coordinator: NSObject, NSTextViewDelegate {
        var parent: TextView
     
        init(_ parent: TextView) {
            self.parent = parent
        }
        
        public func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            if self.parent.text != textView.string {
                self.parent.text = textView.string
            }
        }
        
        public func textDidBeginEditing(_ notification: Notification) {
            self.parent.textViewIsEditing = true
        }
        
        public func textDidEndEditing(_ notification: Notification) {
            self.parent.textViewIsEditing = false
        }
    }
}



#else



// MARK: iOS
public struct TextView: UIViewRepresentable {
    
    public init(text: Binding<String>, textViewIsEditing: Binding<Bool>, searchText: String, caseSensitiveSearch: Bool = false, diacriticSensitiveSearch: Bool = false, searchWithRegexCharacters: Bool = false, hyperlinkDetection: Bool = true) {
        self._text = text
        self._textViewIsEditing = textViewIsEditing
        if !searchText.isEmpty {
            self.regexResults = Regex.results(regExText: "\(searchText)", targetText: text.wrappedValue, caseSensitive: caseSensitiveSearch,  diacriticSensitive: diacriticSensitiveSearch, searchWithRegexCharacters: searchWithRegexCharacters)
        } else {
            self.regexResults = []
        }
        self.hyperlinkDetection = hyperlinkDetection
    }
    
    @Binding var text: String
    @Binding var textViewIsEditing: Bool
    let regexResults: [NSTextCheckingResult]
    let hyperlinkDetection: Bool
    
    private let yellowAttr = [
        NSAttributedString.Key.backgroundColor: UIColor.yellow,
        NSAttributedString.Key.foregroundColor: UIColor.black
    ]
    
    public func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        
        if hyperlinkDetection {
            // Ενεργοποιώ τα hyperlink
            textView.isEditable = false
            textView.isSelectable = true
            textView.dataDetectorTypes = .all
            // tap gesture for textView
            /// Το tap gesture που θα κάνει το isEditable = true του textView. Αυτό χρειάζεται ώστε όταν ο χρήστης δεν επεξεργάζεται το textView, αυτό θα είναι isEditable = false και έτσι δείχνει τα links ενεργοποιημένα, ενώ όταν πατηθεί το textView και ενεργοποιηθεί το παρακάτω gesture, θα κάνει το isEditable = true και έτσι θα μπορεί ο χρήστης να επεξεργαστεί το κείμενο.
            let tap = UITapGestureRecognizer(target: textView.self, action: #selector(UITextView.textViewDidTapped(recognizer:)))
            textView.addGestureRecognizer(tap)
        }
        
        return textView
    }
    
    public func updateUIView(_ textView: UITextView, context: Context) {
        // Δίνει ή πέρνει το firstResponder απο το textView ανάλογα με το textViewIsEditing
        if textViewIsEditing && !textView.isFirstResponder {
            DispatchQueue.main.async {
                textView.isEditable = true
                textView.becomeFirstResponder()
            }
        } else if !textViewIsEditing && textView.isFirstResponder {
            DispatchQueue.main.async {
                textView.isEditable = false
                textView.resignFirstResponder()
            }
        }
        if textView.text != text {
            // Αν έχει άλλάξει το κείμενο προγραμματιστικά μέσω του binding(και όχι αν πληκτρολόγισε ο χρήστης μέσα στο textView), μόνο τότε αλλάζω το κείμενο του textView.
            textView.attributedText = NSMutableAttributedString(string: text)
            // κάνω το χρώμα του text να αλλάζει ανάλογα με το darkmode
            textView.textColor = UIColor.label
            textView.font = UIFont.preferredFont(forTextStyle: .body)
        } else {
            // Αφαιρώ όλα τα προηγούμενα attributes
            textView.textStorage.enumerateAttributes(in: NSRange(location: 0, length: textView.attributedText.length)) { (attributes, range, pointer) in
                if (attributes[.backgroundColor] as? UIColor) == UIColor.yellow {
                    textView.textStorage.removeAttribute(NSAttributedString.Key.backgroundColor, range: range)
                    textView.textStorage.addAttribute(.foregroundColor, value: UIColor.label, range: range)
                }

            }
        }
        // Προσθέτω attributes που επιθυμώ ανάλογα με το αποτέλεσμα
        for result in regexResults {
            textView.textStorage.addAttributes(yellowAttr, range: result.range)
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
     
    public class Coordinator: NSObject, UITextViewDelegate {
        var parent: TextView
     
        init(_ parent: TextView) {
            self.parent = parent
        }
     
        public func textViewDidChange(_ textView: UITextView) {
            if self.parent.text != textView.text {
                self.parent.text = textView.text
            }
        }
        
        public func textViewDidBeginEditing(_ textView: UITextView) {
            self.parent.textViewIsEditing = true
        }
        
        public func textViewDidEndEditing(_ textView: UITextView) {
            self.parent.textViewIsEditing = false
            if self.parent.hyperlinkDetection {
                // Ξανααπενεργοποιεί το textView ώστε να είναι επιλέξιμα τα hyperlinks.
                textView.isEditable = false
            }
        }
    }
}


// MARK: TEXTVIEW EXTENSION
extension UITextView {
    /// Τοποθετεί τον cursor στο σημείο που πάτησε ο χρήστης
    func placeCursor(_ textView: UITextView, _ location: CGPoint) {
        // Βρίσκω το κοντινότερο σημείο στο tap που μπορεί να τοποθετηθεί ο κέρσορας
        if let tapPosition = textView.closestPosition(to: location) {
            let loc = textView.offset(from: textView.beginningOfDocument, to: tapPosition)
            textView.selectedRange = NSMakeRange(loc, 0)
            textView.isEditable = true
            textView.becomeFirstResponder()
        }
    }
    
    /// Η συνάρτηση που ενεργοποιήται απο το gestureRecognizer όταν πατηθεί το textView. Αν πατηθεί απλό κείμενο ενεργοποιείται η επεξεργασία, αν πατηθεί link ενεργοποιείται το link.
    @objc func textViewDidTapped(recognizer: UITapGestureRecognizer) {
        /// Σιγουρεύομαι ότι το view απο το recognizer είναι το textView
        guard let textView = recognizer.view as? UITextView else { return }
        /// Το  CGPoint που πάτησε ο χρήστης στο textView
        let location = recognizer.location(in: textView)
        /// Το CGPoint που πάτησε ο χρήστης στο textView, αφού έχω αφαιρέσει όμως τα insets για να λειτουργήσει σωστά το σημείο που πατάω τα links.
        var glyphLocation = location
        glyphLocation.x -= textView.textContainerInset.left
        glyphLocation.y -= textView.textContainerInset.top
        /// Τα link που βρίσκονται κοντά στο σημείο που πάτησε ο χρήστης
        let glyphIndex: Int = textView.layoutManager.glyphIndex(for: glyphLocation, in: textView.textContainer, fractionOfDistanceThroughGlyph: nil)
        /// Βρίσκω το CGRect του συγκεκριμένου link που πάτησε ο χρήστης
        let glyphRect = textView.layoutManager.boundingRect(forGlyphRange: NSRange(location: glyphIndex, length: 1), in: textView.textContainer)
        // Αν το CGRect του link περιέχει το CGPoint που πάτησε ο χρήστης τότε...
        if glyphRect.contains(glyphLocation) {
            /// Η θέση που βρίσκεται ο πρώτος χαρακτήρας του link στο κείμενο
            let characterIndex: Int = textView.layoutManager.characterIndexForGlyph(at: glyphIndex)
            /// Το attribute του link.
            let attributeValue = textView.textStorage.attribute(NSAttributedString.Key.link, at: characterIndex, effectiveRange: nil)
            /// Αν το attribute του link είναι URL τότε...
            if let url = attributeValue as? URL {
                /// Αν μπορεί να ανοίξει το URL τότε...
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    print("There is a problem in your link.")
                }
            } else {
                // place the cursor to tap position
                placeCursor(textView, location)
            }
        } else {
            // place the cursor to tap position
            placeCursor(textView, location)
        }
    }
}
#endif







// MARK: REGEX FUNCTION
// Επιστρέφει τα αποτελέσματα απο την αναζήτηση με regex σε ένα κείμενο.
struct Regex {
    static func results(regExText: String, targetText: String, caseSensitive: Bool, diacriticSensitive: Bool, searchWithRegexCharacters: Bool) -> [NSTextCheckingResult] {
        // Αφαιρώ τα διακριτικά (τόνους) απο το κείμενο.
        let foldedRegexText = diacriticSensitive ? regExText : regExText.folding(options: .diacriticInsensitive, locale: .current)
        // Υπάρχει κίνδυνος να τροποποιεί το μήκος του string χωρίς να το ξέρω, και να δημιουργήσει προβλήματα αργότερα, να το έχω υπ' όψην μου.
        // Αν χρειαστεί να το αφαιρέσω, σε περίπτωση που χρησιμοποιώ το SPM με κάποιο NSPredicate, να αφαιρέσω και απο εκεί το diacritic Insensitive [d]
        guard regExText.utf16.count == foldedRegexText.utf16.count else { fatalError("Πώ ρε φίλε, έπρεπε να είναι ίδια.")}
        let foldedTargetText = diacriticSensitive ? targetText : targetText.folding(options: .diacriticInsensitive, locale: .current)
        // Υπάρχει κίνδυνος να τροποποιεί το μήκος του string χωρίς να το ξέρω, και να δημιουργήσει προβλήματα αργότερα, να το έχω υπ' όψην μου.
        // Αν χρειαστεί να το αφαιρέσω, σε περίπτωση που χρησιμοποιώ το SPM με κάποιο NSPredicate, να αφαιρέσω και απο εκεί το diacritic Insensitive [d]
        guard targetText.utf16.count == foldedTargetText.utf16.count else { fatalError("Πώ ρε φίλε, έπρεπε να είναι ίδια.")}

        // μηδενίζω τα αποτελέσματα
        var results: [NSTextCheckingResult] = []
        // τα options του regular expression
        var regexOptions: NSRegularExpression.Options = []
        // Αν θα αγνοεί τους ειδικούς χαρακτήρες για το REGEX και θα θεωρεί το regExText ως κανονικό String.
        if !searchWithRegexCharacters { regexOptions.insert(.ignoreMetacharacters) }
        // Αν για την αναζήτηση θα υπολογίζονται η διαφορά κεφαλαίων-μικρών ή όχι.
        if !caseSensitive { regexOptions.insert(.caseInsensitive) }
        do {
            // δημιουργία του regex
            let reg = try NSRegularExpression(pattern: foldedRegexText, options: regexOptions)
            // εκτέλεση του regex
            return reg.matches(in: foldedTargetText, options: [], range: NSRange(location: 0, length: targetText.utf16.count))
        } catch {
            // σε περίπτωση σφάλματος μηδενίζω το array
            results = []
        }
        return results
    }
    
}
