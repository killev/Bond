import Foundation

//
//  The MIT License (MIT)
//
//  Copyright (c) 2016 Srdan Rasic (@srdanrasic)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#if os(iOS) || os(tvOS)

import UIKit
import ReactiveKit

extension SignalProtocol where Element: PODiffConvertibleProtocol, Error == Never, Element.PODataSource.POIndex == IndexPath {

    /// Binds the signal of data source elements to the given table view.
    ///
    /// - parameters:
    ///     - collectionView: A collection view that should display the data from the data source.
    ///     - animated: Animate partial or batched updates. Default is `true`.
    ///     - rowAnimation: Row animation for partial or batched updates. Relevant only when `animated` is `true`. Default is `.automatic`.
    ///     - createCell: A closure that creates (dequeues) cell for the given table view and configures it with the given data source at the given index path.
    /// - returns: A disposable object that can terminate the binding. Safe to ignore - the binding will be automatically terminated when the table view is deallocated.
    @discardableResult
    public func po_bind(to collectionView: UICollectionView, createCell: @escaping (Element.PODataSource, Element.PODataSource.POIndex, UICollectionView) -> UICollectionViewCell) -> Disposable  {
        let binder = POCollectionViewBinderDataSource<Element.PODataSource>(createCell)
        return po_bind(to: collectionView, using: binder)
    }

    /// Binds the signal of data source elements to the given table view.
    ///
    /// - parameters:
    ///     - tableView: A table view that should display the data from the data source.
    ///     - binder: A `TableViewBinder` or its subclass that will manage the binding.
    /// - returns: A disposable object that can terminate the binding. Safe to ignore - the binding will be automatically terminated when the table view is deallocated.
    @discardableResult
    public func po_bind(to collectionView: UICollectionView, using binderDataSource: POCollectionViewBinderDataSource<Element.PODataSource>) -> Disposable {
        binderDataSource.collectionView = collectionView

        return bind(to: collectionView, setter: { (_: UICollectionView, diff: Element) in
                binderDataSource.apply(diff: diff.asDiff)
        })
    }
}

extension SignalProtocol where Element: PODiffConvertibleProtocol, Error == Never, Element.PODataSource.POIndex == IndexPath {

    /// Binds the signal of data source elements to the given table view.
    ///
    /// - parameters:
    ///     - tableView: A table view that should display the data from the data source.
    ///     - cellType: A type of the cells that should display the data.
    ///     - animated: Animate partial or batched updates. Default is `true`.
    ///     - rowAnimation: Row animation for partial or batched updates. Relevant only when `animated` is `true`. Default is `.automatic`.
    ///     - configureCell: A closure that configures the cell with the data source item at the respective index path.
    /// - returns: A disposable object that can terminate the binding. Safe to ignore - the binding will be automatically terminated when the table view is deallocated.
    ///
    /// Note that the cell type name will be used as a reusable identifier and the binding will automatically register and dequeue the cell.
    /// If there exists a nib file in the bundle with the same name as the cell type name, the framework will load the cell from the nib file.
    @discardableResult
    public func po_bind<Cell: UICollectionViewCell>(to collectionView: UICollectionView, cellType: Cell.Type, configureCell: @escaping (Cell, Element.PODataSource.POItem) -> Void) -> Disposable {
        let identifier = String(describing: Cell.self)
        let bundle = Bundle(for: Cell.self)
        if let _ = bundle.path(forResource: identifier, ofType: "nib") {
            let nib = UINib(nibName: identifier, bundle: bundle)
            collectionView.register(nib, forCellWithReuseIdentifier: identifier)
        } else {
            collectionView.register(cellType as AnyClass, forCellWithReuseIdentifier: identifier)
        }
        return po_bind(to: collectionView, createCell: { (dataSource, indexPath, collectionView) -> UICollectionViewCell in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! Cell
            let item = dataSource.po_item(at: indexPath)
            configureCell(cell, item)
            return cell
        })
    }

    /// Binds the signal of data source elements to the given table view.
    ///
    /// - parameters:
    ///     - tableView: A table view that should display the data from the data source.
    ///     - cellType: A type of the cells that should display the data. Cell type name will be used as reusable identifier and the binding will automatically dequeue cell.
    ///     - animated: Animate partial or batched updates. Default is `true`.
    ///     - rowAnimation: Row animation for partial or batched updates. Relevant only when `animated` is `true`. Default is `.automatic`.
    ///     - configureCell: A closure that configures the cell with the data source item at the respective index path.
    /// - returns: A disposable object that can terminate the binding. Safe to ignore - the binding will be automatically terminated when the table view is deallocated.
    ///
    /// Note that the cell type name will be used as a reusable identifier and the binding will automatically register and dequeue the cell.
    /// If there exists a nib file in the bundle with the same name as the cell type name, the framework will load the cell from the nib file.
    @discardableResult
    public func po_bind<Cell: UICollectionViewCell>(to collectionView: UICollectionView, cellType: Cell.Type, using binderDataSource: POCollectionViewBinderDataSource<Element.PODataSource>, configureCell: @escaping (Cell, Element.PODataSource.POItem) -> Void) -> Disposable {
        let identifier = String(describing: Cell.self)
        let bundle = Bundle(for: Cell.self)
        if let _ = bundle.path(forResource: identifier, ofType: "nib") {
            let nib = UINib(nibName: identifier, bundle: bundle)
            collectionView.register(nib, forCellWithReuseIdentifier: identifier)
        } else {
            collectionView.register(cellType as AnyClass, forCellWithReuseIdentifier: identifier)
        }
        binderDataSource.createCell = { (dataSource, indexPath, collectionView) -> UICollectionViewCell in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! Cell
            let item = dataSource.po_item(at: indexPath)
            configureCell(cell, item)
            return cell
        }
        return po_bind(to: collectionView, using: binderDataSource)
    }
}

private var POCollectionViewBinderDataSourceAssociationKey = "POCollectionViewBinderDataSource"

open class POCollectionViewBinderDataSource<PODataSource: POQueryableSectionedDataSourceProtocol>: NSObject, UICollectionViewDataSource where PODataSource.POIndex == IndexPath {

    public var createCell: ((PODataSource, PODataSource.POIndex, UICollectionView) -> UICollectionViewCell)?

    var dataSource = PODataSource()

    open weak var collectionView: UICollectionView? = nil {
        didSet {
            guard let collectionView = collectionView else { return }
            associateWithCollectionView(collectionView)
        }
    }

    public override init() {
        createCell = nil
    }

    /// - parameter createCell: A closure that creates cell for a given table view and configures it with the given data source at the given index path.
    public init(_ createCell: @escaping (PODataSource, PODataSource.POIndex, UICollectionView) -> UICollectionViewCell) {
        self.createCell = createCell
    }

    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.po_numberOfSections
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.po_numberOfItems(inSection: section)
    }

    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //guard let changeset = changeset else { fatalError() }

        if let createCell = createCell {
            return createCell(dataSource, indexPath, collectionView)
        } else {
            fatalError("Subclass of CollectionViewBinderDataSource should override and implement collectionView(_:cellForItemAt:) method if they do not initialize `createCell` closure.")
        }
    }

    open func apply(diff: PODiff<PODataSource>) {
        guard let collectionView = collectionView else { return }

        switch diff {
        case .reload(let newDataSource):
            dataSource = newDataSource
            collectionView.reloadData()
        case .update(let newDataSource, let deletes, let inserts, let updates, let moves):
            collectionView.performBatchUpdates({
                
                dataSource = newDataSource
                let insertedSections = inserts.filter { $0.count == 1 }.map { $0[0] }
                if !insertedSections.isEmpty {
                    collectionView.insertSections(IndexSet(insertedSections))
                }
                let insertedItems = inserts.filter { $0.count == 2 }
                if !insertedItems.isEmpty {
                    collectionView.insertItems(at: insertedItems)
                }
                let deletedSections = deletes.filter { $0.count == 1 }.map { $0[0] }
                if !deletedSections.isEmpty {
                    collectionView.deleteSections(IndexSet(deletedSections))
                }
                let deletedItems = deletes.filter { $0.count == 2 }
                if !deletedItems.isEmpty {
                    collectionView.deleteItems(at: deletedItems)
                }
                let updatedItems = updates.filter { $0.count == 2 }
                if !updatedItems.isEmpty {
                    collectionView.reloadItems(at: updatedItems)
                }
                let updatedSections = updates.filter { $0.count == 1 }.map { $0[0] }
                if !updatedSections.isEmpty {
                    collectionView.reloadSections(IndexSet(updatedSections))
                }
                for move in moves {
                    if move.from.count == 2 && move.to.count == 2 {
                        collectionView.moveItem(at: move.from, to: move.to)
                    } else if move.from.count == 1 && move.to.count == 1 {
                        collectionView.moveSection(move.from[0], toSection: move.to[0])
                    }
                }

            }, completion: nil)
            dataSource = newDataSource
            collectionView.reloadData()

        }
        ensureCollectionViewSyncsWithTheDataSource()
    }

    private func ensureCollectionViewSyncsWithTheDataSource() {
        // Hack to immediately apply changes. Solves the crashing issue when performing updates before collection view is on screen.
        _ = collectionView?.numberOfSections
    }

    private func associateWithCollectionView(_ collectionView: UICollectionView) {
        objc_setAssociatedObject(collectionView, &POCollectionViewBinderDataSourceAssociationKey, self, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        if collectionView.reactive.hasProtocolProxy(for: UICollectionViewDataSource.self) {
            collectionView.reactive.dataSource.forwardTo = self
        } else {
            collectionView.dataSource = self
        }
    }
}

#endif
