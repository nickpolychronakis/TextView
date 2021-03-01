// Created by Nick Polychronakis with ❤️
// All rights reserved.

import SwiftUI


// MARK: macOS

#if os(macOS)
public struct TextView: NSViewRepresentable {
    
    public init(text: Binding<String>, textViewIsEditing: Binding<Bool>, searchText: String) {
        self._text = text
        self._textViewIsEditing = textViewIsEditing
        if !searchText.isEmpty {
            self.regexResults = Regex.results(regExText: "\(searchText)", targetText: text.wrappedValue, caseSensitive: false, searchWithRegexCharacters: false)
        } else {
            self.regexResults = []
        }
    }
    
    var regexResults: [NSTextCheckingResult]
    @Binding var text: String
    @Binding var textViewIsEditing: Bool
    
    private let yellowAttr = [NSAttributedString.Key.backgroundColor: NSColor.yellow]
    
    public func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        // Πρέπει οποσδήποτε να είναι το textView του τύπου NSTextView
        let textView = scrollView.documentView as! NSTextView
        textView.delegate = context.coordinator
        // Ενεργοποιώ τα hyperlink
        textView.isAutomaticLinkDetectionEnabled = true
        
        return scrollView
    }
    
    public func updateNSView(_ scrollView: NSScrollView, context: Context) {
        // Πρέπει οποσδήποτε να είναι το textView του τύπου NSTextView
        let textView = scrollView.documentView as! NSTextView
        if textView.string != text {
            // Αν έχει άλλάξει το κείμενο προγραμματιστικά μέσω του binding(και όχι αν πληκτρολόγισε ο χρήστης μέσα στο textView), μόνο τότε αλλάζω το κείμενο του textView.
            textView.string = text
        } else {
            // Αφαιρώ όλα τα προηγούμενα attributes
            textView.textStorage?.enumerateAttributes(in: NSRange(location: 0, length: textView.attributedString().length)) { (attributes, range, pointer) in
                for attribute in attributes {
                    if (attributes[.backgroundColor] as? NSColor) == NSColor.yellow {
                        textView.textStorage?.removeAttribute(attribute.key, range: range)
                    }
                }
            }
        }
        
        // κάνω το χρώμα του text να αλλάζει ανάλογα με το darkmode
        textView.textColor = NSColor.labelColor
        
        // Προσθέτω attributes που επιθυμώ ανάλογα με το αποτέλεσμα
        for result in regexResults {
            textView.textStorage?.setAttributes(yellowAttr, range: result.range)
                // Δημιουργεί ένα animation όταν βρεθεί το match
                if textViewIsEditing == false {
                    // Για λόγους πόρων συστήματος έβαλα περιορισμούς στο πότε θα γίνεται το animation
                    if regexResults.count < 10 {
                        textView.showFindIndicator(for: result.range)
                    }
                }
        }
        
        textView.font = NSFont.preferredFont(forTextStyle: .body)
        // Επανέλεγχος για hyperlink
        textView.checkTextInDocument(nil)
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
            // FIXME: Εμφανίζει σφάλμα ότι τροποποιώ το view κατά το update.
            self.parent.textViewIsEditing = true
        }
        
        public func textDidEndEditing(_ notification: Notification) {
            // FIXME: Εμφανίζει σφάλμα ότι τροποποιώ το view κατά το update.
            self.parent.textViewIsEditing = false
         }
    }
}



// MARK: iOS

#else
public struct TextView: UIViewRepresentable {
    
    public init(text: Binding<String>, textViewIsEditing: Binding<Bool>, searchText: String) {
        self._text = text
        self._textViewIsEditing = textViewIsEditing
        if !searchText.isEmpty {
            self.regexResults = Regex.results(regExText: "\(searchText)", targetText: text.wrappedValue, caseSensitive: false, searchWithRegexCharacters: false)
        } else {
            self.regexResults = []
        }
    }
    
    var regexResults: [NSTextCheckingResult]
    @Binding var text: String
    @Binding var textViewIsEditing: Bool
    
    private let yellowAttr = [NSAttributedString.Key.backgroundColor: UIColor.yellow]
    
    public func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        
        // Ενεργοποιώ τα hyperlink
        textView.isEditable = false
        textView.isSelectable = true
        textView.dataDetectorTypes = .all
        // tap gesture for textView
        /// Το tap gesture που θα κάνει το isEditable = true του textView. Αυτό χρειάζεται ώστε όταν ο χρήστης δεν επεξεργάζεται το textView, αυτό θα είναι isEditable = false και έτσι δείχνει τα links ενεργοποιημένα, ενώ όταν πατηθεί το textView και ενεργοποιηθεί το παρακάτω gesture, θα κάνει το isEditable = true και έτσι θα μπορεί ο χρήστης να επεξεργαστεί το κείμενο.
        let tap = UITapGestureRecognizer(target: textView.self, action: #selector(UITextView.textViewDidTapped(recognizer:)))
        textView.addGestureRecognizer(tap)
        
        return textView
    }
    
    public func updateUIView(_ textView: UITextView, context: Context) {
        if textView.text != text {
            // Αν έχει άλλάξει το κείμενο προγραμματιστικά μέσω του binding(και όχι αν πληκτρολόγισε ο χρήστης μέσα στο textView), μόνο τότε αλλάζω το κείμενο του textView.
            textView.attributedText = NSMutableAttributedString(string: text)
        } else {
            // Αφαιρώ όλα τα προηγούμενα attributes
            textView.textStorage.enumerateAttributes(in: NSRange(location: 0, length: textView.attributedText.length)) { (attributes, range, pointer) in
                for attribute in attributes {
                    if (attributes[.backgroundColor] as? UIColor) == UIColor.yellow {
                        textView.textStorage.removeAttribute(attribute.key, range: range)
                    }
                }
            }
        }
        
        // κάνω το χρώμα του text να αλλάζει ανάλογα με το darkmode
        textView.textColor = UIColor.label
        
        // Προσθέτω attributes που επιθυμώ ανάλογα με το αποτέλεσμα
        for result in regexResults {
            textView.textStorage.setAttributes(yellowAttr, range: result.range)
        }
        
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        
        // FIXME: Να προσπαθήσω να βρώ άλλον τρόπο να ξαναϋπολογίζει τα hyperlinks, γιατί έτσι προκαλείται ένα μικρό flickering στα hyperlinks.
        // Το κάνω αναγκαστικά για να ξαναυπολογίσει τα hyperlinks
        if textView.isEditable == false {
            textView.isEditable = true
            textView.isEditable = false
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
            // Ξανααπενεργοποιεί το textView ώστε να είναι επιλέξιμα τα hyperlinks.
            textView.isEditable = false
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
    static func results(regExText: String, targetText: String, caseSensitive: Bool, searchWithRegexCharacters: Bool) -> [NSTextCheckingResult] {
        // Αφαιρώ τα διακριτικά (τόνους) απο το κείμενο.
        let foldedRegexText = regExText.folding(options: .diacriticInsensitive, locale: .current)
        // Υπάρχει κίνδυνος να τροποποιεί το μήκος του string χωρίς να το ξέρω, και να δημιουργήσει προβλήματα αργότερα, να το έχω υπ' όψην μου.
        // Αν χρειαστεί να το αφαιρέσω, σε περίπτωση που χρησιμοποιώ το SPM με κάποιο NSPredicate, να αφαιρέσω και απο εκεί το diacritic Insensitive [d]
        guard regExText.utf16.count == foldedRegexText.utf16.count else { fatalError("Πώ ρε φίλε, έπρεπε να είναι ίδια.")}
        let foldedTargetText = targetText.folding(options: .diacriticInsensitive, locale: .current)
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
