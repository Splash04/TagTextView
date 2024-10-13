import Foundation

// ******************************* MARK: - StringProtocol

internal extension StringProtocol {
    
    /// Returns `self` if it is not blank. Otherwise, returns `nil`
    /// - note: Blank means that string contains only whitespaces and newlines
    var nonBlank: Self? {
        isBlank ? nil : self
    }
    
    /// Checks if `self` is blank
    /// - note: Blank means that string contains only whitespaces and newlines
    var isBlank: Bool {
        let trimmed = trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return trimmed.isEmpty
    }
    
    /// Checks if `self` is not blank
    /// - note: Blank means that string contains only whitespaces and newlines
    var isNotBlank: Bool {
        let trimmed = trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return !(trimmed.isEmpty)
    }
    
    /// Checks if `self`has text (is not blank)
    /// - note: Blank means that string contains only whitespaces and newlines
    var hasText: Bool {
        isNotBlank
    }
}


// ******************************* MARK: - String extension

public extension String {
    func sliceMultipleTimes(from: String, to: String) -> [String] {
        components(separatedBy: from).dropFirst().compactMap { sub in
            (sub.range(of: to)?.lowerBound).flatMap { endRange in
                String(sub[sub.startIndex..<endRange])
            }
        }
    }
    
    func findHashtags() -> [(String, NSRange)] {
        var hashtags: [(String, NSRange)] = []
        let regex = try? NSRegularExpression(pattern: "(#[a-zA-Z0-9_\\p{Arabic}\\p{N}]*)", options: [])
        if let matches = regex?.matches(in: self, options: [], range: NSRange(location: 0, length: self.count)) {
            for match in matches {
                let range = NSRange(location: match.range.location, length: match.range.length)
                let tag = NSString(string: self).substring(with: range)
                hashtags.append((tag, range))
            }
        }
        return hashtags
    }
    
    func findMentions() -> [(String, NSRange)] {
        var hashtags: [(String, NSRange)] = []
        let regex = try? NSRegularExpression(pattern: "@[\\p{L}0-9_.]*", options: [])
        if let matches = regex?.matches(in: self, options: [], range: NSRange(location: 0, length: self.count)) {
            for match in matches {
                let range = NSRange(location: match.range.location, length: match.range.length)
                let tag = NSString(string: self).substring(with: range)
                hashtags.append((tag, range))
            }
        }
        return hashtags
    }
}

// ******************************* MARK: - Constants

internal extension String {
    static let empty = String()
    static let space = " "
}
