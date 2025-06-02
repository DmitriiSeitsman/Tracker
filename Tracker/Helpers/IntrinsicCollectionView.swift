import UIKit

final class IntrinsicCollectionView: UICollectionView {
    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return collectionViewLayout.collectionViewContentSize
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        invalidateIntrinsicContentSize()
    }
}
