//
//  WKCalendarViewCell.m
//  WKCalendarDemo
//
//  Created by ZhuangXiaowei on 14-9-9.
//  Copyright (c) 2014年 Tyrant. All rights reserved.
//

#import "WKCalendarViewCell.h"

@implementation WKCalendarViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initial];
    }
    return self;
}

- (void)initial
{
    self.backgroundColor = UIColor.whiteColor;
    self.lineColor = UIColor.lightGrayColor;
    self.fontSize = 20.0f;
    self.isCurrent = YES;
    self.day = 1;
    self.textColor = UIColor.redColor;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);
    CGPathAddLineToPoint(path, NULL, rect.size.width, 0);
    CGPathAddLineToPoint(path, NULL, rect.size.width, rect.size.height);
    CGPathAddLineToPoint(path, NULL, 0, rect.size.height);
    CGPathAddLineToPoint(path, NULL, 0, 0);
    
    CGContextAddPath(context, path);
    [UIColor.blackColor setStroke];
    CGContextSetLineWidth(context, 1.0f);
    CGContextDrawPath(context, kCGPathStroke);
    CGPathRelease(path);
    
    NSString *text = [NSString stringWithFormat:@"%d", self.day];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    [text drawInRect:rect withAttributes:@{
                                           NSFontAttributeName : [UIFont systemFontOfSize:self.fontSize],
                                           NSParagraphStyleAttributeName : paragraphStyle,
                                           NSForegroundColorAttributeName : self.textColor,
                                           NSStrokeColorAttributeName : UIColor.blackColor,
                                           NSStrokeWidthAttributeName : @(2.0)
                                           }];
}

- (void)addShadowColor:(CGContextRef)context
{
    CGContextSetShadowWithColor(context, (CGSize){10, 10}, 20.0f, UIColor.grayColor.CGColor);
}

@end
