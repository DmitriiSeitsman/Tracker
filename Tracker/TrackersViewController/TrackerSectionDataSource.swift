import UIKit

final class TrackerSectionDataSource: NSObject, UICollectionViewDataSource {
    private let trackers: [Tracker]
    private let completedTrackers: [TrackerRecord]
    private let currentDate: Date
    private let toggleHandler: (Tracker, Bool) -> Void
    private weak var delegate: TrackerCellDelegate?

    init(
        trackers: [Tracker],
        completedTrackers: [TrackerRecord],
        currentDate: Date,
        toggleHandler: @escaping (Tracker, Bool) -> Void,
        delegate: TrackerCellDelegate
    ) {
        self.trackers = trackers
        self.completedTrackers = completedTrackers
        self.currentDate = currentDate
        self.toggleHandler = toggleHandler
        self.delegate = delegate
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        trackers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let tracker = trackers[indexPath.item]

        let isCompletedToday = completedTrackers.contains {
            $0.id == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: currentDate)
        }

        let completedDays = completedTrackers.filter { $0.id == tracker.id }.count

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.reuseIdentifier,
            for: indexPath
        ) as? TrackerCell else {
            print("Не удалось привести ячейку к TrackerCell на \(indexPath)")
            return UICollectionViewCell()
        }

        cell.configure(with: tracker, completedDays: completedDays, isCompletedToday: isCompletedToday)
        cell.toggleCompletion = toggleHandler
        cell.delegate = delegate

        return cell
    }

}
