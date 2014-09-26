//
//  WKDateTimeHeaderView.h
//  WKCalendarDemo
//
//  Created by ZhuangXiaowei on 14-9-25.
//  Copyright (c) 2014年 Tyrant. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WKDateTimeHeaderViewDelegate

@optional
- (void)didButtonClick:(UIButton *)button;
- (void)didFunctionButtonClick:(UIButton *)button withTime:(NSString *)time;

@end

@interface WKDateTimeHeaderView : UIButton

@property (nonatomic, weak) id delegate;
@property (nonatomic) NSString *hour;
@property (nonatomic) NSString *minute;
@property (nonatomic) NSString *second;

@end
