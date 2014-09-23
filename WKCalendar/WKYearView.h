//
//  WKYearView.h
//  WKCalendarDemo
//
//  Created by ZhuangXiaowei on 14-9-23.
//  Copyright (c) 2014年 Tyrant. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WKYearView : UIView

@property (nonatomic) NSInteger selectedYear;
@property (nonatomic, copy) void (^didSelectedWithYear)(NSInteger year);

- (instancetype)initWithFrame:(CGRect)frame year:(NSInteger)year;
- (void)showInView:(UIView *)view;
- (void)hiddenFromViewWithYear:(NSInteger)year;

@end
