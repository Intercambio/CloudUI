//
//  ResourcePreviewViewController.swift
//  CloudUI
//
//  Created by Tobias Kräntzer on 10.02.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import UIKit
import WebKit

class ResourcePreviewViewController: UIViewController, ResourcePreviewView, WKNavigationDelegate {
    
    let presenter: ResourcePreviewPresenter
    init(presenter: ResourcePreviewPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
        self.presenter.view = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var webView: WKWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaPlaybackRequiresUserAction = true
        
        let webView = WKWebView(frame: view.bounds, configuration: configuration)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        view.addSubview(webView)
        self.webView = webView
        
        if let url = resourceURL {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    var resourceURL: URL? {
        didSet {
            if let url = resourceURL {
                let request = URLRequest(url: url)
                webView?.load(request)
            } else {
                webView?.loadHTMLString("", baseURL: nil)
            }
        }
    }
    
    // MARK: - WKNavigationDelegate
    
    func webView(_ webView: WKWebView,
                 didReceive challenge: URLAuthenticationChallenge,
                 completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        presenter.handle(challenge: challenge, completionHandler: completionHandler)
    }
}
