//
//  AccountListViewController.swift
//  CloudUI
//
//  Created by Tobias Kraentzer on 24.01.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import UIKit
import Fountain

class AccountListViewController: UITableViewController, AccountListView {
    
    var presenter: AccountListPresenter?
    var dataSource: FTDataSource?
    
    private var tableViewAdapter: FTTableViewAdapter?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewAdapter = FTTableViewAdapter(tableView: tableView)
        
        tableView.register(AccountListCell.self, forCellReuseIdentifier: "AccountListCell")
        tableViewAdapter?.forRowsMatching(nil, useCellWithReuseIdentifier: "AccountListCell") {
            (view, item, indexPath, dataSource) in
            if  let cell = view as? AccountListCell,
                let account = item as? AccountListViewModel {
                cell.textLabel?.text = account.title
                cell.detailTextLabel?.text = account.subtitle
                cell.accessoryType = .detailDisclosureButton
            }
        }
        
        tableViewAdapter?.delegate = self
        tableViewAdapter?.dataSource = dataSource
        
        navigationItem.title = "Accounts"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAccount))
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter?.didSelect(itemAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        presenter?.didTapAccessoryButton(forItemAt: indexPath)
    }
    
    @objc private func addAccount() {
        presenter?.addAccount()
    }
}
