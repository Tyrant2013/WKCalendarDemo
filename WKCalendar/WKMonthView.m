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
    self.backgroundColor = UIColor.whiteColor;
    NSInteger width = self.frame.size.width / 3;
    NSInteger height = self.frame.size.height / 4;
    
    for (int i = 0; i < 4; ++i) {
        for (int j = 0; j < 3; ++j){
            NSInteger x = j * width;
            NSInteger y = i * height;
            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            button.frame = (CGRect){x, y, width, height};
            button.tag = i * 3 + j + 1;
            [button setTitle:[NSString stringWithFormat:@"%d", button.tag] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            button.layer.borderColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f].CGColor;
            button.layer.borderWidth = 1.0f;
            if (button.tag == self.selectedMonth)
            {
                button.backgroundColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
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
    [self viewWithTag:selectedMonth].backgroundColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
}

- (void)showInView:(UIView *)view
{
    [view addSubview:self];
    [self addbackView:view.bounds];
    [view bringSubviewToFront:self];
    [self animationWithShow:YES direction:WKMonthViewAnimateDirectionUp month:self.selectedMonth];
}

- (void)addbackView:(CGRect)rect
{
    UIView *backView = [[UIView alloc] initWithFrame:rect];
    backView.layer.cornerRadius = self.superview.layer.cornerRadius;
    backView.backgroundColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
    backView.tag = 2225;
    backView.layer.opacity = 0.3f;
    [self.superview addSubview:backView];
    
    UISwipeGestureRecognizer *up = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(backViewRecognizer:)];
    up.direction = UISwipeGestureRecognizerDirectionUp;
    [backView addGestureRecognizer:up];
    
    UISwipeGestureRecognizer *down = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(backViewRecognizer:)];
    down.direction = UISwipeGestureRecognizerDirectionDown;
    [backView addGestureRecognizer:down];
    
    UISwipeGestureRecognizer *left = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(backViewRecognizer:)];
    left.direction = UISwipeGestureRecognizerDirectionLeft;
    [backView addGestureRecognizer:left];
    
    UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(backViewRecognizer:)];
    right.direction = UISwipeGestureRecognizerDirectionRight;
    [backView addGestureRecognizer:right];
}

- (void)backViewRecognizer:(UISwipeGestureRecognizer *)gesture
{
    
}

- (void)hiddenFromViewWithMonth:(NSInteger)month
{
    [self animationWithShow:NO direction:WKMonthViewAnimateDirectionDown month:month];
}

- (void)animationWithShow:(BOOL)show direction:(WKMonthViewAnimateDirection)direction month:(NSInteger)month
{
    CGRect frame = self.frame;
    UIView *backView = [self.superview viewWithTag:2225];
    if (show)
    {
        self.frame = CGRectOffset(frame, 0, frame.size.height);
        backView.frame = CGRectOffset(backView.frame, 0, -backView.frame.size.height);
        [UIView animateWithDuration:0.25f delay:0 usingSpringWithDamping:0.6f initialSpringVelocity:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.frame = frame;
            backView.frame = CGRectOffset(backView.frame, 0, backView.frame.size.height);
        } completion:^(BOOL finished) {
            
        }];
    }
    else
    {
        CGFloat offset = direction == WKMonthViewAnimateDirectionDown ? frame.size.height : -(frame.size.height + frame.origin.y);
        CGFloat backOffset = (direction == WKMonthViewAnimateDirectionDown ? -1 : 1) * backView.frame.size.height;
        [UIView animateWithDuration:0.3f animations:^{
            self.frame = CGRectOffset(self.frame, 0, offset);
            backView.frame = CGRectOffset(backView.frame, 0, backOffset);
        } completion:^(BOOL finished) {
            if (self.didSelectedMonth)
            {
                self.didSelectedMonth(month);
            }
            [self removeFromSuperview];
            [backView removeFromSuperview];
        }];
    }
}

@end
