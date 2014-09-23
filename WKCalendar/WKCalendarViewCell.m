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
    self.fontSize = 12.0f;
    self.day = 1;
    self.textColor = UIColor.redColor;
    self.isStroke = NO;
    self.isWorkday = YES;
    self.isSelected = NO;
    self.isCurrentDay = NO;
    self.isCurrentMonthDay = YES;
}

- (void)setIsSelected:(BOOL)isSelected
{
    _isSelected = isSelected;
    
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
//    [self addRect:context size:rect.size];
    
    [self setLinearGradient:context rect:rect];
    
    [self addCirle:context size:rect.size];
    
    [self addText:context rect:rect];
}

- (void)addShadowColor:(CGContextRef)context
{
    CGContextSetShadowWithColor(context, (CGSize){10, 10}, 20.0f, UIColor.grayColor.CGColor);
}

- (void)setLinearGradient:(CGContextRef)context rect:(CGRect)rect
{
    UIColor *startColor = [UIColor colorWithRed:221/255.0f green:221/255.0f blue:221/255.0f alpha:1.0f];
    CGFloat *startColorComponent = (CGFloat *)CGColorGetComponents(startColor.CGColor);
    
    UIColor *endColor = UIColor.grayColor;
    CGFloat *endColorComponent = (CGFloat *)CGColorGetComponents(endColor.CGColor);
    
    CGFloat colorComponent[8] = {
        startColorComponent[0],
        startColorComponent[1],
        startColorComponent[2],
        startColorComponent[3],
        endColorComponent[0],
        endColorComponent[1],
        endColorComponent[2],
        endColorComponent[3]
    };
    
    CGFloat colorIndices[2] = {0.0, 1.0};
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, (const CGFloat *)&colorComponent, (const CGFloat *)&colorIndices, 2);
    CGColorSpaceRelease(colorSpace);
    
    CGPoint startPoint = (CGPoint){rect.size.width / 2, 0};
    CGPoint endPoint = (CGPoint){rect.size.width / 2, rect.size.height};
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    CGGradientRelease(gradient);
}

//边框
- (void)addRect:(CGContextRef)context size:(CGSize)size
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);
    CGPathAddLineToPoint(path, NULL, size.width, 0);
    CGPathAddLineToPoint(path, NULL, size.width, size.height);
    CGPathAddLineToPoint(path, NULL, 0, size.height);
    CGPathAddLineToPoint(path, NULL, 0, 0);
    
    CGContextAddPath(context, path);
    [UIColor.blackColor setStroke];
    CGContextSetLineWidth(context, 1.0f);
    CGContextDrawPath(context, kCGPathStroke);
    CGPathRelease(path);
}

- (void)addCirle:(CGContextRef)context size:(CGSize)size
{
    [[UIColor colorWithRed:125/255 green:125/255 blue:125/255 alpha:0.3f] set];
    if (!self.isWorkday)
    {
        [[UIColor colorWithRed:125/255 green:125/255 blue:125/255 alpha:0.1f] set];
    }
    if (!self.isCurrentMonthDay)
    {
        [[UIColor colorWithRed:245.0f/255.0f green:245.0f/255.0f blue:245.0f/255.0f alpha:1.0f] set];
    }
    if (self.isSelected)
    {
        [UIColor.yellowColor set];
    }
    if (self.isCurrentDay)
    {
        [UIColor.redColor set];
    }
    CGContextFillEllipseInRect(context, (CGRect){0, 0, size});
}

- (void)addText:(CGContextRef)context rect:(CGRect)rect
{
    UIColor *textColor = self.textColor;
    if (self.isSelected)
    {
        textColor = UIColor.blackColor;
    }
    if (self.isCurrentDay)
    {
        textColor = UIColor.whiteColor;
    }
    NSString *text = [NSString stringWithFormat:@"%d", self.day];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSMutableDictionary *attrsDic = [[NSMutableDictionary alloc] init];
    attrsDic[NSFontAttributeName] = [UIFont systemFontOfSize:self.fontSize];
    attrsDic[NSParagraphStyleAttributeName] = paragraphStyle;
    attrsDic[NSForegroundColorAttributeName] = textColor;
    if (self.isStroke)
    {
        attrsDic[NSStrokeColorAttributeName] = self.textColor;
        attrsDic[NSStrokeWidthAttributeName] = @(2.0f);
    }
    rect.origin.y = rect.size.height / 4;
    [text drawInRect:rect withAttributes:attrsDic];
}

@end
