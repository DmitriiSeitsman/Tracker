import UIKit

enum TrackerLayoutFactory {
    static func createLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { sectionIndex, _ in
            switch sectionIndex {
            case 0:
                return makeEmojiSection(title: "Emoji")
            case 1:
                return makeColorSection(title: "Цвет")
            default:
                return nil
            }
        }
    }

    private static func makeEmojiSection(title: String) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(52),
            heightDimension: .absolute(52)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8)

        let horizontalGroupSize = NSCollectionLayoutSize(
            widthDimension: .estimated(52 * 6 + 8 * 5),
            heightDimension: .absolute(52)
        )
        let horizontalGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: horizontalGroupSize,
            subitem: item,
            count: 6
        )
        horizontalGroup.interItemSpacing = .fixed(8)

        let verticalGroupSize = NSCollectionLayoutSize(
            widthDimension: .estimated(52 * 6 + 8 * 5),
            heightDimension: .absolute((52 * 3) + (8 * 2))
        )
        let verticalGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: verticalGroupSize,
            subitems: [horizontalGroup, horizontalGroup, horizontalGroup]
        )
        verticalGroup.interItemSpacing = .fixed(8)

        let section = NSCollectionLayoutSection(group: verticalGroup)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 16)
        section.boundarySupplementaryItems = [makeHeaderItem()]

        return section
    }

    private static func makeColorSection(title: String) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(52),
            heightDimension: .absolute(52)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(120)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: item,
            count: 6
        )
        group.interItemSpacing = .fixed(8)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 16)

        section.boundarySupplementaryItems = [makeHeaderItem()]

        return section
    }

    private static func makeHeaderItem() -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(28)
        )
        return NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
    }
}

