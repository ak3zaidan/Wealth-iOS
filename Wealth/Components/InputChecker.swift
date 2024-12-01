import Foundation

class inputChecker {
    private var sendBack: String = ""
    private var badWords = ["fuck", "bitch", "nigger", "nigga", "pussy", "asshole", "slut", "whore"]
    
    func myInputChecker(withString mystring: String, withLowerSize size: Int, withUpperSize sizebig: Int, needsLower: Bool) -> String {
        let checkString = mystring.trimmingCharacters(in: .whitespacesAndNewlines)
        sendBack = ""
        if checkString == "" && needsLower {
            sendBack = "Field cannot be empty"
        } else if badWords.contains(where: { checkString.lowercased().contains($0) }){
            sendBack = "Cannot contain profanity"
        } else {
            if checkString.count < size && needsLower {
                sendBack = "field is too short"
            }
            if checkString.count > sizebig{
                sendBack = "field is too long"
            }
        }
        return sendBack
    }
    func isValidEmail(_ email: String) -> Bool {
        if email.isEmpty {
            return true
        }
        
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}
