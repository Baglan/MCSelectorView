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
    MCSelectorView * _horizontalSelectorView;
    MCSelectorView * _verticalSelectorView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    // Horizontal
    _horizontalSelectorView = [[MCSelectorView alloc] init];
    _horizontalSelectorView.dataSource = self;
    _horizontalSelectorView.delegate = self;
    [_horizontalContainerView addSubview:_horizontalSelectorView];
    [_horizontalSelectorView present];
    
    [_horizontalSelectorView scrollToIndex:2 animated:NO];

    _horizontalSampleLabel.hidden = YES;

    // Vertical
    _verticalSelectorView = [[MCSelectorView alloc] init];
    _verticalSelectorView.dataSource = self;
    _verticalSelectorView.delegate = self;
    _verticalSelectorView.layoutType = MCSelectorViewLayoutType_Vertical;
    [_verticalContainerView addSubview:_verticalSelectorView];
    [_verticalSelectorView present];
    
    [_verticalSelectorView scrollToIndex:2 animated:NO];
    
    _verticalSampleLabel.hidden = YES;
}

- (UILabel *)copyLabel {
    UILabel * label = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:_horizontalSampleLabel]];
    label.hidden = NO;
    return label;
}

#pragma mark - MCSelectorViewDelegate

- (void)selectorView:(MCSelectorView *)selectorView didSelectOptionAtIndex:(NSUInteger)index
{
    if (selectorView == _horizontalSelectorView) {
        NSLog(@"--- horizontal: %d", index);
    }
    
    if (selectorView == _verticalSelectorView) {
        NSLog(@"--- vertical: %d", index);
    }
}

- (void)selectorView:(MCSelectorView *)selectorView updateOptionView:(UIView *)view atIndex:(NSUInteger)index
{
    UILabel * label = (UILabel *)view;
    label.textColor = selectorView.highlightedIndex == index ? [UIColor colorWithRed:0.6 green:0.6 blue:1.0 alpha:1.0] : [UIColor whiteColor];
}

#pragma mark - MCSelectorViewDataSource

- (CGRect)optionRectForSelectorView:(MCSelectorView *)view
{
    CGRect frame = CGRectZero;
    
    if (view == _horizontalSelectorView) {
        frame = _horizontalSampleLabel.frame;
    }
    
    if (view == _verticalSelectorView) {
        frame = _verticalSampleLabel.frame;
    }
    
    return frame;
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
