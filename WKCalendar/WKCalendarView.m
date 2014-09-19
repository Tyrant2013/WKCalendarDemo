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
@property (nonatomic) NSInteger headerHeight;//height of header
@property (nonatomic) NSDictionary *weekDaysChinese;

@property (nonatomic) NSInteger currentDay;
@property (nonatomic) NSInteger currentMonth;
@property (nonatomic) NSInteger currentYear;

@property (nonatomic) NSInteger day;
@property (nonatomic) NSInteger month;
@property (nonatomic) NSInteger year;

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
    self.headerHeight = 60;
    
    self.cellWidth = (self.frame.size.width - (self.colPadding * self.colTotal)) / self.colTotal;
    self.cellHeight = (self.frame.size.height - self.headerHeight - (self.rowPadding * self.rowTotal)) / self.rowTotal;
    
    self.weekDaysChinese = @{@"Sunday":@"日",
                             @"Monday":@"一",
                             @"Tuesday":@"二",
                             @"Wednesday":@"三",
                             @"Thursday":@"四",
                             @"Friday":@"五",
                             @"Saturday":@"六"};
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear
                                                                   fromDate:[NSDate date]];
    self.day = components.day;
    self.month = components.month;
    self.year = components.year;
    
    self.currentDay = components.day;
    self.currentMonth = components.month;
    self.currentYear = components.year;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = UIColor.grayColor.CGColor;
    self.layer.cornerRadius = 15.0f;
    
    NSInteger totalWidth = CGRectGetWidth(self.frame);
    
    NSInteger colOffset = (totalWidth - (self.colTotal * (self.cellWidth + self.colPadding) - self.colPadding)) / 2;
    
    [self addTitleInfomation:context offset:colOffset];
    
    [self addWeekdays:context offset:colOffset];
    
    [self addDayPanel:context offset:colOffset rect:rect];
}

//添加头部信息
- (void)addTitleInfomation:(CGContextRef)context offset:(NSInteger)colOffset
{
    CGContextSaveGState(context);
    CGFloat x = 44 + colOffset;
    CGFloat y = 7;
    NSInteger width = self.frame.size.width - x * 2 - colOffset * 2;
    NSInteger height = 20;
    
    NSString *yearMonth = @"2014 年 09 月";
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    dic[NSParagraphStyleAttributeName] = paragraphStyle;
    dic[NSFontAttributeName] = [UIFont systemFontOfSize:18];
    
    CGRect frame = (CGRect){x, y, width, height};
    [yearMonth drawInRect:frame withAttributes:dic];
    
    CGContextRestoreGState(context);
}

//添加星期行
- (void)addWeekdays:(CGContextRef)context offset:(NSInteger)colOffset
{
    CGContextSaveGState(context);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSArray *weekDays = [dateFormatter standaloneWeekdaySymbols];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    dic[NSFontAttributeName] = [UIFont systemFontOfSize:12];
    dic[NSParagraphStyleAttributeName] = paragraphStyle;
    NSInteger fontHeight = 16;
    for (int i = 0; i < weekDays.count; ++i) {
        NSInteger x = (self.cellWidth + self.colPadding) * i + colOffset;
        NSString *item = weekDays[i];
        [self.weekDaysChinese[item] drawInRect:(CGRect){x, self.headerHeight - fontHeight, self.cellWidth, fontHeight} withAttributes:dic];
    }
    CGContextRestoreGState(context);
}

//添加日期面板
- (void)addDayPanel:(CGContextRef)context offset:(NSInteger)colOffset rect:(CGRect)rect
{
    NSInteger dayOfMonth = [self getTotalDayInMonth:self.month year:self.year];
    NSInteger firstWeekday = [self getWeekdayInDay:1 month:self.month year:self.year] - 1;
    
    CGContextSaveGState(context);
    [UIColor.lightGrayColor setStroke];
    for (int i = 0; i < self.rowTotal; ++i) {
        NSInteger y = (self.cellHeight + self.rowPadding ) * i + self.headerHeight;
        for (int j = 0; j < self.colTotal; ++j) {
            NSInteger day = j + 1 + i * self.colTotal - firstWeekday;
            if (day <= 0) continue;//确定1号开始的位置
            NSInteger x = (self.cellWidth + self.colPadding ) * j + colOffset;
            WKCalendarViewCell *cell = [[WKCalendarViewCell alloc] initWithFrame:(CGRect){
                x,
                y,
                self.cellWidth,
                self.cellHeight
            }];
            cell.isWorkday = !(j == 0 || j == 6);
            cell.isCurrentDay = day == self.currentDay && self.year == self.currentYear && self.month == self.currentMonth;
            cell.isSelected = day >= 19;
            cell.day = day;
            [self addSubview:cell];
            if (--dayOfMonth <= 0) break;//本月最后一天的位置
        }
        if (i == 0)
        {
            CGContextMoveToPoint(context, colOffset, y - self.rowPadding / 2);
            CGContextAddLineToPoint(context, rect.size.width - colOffset, y - self.rowPadding / 2);
        }
    }
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}

//获取指定年月的天数
- (NSInteger)getTotalDayInMonth:(NSInteger)month year:(NSInteger)year
{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.day = 1;
    components.month = month;
    components.year = year;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *date = [calendar dateFromComponents:components];
    NSRange range = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
    return range.length;
}

//获取指定日期是星期几
- (NSInteger)getWeekdayInDay:(NSInteger)day month:(NSInteger)month year:(NSInteger)year
{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.day = day;
    components.month = month;
    components.year = year;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *date = [calendar dateFromComponents:components];
    
    NSDateComponents *weekDayCompnents = [calendar components:NSWeekdayCalendarUnit fromDate:date];
    return weekDayCompnents.weekday;
}

@end
