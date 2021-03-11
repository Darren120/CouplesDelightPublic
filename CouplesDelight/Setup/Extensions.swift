//
//  Extensions.swift
//  CouplesDelight
//
//  Created by Darren Zou on 10/25/20.
//


import Foundation
import SwiftUI
//                    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: repeatAnimation) { timer in
//                        self.toggle.toggle()
//}
extension View {
    func stacked(at position: Int, in total: Int) -> some View {
        let offset = CGFloat(total - position)
        return self.offset(CGSize(width: 0, height: offset * 10))
    }
}
extension Array where Element: Hashable {
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}
extension StringProtocol {
    var firstUppercased: String { prefix(1).uppercased() + dropFirst() }
    var firstCapitalized: String { prefix(1).capitalized + dropFirst() }
}
extension UIImage {
    var jpegData: Data? { jpegData(compressionQuality: 1) }  // QUALITY min = 0 / max = 1
    var pngData: Data? { pngData() }
}
extension Date {

    var tomorrow: Date? {
        return Calendar.current.date(byAdding: .day, value: 1, to: self)
    }
    var sevenTeenYearsOld: Date? {
        return Calendar.current.date(byAdding: .year, value: -17, to: self)
    }
}
func dismissKeyboard() {
    UIApplication.shared.windows.forEach { $0.endEditing(false) }
}
public struct CustomError: Error {
    let errMsg: String

}

// random float
extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}
//random color
extension UIColor {
    static func random() -> UIColor {
        return UIColor(
           red:   .random(),
           green: .random(),
           blue:  .random(),
           alpha: 1.0
        )
    }
}
// removes the hour and minutes and seconds from date

extension Date {
    /**
        - Returns:
     - Date without hours and seconds, just month, day, year.
     */
    public var removeHours : Date? {
       guard let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: self)) else {
        return nil
       }
       return date
   }
}
extension Collection {
    func subSequences(limitedTo maxLength: Int) -> [SubSequence] {
        precondition(maxLength > 0, "groups must be greater than zero")
        return .init(sequence(state: startIndex) { start in
            guard start < self.endIndex else { return nil }
            let end = self.index(start, offsetBy: maxLength, limitedBy: self.endIndex) ?? self.endIndex
            defer { start = end }
            return self[start..<end]
        })
    }
    var pairs: [SubSequence] { subSequences(limitedTo: 2) }
}
extension Collection {
    func distance(to index: Index) -> Int { distance(from: startIndex, to: index) }
}
//

extension StringProtocol where Self: RangeReplaceableCollection {
    /**
        - Returns: - insert something every x position, and returns the result as string
     */
    mutating func insert<S: StringProtocol>(separator: S, every n: Int) {
        for index in indices.dropFirst().reversed()
            where distance(to: index).isMultiple(of: n) {
            insert(contentsOf: separator, at: index)
        }
    }
    func inserting<S: StringProtocol>(separator: S, every n: Int) -> Self {
        var string = self
        string.insert(separator: separator, every: n)
        return string
    }
}
extension String {

    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }

}

//date formatter

extension Date {
    /**
        - Returns: Date in a MM/DD/YYYY format in string.
     */
  func getCurrentDate() -> String {
    
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "MM/dd/yyyy"

    return dateFormatter.string(from: self)

    }
}
extension String {
    static func randomString(length: Int) -> String {
      let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
}
extension String {
    func condenseWhitespace() -> String {
        let components = self.components(separatedBy: .whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }
}
extension Decodable {
  init(from: Any) throws {
    let data = try JSONSerialization.data(withJSONObject: from)
    let decoder = JSONDecoder()
    self = try decoder.decode(Self.self, from: data)
  }
}

extension String {
    /**
        - Returns: Replaces underscore with spaces
     */
    func removeUnderscore() -> String {
        return self.replacingOccurrences(of: "_", with: " ")
    }
}


extension String {
    /**
        - Returns: Replaces space with underscores
     */
    func addUnderScores() -> String {
        return self.replacingOccurrences(of: " ", with: "_")
    }
}
extension Dictionary {
    public init(keys: [Key], values: [Value]) {
        precondition(keys.count == values.count)

        self.init()

        for (index, key) in keys.enumerated() {
            self[key] = values[index]
        }
    }
}
