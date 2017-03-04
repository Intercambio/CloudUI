//
//  DownloadButton.swift
//  CloudUI
//
//  Created by Tobias Kräntzer on 22.02.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import UIKit

enum DownloadButtonType {
    case download
    case update
}

class DownloadButton: UIControl {
    
    var type: DownloadButtonType = .download {
        didSet {
            updateButton()
        }
    }
    dynamic var progress: Progress? {
        didSet {
            progressView.progress = progress
            progressView.isHidden = progress == nil
            updateButton()
        }
    }
    
    private var context = "DownloadButton.Context"
    
    private let button: UIButton
    private let progressView: ProgressView
    
    override init(frame: CGRect) {
        button = UIButton(type: .custom)
        progressView = ProgressView()
        super.init(frame: frame)
        setup()
        updateButton()
        setupObserver()
    }
    
    required init?(coder aDecoder: NSCoder) {
        button = UIButton(type: .custom)
        progressView = ProgressView()
        super.init(coder: aDecoder)
        setup()
        updateButton()
        setupObserver()
    }
    
    deinit {
        removeObserver(self, forKeyPath: "progress.isCancellable")
        removeObserver(self, forKeyPath: "progress.isCancelled")
    }
    
    private func setupObserver() {
        addObserver(self, forKeyPath: "progress.isCancellable", options: [], context: &context)
        addObserver(self, forKeyPath: "progress.isCancelled", options: [], context: &context)
    }
    
    private func setup() {
        addSubview(progressView)
        progressView.translatesAutoresizingMaskIntoConstraints = true
        progressView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        progressView.frame = bounds
        
        addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = true
        button.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        button.frame = bounds
        
        button.addTarget(self, action: #selector(handleButtonTouchUpInside(sender:)), for: .touchUpInside)
        
        progressView.isHidden = true
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 28, height: 28)
    }
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        updateButton()
    }
    
    func updateButton() {
        if let progress = self.progress {
            if progress.isCancellable == true && progress.isCancelled == false {
                let icon = StyleKit.imageOfCancel(color: tintColor)
                button.setImage(icon, for: .normal)
            } else {
                button.setImage(nil, for: .normal)
            }
        } else {
            switch type {
            case .download:
                let icon = StyleKit.imageOfDownload(color: tintColor)
                button.setImage(icon, for: .normal)
            case .update:
                let icon = StyleKit.imageOfUpdate(color: tintColor)
                button.setImage(icon, for: .normal)
            }
        }
    }
    
    @objc private func handleButtonTouchUpInside(sender _: UIButton) {
        if let progress = self.progress {
            if progress.isCancellable == true && progress.isCancelled == false {
                progress.cancel()
            }
        } else {
            sendActions(for: .touchUpInside)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard
            context == &self.context
        else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        DispatchQueue.main.async {
            self.updateButton()
        }
    }
}
