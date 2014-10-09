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
@property (nonatomic) NSInteger headerHeight;

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
    self.clipsToBounds = YES;
    self.backgroundColor = UIColor.whiteColor;
    self.currentFirstYear = self.selectedYear - 4;
    self.headerHeight = 60;
    UIButton *header = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    header.tag = -1;
    header.frame = (CGRect){0, 0, self.frame.size.width, self.headerHeight};
    [header setTitle:[NSString stringWithFormat:@"%d 年", self.selectedYear] forState:UIControlStateNormal];
    [header addTarget:self action:@selector(hiddenDownWithAnimation) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:header];
    
    [self removeAndAddYearButton];
    
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
    UIView *oldView = [self snapshotViewAfterScreenUpdates:NO];
    [self removeAndAddYearButton];
    [self addSubview:oldView];
    
    oldView.backgroundColor = UIColor.clearColor;
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
    UIView *oldView = [self snapshotViewAfterScreenUpdates:NO];
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
        if ([view isKindOfClass:[UIButton class]] && view.tag != -1)
        {
            [view removeFromSuperview];
        }
    }
    
    NSInteger width = self.frame.size.width / 3;
    NSInteger height = (self.frame.size.height - self.headerHeight) / 3;
    
    for (int i = 0; i < 3; ++i)
    {
        for (int j = 0; j < 3; ++j)
        {
            NSInteger x = j * width;
            NSInteger y = i * height + self.headerHeight;
            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            button.frame = (CGRect){x, y, width, height};
            button.tag = self.currentFirstYear + (i * 3 + j);
            [button setTitle:[NSString stringWithFormat:@"%d", button.tag] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            button.layer.borderColor = grayColor240.CGColor;
            button.layer.borderWidth = 1.0f;
            if (button.tag == self.selectedYear)
            {
                button.backgroundColor = grayColor240;
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
    [self viewWithTag:selectedYear].backgroundColor = grayColor240;
}

- (void)showInView:(UIView *)view
{
    [view addSubview:self];
    [view bringSubviewToFront:self];

    [self animationWithShow:YES direction:WKYearViewAnimateDirectionDown year:self.selectedYear];
}

- (void)hiddenFromViewWithYear:(NSInteger)year
{
    [self animationWithShow:NO direction:WKYearViewAnimateDirectionUp year:year];
}

- (void)animationWithShow:(BOOL)show direction:(WKYearViewAnimateDirection)direction year:(NSInteger)year
{
    CGRect frame = self.frame;
    if (show)
    {
        self.frame = CGRectOffset(frame, 0, -(frame.size.height + frame.origin.y));
        [UIView animateWithDuration:0.25f delay:0 usingSpringWithDamping:0.6f initialSpringVelocity:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.frame = frame;
        } completion:^(BOOL finished) {
            
        }];
    }
    else
    {
        CGFloat offset = direction == WKYearViewAnimateDirectionDown ? frame.size.height : -(frame.size.height + frame.origin.y);
        [UIView animateWithDuration:0.3f animations:^{
            self.frame = CGRectOffset(self.frame, 0, offset);
        } completion:^(BOOL finished) {
            if (self.didSelectedWithYear)
            {
                self.didSelectedWithYear(year);
            }
            [self removeFromSuperview];
        }];
    }
}

@end
