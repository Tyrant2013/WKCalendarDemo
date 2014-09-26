//
//  WKHourMinuteView.m
//  WKCalendarDemo
//
//  Created by ZhuangXiaowei on 14-9-25.
//  Copyright (c) 2014年 Tyrant. All rights reserved.
//

#import "WKHourMinuteView.h"

@interface WKHourMinuteView()

@property (nonatomic) NSArray *zeroHourMinuteArray;
@property (nonatomic) NSArray *quarterHourMinuteArray;
@property (nonatomic) NSArray *halfHourMinuteArray;

@property (nonatomic) NSArray *currentArray;
@property (nonatomic) NSArray *nextArray;

@end

@implementation WKHourMinuteView

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
    
    _zeroHourMinuteArray = @[@"07:00", @"08:00", @"09:00",
                             @"10:00", @"11:00", @"12:00",
                             @"13:00", @"14:00", @"15:00",
                             @"16:00", @"17:00", @"18:00",
                             @"19:00", @"07:15", @"07:30"];
    
    _quarterHourMinuteArray = @[@"07:15", @"08:15", @"09:15",
                                @"10:15", @"11:15", @"12:15",
                                @"13:15", @"14:15", @"15:15",
                                @"16:15", @"17:15", @"18:15",
                                @"19:15", @"07:00", @"07:30"
                                ];
    _halfHourMinuteArray = @[@"07:30", @"08:30", @"09:30",
                             @"10:30", @"11:30", @"12:30",
                             @"13:30", @"14:30", @"15:30",
                             @"16:30", @"17:30", @"18:30",
                             @"19:30", @"07:00", @"07:15"];
    
    self.currentArray = self.zeroHourMinuteArray;
    self.nextArray = @[self.quarterHourMinuteArray, self.halfHourMinuteArray];
    
    [self addButton];
}

- (void)addButton
{
    CGFloat x, y;
    CGFloat width = self.frame.size.width / 3;
    CGFloat height = self.frame.size.height / 5;
    
    for (int i = 0; i < 5; ++i)
    {
        for (int j = 0; j < 3; ++j)
        {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            x = j * width;
            y = i * height;
            button.frame = (CGRect){0, 0, width, height};
            CGRect frame = (CGRect){x, y, width, height};
            NSInteger index = i * 3 + j;
            button.tag = index;
            NSString *title = self.currentArray[index];
            [button setTitle:title forState:UIControlStateNormal];
            if (index == 13 && index == 14)
            {
                
            }
            [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
            button.layer.opacity = index == 0 ? 1.0f : 0.0f;
            [UIView animateWithDuration:0.3f animations:^{
                button.frame = frame;
                button.layer.opacity = 1.0f;
            }];
        }
    }
}

- (void)buttonClick:(UIButton *)button
{
    NSInteger index = button.tag;
    if (self.didSelectedTime)
    {
        NSString *time = self.currentArray[index];
        self.didSelectedTime(time);
    }
    if (index == 13 || index == 14)
    {
        index -= 13;
        if (self.currentArray == self.zeroHourMinuteArray)
        {
            self.currentArray = self.nextArray[index];
            self.nextArray = @[self.zeroHourMinuteArray, self.nextArray[1 - index]];
        }
        else if (self.currentArray == self.quarterHourMinuteArray)
        {
            self.currentArray = self.nextArray[index];
            if (index == 0)
            {
                self.nextArray = @[self.quarterHourMinuteArray, self.halfHourMinuteArray];
            }
            else
            {
                self.nextArray = @[self.zeroHourMinuteArray, self.quarterHourMinuteArray];
            }
        }
        else
        {
            self.currentArray = self.nextArray[index];
            self.nextArray = @[self.nextArray[1 - index], self.halfHourMinuteArray];
        }
        for (UIView *view in self.subviews)
        {
            if ([view isKindOfClass:[UIButton class]] && button.tag != view.tag)
            {
                [UIView animateWithDuration:0.25f animations:^{
                    view.layer.opacity = 0.0f;
                } completion:^(BOOL finished) {
                    [view removeFromSuperview];
                }];
            }
        }
        [UIView animateWithDuration:0.3f animations:^{
            button.frame = (CGRect){CGPointZero, button.frame.size};
        } completion:^(BOOL finished) {
            [button removeFromSuperview];
            [self addButton];
        }];
    }
}

@end
