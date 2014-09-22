//
//  ViewController.m
//  WKCalendarDemo
//
//  Created by ZhuangXiaowei on 14-9-9.
//  Copyright (c) 2014年 Tyrant. All rights reserved.
//

#import "ViewController.h"
#import "WKCalendarView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = UIColor.whiteColor;
    WKCalendarView *calendar = [[WKCalendarView alloc] initWithFrame:(CGRect){10,100,0,0}];
    calendar.resultType = WKCalendarViewTypeSimple;
    [self.view addSubview:calendar];
//    calendar.backgroundColor = UIColor.whiteColor;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
