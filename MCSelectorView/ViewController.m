//
//  ViewController.m
//  MCSelectorView
//
//  Created by Baglan on 7/30/13.
//  Copyright (c) 2013 MobileCreators. All rights reserved.
//

#import "ViewController.h"
#import "MCSelectorView.h"

@interface ViewController () <MCSelectorViewDataSource, MCSelectorViewDelegate>

@end

@implementation ViewController {
    MCSelectorView * _selectorView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    _selectorView = [[MCSelectorView alloc] init];
    _selectorView.dataSource = self;
    _selectorView.delegate = self;
    [self.view addSubview:_selectorView];
    [_selectorView present];
    
    [_selectorView scrollToIndex:2 animated:NO];

    _sampleLabel.hidden = YES;
}

- (UILabel *)copyLabel {
    UILabel * label = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:_sampleLabel]];
    label.hidden = NO;
    return label;
}

#pragma mark - MCSelectorViewDelegate

- (void)selectorView:(MCSelectorView *)selectorView didSelectOptionAtIndex:(NSUInteger)index
{
    NSLog(@"--- %d", index);
}

- (void)selectorView:(MCSelectorView *)selectorView updateOptionView:(UIView *)view atIndex:(NSUInteger)index
{
    UILabel * label = (UILabel *)view;
    label.textColor = selectorView.highlightedIndex == index ? [UIColor colorWithRed:0.6 green:0.6 blue:1.0 alpha:1.0] : [UIColor whiteColor];
}

#pragma mark - MCSelectorViewDataSource

- (CGRect)optionRectForSelectorView:(MCSelectorView *)view
{
    return _sampleLabel.frame;
}

- (NSArray *)optionViewsForSelectorView:(MCSelectorView *)view
{
    NSArray * optionTitles = @[@"One", @"Two", @"Three", @"Four", @"Five"];
    NSMutableArray * options = [NSMutableArray array];
    
    [optionTitles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UILabel * label = [self copyLabel];
        label.text = obj;
        [options addObject:label];
    }];
    
    return options;
}

@end
