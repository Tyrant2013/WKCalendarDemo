//
//  WKMonthView.m
//  WKCalendarDemo
//
//  Created by ZhuangXiaowei on 14-9-23.
//  Copyright (c) 2014年 Tyrant. All rights reserved.
//

#import "WKMonthView.h"

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
    self.frame = CGRectOffset(self.frame, 0, self.frame.size.height);
    [UIView animateWithDuration:0.25f delay:0 usingSpringWithDamping:0.6f initialSpringVelocity:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.frame = CGRectOffset(self.frame, 0, -self.frame.size.height);
    } completion:^(BOOL finished) {

    }];
}

- (void)hiddenFromViewWithMonth:(NSInteger)month
{
    [UIView animateWithDuration:0.25f animations:^{
        self.frame = CGRectOffset(self.frame, 0, self.frame.size.height);
    } completion:^(BOOL finished) {
        if (self.didSelectedMonth)
        {
            self.didSelectedMonth(month);
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
