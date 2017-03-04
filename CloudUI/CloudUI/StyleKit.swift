//
//  StyleKit.swift
//  CloudUI
//
//  Created by Tobias Kräntzer on 22.02.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import UIKit

public class StyleKit: NSObject {
    
    //// Drawing Methods
    
    public dynamic class func drawDownload(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 28, height: 28), resizing: ResizingBehavior = .aspectFit, color: UIColor = UIColor(red: 0.252, green: 0.698, blue: 1.000, alpha: 1.000)) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 28, height: 28), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 28, y: resizedFrame.height / 28)
        
        //// Oval Drawing
        let ovalPath = UIBezierPath(ovalIn: CGRect(x: 1, y: 1, width: 26, height: 26))
        color.setStroke()
        ovalPath.lineWidth = 2
        ovalPath.stroke()
        
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 14, y: 7))
        bezierPath.addLine(to: CGPoint(x: 14, y: 20))
        color.setStroke()
        bezierPath.lineWidth = 2
        bezierPath.lineCapStyle = .round
        bezierPath.stroke()
        
        //// Group
        //// Bezier 2 Drawing
        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: 18, y: 15))
        bezier2Path.addLine(to: CGPoint(x: 14, y: 20))
        color.setStroke()
        bezier2Path.lineWidth = 2
        bezier2Path.lineCapStyle = .round
        bezier2Path.stroke()
        
        //// Bezier 3 Drawing
        let bezier3Path = UIBezierPath()
        bezier3Path.move(to: CGPoint(x: 10, y: 15))
        bezier3Path.addLine(to: CGPoint(x: 14, y: 20))
        color.setStroke()
        bezier3Path.lineWidth = 2
        bezier3Path.lineCapStyle = .round
        bezier3Path.stroke()
        
        context.restoreGState()
        
    }
    
    public dynamic class func drawCancel(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 28, height: 28), resizing: ResizingBehavior = .aspectFit, color: UIColor = UIColor(red: 0.252, green: 0.698, blue: 1.000, alpha: 1.000)) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 28, height: 28), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 28, y: resizedFrame.height / 28)
        
        //// Rectangle Drawing
        let rectanglePath = UIBezierPath(roundedRect: CGRect(x: 9, y: 9, width: 10, height: 10), cornerRadius: 2)
        color.setFill()
        rectanglePath.fill()
        
        context.restoreGState()
        
    }
    
    public dynamic class func drawUpdate(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 28, height: 28), resizing: ResizingBehavior = .aspectFit, color: UIColor = UIColor(red: 0.252, green: 0.698, blue: 1.000, alpha: 1.000)) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 28, height: 28), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 28, y: resizedFrame.height / 28)
        
        //// Oval Drawing
        let ovalRect = CGRect(x: 1, y: 1, width: 26, height: 26)
        let ovalPath = UIBezierPath()
        ovalPath.addArc(withCenter: CGPoint(x: ovalRect.midX, y: ovalRect.midY), radius: ovalRect.width / 2, startAngle: 90 * CGFloat.pi / 180, endAngle: 53 * CGFloat.pi / 180, clockwise: true)
        
        color.setStroke()
        ovalPath.lineWidth = 2
        ovalPath.lineCapStyle = .round
        ovalPath.stroke()
        
        //// Group
        context.saveGState()
        context.translateBy(x: 20.29, y: 25.38)
        context.rotate(by: 51.71 * CGFloat.pi / 180)
        
        //// Bezier 2 Drawing
        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: 4, y: -5))
        bezier2Path.addLine(to: CGPoint(x: -0, y: 0))
        color.setStroke()
        bezier2Path.lineWidth = 2
        bezier2Path.lineCapStyle = .round
        bezier2Path.stroke()
        
        //// Bezier 3 Drawing
        let bezier3Path = UIBezierPath()
        bezier3Path.move(to: CGPoint(x: -4, y: -5))
        bezier3Path.addLine(to: CGPoint(x: -0, y: 0))
        color.setStroke()
        bezier3Path.lineWidth = 2
        bezier3Path.lineCapStyle = .round
        bezier3Path.stroke()
        
        context.restoreGState()
        
        context.restoreGState()
        
    }
    
    public dynamic class func drawIndeterminate(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 28, height: 28), resizing: ResizingBehavior = .aspectFit, color: UIColor = UIColor(red: 0.252, green: 0.698, blue: 1.000, alpha: 1.000), phase: CGFloat = 0) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 28, height: 28), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 28, y: resizedFrame.height / 28)
        
        //// Variable Declarations
        let rotation: CGFloat = -1 * 360 * phase
        
        //// Oval Drawing
        context.saveGState()
        context.translateBy(x: 14, y: 14)
        context.rotate(by: -rotation * CGFloat.pi / 180)
        
        let ovalRect = CGRect(x: -13, y: -13, width: 26, height: 26)
        let ovalPath = UIBezierPath()
        ovalPath.addArc(withCenter: CGPoint(x: ovalRect.midX, y: ovalRect.midY), radius: ovalRect.width / 2, startAngle: 40 * CGFloat.pi / 180, endAngle: 0 * CGFloat.pi / 180, clockwise: true)
        
        color.setStroke()
        ovalPath.lineWidth = 2
        ovalPath.lineCapStyle = .round
        ovalPath.stroke()
        
        context.restoreGState()
        
        context.restoreGState()
        
    }
    
    public dynamic class func drawProgress(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 28, height: 28), resizing: ResizingBehavior = .aspectFit, color: UIColor = UIColor(red: 0.252, green: 0.698, blue: 1.000, alpha: 1.000), backgroundColor: UIColor = UIColor(red: 0.898, green: 0.898, blue: 0.918, alpha: 1.000), fractionCompleted: CGFloat = 0.386) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 28, height: 28), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 28, y: resizedFrame.height / 28)
        
        //// Variable Declarations
        let progressAngle: CGFloat = 90 - fractionCompleted * 360
        
        //// Background Drawing
        let backgroundPath = UIBezierPath(ovalIn: CGRect(x: 1, y: 1, width: 26, height: 26))
        backgroundColor.setStroke()
        backgroundPath.lineWidth = 2
        backgroundPath.lineCapStyle = .round
        backgroundPath.stroke()
        
        //// Arc Drawing
        let arcRect = CGRect(x: 1, y: 1, width: 26, height: 26)
        let arcPath = UIBezierPath()
        arcPath.addArc(withCenter: CGPoint(x: arcRect.midX, y: arcRect.midY), radius: arcRect.width / 2, startAngle: -90 * CGFloat.pi / 180, endAngle: -progressAngle * CGFloat.pi / 180, clockwise: true)
        
        color.setStroke()
        arcPath.lineWidth = 2
        arcPath.lineCapStyle = .round
        arcPath.stroke()
        
        context.restoreGState()
        
    }
    
    //// Generated Images
    
    public dynamic class func imageOfDownload(color: UIColor = UIColor(red: 0.252, green: 0.698, blue: 1.000, alpha: 1.000)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 28, height: 28), false, 0)
        StyleKit.drawDownload(color: color)
        
        let imageOfDownload = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return imageOfDownload
    }
    
    public dynamic class func imageOfCancel(color: UIColor = UIColor(red: 0.252, green: 0.698, blue: 1.000, alpha: 1.000)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 28, height: 28), false, 0)
        StyleKit.drawCancel(color: color)
        
        let imageOfCancel = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return imageOfCancel
    }
    
    public dynamic class func imageOfUpdate(color: UIColor = UIColor(red: 0.252, green: 0.698, blue: 1.000, alpha: 1.000)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 28, height: 28), false, 0)
        StyleKit.drawUpdate(color: color)
        
        let imageOfUpdate = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return imageOfUpdate
    }
    
    public dynamic class func imageOfIndeterminate(color: UIColor = UIColor(red: 0.252, green: 0.698, blue: 1.000, alpha: 1.000), phase: CGFloat = 0) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 28, height: 28), false, 0)
        StyleKit.drawIndeterminate(color: color, phase: phase)
        
        let imageOfIndeterminate = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return imageOfIndeterminate
    }
    
    public dynamic class func imageOfProgress(color: UIColor = UIColor(red: 0.252, green: 0.698, blue: 1.000, alpha: 1.000), backgroundColor: UIColor = UIColor(red: 0.898, green: 0.898, blue: 0.918, alpha: 1.000), fractionCompleted: CGFloat = 0.386) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 28, height: 28), false, 0)
        StyleKit.drawProgress(color: color, backgroundColor: backgroundColor, fractionCompleted: fractionCompleted)
        
        let imageOfProgress = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return imageOfProgress
    }
    
    @objc public enum ResizingBehavior: Int {
        case aspectFit /// The content is proportionally resized to fit into the target rectangle.
        case aspectFill /// The content is proportionally resized to completely fill the target rectangle.
        case stretch /// The content is stretched to match the entire target rectangle.
        case center /// The content is centered in the target rectangle, but it is NOT resized.
        
        public func apply(rect: CGRect, target: CGRect) -> CGRect {
            if rect == target || target == CGRect.zero {
                return rect
            }
            
            var scales = CGSize.zero
            scales.width = abs(target.width / rect.width)
            scales.height = abs(target.height / rect.height)
            
            switch self {
            case .aspectFit:
                scales.width = min(scales.width, scales.height)
                scales.height = scales.width
            case .aspectFill:
                scales.width = max(scales.width, scales.height)
                scales.height = scales.width
            case .stretch:
                break
            case .center:
                scales.width = 1
                scales.height = 1
            }
            
            var result = rect.standardized
            result.size.width *= scales.width
            result.size.height *= scales.height
            result.origin.x = target.minX + (target.width - result.width) / 2
            result.origin.y = target.minY + (target.height - result.height) / 2
            return result
        }
    }
}
