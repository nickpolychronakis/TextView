# TextView

Δημιουργεί το TextView σε SwiftUI με δυνατότητες: 

- Ενημέρωσης πότε είναι σε επεξεργασία και ποτε όχι.
- Εύρεσης μέσα στο κείμενο ( με επιλογή για κεφαλαίους ή τονισμένους χαρακτήρες ή ακόμα και για εισαγωγή Regex), όπου η εύρεση τονίζεται με κίτρινο χρώμα.
- Αυτόματης αναγνώρισης hyperlinks.

Το TextView υποστηρίζει **iOS** και **macOS**.

Δημιουργείται έτσι:

``` swift
// Το κείμενο που θέλουμε να γίνει αναζήτηση
@State private var searchText = ""
// Το κείμενο του textView. 
@State private var textViewText  = "Το κείμενο περιέχει ένα hyperlink\nwww.apple.com"
// Αν είναι σε επεξεργασία ή όχι. Με αυτόν τον τρόπο μπορούμε να ανοίξουμε ή να κλείσουμε το πληκτρολόγιο.
@State private var textViewIsEditing = false

TextView(text: $textViewText, textViewIsEditing: $textViewIsEditing, searchText: searchText, caseSensitiveSearch: false, diacriticSensitiveSearch: false, regexSearch: false, hyperlinkDetection: true)
```

| Attributes  |  Τι κάνουν |
|:----------|:----------|
| text | Το κείμενο που περιέχει το textView |
| TextViewIsEditing | Αν είναι σε επεξεργασία ή όχι το textView |
| searchText | Το κείμενο που θέλουμε να γίνει αναζήτηση. Το ανευρεθέν κείμενο θα τονίζεται με κίτρινο φόντο | 
| caseSensitiveSearch | Αν η αναζήτηση θα λαμβάνει υπ' όψη την διαφορά κεφαλαίων-μικρών χαρακτήρων. |
| diacriticSensitiveSearch | Αν η αναζήτηση θα λαμβάνει υπ' όψη την διαφορά τονισμένων χαρακτήρων. |
| regexSearch | Αν θέλουμε το κείμενο της αναζήτησης να είναι regex. |
| hyperlinkDetection | Αν θέλουμε να εντοπίζονται και να εμφανίζονται ως μπλέ κείμενο τα hyperlinks (url, mail κτλ). |



