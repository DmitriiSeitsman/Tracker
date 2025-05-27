import UIKit
import CoreData

final class TrackerSectionDataSource: NSObject, UICollectionViewDataSource {
    private let trackers: [Tracker]

    init(trackers: [Tracker]) {
        self.trackers = trackers
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        trackers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as! TrackerCell
        cell.configure(with: trackers[indexPath.item])
        return cell
    }
}
