//
//  WKMinuteView.m
//  WKCalendarDemo
//
//  Created by ZhuangXiaowei on 14-9-25.
//  Copyright (c) 2014年 Tyrant. All rights reserved.
//

#import "WKMinuteView.h"

typedef NS_ENUM(NSInteger, WKMinuteViewStyle)
{
    WKMinuteViewStyleNormal,
    WKMinuteViewStyleExtend
};

@interface WKMinuteView()

@property (nonatomic) NSInteger beginNumber;
@property (nonatomic) WKMinuteViewStyle curStyle;
@property (nonatomic) CGRect currentExtendButtonOriginFrame;
@property (nonatomic) CGRect lastExtendButtonOriginFrame;
@property (nonatomic) UIButton *currentExtendButton;

@end

@implementation WKMinuteView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self inital];
    }
    return self;
}

- (void)inital
{
    CGFloat x = 0, y = 0, width = self.frame.size.width, height = self.frame.size.height;
    CGFloat btnWidth = width / 3;
    CGFloat btnHeight = height / 2;
    for (int i = 0; i < 2; ++i)
    {
        for (int j = 0; j < 3; ++j)
        {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            x = j * btnWidth;
            y = i * btnHeight;
            button.frame = (CGRect){x, y, btnWidth, btnHeight};
            button.layer.borderColor = UIColor.grayColor.CGColor;
            button.layer.borderWidth = 1.0f;
            button.tag = i * 3 + j;
            [button setTitle:[NSString stringWithFormat:@"%d0", button.tag] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
        }
    }
}

- (void)addDetailButtonWithNumber:(NSInteger)number Width:(CGFloat)width height:(CGFloat)height
{
    CGFloat x, y;
    number *= 10;
    for (int i = 0; i < 4; ++i)
    {
        for (int j=0; j < 3; ++j)
        {
            if (i == 0 && j == 0) continue;
            if (i == 3 && j > 0) break;
            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            x = j * width;
            y = i * height;
            
            button.layer.borderColor = UIColor.grayColor.CGColor;
            button.layer.borderWidth = 1.0f;
            NSInteger num = number + i * 3 + j;
            button.tag = 1000 + num;
            [button setTitle:[NSString stringWithFormat:@"%d", num] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
            [UIView animateWithDuration:0.3f animations:^{
                button.frame = (CGRect){x, y, width, height};
            }];
        }
    }
}

//点击按钮
- (void)buttonClick:(UIButton *)button
{
    if (self.curStyle == WKMinuteViewStyleNormal)
    {
        self.currentExtendButton = button;
        self.currentExtendButtonOriginFrame = button.frame;
        [self extendNumberFromButton:button];
    }
    else
    {
        if (button == self.currentExtendButton)
        {
            self.currentExtendButton = nil;
            [self unExtendNumberFromButton:button];
        }
        else if (button.tag == self.currentExtendButton.tag + 1)
        {
            self.currentExtendButton.frame = self.currentExtendButtonOriginFrame;
            self.currentExtendButton.layer.opacity = 0.0f;
            self.currentExtendButton = button;
            self.currentExtendButtonOriginFrame = self.lastExtendButtonOriginFrame;
            [self extendNumberFromButton:button];
        }
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(didMinuteButtonClick:withData:)])
    {
        [self.delegate didMinuteButtonClick:button withData:button.titleLabel.text];
    }
}

//扩展出更多的选择
- (void)extendNumberFromButton:(UIButton *)button
{
    for (UIButton *btn in self.subviews)
    {
        if (btn != button && btn.tag != button.tag + 1 && btn.tag < 1000)
        {
            [UIView animateWithDuration:0.5f animations:^{
                btn.layer.opacity = 0.0f;
            }];
        }
        if (btn.tag > 1000)
        {
            [UIView animateWithDuration:0.5f animations:^{
                btn.layer.opacity = 0.0f;
            } completion:^(BOOL finished) {
                [btn removeFromSuperview];
            }];
        }
    }
    
    CGFloat width = self.frame.size.width / 3, height = self.frame.size.height / 4;
    UIButton *lastButton = (UIButton *)[self viewWithTag:button.tag + 1];
    self.lastExtendButtonOriginFrame = lastButton.frame;
    [UIView animateWithDuration:0.5f animations:^{
        button.frame = (CGRect){CGPointZero, width, height};
        lastButton.frame = (CGRect){self.frame.size.width - width * 2, self.frame.size.height - height, width * 2, height};
        lastButton.layer.opacity = 1.0f;
    } completion:^(BOOL finished) {
        [self addDetailButtonWithNumber:button.tag Width:width height:height];
    }];
    
    
    self.curStyle = WKMinuteViewStyleExtend;
}

//收缩回原来的样子
- (void)unExtendNumberFromButton:(UIButton *)button
{
    NSMutableArray *hiddenButtons = [[NSMutableArray alloc] init];
    for (UIButton *btn in self.subviews)
    {
        if (btn != button && btn.tag != button.tag + 1 && btn.tag < 1000)
        {
            [hiddenButtons addObject:btn];
        }
        if (btn.tag > 1000)
        {
            [UIView animateWithDuration:0.5f animations:^{
                btn.layer.opacity = 0.0f;
            } completion:^(BOOL finished) {
                [btn removeFromSuperview];
            }];
        }
    }
    UIButton *lastButton = (UIButton *)[self viewWithTag:button.tag + 1];
    [UIView animateWithDuration:0.3f animations:^{
        button.frame = self.currentExtendButtonOriginFrame;
        lastButton.frame = self.lastExtendButtonOriginFrame;
    } completion:^(BOOL finished) {
        for (UIButton *btn in hiddenButtons)
        {
            [UIView animateWithDuration:0.5f animations:^{
                btn.layer.opacity = 1.0f;
            }];
        }
    }];
    self.curStyle = WKMinuteViewStyleNormal;
}

@end
