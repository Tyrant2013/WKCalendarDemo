//
//  WKCalendarDayView.m
//  WKCalendarDemo
//
//  Created by ZhuangXiaowei on 14-9-28.
//  Copyright (c) 2014年 Tyrant. All rights reserved.
//

#import "WKCalendarDayView.h"
#import "WKCalendarViewCell.h"

@interface WKCalendarDayView()

@property (nonatomic) NSInteger colTotal;//number of col
@property (nonatomic) NSInteger rowTotal;//number of row
@property (nonatomic) NSInteger cellWidth;//with of cell
@property (nonatomic) NSInteger cellHeight;//height of cell
@property (nonatomic) NSInteger colPadding;//horizon padding between cell
@property (nonatomic) NSInteger rowPadding;//vertical padding between cell
@property (nonatomic) NSInteger currentYear;
@property (nonatomic) NSInteger currentMonth;
@property (nonatomic) NSInteger currentDay;

@end

@implementation WKCalendarDayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = UIColor.whiteColor;
    }
    return self;
}

- (id)initWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear|NSCalendarUnitHour|NSCalendarUnitMinute
                                                                       fromDate:[NSDate date]];
        _year = year;
        _month = month;
        _day = day;
        
        _currentDay = components.day;
        _currentMonth = components.month;
        _currentYear = components.year;
        
        self.backgroundColor = UIColor.whiteColor;
        _colTotal = 7;
        _rowTotal = 6;
        _colPadding = 2;
        _rowPadding = 2;
        _cellWidth = (self.frame.size.width - (self.colPadding * self.colTotal)) / self.colTotal;
        _cellHeight = (self.frame.size.height - (self.rowPadding * self.rowTotal)) / self.rowTotal;
        
        [self initGestureRecognizer];
    }
    return self;
}

- (void)initGestureRecognizer
{
    UISwipeGestureRecognizer *swipeLeftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture:)];
    swipeLeftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:swipeLeftGesture];
    
    UISwipeGestureRecognizer *swipeRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture:)];
    swipeRightGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:swipeRightGesture];
}

- (void)swipeGesture:(UISwipeGestureRecognizer *)gesture
{
    switch (gesture.direction)
    {
        case UISwipeGestureRecognizerDirectionLeft:
            if (++self.month > 12)
            {
                self.month = 1;
                ++self.year;
            }
            [self animationForSwipe:-1];
            break;
        case UISwipeGestureRecognizerDirectionRight:
            if (--self.month < 1)
            {
                self.month = 12;
                --self.year;
            }
            [self animationForSwipe:1];
            break;
        default:
            break;
    }
}

- (void)animationForSwipe:(NSInteger)sign
{
    CGFloat offset = sign * self.frame.size.width;
    UIView *oldView = [self snapshotViewAfterScreenUpdates:NO];
    oldView.layer.zPosition = 1024;
    [self addSubview:oldView];
    [self setNeedsDisplay];
    if (self.delegate && [((NSObject *)self.delegate) respondsToSelector:@selector(calendarDayView:didMonthChange:)])
    {
        [self.delegate calendarDayView:self didMonthChange:self.month];
    }
    [UIView animateWithDuration:0.3f animations:^{
        oldView.frame = CGRectOffset(oldView.frame, offset, 0);
    } completion:^(BOOL finished) {
        [oldView removeFromSuperview];
    }];
}

- (void)reloadData
{
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, rect.size.width, 0);
    CGContextStrokePath(context);
    
    NSInteger totalWidth = CGRectGetWidth(self.frame);
    NSInteger colOffset = (totalWidth - (self.colTotal * (self.cellWidth + self.colPadding) - self.colPadding)) / 2;
    [self addDayPanelWithOffset:colOffset rect:rect];
}

- (void)addDayPanelWithOffset:(NSInteger)colOffset rect:(CGRect)rect
{
    NSInteger dayOfMonth = [self getTotalDayInMonth:self.month year:self.year];
    NSInteger preDayOfMonth = [self getTotalDayInMonth:self.month - 1 year:self.year];
    NSInteger firstWeekday = [self getWeekdayInDay:1 month:self.month year:self.year] - 1;
    for (UIView *view in self.subviews)
    {
        if (view.tag == 1000)
            [ view removeFromSuperview];
    }
    
    for (int i = 0; i < self.rowTotal; ++i)
    {
        NSInteger y = (self.cellHeight + self.rowPadding ) * i + 1;
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
                if (--month < 1)
                {
                    month = 12;
                    --year;
                }
                tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(preMonthCellDidTouchedUpInside:)];
                cell.isCurrentMonthDay = NO;
            }
            else if (--dayOfMonth < 0)
            {
                //                break;//最后一天
                day = abs(dayOfMonth);
                if (++month > 12)
                {
                    month = 1;
                    ++year;
                }
                tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nextMonthCellDidTouchedUpInside:)];
                cell.isCurrentMonthDay = NO;
            }
            else
            {
                day = checkDay;
                tapGesture  = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellDidTouchedUpInside:)];
                cell.isCurrentMonthDay = YES;
            }
            
            cell.tag = 1000;
            cell.day = day;
            cell.isWorkday = !(j == 0 || j == 6);
            cell.isCurrentDay = day == self.currentDay && self.currentYear == year && self.currentMonth == month;

            if (self.delegate && [((NSObject *)self.delegate) respondsToSelector:@selector(calendarDayView:willDisplaySelectedWithYear:month:day:)])
            {
                cell.isSelected = [self.delegate calendarDayView:self willDisplaySelectedWithYear:year month:month day:day];
            }
            
            [cell addGestureRecognizer:tapGesture];
            [self addSubview:cell];
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
    self.day = day;
    if (self.delegate && [((NSObject *)self.delegate) respondsToSelector:@selector(calendarDayView:didSelectedCurrentMonthDay:)])
    {
        [self.delegate calendarDayView:self didSelectedCurrentMonthDay:day];
        [self setNeedsDisplay];
    }
}

//上一个月的天数
- (void)preMonthCellDidTouchedUpInside:(UITapGestureRecognizer *)tapGuesture
{
    WKCalendarViewCell *cell = (WKCalendarViewCell *)tapGuesture.view;
    NSInteger day = cell.day;
    self.day = day;
    if (--self.month < 1)
    {
        self.month = 1;
        --self.year;
    }
    if (self.delegate && [((NSObject *)self.delegate) respondsToSelector:@selector(calendarDayView:didSelectedPreMonthDay:)])
    {
        [self.delegate calendarDayView:self didSelectedPreMonthDay:day];
        [self setNeedsDisplay];
    }
}

//下一个月的天数
- (void)nextMonthCellDidTouchedUpInside:(UITapGestureRecognizer *)tapGuesture
{
    WKCalendarViewCell *cell = (WKCalendarViewCell *)tapGuesture.view;
    NSInteger day = cell.day;
    self.day = day;
    if (++self.month > 12)
    {
        self.month = 12;
        ++self.year;
    }
    if (self.delegate && [((NSObject *)self.delegate) respondsToSelector:@selector(calendarDayView:didSelectedNextMonthDay:)])
    {
        [self.delegate calendarDayView:self didSelectedNextMonthDay:day];
        [self setNeedsDisplay];
    }
}

@end
