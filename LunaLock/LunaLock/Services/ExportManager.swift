import Foundation
import UIKit

class ExportManager {
    static let shared = ExportManager()

    func exportAsPDF(records: [DayRecord]) -> URL? {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("LunaLock_Export.pdf")
        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792

        UIGraphicsBeginPDFContextToFile(url.path, CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), nil)

        var y: CGFloat = 50

        UIGraphicsBeginPDFPage()
        let titleAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 20)]
        let bodyAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 12)]

        "LunaLock Period Data Export".draw(at: CGPoint(x: 50, y: y), withAttributes: titleAttributes)
        y += 30

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium

        let sortedRecords = records.sorted { $0.date > $1.date }

        for record in sortedRecords {
            if y > pageHeight - 60 {
                UIGraphicsBeginPDFPage()
                y = 50
            }

            let dateString = dateFormatter.string(from: record.date)
            var line = dateString

            if record.isPeriodStart { line += " | Period Start" }
            if record.isPeriodEnd { line += " | Period End" }
            if let flow = record.flowLevel { line += " | Flow: \(flow.label)" }
            if !record.symptoms.isEmpty {
                line += " | Symptoms: \(record.symptoms.map(\.rawValue).joined(separator: ", "))"
            }
            if let mood = record.mood { line += " | Mood: \(mood.rawValue)" }

            line.draw(at: CGPoint(x: 50, y: y), withAttributes: bodyAttributes)
            y += 20
        }

        UIGraphicsEndPDFContext()
        return url
    }

    func exportAsJSON(records: [DayRecord]) -> URL? {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("LunaLock_Export.json")
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted

        guard let data = try? encoder.encode(records) else { return nil }
        try? data.write(to: url)
        return url
    }
}
