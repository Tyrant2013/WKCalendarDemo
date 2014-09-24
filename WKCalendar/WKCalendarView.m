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
#import "WKMonthView.h"
#import "WKYearView.h"

typedef NS_ENUM(NSInteger, WKCalendarAnimationDirection)
{
    WKCalendarAnimationDirectionUp,
    WKCalendarAnimationDirectionRight,
    WKCalendarAnimationDirectionDown,
    WKCalendarAnimationDirectionLeft
};

@interface WKCalendarView()

@property (nonatomic) WKCalendar *calendar;
@property (nonatomic) NSInteger colTotal;//number of col
@property (nonatomic) NSInteger rowTotal;//number of row
@property (nonatomic) NSInteger cellWidth;//with of cell
@property (nonatomic) NSInteger cellHeight;//height of cell
@property (nonatomic) NSInteger headerTotalHeight;//height of header
@property (nonatomic) NSInteger heaerResultHeight;//selection result;
@property (nonatomic) NSDictionary *weekDaysChinese;
@property (nonatomic) BOOL isShowAnimation;

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
    _isShowAnimation = NO;
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
    
    UISwipeGestureRecognizer *swipeRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture:)];
    swipeRightGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:swipeRightGesture];
    
    UISwipeGestureRecognizer *swipeLeftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture:)];
    swipeLeftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:swipeLeftGesture];
    
    UISwipeGestureRecognizer *swipeUpGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture:)];
    swipeUpGesture.direction = UISwipeGestureRecognizerDirectionUp;
    [self addGestureRecognizer:swipeUpGesture];
    
    UISwipeGestureRecognizer *swipeDownGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture:)];
    swipeDownGesture.direction = UISwipeGestureRecognizerDirectionDown;
    [self addGestureRecognizer:swipeDownGesture];
}

- (void)swipeGesture:(UISwipeGestureRecognizer *)gesture
{
    switch (gesture.direction) {
        case UISwipeGestureRecognizerDirectionDown:
            [self showYearViewForSelected];
            break;
        case UISwipeGestureRecognizerDirectionLeft:
            [self preMonth:nil];
            break;
        case UISwipeGestureRecognizerDirectionRight:
            [self nextMonth:nil];
            break;
        case UISwipeGestureRecognizerDirectionUp:
            [self showMonthViewForSelected];
            break;
    }
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
                startDate = endDate = [NSString stringWithFormat:@"%d-%d-%d", self.year, self.month, self.day];
                break;
            case WKCalendarViewTypeDouble:
                startDate = [NSString stringWithFormat:@"%d-%d-%d", self.beginYear, self.beginMonth, self.beginDay];
                endDate = [NSString stringWithFormat:@"%d-%d-%d", self.endYear, self.endMonth, self.endDay];
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
    self.isShowAnimation = YES;

    [self beginAnimationForSwapMonth:nil direction:WKCalendarAnimationDirectionLeft];
}

- (void)nextMonth:(UIButton *)button
{
    ++self.month;
    if (self.month > 12)
    {
        self.month = 1;
        ++self.year;
    }
    self.isShowAnimation = YES;
    
    [self beginAnimationForSwapMonth:nil direction:WKCalendarAnimationDirectionRight];
}

- (void)beginAnimationForSwapMonth:(UIView *)oldMonthView direction:(WKCalendarAnimationDirection)direction
{
    if (oldMonthView == nil)
    {
        oldMonthView = [self snapshotViewAfterScreenUpdates:NO];
        [self setNeedsDisplay];
    }
    oldMonthView.backgroundColor = UIColor.whiteColor;
    oldMonthView.layer.zPosition = 1024;
    CGRect frame = oldMonthView.frame;
    [self addSubview:oldMonthView];
    switch (direction)
    {
        case WKCalendarAnimationDirectionDown:
            frame = CGRectOffset(frame, 0, frame.size.height);
            break;
        case WKCalendarAnimationDirectionLeft:
            frame = CGRectOffset(frame, -frame.size.width, 0);
            break;
        case WKCalendarAnimationDirectionRight:
            frame = CGRectOffset(frame, frame.size.width, 0);
            break;
        case WKCalendarAnimationDirectionUp:
            frame = CGRectOffset(frame, 0, -frame.size.height);
            break;
    }
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        oldMonthView.frame = frame;
    } completion:^(BOOL finished) {
        [oldMonthView removeFromSuperview];
    }];
}

//添加年月信息
- (void)addTitleInfomation:(CGContextRef)context offset:(NSInteger)colOffset
{
//    CGContextSaveGState(context);
//    CGFloat x = 44 + colOffset;
//    CGFloat y = self.heaerResultHeight + 5;
//    NSInteger width = self.frame.size.width - x * 2 - colOffset * 2;
//    NSInteger height = 20;
//    
//    NSString *yearMonth = [NSString stringWithFormat:@"%d 年 %d 月", self.year, self.month];
//    
//    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//    paragraphStyle.alignment = NSTextAlignmentCenter;
//    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
//    dic[NSParagraphStyleAttributeName] = paragraphStyle;
//    dic[NSFontAttributeName] = [UIFont systemFontOfSize:18];
//    
//    CGRect frame = (CGRect){x, y, width, height};
//    [yearMonth drawInRect:frame withAttributes:dic];
//    
//    CGContextRestoreGState(context);
    CGFloat x = 45;
    CGFloat y = self.heaerResultHeight + 5;
    CGFloat width = (self.frame.size.width - 88) / 2 - 1;
    CGFloat height = 20;
    UIButton *yearButton = (UIButton *)[self viewWithTag:1101];
    if (!yearButton)
    {
        yearButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        yearButton.frame = (CGRect){x, y, width, height};
        yearButton.tag = 1101;
        yearButton.titleLabel.textAlignment = NSTextAlignmentRight;
//        [yearButton addTarget:self action:@selector(showYearViewForSelected) forControlEvents:UIControlEventTouchUpInside];
        [yearButton addTarget:self action:@selector(showYearViewFromButton:) forControlEvents:UIControlEventTouchUpInside];
        yearButton.layer.borderColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f].CGColor;
        yearButton.layer.borderWidth = 1.0f;
        [self addSubview:yearButton];
    }

    x += width;
    UIButton *monthButton = (UIButton *)[self viewWithTag:1102];
    if (!monthButton)
    {
        monthButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        monthButton.frame = (CGRect){x, y, width, height};
        monthButton.tag = 1102;
        monthButton.titleLabel.textAlignment = NSTextAlignmentLeft;
//        [monthButton addTarget:self action:@selector(showMonthViewForSelected) forControlEvents:UIControlEventTouchUpInside];
        [monthButton addTarget:self action:@selector(showMonthViewFromButton:) forControlEvents:UIControlEventTouchUpInside];
        monthButton.layer.borderColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f].CGColor;
        monthButton.layer.borderWidth = 1.0f;
        [self addSubview:monthButton];
    }
    
    [yearButton setTitle:[NSString stringWithFormat:@"%d 年",self.year] forState:UIControlStateNormal];
    [monthButton setTitle:[NSString stringWithFormat:@"%d 月", self.month] forState:UIControlStateNormal];
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
    NSInteger preDayOfMonth = [self getTotalDayInMonth:self.month - 1 year:self.year];
    NSInteger firstWeekday = [self getWeekdayInDay:1 month:self.month year:self.year] - 1;
    for (UIView *view in self.subviews)
    {
        if (view.tag == 1000)
           [ view removeFromSuperview];
    }
    
    

    NSDateComponents *beginCompare = [[NSDateComponents alloc] init];
    NSDateComponents *endCompare = [[NSDateComponents alloc] init];
    
    NSDate *beginDate = [self dateFormYear:self.beginYear month:self.beginMonth day:self.beginDay];
    NSDate *endDate = [self dateFormYear:self.endYear month:self.endMonth day:self.endDay];

    for (int i = 0; i < self.rowTotal; ++i)
    {
        NSInteger y = (self.cellHeight + self.rowPadding ) * i + self.headerTotalHeight;
        for (int j = 0; j < self.colTotal; ++j)
        {
            NSInteger checkDay = j + 1 + i * self.colTotal - firstWeekday;
            NSInteger day = 0, month = self.month, year = self.year;
            UITapGestureRecognizer *tapGesture;
            NSInteger x = (self.cellWidth + self.colPadding ) * j + colOffset;
            WKCalendarViewCell *cell = [[WKCalendarViewCell alloc] initWithFrame:(CGRect){
                x,
                y,
                self.cellWidth,
                self.cellHeight
            }];
            if (checkDay <= 0)
            {
//                continue;//确定1号开始的位置
                day = preDayOfMonth + checkDay;
                --month;
                tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(preMonthCellDidTouchedUpInside:)];
                cell.isCurrentMonthDay = NO;
            }
            else if (--dayOfMonth < 0)
            {
//                break;//最后一天
                day = abs(dayOfMonth);
                ++month;
                tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nextMonthCellDidTouchedUpInside:)];
                cell.isCurrentMonthDay = NO;
            }
            else
            {
                day = checkDay;
                tapGesture  = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellDidTouchedUpInside:)];
                cell.isCurrentMonthDay = YES;
            }
            NSDate *date = [self dateFormYear:year month:month day:day];
            
            cell.tag = 1000;
            cell.day = day;
            cell.isWorkday = !(j == 0 || j == 6);
            cell.isCurrentDay = day == self.currentDay && self.year == self.currentYear && self.month == self.currentMonth;
            if (self.resultType == WKCalendarViewTypeDouble)
            {
                beginCompare = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:date toDate:beginDate options:NSCalendarWrapComponents];
                endCompare = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:date toDate:endDate options:NSCalendarWrapComponents];
                cell.isSelected = (beginCompare.day < 0 && endCompare.day > 0) || beginCompare.day == 0 || endCompare.day == 0;
            }
            else
            {
                cell.isSelected = day == self.day;
            }
            
            [cell addGestureRecognizer:tapGesture];
            [self addSubview:cell];
        }
        if (i == 0)
        {
            CGContextSaveGState(context);
            [UIColor.lightGrayColor setStroke];
            CGContextMoveToPoint(context, colOffset, y - self.rowPadding);
            CGContextAddLineToPoint(context, rect.size.width - colOffset, y - self.rowPadding);
            CGContextStrokePath(context);
            CGContextRestoreGState(context);
        }
    }
    
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
            [self dealWithRangeWithDay:day month:self.month year:self.year];
            break;
    }
    
    [self setNeedsDisplay];
}

//上一个月的天数
- (void)preMonthCellDidTouchedUpInside:(UITapGestureRecognizer *)tapGuesture
{
    [self preMonth:nil];
    
    [self cellDidTouchedUpInside:tapGuesture];
}

//下一个月的天数
- (void)nextMonthCellDidTouchedUpInside:(UITapGestureRecognizer *)tapGuesture
{
    [self nextMonth:nil];
    
    [self cellDidTouchedUpInside:tapGuesture];
}

- (void)dealWithSimpleWithDay:(NSInteger)day
{
    self.day = day;
}

- (void)dealWithRangeWithDay:(NSInteger)day month:(NSInteger)month year:(NSInteger)year
{
    if (self.beginDay == 0)
    {
        self.beginDay = day;
        self.beginMonth = month;
        self.beginYear = year;
    }
    else
    {
        if (self.beginDay == day && month == self.beginMonth && year == self.beginYear)
        {
            self.beginDay = self.endDay;
            self.beginMonth = self.endMonth;
            self.beginYear = self.endYear;
            self.endDay = self.endMonth = self.endYear = 0;
        }
        else if (self.endDay == day && month == self.endMonth && year == self.endYear)
        {
            self.endDay = self.endMonth = self.endYear = 0;
        }
        else
        {
            if (self.endDay > 0)
            {
                NSDate *date = [self dateFormYear:year month:month day:day];
                NSDate *beginDate = [self dateFormYear:self.beginYear month:self.beginMonth day:self.beginDay];
                NSDateComponents *compare = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:date toDate:beginDate options:NSCalendarWrapComponents];
                if (compare.day > 0)
                {
                    self.beginDay = day;
                    self.beginMonth = month;
                    self.beginYear = year;
                }
                else
                {
                    self.endDay = day;
                    self.endMonth = month;
                    self.endYear = year;
                }
            }
            else
            {
                self.endDay = day;
                self.endMonth = month;
                self.endYear = year;
            }
        }
    }
    
    [self swapSelectedDay];
}

//交换开始日期和结束日期
- (void)swapSelectedDay
{
    if (self.beginDay == 0 && self.beginMonth == 0 && self.endYear == 0) return;
    if (self.endDay == 0 && self.endMonth == 0 && self.endYear == 0) return;
    NSDateComponents *beginComp = [[NSDateComponents alloc] init];
    NSDateComponents *endComp = [[NSDateComponents alloc] init];
    beginComp.day = self.beginDay;
    beginComp.month = self.beginMonth;
    beginComp.year = self.beginYear;
    endComp.day = self.endDay;
    endComp.month = self.endMonth;
    endComp.year = self.endYear;
    NSDate *beginDate = [[NSCalendar currentCalendar] dateFromComponents:beginComp];
    NSDate *endDate = [[NSCalendar currentCalendar] dateFromComponents:endComp];
    NSDateComponents *compareComp = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:beginDate toDate:endDate options:NSCalendarWrapComponents];
    if (compareComp.day < 0)
    {
        self.beginYear = self.beginYear + self.endYear;
        self.endYear = self.beginYear - self.endYear;
        self.beginYear = self.beginYear - self.endYear;
        
        self.beginMonth = self.beginMonth + self.endMonth;
        self.endMonth = self.beginMonth - self.endMonth;
        self.beginMonth = self.beginMonth - self.endMonth;
        
        self.beginDay = self.beginDay + self.endDay;
        self.endDay = self.beginDay - self.endDay;
        self.beginDay = self.beginDay - self.endDay;
    }
}

- (NSDate *)dateFormYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.day = day;
    dateComponents.month = month;
    dateComponents.year = year;
    
    return [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
}

- (void)showMonthViewForSelected
{
    if ([self viewWithTag:666])
    {
        WKMonthView *monthView = (WKMonthView *)[self viewWithTag:666];
        [monthView hiddenFromViewWithMonth:self.month];
    }
    else
    {
        WKMonthView *monthView = [[WKMonthView alloc] initWithFrame:(CGRect){0, self.headerTotalHeight - 20, self.frame.size.width, self.frame.size.height - self.headerTotalHeight + 20}];
        monthView.tag = 666;
        monthView.layer.zPosition = 1110;
        monthView.selectedMonth = self.month;
        monthView.didSelectedMonth = ^(NSInteger month){
            if (month == self.month) return;
            self.month = month;
            [self beginAnimationForSwapMonth:nil direction:WKCalendarAnimationDirectionUp];
        };
        [monthView showInView:self];
    }
}

- (void)showYearViewForSelected
{
    if ([self viewWithTag:555])
    {
        WKYearView *yearView = (WKYearView *)[self viewWithTag:555];
        [yearView hiddenFromViewWithYear:self.year];
    }
    else
    {
        WKYearView *yearView = [[WKYearView alloc] initWithFrame:(CGRect){0, 0, self.frame.size.width, self.frame.size.height} year:self.year];
        yearView.tag = 555;
        yearView.layer.zPosition = 1110;
        yearView.didSelectedWithYear = ^(NSInteger year){
            if (year == self.year) return;
            self.year = year;
            [self beginAnimationForSwapMonth:nil direction:WKCalendarAnimationDirectionDown];
        };
        [yearView showInView:self];
    }
}

- (void)showMonthViewFromButton:(UIButton *)button
{
    CGRect frame = button.frame;
    CGFloat position = button.layer.zPosition;
    
    WKMonthView *monthView = [[WKMonthView alloc] initWithFrame:(CGRect){0, 0, self.frame.size.width, self.frame.size.height}];
    monthView.tag = 666;
    monthView.layer.zPosition = 1110;
    monthView.selectedMonth = self.month;
    monthView.didSelectedMonth = ^(NSInteger month){
        if (month == self.month) return;
        self.month = month;
        [self beginAnimationForSwapMonth:nil direction:WKCalendarAnimationDirectionUp];
    };
    CGRect dstFrame = (CGRect){0, 0, self.frame.size.width, 60};
    CGRect monthFrame = monthView.frame;
    monthView.frame = dstFrame;
    button.layer.zPosition = 1000;
    button.backgroundColor = UIColor.whiteColor;
    [UIView animateWithDuration:0.3f animations:^{
        button.frame = dstFrame;
    } completion:^(BOOL finished) {
        button.frame = frame;
        button.layer.zPosition = position;
        [self addSubview:monthView];
        [UIView animateWithDuration:0.3f animations:^{
            monthView.frame = monthFrame;
        }];
    }];
}

- (void)showYearViewFromButton:(UIButton *)button
{
    CGRect frame = button.frame;
    CGFloat position = button.layer.zPosition;
    WKYearView *yearView = [[WKYearView alloc] initWithFrame:(CGRect){0, 0, self.frame.size.width, self.frame.size.height} year:self.year];
    yearView.tag = 555;
    yearView.layer.zPosition = 1110;
    yearView.didSelectedWithYear = ^(NSInteger year){
        if (year == self.year) return;
        self.year = year;
        [self beginAnimationForSwapMonth:nil direction:WKCalendarAnimationDirectionDown];
    };
    CGRect dstFrame = (CGRect){0, 0, self.frame.size.width, 60};
    CGRect yearFrame = yearView.frame;
    yearView.frame = dstFrame;
    button.layer.zPosition = 1000;
    button.backgroundColor = UIColor.whiteColor;
    [UIView animateWithDuration:0.3f animations:^{
        button.frame = dstFrame;
    } completion:^(BOOL finished) {
        button.frame = frame;
        button.layer.zPosition = position;
        [self addSubview:yearView];
        [UIView animateWithDuration:0.3f animations:^{
            yearView.frame = yearFrame;
        }];
    }];
}

@end
