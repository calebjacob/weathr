//
//  UIImage+darkenImageWithColor.m
//  Weather
//
//  Created by Caleb Jacob on 5/27/14.
//  Copyright (c) 2014 Caleb Jacob. All rights reserved.
//

#import "UIImage+darkenWithColor.h"

@implementation UIImage (darkenWithColor)

- (UIImage *)darkenWithColor:(UIColor *)color {
    UIImage *image = self;
    
    UIGraphicsBeginImageContext(image.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, image.size.width, image.size.height);
    
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -area.size.height);
    
    CGContextSaveGState(context);
    CGContextClipToMask(context, area, image.CGImage);
    
    [color set];
    CGContextFillRect(context, area);
    
    CGContextRestoreGState(context);
    
    CGContextSetBlendMode(context, kCGBlendModeMultiply);
    
    CGContextDrawImage(context, area, image.CGImage);
    
    UIImage *colorizedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return colorizedImage;
}

@end
