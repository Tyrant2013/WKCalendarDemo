//
//  WKCalendarDayView.h
//  WKCalendarDemo
//
//  Created by ZhuangXiaowei on 14-9-28.
//  Copyright (c) 2014年 Tyrant. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WKCalendarDayView;

@protocol WKCalendarDayViewDelegate

//@required
//- (NSInteger)numberOfPreMonthDays;
//- (NSInteger)numberOfCurrentMonthDays;
//- (NSInteger)weekDayOfFirstDayInCurrentMonth;

@optional
- (void)calendarDayView:(WKCalendarDayView *)calendarDayView didSelectedPreMonthDay:(NSInteger)day;
- (void)calendarDayView:(WKCalendarDayView *)calendarDayView didSelectedCurrentMonthDay:(NSInteger)day;
- (void)calendarDayView:(WKCalendarDayView *)calendarDayView didSelectedNextMonthDay:(NSInteger)day;
- (void)calendarDayView:(WKCalendarDayView *)calendarDayView didMonthChange:(NSInteger)month;

- (BOOL)calendarDayView:(WKCalendarDayView *)calendarDayview willDisplaySelectedWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;

////if the day is selected, then return YES,otherwise return NO;
//- (BOOL)calendarDayView:(WKCalendarDayView *)calendarDayView willDisplaySelectedWithCurrentMonthDay:(NSInteger)day;
////if the day is selected, then return YES,otherwise return NO;
//- (BOOL)calendarDayView:(WKCalendarDayView *)calendarDayView willDisplaySelectedWithPreMonthDay:(NSInteger)day;
////if the day is selected, then return YES,otherwise return NO;
//- (BOOL)calendarDayView:(WKCalendarDayView *)calendarDayView willDisplaySelectedWithNextMonthDay:(NSInteger)day;

@end

@interface WKCalendarDayView : UIView

@property (nonatomic) NSInteger year;
@property (nonatomic) NSInteger month;
@property (nonatomic) NSInteger day;
@property (nonatomic, weak) id<WKCalendarDayViewDelegate> delegate;

- (id)initWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day frame:(CGRect)frame;
- (void)reloadData;

@end
