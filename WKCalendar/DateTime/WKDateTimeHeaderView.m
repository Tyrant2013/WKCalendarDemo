//
//  WKDateTimeHeaderView.m
//  WKCalendarDemo
//
//  Created by ZhuangXiaowei on 14-9-25.
//  Copyright (c) 2014年 Tyrant. All rights reserved.
//

#import "WKDateTimeHeaderView.h"

@interface WKDateTimeHeaderView()

@property (nonatomic) UIButton *btnHour;
@property (nonatomic) UIButton *btnMinute;
@property (nonatomic) UIButton *btnSecond;

@end

@implementation WKDateTimeHeaderView

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
    _hour = _hour == nil ? @"00" : _hour;
    _minute = _minute == nil ? @"00" : _minute;
    _second = _second == nil ? @"00" : _second;
    
    CGFloat btnWidth = 50.0f;
    CGFloat btnHeight = self.frame.size.height;
    CGFloat width = (self.frame.size.width - btnWidth * 2) / 3;
    CGFloat height = self.frame.size.height - 10;
    CGFloat x = (self.frame.size.width - width * 2 - 7) / 2;
    CGFloat y = (self.frame.size.height - height) / 2;
    UIColor *borderColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    cancelButton.frame = (CGRect){0, 0, btnWidth, btnHeight};
    cancelButton.layer.borderColor = borderColor.CGColor;
    cancelButton.layer.borderWidth = 1.0f;
    cancelButton.tag = 0;
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(functionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelButton];
    
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [confirmButton setTitle:@"确定" forState:UIControlStateNormal];
    [confirmButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    confirmButton.layer.borderColor = borderColor.CGColor;
    confirmButton.layer.borderWidth = 1.0f;
    confirmButton.frame = (CGRect){self.frame.size.width - btnWidth, 0, btnWidth, btnHeight};
    confirmButton.tag = 1;
    [confirmButton addTarget:self action:@selector(functionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:confirmButton];
    
    _btnHour = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _btnMinute = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    _btnSecond = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    _btnHour.frame = (CGRect){x, y, width, height};
    _btnHour.tag = 0;
    [_btnHour setTitle:self.hour forState:UIControlStateNormal];
    [_btnHour setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [_btnHour addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.btnHour];
    
    x += width + 2;
    UILabel *label = [[UILabel alloc] initWithFrame:(CGRect){x, y, 3, height}];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @":";
    [self addSubview:label];
    
    x += 5;
    _btnMinute.frame = (CGRect){x, y, width, height};
    _btnMinute.tag = 1;
    [_btnMinute setTitle:self.minute forState:UIControlStateNormal];
    [_btnMinute setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [_btnMinute addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.btnMinute];
}

- (void)setHour:(NSString *)hour
{
    _hour = [self canChangevalue:hour oldValue:_hour minValue:0 maxValue:24];
    [self.btnHour setTitle:self.hour forState:UIControlStateNormal];
}

- (void)setMinute:(NSString *)minute
{
    _minute = [self canChangevalue:minute oldValue:_minute minValue:0 maxValue:60];
    [self.btnMinute setTitle:self.minute forState:UIControlStateNormal];
}

- (void)setSecond:(NSString *)second
{
    _second = [self canChangevalue:second oldValue:_second minValue:0 maxValue:60];
    [self.btnSecond setTitle:self.second forState:UIControlStateNormal];
}

- (void)buttonClick:(UIButton *)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didButtonClick:)])
    {
        [self.delegate didButtonClick:button];
    }
}

- (void)functionButtonClick:(UIButton *)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didFunctionButtonClick:withTime:)])
    {
        NSString *time = [NSString stringWithFormat:@"%@:%@", self.btnHour.titleLabel.text, self.btnMinute.titleLabel.text];
        if (button.tag == 0) time = nil;
        [self.delegate didFunctionButtonClick:button withTime:time];
    }
}

- (NSString *)canChangevalue:(NSString *)newValue oldValue:(NSString *)oldValue minValue:(NSInteger)minValue maxValue:(NSInteger)maxValue
{
    NSInteger value = [newValue integerValue];
    if (value >= 10 && value <= maxValue) return newValue;
    if (value >= minValue && value < 10)
    {
        if (newValue.length == 1)
            return [NSString stringWithFormat:@"0%@", newValue];
        else return newValue;
    }
    return oldValue;
}

@end
