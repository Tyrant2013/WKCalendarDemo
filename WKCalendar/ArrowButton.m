//
//  ArrowButton.m
//  WKCalendarDemo
//
//  Created by ZhuangXiaowei on 14-9-22.
//  Copyright (c) 2014年 Tyrant. All rights reserved.
//

#import "ArrowButton.h"

@implementation ArrowButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    NSInteger offset = rect.size.width / 5;
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, rect.size.width / 3 - offset, rect.size.height / 2);
    CGPathAddLineToPoint(path, NULL, rect.size.width / 3 * 2, 0);
    CGPathAddLineToPoint(path, NULL, rect.size.width / 3 * 2, rect.size.height / 3);
    CGPathAddLineToPoint(path, NULL, rect.size.width - offset, rect.size.height / 3);
    CGPathAddLineToPoint(path, NULL, rect.size.width - offset, rect.size.height / 3 * 2);
    CGPathAddLineToPoint(path, NULL, rect.size.width / 3 * 2, rect.size.height / 3 * 2);
    CGPathAddLineToPoint(path, NULL, rect.size.width / 3 * 2, rect.size.height);
    CGPathAddLineToPoint(path, NULL, rect.size.width / 3 - offset, rect.size.height / 2);
    
    CGContextAddPath(context, path);
    
    [UIColor.blackColor setStroke];
    CGContextStrokePath(context);
    
    CGPathRelease(path);
}

@end
