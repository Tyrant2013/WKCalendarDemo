//
//  WKCalendarYearMonthView.h
//  WKCalendarDemo
//
//  Created by ZhuangXiaowei on 14-9-28.
//  Copyright (c) 2014年 Tyrant. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WKCalendarYearMonthView;

@protocol WKCalendarYearMonthViewDelegate

@optional
- (void)calendarYearMonthView:(WKCalendarYearMonthView *)calendarYearMonthView didYearChange:(NSInteger)year;
- (void)calendarYearMonthView:(WKCalendarYearMonthView *)calendarYearMonthView didSelectedMonth:(NSInteger)month;

@end

@interface WKCalendarYearMonthView : UIView

@property (nonatomic, weak) id delegate;
@property (nonatomic) NSInteger year;
@property (nonatomic) NSInteger month;

- (id)initWithYear:(NSInteger)year month:(NSInteger)month frame:(CGRect)frame;
- (void)reloadData;

@end
