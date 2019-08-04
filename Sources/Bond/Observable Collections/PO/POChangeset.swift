//
//  POChangeset.swift
//  Bond-iOS
//
//  Created by Peter Ovchinnikov on 7/31/19.
//  Copyright © 2019 Swift Bond. All rights reserved.
//

import UIKit
import ReactiveKit

//public protocol POUnorderedDiffOperationsProtocol {
//    associatedtype Index
//    var deletes: [Index] { get }
//    var inserts: [Index] { get }
//
//    var updates: [Index] { get }
//
//    /// Indices of moved elements where `from` is an index in the source collection
//    /// index space, while `to` is an index in the final collection index space.
//    var moves: [(from: Index, to: Index)] { get }
//}

//struct POUnorderedDiffOperations<Index>: POUnorderedDiffOperationsProtocol {
//
//    let deletes: [Index]
//    let inserts: [Index]
//    let updates: [Index]
//
//    /// Indices of moved elements where `from` is an index in the source collection
//    /// index space, while `to` is an index in the final collection index space.
//    let moves: [(from: Index, to: Index)]
//}

public enum PODiff<PODataSource: POQueryableSectionedDataSourceProtocol> {
    public typealias POIndex = PODataSource.POIndex

    case reload(dataSource: PODataSource)
    case update(dataSource: PODataSource, deletes: [POIndex], inserts: [POIndex], updates: [POIndex], moves: [(from: POIndex, to: POIndex)])
}



public protocol POQueryableSectionedDataSourceProtocol: Instantiatable {
    associatedtype POItem
    associatedtype POIndex: RandomAccessCollection
    var po_numberOfSections: Int { get }
    func po_numberOfItems(inSection section: Int) -> Int
    func po_item(at indexPath: POIndex) -> POItem
}

public protocol PODiffConvertibleProtocol: Instantiatable {
    associatedtype PODataSource: POQueryableSectionedDataSourceProtocol
    var asDiff: PODiff<PODataSource>  { get }
    init(dataSource: PODataSource)
}

extension PODiff: PODiffConvertibleProtocol {
    public var asDiff: PODiff<PODataSource>  { return self }
    public init() {
        self = .reload(dataSource: PODataSource())
    }
    public init(dataSource: PODataSource) {
        self = .reload(dataSource: dataSource)
    }
}

extension Array: POQueryableSectionedDataSourceProtocol {
    public var po_numberOfSections: Int {
        return 1
    }

    public func po_numberOfItems(inSection section: Int) -> Int {
        assert(section == 0, "Array ")
        return count
    }

    public func po_item(at indexPath: IndexPath) -> Element {
        assert(indexPath.section == 0)
        return item(at: indexPath.row)
    }

    public typealias POIndex = IndexPath
    public typealias POItem = Element

}

extension Array : PODiffConvertibleProtocol {
    public var asDiff: PODiff<Array>  { return .reload(dataSource: self) }
    public init(dataSource: Array) {
        self.init(dataSource)
    }
}

public typealias POMutableObservableArray<Element> = Property<PODiff<[Element]>>

extension Property where ProperyElement: PODiffConvertibleProtocol {
    convenience init(_ dataSource: ProperyElement.PODataSource) {
        self.init(ProperyElement(dataSource: dataSource))
    }
//    convenience init() {
//        self.init(ProperyElement())
//    }

    func insert(item: Value.PODataSource.POItem, at indexPath: IndexPath) {
    }
}






func simpleSSS(){
    let tes = POMutableObservableArray<Int>([])
    let tes1 = Property<OrderedCollectionChangeset<[Int]>>([])


    let tree =  MutableObservableTree<TreeArray<String>>()
    tree.batchUpdate{ tree in

    }

    

    var sss = [1,2,3,4,5,6]
    var sss1 = [1,2,3,4,5,7]


   

    tes1.insert(0, at: 0)


}

//class POCollectionViewDataSource<DataSource: POQueryableSectionedDataSourceProtocol>: NSObject, UICollectionViewDataSource {
//
//    var dataSource = DataSource()
//
//
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return dataSource.numberOfSections
//    }
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return dataSource.numberOfItems(inSection: section)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//         
//    }
//
//    
//}
