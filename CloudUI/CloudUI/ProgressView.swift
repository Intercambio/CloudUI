//
//  ProgressView.swift
//  CloudUI
//
//  Created by Tobias Kräntzer on 22.02.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import UIKit

class ProgressView: UIView {
    
    dynamic var progress: Progress? {
        didSet{
            setNeedsDisplay()
        }
    }
    
    private var context = "ProgressView.Context"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDisplayLink()
        setupObserver()
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupDisplayLink()
        setupObserver()
        backgroundColor = UIColor.clear
    }
    
    private func setupObserver() {
        addObserver(self,
                    forKeyPath: "progress.fractionCompleted",
                    options: [],
                    context: &context)
        addObserver(self,
                    forKeyPath: "progress.isIndeterminate",
                    options: [],
                    context: &context)
    }
    
    private var displayLink: CADisplayLink?
    private func setupDisplayLink() {
        let displayLink = CADisplayLink(target: self, selector: #selector(updateProgress))
        displayLink.add(to: RunLoop.main, forMode: .commonModes)
        self.displayLink = displayLink
    }
    
    @objc private func updateProgress() {
        setNeedsDisplay()
    }
    
    deinit {
        displayLink?.invalidate()
        removeObserver(self, forKeyPath: "progress.fractionCompleted")
        removeObserver(self, forKeyPath: "progress.isIndeterminate")
    }
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        setNeedsDisplay()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard
            context == &self.context
            else {
                super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
                return
        }
        
        DispatchQueue.main.async {
            self.displayLink?.isPaused = !(self.progress?.isIndeterminate ?? false)
            self.setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if progress?.isIndeterminate ?? true {
            StyleKit.drawIndeterminate(frame: bounds,
                                       resizing: .aspectFit,
                                       color: tintColor,
                                       phase: CGFloat(Date.timeIntervalSinceReferenceDate))
        } else {
            StyleKit.drawProgress(frame: bounds,
                                  resizing: .aspectFit,
                                  color: tintColor,
                                  fractionCompleted: CGFloat(progress?.fractionCompleted ?? 0))
        }
    }
}
