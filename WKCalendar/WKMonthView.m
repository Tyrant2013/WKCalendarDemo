//
//  WKMonthView.m
//  WKCalendarDemo
//
//  Created by ZhuangXiaowei on 14-9-23.
//  Copyright (c) 2014年 Tyrant. All rights reserved.
//

#import "WKMonthView.h"

typedef NS_ENUM(NSInteger, WKMonthViewAnimateDirection)
{
    WKMonthViewAnimateDirectionUp,
    WKMonthViewAnimateDirectionDown
};

@interface WKMonthView()

@property (nonatomic) NSInteger headerHeight;

@end

@implementation WKMonthView

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
    self.headerHeight = 60;
    self.clipsToBounds = YES;
    self.backgroundColor = UIColor.whiteColor;
    NSInteger width = self.frame.size.width / 3;
    NSInteger height = (self.frame.size.height - self.headerHeight) / 4;
    
    UIButton *header = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    header.frame = (CGRect){0, 0, self.frame.size.width, self.headerHeight};
    header.tag = -1;
    [header setTitle:[NSString stringWithFormat:@"%d", self.selectedMonth] forState:UIControlStateNormal];
    [header addTarget:self action:@selector(hiddenUpSideWithAnimation) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:header];
    
    for (int i = 0; i < 4; ++i) {
        for (int j = 0; j < 3; ++j){
            NSInteger x = j * width;
            NSInteger y = i * height + self.headerHeight;
            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            button.frame = (CGRect){x, y, width, height};
            button.tag = i * 3 + j + 1;
            [button setTitle:[NSString stringWithFormat:@"%d", button.tag] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            button.layer.borderColor = grayColor240.CGColor;
            button.layer.borderWidth = 1.0f;
            if (button.tag == self.selectedMonth)
            {
                button.backgroundColor = grayColor240;
            }
            [self addSubview:button];
        }
    }
    
    UISwipeGestureRecognizer *swipeUpGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture:)];
    swipeUpGesture.direction = UISwipeGestureRecognizerDirectionUp;
    [self addGestureRecognizer:swipeUpGesture];
    
    UISwipeGestureRecognizer *swipeDownGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture:)];
    swipeDownGesture.direction = UISwipeGestureRecognizerDirectionDown;
    [self addGestureRecognizer:swipeDownGesture];
    
    UISwipeGestureRecognizer *swipeLeftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture:)];
    swipeLeftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:swipeLeftGesture];
    
    UISwipeGestureRecognizer *swipeRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture:)];
    swipeRightGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:swipeRightGesture];
}

- (void)swipeGesture:(UISwipeGestureRecognizer *)gesture
{
    switch (gesture.direction)
    {
        case UISwipeGestureRecognizerDirectionDown:
            [self hiddenFromViewWithMonth:self.selectedMonth];
            break;
        case UISwipeGestureRecognizerDirectionUp:
            [self hiddenUpSideWithAnimation];
            break;
        default:
            
            break;
    }
}

- (void)hiddenUpSideWithAnimation
{
    [self animationWithShow:NO direction:WKMonthViewAnimateDirectionUp month:self.selectedMonth];
}

- (void)buttonClick:(UIButton *)button
{
    [self hiddenFromViewWithMonth:button.tag];
}

- (void)setSelectedMonth:(NSInteger)selectedMonth
{
    _selectedMonth = selectedMonth;
    NSLog(@"month background view");
    [self viewWithTag:selectedMonth].backgroundColor = grayColor240;
    UIButton *button = (UIButton *)[self viewWithTag:-1];
    [button setTitle:[NSString stringWithFormat:@"%d 月", self.selectedMonth] forState:UIControlStateNormal];
}

- (void)showInView:(UIView *)view
{
    [view addSubview:self];
    [view bringSubviewToFront:self];
    [self animationWithShow:YES direction:WKMonthViewAnimateDirectionUp month:self.selectedMonth];
}

- (void)hiddenFromViewWithMonth:(NSInteger)month
{
    [self animationWithShow:NO direction:WKMonthViewAnimateDirectionDown month:month];
}

- (void)animationWithShow:(BOOL)show direction:(WKMonthViewAnimateDirection)direction month:(NSInteger)month
{
    CGRect frame = self.frame;
    if (show)
    {
        self.frame = CGRectOffset(frame, 0, frame.size.height);
        [UIView animateWithDuration:0.25f delay:0 usingSpringWithDamping:0.6f initialSpringVelocity:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.frame = frame;
        } completion:^(BOOL finished) {
            
        }];
    }
    else
    {
        CGFloat offset = direction == WKMonthViewAnimateDirectionDown ? frame.size.height : -(frame.size.height + frame.origin.y);
        [UIView animateWithDuration:0.3f animations:^{
            self.frame = CGRectOffset(self.frame, 0, offset);
        } completion:^(BOOL finished) {
            if (self.didSelectedMonth)
            {
                self.didSelectedMonth(month);
            }
            [self removeFromSuperview];
        }];
    }
}

@end
