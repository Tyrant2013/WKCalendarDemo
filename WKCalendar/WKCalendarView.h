//
//  WKCalendarView.h
//  WKCalendarDemo
//
//  Created by ZhuangXiaowei on 14-9-9.
//  Copyright (c) 2014年 Tyrant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WKCalendarViewCell.h"

typedef NS_ENUM(NSInteger, WKCalendarViewType)
{
    WKCalendarViewTypeSimple,
    WKCalendarViewTypeDouble,
    WKCalendarViewTypeSimpleDateTime,
    WKCalendarViewTypeSimpleYearMonth,
    WKCalendarViewTypeDoubleYearMonth
};

@interface WKCalendarView : UIView

@property (nonatomic, weak) id delegate;
@property (nonatomic) WKCalendarViewType resultType;
@property (nonatomic) NSInteger colPadding;//horizon padding between cell
@property (nonatomic) NSInteger rowPadding;//vertical padding between cell

@property (nonatomic) NSInteger beginYear;
@property (nonatomic) NSInteger beginMonth;
@property (nonatomic) NSInteger beginDay;
@property (nonatomic) NSString *beginTime;

@property (nonatomic) NSString *time;
@property (nonatomic) NSInteger day;
@property (nonatomic) NSInteger month;
@property (nonatomic) NSInteger year;

@property (nonatomic) NSInteger endYear;
@property (nonatomic) NSInteger endMonth;
@property (nonatomic) NSInteger endDay;
@property (nonatomic) NSString *endTime;

@end


@protocol WKCalendarViewDelegate

@optional
- (void)calendarView:(WKCalendarView *)calendarView didSelectedStartDate:(NSString *)startDate endDate:(NSString *)endDate;
- (void)calendarView:(WKCalendarView *)calendarView didSelectedChange:(NSString *)date;

@end