//
//  WKCalendarViewCell.h
//  WKCalendarDemo
//
//  Created by ZhuangXiaowei on 14-9-9.
//  Copyright (c) 2014年 Tyrant. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WKCalendarViewCell : UIView

@property (nonatomic) NSInteger day;
@property (nonatomic) BOOL isCurrent;
@property (nonatomic) BOOL isStroke;
@property (nonatomic) UIColor *lineColor;
@property (nonatomic) UIColor *textColor;
@property (nonatomic) CGFloat fontSize;
@property (nonatomic) UIFont *font;
@property (nonatomic) BOOL isSelected;
@property (nonatomic) BOOL isCurrentDay;

@end
