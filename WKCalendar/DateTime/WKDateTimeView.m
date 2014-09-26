//
//  WKDateTimeView.m
//  WKCalendarDemo
//
//  Created by ZhuangXiaowei on 14-9-25.
//  Copyright (c) 2014年 Tyrant. All rights reserved.
//

#import "WKDateTimeView.h"
#import "WKDateTimeHeaderView.h"
#import "WKHourView.h"
#import "WKMinuteView.h"
#import "WKHourMinuteView.h"

#define HOUR_MINUTE_TAG 1001

@interface WKDateTimeView()<
  WKDateTimeHeaderViewDelegate,
  WKHourViewDelegate,
  WKMinuteViewDelegate
>

@property (nonatomic) WKDateTimeHeaderView *header;

@end

@implementation WKDateTimeView

- (id)initWithFrame:(CGRect)frame
{
//    frame.size.width = 300;
//    frame.size.height = 280;
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
    self.clipsToBounds = YES;
    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.cornerRadius = 15.0f;
    
    CGFloat headerHeight = 40;
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGFloat x = 0;
    CGFloat y = 0;
    _header = [[WKDateTimeHeaderView alloc] initWithFrame:(CGRect){x, y, width, headerHeight}];
    self.header.delegate = self;
    self.header.layer.zPosition = 100;
    self.header.backgroundColor = UIColor.whiteColor;
    [self addSubview:self.header];
    
    y += headerHeight;
    WKHourMinuteView *hourMinuteView = [[WKHourMinuteView alloc] initWithFrame:(CGRect){x, y, width, height - headerHeight}];
    hourMinuteView.tag = HOUR_MINUTE_TAG;
    hourMinuteView.didSelectedTime = ^(NSString *time){
        NSArray *arr = [time componentsSeparatedByString:@":"];
        self.header.hour = arr[0];
        self.header.minute = arr[1];
    };
    [self addSubview:hourMinuteView];
    
}

- (void)setTime:(NSString *)time
{
    _time = time;
    NSArray *arr = [time componentsSeparatedByString:@":"];
    self.header.hour = arr[0];
    self.header.minute = arr[1];
}

#pragma mark - WKDateTimeHeaderView delegate

- (void)didButtonClick:(UIButton *)button
{
    //button.tag--->0:小时,1分钟

    CGFloat headerHeight = 40;
    CGFloat height = self.frame.size.height;
    CGFloat width = self.frame.size.width;
    CGFloat x = 0;
    CGFloat y = 0;
    y += headerHeight;
    CGRect frame = (CGRect){x, y, width, height - headerHeight};
    UIView *oldView = [self viewWithTag:110];
    if (!oldView)
    {
        oldView = [self viewWithTag:HOUR_MINUTE_TAG];
    }
    UIView *view;

    switch (button.tag)
    {
        case 0:
        {
            WKHourView *hourView = [[WKHourView alloc] initWithFrame:frame];
            hourView.delegate = self;
            view = hourView;
        }
            break;
        case 1:
        {
            WKMinuteView *minuteView = [[WKMinuteView alloc] initWithFrame:frame];
            minuteView.delegate = self;
            view = minuteView;
        }
            break;
    }
    view.tag = 110;
    [self addSubview:view];
    view.layer.zPosition = 90;
    view.frame = CGRectOffset(view.frame, 0, -view.frame.size.height);
    [UIView animateWithDuration:0.5f animations:^{
        oldView.frame = CGRectOffset(oldView.frame, 0, oldView.frame.size.height);
        view.frame = CGRectOffset(view.frame, 0, view.frame.size.height);
    } completion:^(BOOL finished) {
        [oldView removeFromSuperview];
    }];
}

- (void)didFunctionButtonClick:(UIButton *)button withTime:(NSString *)time
{
    [UIView animateWithDuration:0.25f animations:^{
        self.frame = CGRectOffset(self.frame, 0, self.frame.size.height);
    } completion:^(BOOL finished) {
        if (self.didSelectedTime && time)
        {
            self.didSelectedTime(time);
        }
        [self removeFromSuperview];
    }];
}

#pragma mark - WKHourViewDelegate

- (void)didClickHourButton:(UIButton *)button hour:(NSString *)hour
{
    self.header.hour = hour;
}

#pragma mark - WKMinuteViewDelegate

- (void)didMinuteButtonClick:(UIButton *)button withData:(NSString *)data
{
    self.header.minute = data;
}

@end
