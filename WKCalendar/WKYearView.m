//
//  WKYearView.m
//  WKCalendarDemo
//
//  Created by ZhuangXiaowei on 14-9-23.
//  Copyright (c) 2014年 Tyrant. All rights reserved.
//

#import "WKYearView.h"

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
    NSInteger width = self.frame.size.width / 3;
    NSInteger height = self.frame.size.height / 3;
    
    for (int i = 0; i < 3; ++i) {
        for (int j = 0; j < 3; ++j){
            NSInteger x = j * width;
            NSInteger y = i * height;
            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            button.frame = (CGRect){x, y, width, height};
            button.tag = self.selectedYear - (4 - (i * 3 + j));
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
    CGRect frame = self.frame;
    self.frame = CGRectOffset(frame, 0, -(frame.size.height + frame.origin.y));
    [UIView animateWithDuration:0.3f delay:0 usingSpringWithDamping:0.6f initialSpringVelocity:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.frame = frame;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hiddenFromViewWithYear:(NSInteger)year
{
    [UIView animateWithDuration:0.3f animations:^{
        self.frame = CGRectOffset(self.frame, 0, -(self.frame.size.height + self.frame.origin.y));
    } completion:^(BOOL finished) {
        if (self.didSelectedWithYear)
        {
            self.didSelectedWithYear(year);
        }
        [self removeFromSuperview];
    }];
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
