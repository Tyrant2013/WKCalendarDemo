//
//  WKDateTimeView.h
//  WKCalendarDemo
//
//  Created by ZhuangXiaowei on 14-9-25.
//  Copyright (c) 2014年 Tyrant. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WKDateTimeView : UIView

@property (nonatomic, copy) void (^didSelectedTime)(NSString *time);
@property (nonatomic) NSString *time;

@end
