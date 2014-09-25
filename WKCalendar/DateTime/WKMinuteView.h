//
//  WKMinuteView.h
//  WKCalendarDemo
//
//  Created by ZhuangXiaowei on 14-9-25.
//  Copyright (c) 2014年 Tyrant. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WKMinuteViewDelegate

@optional
- (void)didMinuteButtonClick:(UIButton *)button withData:(NSString *)data;

@end

@interface WKMinuteView : UIView

@property (nonatomic, weak) id delegate;

@end
