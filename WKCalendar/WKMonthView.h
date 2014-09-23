//
//  WKMonthView.h
//  WKCalendarDemo
//
//  Created by ZhuangXiaowei on 14-9-23.
//  Copyright (c) 2014年 Tyrant. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WKMonthView : UIView

@property (nonatomic) NSInteger selectedMonth;
@property (nonatomic, copy) void (^didSelectedMonth)(NSInteger month);

- (void)showInView:(UIView *)view;
- (void)hiddenFromViewWithMonth:(NSInteger)month;

@end
