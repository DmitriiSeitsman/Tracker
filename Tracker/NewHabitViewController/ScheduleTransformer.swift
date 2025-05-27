import Foundation

@objc(ScheduleTransformer)
final class ScheduleTransformer: ValueTransformer {

    override class func allowsReverseTransformation() -> Bool { true }

    override class func transformedValueClass() -> AnyClass {
        NSData.self
    }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let set = value as? Set<Tracker.Weekday> else { return nil }
        let rawValues = set.map { $0.rawValue }

        do {
            return try NSKeyedArchiver.archivedData(
                withRootObject: rawValues,
                requiringSecureCoding: true
            )
        } catch {
            print("❌ Failed to archive schedule: \(error)")
            return nil
        }
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }

        do {
            let rawValues = try NSKeyedUnarchiver.unarchivedObject(
                ofClasses: [NSArray.self, NSNumber.self],
                from: data
            ) as? [Int]

            return Set(rawValues?.compactMap { Tracker.Weekday(rawValue: $0) } ?? [])
        } catch {
            print("❌ Failed to unarchive schedule: \(error)")
            return nil
        }
    }
}
