//
//  WKCalendarYearMonthView.m
//  WKCalendarDemo
//
//  Created by ZhuangXiaowei on 14-9-28.
//  Copyright (c) 2014年 Tyrant. All rights reserved.
//

#import "WKCalendarYearMonthView.h"

@interface WKCalendarYearMonthView()

@property (nonatomic) NSInteger currentYear;
@property (nonatomic) NSInteger currentMonth;

@end

@implementation WKCalendarYearMonthView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithYear:(NSInteger)year month:(NSInteger)month frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _year = year;
        _month = month;
        self.backgroundColor = UIColor.whiteColor;
        [self addMonthPanel];
        [self initGestureRecognizer];
    }
    return self;
}

- (void)setMonth:(NSInteger)month
{
    if (month == _month) return;
    [self viewWithTag:_month].backgroundColor = UIColor.whiteColor;
    [self viewWithTag:month].backgroundColor = grayColor240;
    _month = month;
}

- (void)reloadData
{
    [self setNeedsDisplay];
}

- (void)initGestureRecognizer
{
    UISwipeGestureRecognizer *swipeLeftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture:)];
    swipeLeftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:swipeLeftGesture];
    
    UISwipeGestureRecognizer *swipeRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture:)];
    swipeRightGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:swipeRightGesture];
}

- (void)addMonthPanel
{
    CGFloat x = 0, y = 0;
    CGFloat width = self.frame.size.width / 3, height = self.frame.size.height / 4;
    for (int i = 0; i < 4; ++i)
    {
        for (int j = 0; j < 3; ++j)
        {
            x = j * width;
            y = i * height;
            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            button.frame = (CGRect){x, y, width, height};
            button.tag = i * 3 + j + 1;
            button.layer.borderColor = grayColor240.CGColor;
            button.layer.borderWidth = 1.0f;
            NSString *title = [NSString stringWithFormat:@"%ld月", (long)button.tag];
            [button setTitle:title forState:UIControlStateNormal];
            [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            if (button.tag == self.month)
            {
                button.backgroundColor = grayColor240;
            }
            [self addSubview:button];
        }
    }
}

- (void)buttonClick:(UIButton *)button
{
    self.month = button.tag;
    if (self.delegate && [self.delegate respondsToSelector:@selector(calendarYearMonthView:didSelectedMonth:)])
    {
        [self.delegate calendarYearMonthView:self didSelectedMonth:button.tag];
    }
}

- (void)swipeGesture:(UISwipeGestureRecognizer *)gesture
{
    switch (gesture.direction)
    {
        case UISwipeGestureRecognizerDirectionLeft:
            ++self.year;
            [self animationForSwipe:-1];
            break;
        case UISwipeGestureRecognizerDirectionRight:
            --self.year;
            [self animationForSwipe:1];
            break;
        default:
            break;
    }
}

- (void)animationForSwipe:(NSInteger)sign
{
    CGFloat offset = sign * self.frame.size.width;
    UIView *oldView = [self snapshotViewAfterScreenUpdates:NO];
    oldView.layer.zPosition = 1024;
    [self addSubview:oldView];
    [self setNeedsDisplay];
    if (self.delegate && [((NSObject *)self.delegate) respondsToSelector:@selector(calendarYearMonthView:didYearChange:)])
    {
        [self.delegate calendarYearMonthView:self didYearChange:self.year];
    }
    [UIView animateWithDuration:0.3f animations:^{
        oldView.frame = CGRectOffset(oldView.frame, offset, 0);
    } completion:^(BOOL finished) {
        [oldView removeFromSuperview];
    }];
}

@end
