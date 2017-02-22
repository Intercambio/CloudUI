//
//  DownloadButton.swift
//  CloudUI
//
//  Created by Tobias Kräntzer on 22.02.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import UIKit

class DownloadButton: UIControl {
    
    var progress: Progress? {
        didSet {
            progressView.progress = progress
            if progress == nil {
                button.isHidden = false
                progressView.isHidden = true
            } else {
                button.isHidden = true
                progressView.isHidden = false
            }
        }
    }
    
    private let button: UIButton
    private let progressView: ProgressView
    
    override init(frame: CGRect) {
        button = UIButton(type: .custom)
        progressView = ProgressView()
        super.init(frame: frame)
        setup()
        updateButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        button = UIButton(type: .custom)
        progressView = ProgressView()
        super.init(coder: aDecoder)
        setup()
        updateButton()
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
        
        button.isHidden = false
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
        let icon = StyleKit.imageOfDownload(color: tintColor)
        button.setImage(icon, for: .normal)
    }
    
    @objc private func handleButtonTouchUpInside(sender: UIButton) {
        sendActions(for: .touchUpInside)
    }
}
