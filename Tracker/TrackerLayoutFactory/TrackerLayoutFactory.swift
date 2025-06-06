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

        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

        let horizontalGroupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(52)
        )
        let horizontalGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: horizontalGroupSize,
            subitem: item,
            count: 6
        )
        horizontalGroup.interItemSpacing = .fixed(5)

        let verticalGroupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute((52 * 3) + (8 * 2))
        )

        let verticalGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: verticalGroupSize,
            subitems: [horizontalGroup, horizontalGroup, horizontalGroup]
        )
        verticalGroup.interItemSpacing = .fixed(0)

        let section = NSCollectionLayoutSection(group: verticalGroup)
        section.orthogonalScrollingBehavior = .none
        section.contentInsets = NSDirectionalEdgeInsets(top: 24, leading: 6, bottom: 24, trailing: 6)
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
        group.interItemSpacing = .fixed(5)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 0
        
        section.contentInsets = NSDirectionalEdgeInsets(top: 24, leading: 6, bottom: 24, trailing: 6)

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

