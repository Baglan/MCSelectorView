//
//  MCSelectorView.m
//  InteractiveVideoTest
//
//  Created by Baglan on 7/25/13.
//  Copyright (c) 2013 MobileCreators. All rights reserved.
//

#import "MCSelectorView.h"

#define MCSelectorView_UnselectedOptionAlpha    0.4

@interface MCSelectorView () <UIScrollViewDelegate>

@property (nonatomic, assign) NSUInteger page;

@end

@implementation MCSelectorView {
    UIScrollView * _scrollView;
    NSTimeInterval _timeout;
    NSTimer * _timeoutTimer;
    BOOL _presented;
    BOOL _laidOut;
}

- (id)init
{
    self = [super init];
    if (self) {
        _laidOut = NO;
        
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _scrollView.hidden = YES;
        [self addSubview:_scrollView];
        // _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
        
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)]];
    }
    return self;
}

- (void)tap:(UITapGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:self];
    [self.optionViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView * view = obj;
        if (CGRectContainsPoint(view.frame, location)) {
            CGRect optionRect = [self.dataSource optionRectForSelectorView:self];
            [_scrollView setContentOffset:CGPointMake(optionRect.size.width * idx, 0) animated:YES];
            *stop = YES;
        }
    }];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (self.superview) {
        [self.superview removeGestureRecognizer:_scrollView.panGestureRecognizer];
    }
    [newSuperview addGestureRecognizer:_scrollView.panGestureRecognizer];
}

- (void)layoutSubviews
{
    if (self.dataSource) {
        CGRect optionRect = [self.dataSource optionRectForSelectorView:self];
        _scrollView.frame = CGRectMake(0, 0, optionRect.size.width, optionRect.size.height);
        _scrollView.contentSize = CGSizeMake(optionRect.size.width * self.optionViews.count, optionRect.size.height);
        _scrollView.contentOffset = CGPointMake(optionRect.size.width * _highlightedIndex, 0);
        [self.optionViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UIView * view = obj;
            CGRect frame = CGRectMake(optionRect.size.width * idx, 0, optionRect.size.width, optionRect.size.height);
            view.frame = frame;
        }];
        self.transform = CGAffineTransformIdentity;
        self.frame = CGRectMake(optionRect.origin.x, optionRect.origin.y, optionRect.size.width * self.optionViews.count, optionRect.size.height);
        self.transform = CGAffineTransformMakeTranslation(-_scrollView.contentOffset.x, 0);
    }
    [self updateOptions];
    _laidOut = YES;
}

#pragma mark - Present, dismiss and reload

- (void)reloadData
{
    [self.optionViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView * view = obj;
        [view removeFromSuperview];
    }];
    self.optionViews = nil;
    [self setNeedsLayout];
}

- (void)presentWithTimeout:(NSTimeInterval)timeout
{
    [self setNeedsLayout];
    
    _timeout = timeout;
    
    if ([self.delegate respondsToSelector:@selector(willPresentSelectorView:)]) {
        [self.delegate willPresentSelectorView:self];
    }
    
    self.hidden = NO;
    self.alpha = 0.0;
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1.0;
    } completion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(didPresentSelectorView:)]) {
            [self.delegate didPresentSelectorView:self];
        }
        [self resetTimeout];
    }];
    
    _presented = YES;
}

- (void)present
{
    [self presentWithTimeout:0];
}

- (void)dismiss
{
    if ([self.delegate respondsToSelector:@selector(willDismissSelectorView:)]) {
        [self.delegate willDismissSelectorView:self];
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.hidden = YES;
        
        if ([self.delegate respondsToSelector:@selector(didDismissSelectorView:)]) {
            [self.delegate didDismissSelectorView:self];
        }
    }];
    
    _presented = NO;
}

#pragma mark - Properties

- (NSArray *)optionViews
{
    // Initialize lazily
    if (!_optionViews) {
        _optionViews = [self.dataSource optionViewsForSelectorView:self];
        [_optionViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [self addSubview:obj];
        }];
    }
    return _optionViews;
}

- (void)setIndex:(NSUInteger)index
{
    [self setIndex:index animated:NO];
}

- (void)setIndex:(NSUInteger)index animated:(BOOL)animated
{
    if (!_laidOut) {
        _index = index;
        _highlightedIndex = index;
    }
    
    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width * index, 0) animated:animated];
}

#pragma mark - Internals

- (void)resetTimeout
{
    [_timeoutTimer invalidate];
    _timeoutTimer = nil;
    if (_timeout > 0) {
        _timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(dismiss) userInfo:nil repeats:NO];
    }
}

- (NSUInteger)page
{
    return roundf(_scrollView.contentOffset.x / _scrollView.frame.size.width);
}

- (void)updateOptions
{
    [self.optionViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView * view = obj;
        if (idx == _highlightedIndex) {
            view.alpha = 1.0;
        } else {
            view.alpha = MCSelectorView_UnselectedOptionAlpha;
        }
        
        if ([self.delegate respondsToSelector:@selector(selectorView:updateOptionView:atIndex:)]) {
            [self.delegate selectorView:self updateOptionView:view atIndex:idx];
        }
    }];
}

- (void)updateForHighlightedIndex:(NSUInteger)highlightedIndex
{
    _highlightedIndex = highlightedIndex;
    [self updateOptions];
    
    if ([self.delegate respondsToSelector:@selector(selectorView:didHighlightOptionAtIndex:)]) {
        [self.delegate selectorView:self didHighlightOptionAtIndex:highlightedIndex];
    }
}

- (void)updateForSelectedIndex:(NSUInteger)selectedIndex
{
    _index = selectedIndex;
    if ([self.delegate respondsToSelector:@selector(selectorView:didSelectOptionAtIndex:)]) {
        [self.delegate selectorView:self didSelectOptionAtIndex:selectedIndex];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    _hasStopped = NO;
    
    self.transform = CGAffineTransformMakeTranslation(-scrollView.contentOffset.x, 0);
    
    NSUInteger page = self.page;
    
    // If page changed and delegate is OK with this change, reflect it
    if (page != _highlightedIndex && ([self.delegate respondsToSelector:@selector(selectorView:shouldHighlightOptionAtIndex:)] ? [self.delegate selectorView:self shouldHighlightOptionAtIndex:page] : YES)) {
        [self updateForHighlightedIndex:page];
    }
    
    [self checkIfShouldUpdateIndex];
    
    [self resetTimeout];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGFloat pageWidth = scrollView.frame.size.width;
    NSInteger pages = ceilf(scrollView.contentSize.width / pageWidth);
    NSInteger page = roundf(targetContentOffset->x / pageWidth);
    
    if (page>=0 && page <pages) {
        targetContentOffset->x = page * scrollView.frame.size.width;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    _isDragging = NO;
    
    if (!decelerate) {
        _hasStopped = YES;
        [self checkIfShouldUpdateIndex];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _hasStopped = YES;
    [self checkIfShouldUpdateIndex];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _isDragging = YES;
}

- (void)checkIfShouldUpdateIndex
{
    NSUInteger page = self.page;
    
    // If index changed and delegate is OK with is, update it
    if (_index != page && ([self.delegate respondsToSelector:@selector(selectorView:shouldSelectOptionAtIndex:)] ? [self.delegate selectorView:self shouldSelectOptionAtIndex:page] : YES)) {
        [self updateForSelectedIndex:page];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    _hasStopped = YES;
    [self checkIfShouldUpdateIndex];
}

#pragma mark - Pan Gesture Recognizer

- (void)detachPanGestureRecognizer
{
    UIPanGestureRecognizer * recognizer = _scrollView.panGestureRecognizer;
    [recognizer.view removeGestureRecognizer:recognizer];
}

- (void)attachPanGestureRecognizerToView:(UIView *)view
{
    [view addGestureRecognizer:_scrollView.panGestureRecognizer];
}

@end
