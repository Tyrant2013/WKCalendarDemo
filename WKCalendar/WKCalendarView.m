//
//  WKCalendarView.m
//  WKCalendarDemo
//
//  Created by ZhuangXiaowei on 14-9-9.
//  Copyright (c) 2014年 Tyrant. All rights reserved.
//

#import "WKCalendarView.h"
#import "ArrowButton.h"
#import "WKMonthView.h"
#import "WKYearView.h"
#import "DateTime/WKDateTimeView.h"
#import "WKCalendarDayView.h"
#import "WKCalendarYearMonthView.h"

#define MONTH_DAY_PANEL_VIEW_TAG 328

typedef NS_ENUM(NSInteger, WKCalendarAnimationDirection)
{
    WKCalendarAnimationDirectionUp,
    WKCalendarAnimationDirectionRight,
    WKCalendarAnimationDirectionDown,
    WKCalendarAnimationDirectionLeft
};

@interface WKCalendarView()<
  WKCalendarDayViewDelegate,
  WKCalendarYearMonthViewDelegate
>

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
    _colTotal = 7;
    _rowTotal = 5;
    _colPadding = 2;
    _rowPadding = 2;
    _headerTotalHeight = 80;
    _heaerResultHeight = 30;
    
    _cellWidth = (self.frame.size.width - (self.colPadding * self.colTotal)) / self.colTotal;
    _cellHeight = (self.frame.size.height - self.headerTotalHeight - (self.rowPadding * self.rowTotal)) / self.rowTotal;
    
    self.weekDaysChinese = @{@"Sunday":@"日",
                             @"Monday":@"一",
                             @"Tuesday":@"二",
                             @"Wednesday":@"三",
                             @"Thursday":@"四",
                             @"Friday":@"五",
                             @"Saturday":@"六"};
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear|NSCalendarUnitHour|NSCalendarUnitMinute
                                                                   fromDate:[NSDate date]];
    _time = [self changeToTimeValueFormHour:components.hour minute:components.minute];
    _day = components.day;
    _month = components.month;
    _year = components.year;
    
    _currentDay = components.day;
    _currentMonth = components.month;
    _currentYear = components.year;
    
    UISwipeGestureRecognizer *swipeUpGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture:)];
    swipeUpGesture.direction = UISwipeGestureRecognizerDirectionUp;
    [self addGestureRecognizer:swipeUpGesture];
    
    UISwipeGestureRecognizer *swipeDownGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture:)];
    swipeDownGesture.direction = UISwipeGestureRecognizerDirectionDown;
    [self addGestureRecognizer:swipeDownGesture];
}

- (NSString *)changeToTimeValueFormHour:(NSInteger)hour minute:(NSInteger)minute
{
    NSString *time;
    NSString *hourStr = [NSString stringWithFormat:hour >= 10 ? @"%d" : @"0%d", hour];
    NSString *minStr = [NSString stringWithFormat:minute >= 10 ? @"%d" : @"0%d", minute];
    time = [NSString stringWithFormat:@"%@:%@", hourStr, minStr];
    return time;
}

- (void)swipeGesture:(UISwipeGestureRecognizer *)gesture
{
    switch (gesture.direction) {
        case UISwipeGestureRecognizerDirectionDown:
            [self showYearViewForSelected];
            break;
        case UISwipeGestureRecognizerDirectionUp:
            [self showMonthViewForSelected];
            break;
        default:
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
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(calendarView:didSelectedChange:)])
    {
        NSString *date = [self changeToStringFromYear:self.year month:self.month day:self.day];
        NSString *result;
        if (self.resultType == WKCalendarViewTypeSimpleDateTime)
        {
            result = [NSString stringWithFormat:@"%@ %@", date, self.time];
        }
        else
        {
            result = date;
        }
        [self.delegate calendarView:self didSelectedChange:result];
    }
    
    [self addButton];
    [self addResult];
    
    [self addArrowButton];
    [self addTitleInfomation:context offset:colOffset];
    
    [self addWeekdays:context offset:colOffset];
    
    [self addDayPanel:context offset:colOffset rect:rect];
}

//添加两边的按钮
- (void)addButton
{
    if (self.resultType != WKCalendarViewTypeDouble) return;
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat buttonWidth = 50;
    CGFloat height = self.heaerResultHeight - 2;
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
        case WKCalendarViewTypeSimpleDateTime:
        case WKCalendarViewTypeSimpleYearMonth:
            [self addSimpleResult];
            break;
        case WKCalendarViewTypeDouble:
        case WKCalendarViewTypeDoubleYearMonth:
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

    NSString *dateValue = [self changeToStringFromYear:self.year month:self.month day:self.day];
    if (self.resultType == WKCalendarViewTypeSimpleDateTime)
    {
        dateValue = [NSString stringWithFormat:@"%@  %@", dateValue, self.time];
    }
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
    NSString *beginDate = [self changeToStringFromYear:self.beginYear month:self.beginMonth day:self.beginDay];
    NSString *endDate = [self changeToStringFromYear:self.endYear month:self.endMonth day:self.endDay];
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

- (NSString *)changeToStringFromYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day
{
    NSString *date;
    NSString *monValue = [NSString stringWithFormat:month >= 10 ? @"%d": @"0%d", month];
    NSString *dayValue = [NSString stringWithFormat:day >= 10 ? @"%d": @"0%d", day];
    if (self.resultType == WKCalendarViewTypeSimpleYearMonth || self.resultType == WKCalendarViewTypeDoubleYearMonth)
    {
        date = [NSString stringWithFormat:@"%d-%@", year, monValue];
    }
    else
    {
        date = [NSString stringWithFormat:@"%d-%@-%@", year, monValue, dayValue];
    }
    return date;
}

- (void)cancelButtonTouchUpInside:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(calendarView:didSelectedStartDate:endDate:)])
    {
        [self.delegate calendarView:self didSelectedStartDate:nil endDate:nil];
    }
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
            case WKCalendarViewTypeSimpleYearMonth:
                startDate = endDate = [NSString stringWithFormat:@"%d-%d-%d", self.year, self.month, self.day];
                break;
            case WKCalendarViewTypeDouble:
            case WKCalendarViewTypeDoubleYearMonth:
                startDate = [NSString stringWithFormat:@"%d-%d-%d", self.beginYear, self.beginMonth, self.beginDay];
                endDate = [NSString stringWithFormat:@"%d-%d-%d", self.endYear, self.endMonth, self.endDay];
                break;
            case WKCalendarViewTypeSimpleDateTime:
                startDate = endDate = [NSString stringWithFormat:@"%d-%d-%d %@", self.year, self.month, self.day, self.time];
                break;
        }
        [self.delegate calendarView:self didSelectedStartDate:startDate endDate:endDate];
    }
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
        [left addTarget:self action:@selector(preButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:left];
    }
    
    if (![self viewWithTag:1002])
    {
        ArrowButton *right = [[ArrowButton alloc] initWithFrame:(CGRect){self.frame.size.width - 44, y, 44, height}];
        right.backgroundColor = UIColor.whiteColor;
        right.layer.transform = CATransform3DMakeRotation(M_PI, 0, 1, 0);
        right.tag = 1002;
        [right addTarget:self action:@selector(nextButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:right];
    }
}

- (void)preButtonClick:(UIButton *)button
{
    if (self.resultType != WKCalendarViewTypeSimpleYearMonth && self.resultType != WKCalendarViewTypeDoubleYearMonth)
    {
        --self.month;
        if (self.month <= 0)
        {
            self.month = 12;
            --self.year;
        }
        self.isShowAnimation = YES;
    }
    else
    {
        --self.year;
    }
    [self beginAnimationForSwapMonth:nil direction:WKCalendarAnimationDirectionLeft];
}

- (void)nextButtonClick:(UIButton *)button
{
    if (self.resultType == WKCalendarViewTypeDoubleYearMonth || self.resultType == WKCalendarViewTypeSimpleYearMonth)
    {
        ++self.year;
    }
    else
    {
        ++self.month;
        if (self.month > 12)
        {
            self.month = 1;
            ++self.year;
        }
        self.isShowAnimation = YES;
    }
    [self beginAnimationForSwapMonth:nil direction:WKCalendarAnimationDirectionRight];
}

- (void)beginAnimationForSwapMonth:(UIView *)oldMonthView direction:(WKCalendarAnimationDirection)direction
{
    CGRect frame;
    if (self.resultType == WKCalendarViewTypeSimpleYearMonth || self.resultType == WKCalendarViewTypeDoubleYearMonth)
    {
        WKCalendarYearMonthView *yearMonthView = (WKCalendarYearMonthView *)[self viewWithTag:MONTH_DAY_PANEL_VIEW_TAG];
        frame = yearMonthView.frame;
        if (!oldMonthView)
        {
            [self setNeedsDisplay];
            oldMonthView = [yearMonthView snapshotViewAfterScreenUpdates:NO];
        }
    }
    else
    {
        WKCalendarDayView *dayView = (WKCalendarDayView *)[self viewWithTag:MONTH_DAY_PANEL_VIEW_TAG];
        dayView.day = self.day;
        dayView.month = self.month;
        dayView.year = self.year;
        frame = dayView.frame;
        if (!oldMonthView)
        {
            [self setNeedsDisplay];
            oldMonthView = [dayView snapshotViewAfterScreenUpdates:NO];
            [dayView reloadData];
        }
    }
    
    oldMonthView.backgroundColor = UIColor.whiteColor;
    oldMonthView.layer.zPosition = 1024;
    oldMonthView.frame = frame;
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
    CGFloat x = 45;
    CGFloat y = self.heaerResultHeight + 2;
    CGFloat width = (self.frame.size.width - 88) / 2 - 1;
    CGColorRef borderColor = grayColor240.CGColor;
    
    if (self.resultType == WKCalendarViewTypeSimpleDateTime)
    {
        width = (self.frame.size.width - 88) / 3 - 1;
    }
    CGFloat height = 20;
    UIButton *yearButton = (UIButton *)[self viewWithTag:1101];
    if (!yearButton)
    {
        yearButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        yearButton.frame = (CGRect){x, y, width, height};
        yearButton.tag = 1101;
        [yearButton addTarget:self action:@selector(showYearViewFromButton:) forControlEvents:UIControlEventTouchUpInside];
        yearButton.layer.borderColor = borderColor;
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
        [monthButton addTarget:self action:@selector(showMonthViewFromButton:) forControlEvents:UIControlEventTouchUpInside];
        monthButton.layer.borderColor = borderColor;
        monthButton.layer.borderWidth = 1.0f;
        [self addSubview:monthButton];
    }
    
    if (self.resultType == WKCalendarViewTypeSimpleDateTime)
    {
        x += width;
        UIButton *timeButton = (UIButton *)[self viewWithTag:1103];
        if (!timeButton)
        {
            timeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            timeButton.frame = (CGRect){x, y, width, height};
            timeButton.tag = 1103;
            timeButton.layer.borderWidth = 1.0f;
            timeButton.layer.borderColor = borderColor;
            [timeButton addTarget:self action:@selector(showTimeViewFrombutton:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:timeButton];
        }
        [timeButton setTitle:[NSString stringWithFormat:@"%@", self.time] forState:UIControlStateNormal];
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
    if (self.resultType == WKCalendarViewTypeDoubleYearMonth || self.resultType == WKCalendarViewTypeSimpleYearMonth)
    {
        WKCalendarYearMonthView *yearMonthView = (WKCalendarYearMonthView *)[self viewWithTag:MONTH_DAY_PANEL_VIEW_TAG];
        if (!yearMonthView)
        {
            yearMonthView = [[WKCalendarYearMonthView alloc] initWithYear:self.year month:self.month frame:(CGRect){0, self.headerTotalHeight - 20, rect.size.width, rect.size.height - self.headerTotalHeight + 20}];
            yearMonthView.delegate = self;
            yearMonthView.tag = MONTH_DAY_PANEL_VIEW_TAG;
            [self addSubview:yearMonthView];
        }
        else
        {
            yearMonthView.year = self.year;
            yearMonthView.month = self.month;
        }
    }
    else
    {
        WKCalendarDayView *dayView = (WKCalendarDayView *)[self viewWithTag:MONTH_DAY_PANEL_VIEW_TAG];
        if (!dayView)
        {
            dayView = [[WKCalendarDayView alloc] initWithYear:self.year month:self.month day:self.day frame:(CGRect){0, self.headerTotalHeight, rect.size.width,rect.size.height - self.headerTotalHeight}];
            dayView.delegate = self;
            dayView.tag = MONTH_DAY_PANEL_VIEW_TAG;
            [self addSubview:dayView];
        }
        else
        {
            //            [dayView reloadData];
        }
    }
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
        WKMonthView *monthView = [[WKMonthView alloc] initWithFrame:(CGRect){0, 0, self.frame.size.width, self.frame.size.height}];
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

#pragma mark - 两个箭头中间的按钮

- (void)showMonthViewFromButton:(UIButton *)button
{
    if (self.resultType == WKCalendarViewTypeSimpleYearMonth || self.resultType == WKCalendarViewTypeDoubleYearMonth)
    {
        //do nothing
        return;
    }
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

- (void)showTimeViewFrombutton:(UIButton *)button
{
    CGRect frame = button.frame;
    CGFloat position = button.layer.zPosition;
    WKDateTimeView *dateTimeView = [[WKDateTimeView alloc] initWithFrame:(CGRect){0,0,self.frame.size.width, self.frame.size.height}];
    dateTimeView.didSelectedTime = ^(NSString *time){
        if (time)
        {
            self.time = time;
            [self setNeedsDisplay];
        }
    };
    CGRect dstFrame = (CGRect){50, 0, self.frame.size.width - 100, 40};
    CGRect timeFrame = dateTimeView.frame;
    dateTimeView.frame = dstFrame;
    dateTimeView.tag = 777;
    dateTimeView.time = self.time;
    button.layer.zPosition = 1110;
    button.backgroundColor = UIColor.whiteColor;
    [UIView animateWithDuration:0.3f animations:^{
        button.frame = dstFrame;
    } completion:^(BOOL finished) {
        button.frame = frame;
        button.layer.zPosition = position;
        [self addSubview:dateTimeView];
        [UIView animateWithDuration:0.3f animations:^{
            dateTimeView.frame = timeFrame;
        }];
    }];
}

#pragma mark - WKCalendarDayView Delegate

- (BOOL)calendarDayView:(WKCalendarDayView *)calendarDayview willDisplaySelectedWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day
{
    if (self.resultType == WKCalendarViewTypeDouble)
    {
        NSDateComponents *beginCompare = [[NSDateComponents alloc] init];
        NSDateComponents *endCompare = [[NSDateComponents alloc] init];
        NSDate *beginDate = [self dateFormYear:self.beginYear month:self.beginMonth day:self.beginDay];
        NSDate *endDate = [self dateFormYear:self.endYear month:self.endMonth day:self.endDay];
        NSDate *date = [self dateFormYear:year month:month day:day];
        beginCompare = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:date toDate:beginDate options:NSCalendarWrapComponents];
        endCompare = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:date toDate:endDate options:NSCalendarWrapComponents];
//        NSLog(@"%d", (beginCompare.day < 0 && endCompare.day > 0) || beginCompare.day == 0 || endCompare.day == 0);
        return (beginCompare.day < 0 && endCompare.day > 0) || beginCompare.day == 0 || endCompare.day == 0;
    }
    else
    {
        return (day == self.day && month == self.month && year == self.year);
    }
    
}

- (void)calendarDayView:(WKCalendarDayView *)calendarDayView didSelectedPreMonthDay:(NSInteger)day
{
    [self didSelectedDay:day month:calendarDayView.month year:calendarDayView.year];
}

- (void)calendarDayView:(WKCalendarDayView *)calendarDayView didSelectedCurrentMonthDay:(NSInteger)day
{
    [self didSelectedDay:day month:calendarDayView.month year:calendarDayView.year];
}

- (void)calendarDayView:(WKCalendarDayView *)calendarDayView didSelectedNextMonthDay:(NSInteger)day
{
    [self didSelectedDay:day month:calendarDayView.month year:calendarDayView.year];
}

- (void)calendarDayView:(WKCalendarDayView *)calendarDayView didMonthChange:(NSInteger)month
{
    self.month = month;
    self.year = calendarDayView.year;
    [self setNeedsDisplay];
}

- (void)didSelectedDay:(NSInteger)day month:(NSInteger)month year:(NSInteger)year
{
    switch (self.resultType)
    {
        case WKCalendarViewTypeSimple:
        case WKCalendarViewTypeSimpleDateTime:
        case WKCalendarViewTypeSimpleYearMonth:
            [self dealWithSimpleWithDay:day month:month year:year];
            break;
            
        case WKCalendarViewTypeDouble:
        case WKCalendarViewTypeDoubleYearMonth:
            [self dealWithRangeWithDay:day month:month year:year];
            break;
    }
    [self setNeedsDisplay];
}

- (void)dealWithSimpleWithDay:(NSInteger)day month:(NSInteger)month year:(NSInteger)year
{
    self.day = day;
    self.month = month;
    self.year = year;
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

#pragma mark - WKCalendarYearView Delegate

- (void)calendarYearMonthView:(WKCalendarYearMonthView *)calendarYearMonthView didSelectedMonth:(NSInteger)month
{
    self.month = month;
    [self setNeedsDisplay];
}

- (void)calendarYearMonthView:(WKCalendarYearMonthView *)calendarYearMonthView didYearChange:(NSInteger)year
{
    self.year = year;
    [self setNeedsDisplay];
}

@end
