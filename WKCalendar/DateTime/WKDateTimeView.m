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

@interface WKDateTimeView()<
  WKDateTimeHeaderViewDelegate,
  WKMinuteViewDelegate
>

@property (nonatomic) WKDateTimeHeaderView *header;

@end

@implementation WKDateTimeView

- (id)initWithFrame:(CGRect)frame
{
    frame.size.width = 300;
    frame.size.height = 300;
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initial];
    }
    return self;
}

- (void)initial
{
    self.clipsToBounds = YES;
    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.cornerRadius = 15.0f;
    
    CGFloat headerHeight = 40;
    CGFloat width = self.frame.size.width;
    CGFloat x = 0;
    CGFloat y = 0;
    _header = [[WKDateTimeHeaderView alloc] initWithFrame:(CGRect){x, y, width, headerHeight}];
    _header.delegate = self;
    [self addSubview:self.header];
    
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
    UIView *view = [self viewWithTag:110];
    if (view)
    {
        [view removeFromSuperview];
    }
    switch (button.tag)
    {
        case 0:
        {
            WKHourView *hourView = [[WKHourView alloc] initWithFrame:frame];
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
}

#pragma mark - WKMinuteViewDelegate

- (void)didMinuteButtonClick:(UIButton *)button withData:(NSString *)data
{
    self.header.minute = data;
}

@end
