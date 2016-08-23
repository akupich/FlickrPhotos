//
//  RoundedViewWithBorder.swift
//  FlickrPhotoList
//
//  Created by Andriy Kupich on 8/22/16.
//  Copyright © 2016 Remit. All rights reserved.
//

import UIKit

class RoundedViewWithBorder: UIView {
    var image: UIImage? = nil {
        didSet {
            setNeedsDisplay()
        }
    }
    
    //** According to requirements it was done using CoreGraphics, 
    //   but exist much easier way to do it without CoreGraphics
    override func drawRect(rect: CGRect) {
        // set the background image
        image?.drawInRect(self.bounds)
        
        // constants
        let outlineStrokeWidth:CGFloat = Constants.fpImageBorderWidth
        let outlineCornerRadius:CGFloat = Constants.fpImageCornerRadius
        
        let borderColor = Constants.fpImageBorderColor.CGColor
        
        // get the context
        let context = UIGraphicsGetCurrentContext()
        
        // inset the rect because half of the stroke applied to this path will be on the outside
        let insetRect = CGRectInset(rect, outlineStrokeWidth/2.0, outlineStrokeWidth/2.0)
        
        // get our rounded rect as a path
        let path = createRoundedCornerPath(insetRect, cornerRadius: outlineCornerRadius)
        
        // round corners of view
        let bezierPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: outlineCornerRadius)
        let mask = CAShapeLayer()
        mask.path = bezierPath.CGPath
        self.layer.mask = mask
        
        // merge two pathes
        CGPathAddPath(path, nil, bezierPath.CGPath)
        
        // add the path to the context
        CGContextAddPath(context, path)
        
        // set the stroke params
        CGContextSetStrokeColorWithColor(context, borderColor)
        CGContextSetLineWidth(context, outlineStrokeWidth)
        
        // draw the path
        CGContextDrawPath(context, .Stroke)
    }
    
    func createRoundedCornerPath(rect:CGRect, cornerRadius:CGFloat) -> CGMutablePathRef {
        // create a mutable path
        let path = CGPathCreateMutable();
        
        // get the 4 corners of the rect
        let topLeft = CGPointMake(rect.origin.x, rect.origin.y)
        let topRight = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y)
        let bottomRight = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height)
        let bottomLeft = CGPointMake(rect.origin.x, rect.origin.y + rect.size.height)
        
        // move to top left
        CGPathMoveToPoint(path, nil, topLeft.x + cornerRadius, topLeft.y)
        
        // add top line
        CGPathAddLineToPoint(path, nil, topRight.x - cornerRadius, topRight.y)
        
        // add top right curve
        CGPathAddQuadCurveToPoint(path, nil, topRight.x, topRight.y, topRight.x, topRight.y + cornerRadius)
        
        // add right line
        CGPathAddLineToPoint(path, nil, bottomRight.x, bottomRight.y - cornerRadius)
        
        // add bottom right curve
        CGPathAddQuadCurveToPoint(path, nil, bottomRight.x, bottomRight.y, bottomRight.x - cornerRadius, bottomRight.y)
        
        // add bottom line
        CGPathAddLineToPoint(path, nil, bottomLeft.x + cornerRadius, bottomLeft.y)
        
        // add bottom left curve
        CGPathAddQuadCurveToPoint(path, nil, bottomLeft.x, bottomLeft.y, bottomLeft.x, bottomLeft.y - cornerRadius)
        
        // add left line
        CGPathAddLineToPoint(path, nil, topLeft.x, topLeft.y + cornerRadius)
        
        // add top left curve
        CGPathAddQuadCurveToPoint(path, nil, topLeft.x, topLeft.y, topLeft.x + cornerRadius, topLeft.y)
        
        // return the path
        return path
    }
}