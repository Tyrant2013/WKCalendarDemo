//
//  ViewController.m
//  WKCalendarDemo
//
//  Created by ZhuangXiaowei on 14-9-9.
//  Copyright (c) 2014年 Tyrant. All rights reserved.
//

#import "ViewController.h"
#import "WKCalendarView.h"
#import "WKDateTimeView.h"

@interface ViewController ()

@property (nonatomic, weak) WKCalendarView *calendar;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = UIColor.whiteColor;
    WKCalendarView *calendar = [[WKCalendarView alloc] initWithFrame:(CGRect){10,150,0,0}];
    calendar.resultType = WKCalendarViewTypeSimple;
    [self.view addSubview:calendar];
    
    self.calendar = calendar;
}


- (IBAction)switchType:(UISegmentedControl *)sender
{
    WKCalendarViewType t;
    switch (sender.selectedSegmentIndex)
    {
        case 0:
            t = WKCalendarViewTypeSimple;
            break;
        case 1:
            t = WKCalendarViewTypeDoubleYearMonth;
            break;
        default:
            t = WKCalendarViewTypeSimpleDateTime;
            break;
    }
    self.calendar.resultType = t;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
