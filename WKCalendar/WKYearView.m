//
//  WKYearView.m
//  WKCalendarDemo
//
//  Created by ZhuangXiaowei on 14-9-23.
//  Copyright (c) 2014年 Tyrant. All rights reserved.
//

#import "WKYearView.h"

typedef NS_ENUM(NSInteger, WKYearViewAnimateDirection)
{
    WKYearViewAnimateDirectionUp,
    WKYearViewAnimateDirectionDown
};

@interface WKYearView()

@property (nonatomic) NSInteger currentFirstYear;

@end

@implementation WKYearView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initial];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame year:(NSInteger)year
{
    self = [super initWithFrame:frame];
    if (self){
        _selectedYear = year;
        [self initial];
    }
    return self;
}

- (void)initial
{
    self.backgroundColor = UIColor.whiteColor;
    self.currentFirstYear = self.selectedYear - 4;
    [self removeAndAddYearButton];
//    NSInteger width = self.frame.size.width / 3;
//    NSInteger height = self.frame.size.height / 3;
//    
//    for (int i = 0; i < 3; ++i) {
//        for (int j = 0; j < 3; ++j){
//            NSInteger x = j * width;
//            NSInteger y = i * height;
//            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//            button.frame = (CGRect){x, y, width, height};
//            button.tag = self.selectedYear - (4 - (i * 3 + j));
//            if (i == 0 && j == 0) self.currentFirstYear = button.tag;
//            [button setTitle:[NSString stringWithFormat:@"%d", button.tag] forState:UIControlStateNormal];
//            [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
//            button.layer.borderColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f].CGColor;
//            button.layer.borderWidth = 1.0f;
//            if (button.tag == self.selectedYear)
//            {
//                button.backgroundColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
//            }
//            [self addSubview:button];
//        }
//    }
    
    UISwipeGestureRecognizer *swipeLeftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture:)];
    swipeLeftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:swipeLeftGesture];
    
    UISwipeGestureRecognizer *swipeRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture:)];
    swipeRightGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:swipeRightGesture];
    
    UISwipeGestureRecognizer *swipeDownGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture:)];
    swipeDownGesture.direction = UISwipeGestureRecognizerDirectionDown;
    [self addGestureRecognizer:swipeDownGesture];
    
    UISwipeGestureRecognizer *swipeUpGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture:)];
    swipeUpGesture.direction = UISwipeGestureRecognizerDirectionUp;
    [self addGestureRecognizer:swipeUpGesture];
}

- (void)swipeGesture:(UISwipeGestureRecognizer *)gesture
{
    switch (gesture.direction)
    {
        case UISwipeGestureRecognizerDirectionDown:
            [self hiddenDownWithAnimation];
            break;
        case UISwipeGestureRecognizerDirectionLeft:
            [self moreNextYearForSelect];
            break;
        case UISwipeGestureRecognizerDirectionRight:
            [self morePreYearForSelect];
            break;
        case UISwipeGestureRecognizerDirectionUp:
            [self hiddenFromViewWithYear:self.selectedYear];
            break;
    }
}

- (void)morePreYearForSelect
{
    self.currentFirstYear -= 9;
    UIView *oldView = [self snapshotViewAfterScreenUpdates:YES];
    [self removeAndAddYearButton];
    [self addSubview:oldView];
    oldView.layer.zPosition = 1024;
    [UIView animateWithDuration:0.25f animations:^{
        oldView.frame = CGRectOffset(oldView.frame, oldView.frame.size.width, 0);
    } completion:^(BOOL finished) {
        [oldView removeFromSuperview];
    }];
    
}

- (void)moreNextYearForSelect
{
    self.currentFirstYear += 9;
    UIView *oldView = [self snapshotViewAfterScreenUpdates:YES];
    [self removeAndAddYearButton];
    [self addSubview:oldView];
    oldView.layer.zPosition = 1024;
    [UIView animateWithDuration:0.25f animations:^{
        oldView.frame = CGRectOffset(oldView.frame, -oldView.frame.size.width, 0);
    } completion:^(BOOL finished) {
        [oldView removeFromSuperview];
    }];
}

- (void)removeAndAddYearButton
{
    for (UIView *view in self.subviews)
    {
        if ([view isKindOfClass:[UIButton class]])
        {
            [view removeFromSuperview];
        }
    }
    
    NSInteger width = self.frame.size.width / 3;
    NSInteger height = self.frame.size.height / 3;
    
    for (int i = 0; i < 3; ++i) {
        for (int j = 0; j < 3; ++j){
            NSInteger x = j * width;
            NSInteger y = i * height;
            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            button.frame = (CGRect){x, y, width, height};
            button.tag = self.currentFirstYear + (i * 3 + j);
            [button setTitle:[NSString stringWithFormat:@"%d", button.tag] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            button.layer.borderColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f].CGColor;
            button.layer.borderWidth = 1.0f;
            if (button.tag == self.selectedYear)
            {
                button.backgroundColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
            }
            [self addSubview:button];
        }
    }
}

- (void)hiddenDownWithAnimation
{
    [self animationWithShow:NO direction:WKYearViewAnimateDirectionDown year:self.selectedYear];
}

- (void)buttonClick:(UIButton *)button
{
    [self hiddenFromViewWithYear:button.tag];
}

- (void)setSelectedYear:(NSInteger)selectedYear
{
    _selectedYear = selectedYear;
    [self viewWithTag:selectedYear].backgroundColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
}

- (void)showInView:(UIView *)view
{
    [view addSubview:self];
    [self addbackView:view.bounds];
    [view bringSubviewToFront:self];

    [self animationWithShow:YES direction:WKYearViewAnimateDirectionDown year:self.selectedYear];
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

- (void)hiddenFromViewWithYear:(NSInteger)year
{
    [self animationWithShow:NO direction:WKYearViewAnimateDirectionUp year:year];
}

- (void)animationWithShow:(BOOL)show direction:(WKYearViewAnimateDirection)direction year:(NSInteger)year
{
    CGRect frame = self.frame;
    UIView *backView = [self.superview viewWithTag:2225];
    if (show)
    {
        self.frame = CGRectOffset(frame, 0, -(frame.size.height + frame.origin.y));
        backView.frame = CGRectOffset(backView.frame, 0, backView.frame.size.height);
        [UIView animateWithDuration:0.25f delay:0 usingSpringWithDamping:0.6f initialSpringVelocity:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.frame = frame;
            backView.frame = CGRectOffset(backView.frame, 0, -backView.frame.size.height);
        } completion:^(BOOL finished) {
            
        }];
    }
    else
    {
        CGFloat offset = direction == WKYearViewAnimateDirectionDown ? frame.size.height : -(frame.size.height + frame.origin.y);
        CGFloat backOffset = (direction == WKYearViewAnimateDirectionDown ? -1 : 1) * backView.frame.size.height;
        [UIView animateWithDuration:0.3f animations:^{
            self.frame = CGRectOffset(self.frame, 0, offset);
            backView.frame = CGRectOffset(backView.frame, 0, backOffset);
        } completion:^(BOOL finished) {
            if (self.didSelectedWithYear)
            {
                self.didSelectedWithYear(year);
            }
            [self removeFromSuperview];
            [backView removeFromSuperview];
        }];
    }
}

@end
