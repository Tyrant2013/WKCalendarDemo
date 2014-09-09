//
//  WKCalendarView.m
//  WKCalendarDemo
//
//  Created by ZhuangXiaowei on 14-9-9.
//  Copyright (c) 2014年 Tyrant. All rights reserved.
//

#import "WKCalendarView.h"
#import "WKCalendar.h"

@interface WKCalendarView()

@property (nonatomic) WKCalendar *calendar;
@property (nonatomic) NSInteger colTotal;//number of col
@property (nonatomic) NSInteger rowTotal;//number of row
@property (nonatomic) NSInteger cellWidth;//with of cell
@property (nonatomic) NSInteger cellHeight;//height of cell

@end

@implementation WKCalendarView

- (id)initWithFrame:(CGRect)frame
{
//    if (frame.size.width == 0) frame.size.width = 320;
//    if (frame.size.height == 0) frame.size.height = 480;
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = UIColor.whiteColor;
        [self initial];
    }
    return self;
}

- (void)initial
{
    _calendar = [[WKCalendar alloc] init];
    self.colTotal = 7;
    self.rowTotal = 5;
    self.colPadding = 2;
    self.rowPadding = 2;
    self.cellWidth = 40;
    self.cellHeight = 50;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    UIView *superView = self.superview;
    NSInteger totalWidth = 320;
    if (superView){
        totalWidth = CGRectGetWidth(superView.frame);
    }
    NSInteger colOffset = (totalWidth - (self.colTotal * (self.cellWidth + self.colPadding) - self.colPadding)) / 2;
    for (int i = 0; i < self.rowTotal; ++i) {
        for (int j = 0; j < self.colTotal; ++j) {
            NSInteger x = (self.cellWidth + self.colPadding ) * j + colOffset;
            NSInteger y = (self.cellHeight + self.rowPadding ) * i;
            WKCalendarViewCell *cell = [[WKCalendarViewCell alloc] initWithFrame:(CGRect){
                x,
                y,
                self.cellWidth,
                self.cellHeight
            }];
            cell.day = j + 1 + i * self.colTotal;
            [self addSubview:cell];
        }
    }
    
}

@end
