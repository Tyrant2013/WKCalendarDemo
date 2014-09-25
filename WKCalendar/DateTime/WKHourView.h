//
//  WKHourView.h
//  WKCalendarDemo
//
//  Created by ZhuangXiaowei on 14-9-25.
//  Copyright (c) 2014年 Tyrant. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WKHourViewDelegate

@optional
- (void)didClickHourButton:(UIButton *)button hour:(NSString *)hour;

@end

@interface WKHourView : UIView

@property (nonatomic, weak) id delegate;

@end
