//
//  WKCalendarView.h
//  WKCalendarDemo
//
//  Created by ZhuangXiaowei on 14-9-9.
//  Copyright (c) 2014年 Tyrant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WKCalendarViewCell.h"

@interface WKCalendarView : UIView

@property (nonatomic, weak) id delegate;
@property (nonatomic) NSInteger colPadding;//horizon padding between cell
@property (nonatomic) NSInteger rowPadding;//vertical padding between cell

@end


@protocol WKCalendarViewDelegate

@optional
- (void)calendarView:(WKCalendarView *)calendarView didSelectedWithIndex:(NSIndexPath *)indexPath;

@end