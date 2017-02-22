//
//  ResourceListViewController.swift
//  CloudUI
//
//  Created by Tobias Kraentzer on 24.01.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import UIKit
import Fountain

class ResourceListViewController: UITableViewController, ResourceListView, FTDataSourceObserver {
    
    var presenter: ResourceListPresenter?
    var dataSource: ResourceDataSource? {
        didSet {
            tableViewAdapter?.dataSource = dataSource
            if oldValue !== self.dataSource {
                if let dataSource = oldValue {
                    dataSource.removeObserver(self)
                }
                if let dataSource = self.dataSource {
                    dataSource.addObserver(self)
                }
            }
        }
    }
    
    private var tableViewAdapter: FTTableViewAdapter?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewAdapter = FTTableViewAdapter(tableView: tableView)
        
        tableView.register(ResourceListCell.self, forCellReuseIdentifier: "ResourceListCell")
        tableViewAdapter?.forRowsMatching(nil, useCellWithReuseIdentifier: "ResourceListCell") {
            (view, item, indexPath, dataSource) in
            if  let cell = view as? ResourceListCell,
                let account = item as? ResourceListViewModel {
                cell.textLabel?.text = account.title
                cell.detailTextLabel?.text = account.subtitle
//                cell.accessoryType = .disclosureIndicator
                cell.accessoryView = DownloadButton(frame: CGRect(x: 0, y: 0, width: 28, height: 28))
            }
        }
        
        tableViewAdapter?.delegate = self
        tableViewAdapter?.dataSource = dataSource
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        updateTitle()
        updateFooter()
        updateRefreshControl()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter?.updateIfNeeded()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter?.didSelect(itemAt: indexPath)
    }
    
    // MARK: - Actions
    
    @objc private func refresh() {
        presenter?.update()
    }
    
    // MARK: - FTDataSourceObserver
    
    func dataSourceDidReset(_ dataSource: FTDataSource!) {
        updateTitle()
        updateFooter()
        updateRefreshControl()
    }
    
    func dataSourceDidChange(_ dataSource: FTDataSource!) {
        updateTitle()
        updateFooter()
        updateRefreshControl()
    }
    
    // MARK: - Helper
    
    func updateRefreshControl() {
        if dataSource?.isUpdating ?? false {
            refreshControl?.beginRefreshing()
        } else {
            refreshControl?.endRefreshing()
        }
    }
    
    func updateTitle() {
        self.title = dataSource?.title
    }
    
    func updateFooter(animated: Bool = false) {
        
        let footerLabel = UILabel()
        footerLabel.numberOfLines = 0
        footerLabel.textAlignment = .center
        footerLabel.font = UIFont.preferredFont(forTextStyle: .caption2)
        footerLabel.text = dataSource?.footer
        footerLabel.sizeToFit()
        
        let items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(customView: footerLabel),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        ]
        
        setToolbarItems(items, animated: animated)
    }
}
