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
        willSet {
            if let dataSource = self.dataSource {
                dataSource.removeObserver(self)
            }
        }
        didSet {
            if let dataSource = self.dataSource {
                dataSource.addObserver(self)
            }
        }
    }
    
    var isUpdating: Bool = false {
        didSet {
            if isUpdating {
                refreshControl?.beginRefreshing()
            } else {
                refreshControl?.endRefreshing()
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
                cell.accessoryType = .disclosureIndicator
            }
        }
        
        tableViewAdapter?.delegate = self
        tableViewAdapter?.dataSource = dataSource
    
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        if isUpdating {
            refreshControl?.beginRefreshing()
        }
        
        updateTitle()
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
    }
    
    func dataSourceWillChange(_ dataSource: FTDataSource!) {
        updateTitle()
    }
    
    // MARK: - Helper
    
    func updateTitle() {
        self.title = dataSource?.title
    }
}
