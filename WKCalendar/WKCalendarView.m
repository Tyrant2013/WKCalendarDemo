//
//  WKCalendarView.m
//  WKCalendarDemo
//
//  Created by ZhuangXiaowei on 14-9-9.
//  Copyright (c) 2014年 Tyrant. All rights reserved.
//

#import "WKCalendarView.h"
#import "WKCalendar.h"
#import "ArrowButton.h"

@interface WKCalendarView()

@property (nonatomic) WKCalendar *calendar;
@property (nonatomic) NSInteger colTotal;//number of col
@property (nonatomic) NSInteger rowTotal;//number of row
@property (nonatomic) NSInteger cellWidth;//with of cell
@property (nonatomic) NSInteger cellHeight;//height of cell
@property (nonatomic) NSInteger headerTotalHeight;//height of header
@property (nonatomic) NSInteger heaerResultHeight;//selection result;
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
    frame.size.width = 300;
    frame.size.height = 280;
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
    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = UIColor.grayColor.CGColor;
    self.layer.cornerRadius = 15.0f;
    self.clipsToBounds = YES;
    
    _resultType = WKCalendarViewTypeDouble;
    _calendar = [[WKCalendar alloc] init];
    self.colTotal = 7;
    self.rowTotal = 5;
    self.colPadding = 2;
    self.rowPadding = 2;
    self.headerTotalHeight = 100;
    self.heaerResultHeight = 40;
    
    self.cellWidth = (self.frame.size.width - (self.colPadding * self.colTotal)) / self.colTotal;
    self.cellHeight = (self.frame.size.height - self.headerTotalHeight - (self.rowPadding * self.rowTotal)) / self.rowTotal;
    
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
    
    NSInteger totalWidth = CGRectGetWidth(self.frame);
    
    NSInteger colOffset = (totalWidth - (self.colTotal * (self.cellWidth + self.colPadding) - self.colPadding)) / 2;
    
    [self addShadow];
    
    [self addButton];
    [self addResult];
    
    [self addArrowButton];
    [self addTitleInfomation:context offset:colOffset];
    
    [self addWeekdays:context offset:colOffset];
    
    [self addDayPanel:context offset:colOffset rect:rect];
}

//添加阴影
- (void)addShadow
{
    CALayer *shadow = [CALayer layer];
    shadow.frame = self.bounds;
    shadow.shadowColor = UIColor.lightGrayColor.CGColor;
    shadow.shadowOffset = (CGSize){10, 10};
    shadow.shadowOpacity = 0.8f;
    shadow.shadowRadius = 10.0f;
    
    [self.layer addSublayer:shadow];
}

//添加两边的按钮
- (void)addButton
{
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat buttonWidth = 50;
    CGFloat height = self.heaerResultHeight - 4;
    if (![self viewWithTag:9001])
    {
        UIButton *leftButton = [[UIButton alloc] initWithFrame:(CGRect){x, y, buttonWidth, height}];
        [leftButton setTitle:@"取消" forState:UIControlStateNormal];
        [leftButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [leftButton setTitleColor:UIColor.lightGrayColor forState:UIControlStateHighlighted];
        leftButton.titleLabel.font = [UIFont systemFontOfSize:12];
        leftButton.backgroundColor = UIColor.whiteColor;
        leftButton.layer.borderColor = UIColor.lightGrayColor.CGColor;
        leftButton.layer.borderWidth = 1.0f;
        leftButton.tag = 9001;
        [leftButton addTarget:self action:@selector(cancelButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:leftButton];
    }
    
    if (![self viewWithTag:9002])
    {
        UIButton *rightButton = [[UIButton alloc] initWithFrame:(CGRect){self.frame.size.width - buttonWidth, y, buttonWidth, height}];
        [rightButton setTitle:@"确定" forState:UIControlStateNormal];
        [rightButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [rightButton setTitleColor:UIColor.lightGrayColor forState:UIControlStateHighlighted];
        rightButton.titleLabel.font = [UIFont systemFontOfSize:12];
        rightButton.backgroundColor = UIColor.whiteColor;
        rightButton.layer.borderColor = UIColor.lightGrayColor.CGColor;
        rightButton.layer.borderWidth = 1.0f;
        rightButton.tag = 9002;
        [rightButton addTarget:self action:@selector(confirmButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:rightButton];
    }
}

//添加选择的结果
- (void)addResult
{
    switch (self.resultType)
    {
        case WKCalendarViewTypeSimple:
            [self addSimpleResult];
            break;
        case WKCalendarViewTypeDouble:
            [self addRangeResult];
            break;
    }
    
}

//添加单个结果
- (void)addSimpleResult
{
    CGFloat x = 0;
    CGFloat y = 0;
    
    NSString *date = @"日期:";
    NSString *dateValue = [NSString stringWithFormat:@"%d-%d-%d", self.year, self.month, self.day];
    NSString *all = [NSString stringWithFormat:@"%@%@", date, dateValue];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    dic[NSFontAttributeName] = [UIFont systemFontOfSize:12];
    dic[NSForegroundColorAttributeName] = UIColor.blackColor;
    
    NSInteger totalWidth = [all sizeWithAttributes:dic].width + 7;
    
    x = (self.frame.size.width - totalWidth) / 2;
    y = (self.heaerResultHeight - 4 - [date sizeWithAttributes:dic].height) / 2;
    CGRect frame = (CGRect){x, y, self.frame.size.width, self.heaerResultHeight - 4};
    [date drawInRect:frame withAttributes:dic];
    
    x += [date sizeWithAttributes:dic].width + 2;
    frame.origin.x = x;
    dic[NSForegroundColorAttributeName] = UIColor.redColor;
    [dateValue drawInRect:frame withAttributes:dic];
}

//添加范围结果
- (void)addRangeResult
{
    CGFloat x = 0;
    CGFloat y = 0;
    
    NSString *begin = @"开始:";
    NSString *end = @"结束:";
    NSString *beginDate = [NSString stringWithFormat:@"%d-%d-%d", self.beginYear, self.beginMonth, self.beginDay];
    NSString *endDate = [NSString stringWithFormat:@"%d-%d-%d", self.endYear, self.endMonth, self.endDay];
    NSString *all = [NSString stringWithFormat:@"%@%@%@%@", begin,beginDate,end,endDate];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    dic[NSFontAttributeName] = [UIFont systemFontOfSize:12];
    dic[NSForegroundColorAttributeName] = UIColor.blackColor;
    
    NSInteger totalWidth = [all sizeWithAttributes:dic].width + 14;
    
    x = (self.frame.size.width - totalWidth) / 2;
    y = (self.heaerResultHeight - 4 - [begin sizeWithAttributes:dic].height) / 2;
    CGRect frame = (CGRect){x, y, self.frame.size.width, self.heaerResultHeight - 4};
    [begin drawInRect:frame withAttributes:dic];
    
    x += [begin sizeWithAttributes:dic].width + 2;
    frame.origin.x = x;
    dic[NSForegroundColorAttributeName] = UIColor.redColor;
    [beginDate drawInRect:frame withAttributes:dic];
    
    x += [beginDate sizeWithAttributes:dic].width + 5;
    frame.origin.x = x;
    dic[NSForegroundColorAttributeName] = UIColor.blackColor;
    [end drawInRect:frame withAttributes:dic];
    
    x += [end sizeWithAttributes:dic].width + 2;
    frame.origin.x = x;
    dic[NSForegroundColorAttributeName] = UIColor.redColor;
    [endDate drawInRect:frame withAttributes:dic];
}

- (void)cancelButtonTouchUpInside:(UIButton *)button
{
    [self removeFromSuperview];
}

- (void)confirmButtonTouchUpInside:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(calendarView:didSelectedStartDate:endDate:)])
    {
        NSString *startDate;
        NSString *endDate;
        switch (self.resultType)
        {
            case WKCalendarViewTypeSimple:
                startDate = [NSString stringWithFormat:@"%d-%d-%d", self.beginYear, self.beginMonth, self.beginDay];
                endDate = [NSString stringWithFormat:@"%d-%d-%d", self.endYear, self.endMonth, self.endDay];
                break;
            case WKCalendarViewTypeDouble:
                startDate = endDate = [NSString stringWithFormat:@"%d-%d-%d", self.year, self.month, self.day];
                break;
        }
        [self.delegate calendarView:self didSelectedStartDate:startDate endDate:endDate];
    }
    [self removeFromSuperview];
}

- (void)addArrowButton
{
    CGFloat y = self.heaerResultHeight + 5;
    NSInteger height = 20;
    if (![self viewWithTag:1001])
    {
        ArrowButton *left = [[ArrowButton alloc] initWithFrame:(CGRect){0, y, 44, height}];
        left.backgroundColor = UIColor.whiteColor;
        left.tag = 1001;
        [left addTarget:self action:@selector(preMonth:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:left];
    }
    
    if (![self viewWithTag:1002])
    {
        ArrowButton *right = [[ArrowButton alloc] initWithFrame:(CGRect){self.frame.size.width - 44, y, 44, height}];
        right.backgroundColor = UIColor.whiteColor;
        right.layer.transform = CATransform3DMakeRotation(M_PI, 0, 1, 0);
        right.tag = 1002;
        [right addTarget:self action:@selector(nextMonth:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:right];
    }
}

- (void)preMonth:(UIButton *)button
{
    --self.month;
    if (self.month <= 0)
    {
        self.month = 12;
        --self.year;
    }
    [self setNeedsDisplay];
}

- (void)nextMonth:(UIButton *)button
{
    ++self.month;
    if (self.month > 12)
    {
        self.month = 1;
        ++self.year;
    }
    [self setNeedsDisplay];
}

//添加年月信息
- (void)addTitleInfomation:(CGContextRef)context offset:(NSInteger)colOffset
{
    CGContextSaveGState(context);
    CGFloat x = 44 + colOffset;
    CGFloat y = self.heaerResultHeight + 5;
    NSInteger width = self.frame.size.width - x * 2 - colOffset * 2;
    NSInteger height = 20;
    
    NSString *yearMonth = [NSString stringWithFormat:@"%d 年 %d 月", self.year, self.month];
    
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
    NSInteger fontHeight = 20;
    for (int i = 0; i < weekDays.count; ++i) {
        NSInteger x = (self.cellWidth + self.colPadding) * i + colOffset;
        NSString *item = weekDays[i];
        [self.weekDaysChinese[item] drawInRect:(CGRect){x, self.headerTotalHeight - fontHeight, self.cellWidth, fontHeight} withAttributes:dic];
    }
    CGContextRestoreGState(context);
}

//添加日期面板
- (void)addDayPanel:(CGContextRef)context offset:(NSInteger)colOffset rect:(CGRect)rect
{
    NSInteger dayOfMonth = [self getTotalDayInMonth:self.month year:self.year];
    NSInteger firstWeekday = [self getWeekdayInDay:1 month:self.month year:self.year] - 1;
    for (UIView *view in self.subviews)
    {
        if (view.tag == 1000)
           [ view removeFromSuperview];
    }
    
    CGContextSaveGState(context);
    [UIColor.lightGrayColor setStroke];
    for (int i = 0; i < self.rowTotal; ++i) {
        NSInteger y = (self.cellHeight + self.rowPadding ) * i + self.headerTotalHeight;
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
            cell.tag = 1000;
            cell.day = day;
            cell.isWorkday = !(j == 0 || j == 6);
            cell.isCurrentDay = day == self.currentDay && self.year == self.currentYear && self.month == self.currentMonth;
            if (self.resultType == WKCalendarViewTypeDouble)
            {
                cell.isSelected = ((day >= self.beginDay && day <= self.endDay) &&
                                  (self.year >= self.beginYear && self.year <= self.endYear) &&
                                  (self.month >= self.beginMonth && self.month <= self.endMonth)) || (day == self.beginDay && self.month == self.beginMonth && self.year == self.beginYear);
            }
            else
            {
                cell.isSelected = day == self.day;
            }
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellDidTouchedUpInside:)];
            [cell addGestureRecognizer:tapGesture];
            [self addSubview:cell];
            if (--dayOfMonth <= 0) break;//本月最后一天的位置
        }
        if (i == 0)
        {
            CGContextMoveToPoint(context, colOffset, y - self.rowPadding);
            CGContextAddLineToPoint(context, rect.size.width - colOffset, y - self.rowPadding);
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

- (void)cellDidTouchedUpInside:(UITapGestureRecognizer *)tapGuesture
{
    WKCalendarViewCell *cell = (WKCalendarViewCell *)tapGuesture.view;
    NSInteger day = cell.day;
    
    switch (self.resultType)
    {
        case WKCalendarViewTypeSimple:
            [self dealWithSimpleWithDay:day];
            break;
        case WKCalendarViewTypeDouble:
            [self dealWithRangeWithDay:day];
            break;
    }
    
    [self setNeedsDisplay];
}

- (void)dealWithSimpleWithDay:(NSInteger)day
{
    self.day = day;
}

- (void)dealWithRangeWithDay:(NSInteger)day
{
    if (self.beginDay == 0)
    {
        self.beginDay = day;
        self.beginMonth = self.month;
        self.beginYear = self.year;
    }
    else
    {
        if (self.beginDay == day && self.month == self.beginMonth && self.year == self.beginYear)
        {
            self.beginDay = self.endDay;
            self.beginMonth = self.endMonth;
            self.beginYear = self.endYear;
            self.endDay = self.endMonth = self.endYear = 0;
        }
        else if (self.endDay == day && self.month == self.endMonth && self.year == self.endYear)
        {
            self.endDay = self.endMonth = self.endYear = 0;
        }
        else
        {
            self.endDay = day;
            self.endMonth = self.month;
            self.endYear = self.year;
        }
    }
    
    [self swapSelectedDay];
}

//交换开始日期和结束日期
- (void)swapSelectedDay
{
    if (self.beginDay == 0 && self.beginMonth == 0 && self.endYear == 0) return;
    if (self.endDay == 0 && self.endMonth == 0 && self.endYear == 0) return;
    if (self.beginYear > self.endYear)
    {
        self.beginYear = self.beginYear + self.endYear;
        self.endYear = self.beginYear - self.endYear;
        self.beginYear = self.beginYear - self.endYear;
    }
    if (self.beginMonth > self.endMonth)
    {
        self.beginMonth = self.beginMonth + self.endMonth;
        self.endMonth = self.beginMonth - self.endMonth;
        self.beginMonth = self.beginMonth - self.endMonth;
    }
    if (self.beginDay > self.endDay)
    {
        self.beginDay = self.beginDay + self.endDay;
        self.endDay = self.beginDay - self.endDay;
        self.beginDay = self.beginDay - self.endDay;
    }
}

@end
