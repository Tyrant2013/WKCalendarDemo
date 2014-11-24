//
//  WKHourView.m
//  WKCalendarDemo
//
//  Created by ZhuangXiaowei on 14-9-25.
//  Copyright (c) 2014年 Tyrant. All rights reserved.
//

#import "WKHourView.h"

@interface WKHourView()

@property (nonatomic, readwrite) UIView *view;
@property (nonatomic, weak) UISegmentedControl *segment;

@end

@implementation WKHourView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialWithSize:frame.size];
    }
    return self;
}

- (void)initialWithSize:(CGSize)size
{
    self.clipsToBounds = YES;
    CGFloat x = 0, y = 0;
    CGFloat segHeight = 40;
    UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:@[@"上午", @"下午"]];
    segment.frame = (CGRect){x, y ,size.width ,segHeight};
    segment.selectedSegmentIndex = 0;
    [segment addTarget:self action:@selector(timeStyleChange:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:segment];
    self.segment = segment;
    
//    y += segHeight;
//    UIView *view = [[UIView alloc] initWithFrame:(CGRect){x, y, width, height - segHeight}];
//    [self addSubview:view];
//    self.view = view;
    
    [self addHourButton];
}

- (void)addHourButton
{
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGFloat segHeight = self.segment.frame.size.height;
    CGFloat x = 0, y = segHeight;
    UIView *view = [[UIView alloc] initWithFrame:(CGRect){x, y, width, height - segHeight}];
    [self addSubview:view];
    self.view = view;
    
    width = self.view.frame.size.width / 3;
    height = self.view.frame.size.height / 4;
    NSInteger beginHour = self.segment.selectedSegmentIndex == 0 ? 1 : 13;
    
    for (int i = 0; i < 4; ++i)
    {
        for (int j = 0; j < 3; ++j)
        {
            x = j * width;
            y = i * height;
            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            button.frame = (CGRect){x, y, width, height};
            button.layer.borderColor = grayColor240.CGColor;
            button.layer.borderWidth = 1.0f;
            button.tag = beginHour + (i * 3 + j);
            [button setTitle:[NSString stringWithFormat:@"%ld", (long)button.tag] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(hourButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:button];
        }
    }
}

- (void)timeStyleChange:(UISegmentedControl *)segment
{
    UIView *oldView = self.view;
    [self addHourButton];
    UIView *newView = self.view;
    
    [self animateExchangeFrom:oldView toView:newView];
}

- (void)animateExchangeFrom:(UIView *)oldView toView:(UIView *)newView
{
    CGRect frame = oldView.frame;
    CGFloat offset = (self.segment.selectedSegmentIndex == 0 ? -1 : 1) * frame.size.width;
    newView.frame = CGRectOffset(frame, offset, 0);
    [UIView animateWithDuration:0.5f animations:^{
        oldView.frame = CGRectOffset(frame, -offset, 0);
        newView.frame = CGRectOffset(newView.frame, -offset, 0);
    } completion:^(BOOL finished) {
        [oldView removeFromSuperview];
    }];
}

- (void)hourButtonClick:(UIButton *)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickHourButton:hour:)])
    {
        [self.delegate didClickHourButton:button hour:button.titleLabel.text];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
