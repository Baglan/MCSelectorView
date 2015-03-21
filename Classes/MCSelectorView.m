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

@end

@implementation MCSelectorView {
    UIScrollView * _scrollView;
    NSTimeInterval _timeout;
    NSTimer * _timeoutTimer;
    BOOL _presented;
    
    NSInteger _index;
    NSInteger _highlightedIndex;
    
    NSArray * _optionViews;
}

#pragma mark - General

- (id)init
{
    self = [super init];
    if (self) {        
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _scrollView.hidden = YES;
        [self addSubview:_scrollView];
        _scrollView.delegate = self;
        _scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
        
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)]];
        
        _hasStopped = YES;
        _layoutType = MCSelectorViewLayoutType_Horizontal;
    }
    return self;
}

- (void)didMoveToSuperview
{
    [self setNeedsLayout];
}

- (void)tap:(UITapGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:self];
    [self.optionViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView * view = obj;
        if (CGRectContainsPoint(view.frame, location)) {
            [self scrollToIndex:idx animated:YES];
            // Inform delegate
            if ([self.delegate respondsToSelector:@selector(selectorView:didTapOnOptionAtIndex:)]) {
                [self.delegate selectorView:self didTapOnOptionAtIndex:idx];
            }
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
        
        self.transform = CGAffineTransformIdentity;
        self.frame = self.layoutType == MCSelectorViewLayoutType_Horizontal ? CGRectMake(optionRect.origin.x, optionRect.origin.y, optionRect.size.width * self.optionViews.count, optionRect.size.height) : CGRectMake(optionRect.origin.x, optionRect.origin.y, optionRect.size.width, optionRect.size.height * self.optionViews.count);
        
        _scrollView.frame = CGRectMake(0, 0, optionRect.size.width, optionRect.size.height);
        _scrollView.contentSize = self.layoutType == MCSelectorViewLayoutType_Horizontal ? CGSizeMake(optionRect.size.width * self.optionViews.count, optionRect.size.height) : CGSizeMake(optionRect.size.width, optionRect.size.height * self.optionViews.count);
        
        [self.optionViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UIView * view = obj;
            CGRect frame = self.layoutType == MCSelectorViewLayoutType_Horizontal ? CGRectMake(optionRect.size.width * idx, 0, optionRect.size.width, optionRect.size.height) : CGRectMake(0, optionRect.size.height * idx, optionRect.size.width, optionRect.size.height);
            view.frame = frame;
        }];
        
        
    }
    [self onContentOffsetChange];
    
    [super layoutSubviews];
}

#pragma mark - Index

- (NSInteger)index
{
    return [self normalizeIndex:_index];
}

- (NSInteger)normalizeIndex:(NSInteger)index
{
    NSInteger total = _optionViews ? _optionViews.count : 0;
    index = index >= total ? (total - 1) : index;
    index = index < 0 ? 0 : index;
    
    return index;
}

#pragma mark - Delegate

- (void)setDelegate:(id<MCSelectorViewDelegate>)delegate
{
    _delegate = delegate;
    [self setNeedsLayout];
}

#pragma mark - Highlighted index

- (NSInteger)highlightedIndex
{
    return [self normalizeIndex:_highlightedIndex];
}

#pragma mark - Present, dismiss and reload

- (void)reloadData
{
    [self.optionViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView * view = obj;
        [view removeFromSuperview];
    }];
    _optionViews = nil;
    [self setNeedsLayout];
    [self layoutIfNeeded];
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
    
    [UIView animateWithDuration:0.2 delay:0 options:(UIViewAnimationOptionBeginFromCurrentState) animations:^{
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
    
    [UIView animateWithDuration:0.2 delay:0 options:(UIViewAnimationOptionBeginFromCurrentState) animations:^{
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

- (void)setLayoutType:(enum MCSelectorViewLayoutType)layoutType
{
    _layoutType = layoutType;
    [self setNeedsLayout];
    [self layoutIfNeeded];
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

- (void)updateForSelectedIndex:(NSUInteger)selectedIndex
{
    _index = [self normalizeIndex:selectedIndex];
    if ([self.delegate respondsToSelector:@selector(selectorView:didSelectOptionAtIndex:)]) {
        [self.delegate selectorView:self didSelectOptionAtIndex:selectedIndex];
    }
}

#pragma mark - Scrolling

- (void)onContentOffsetChange
{
    CGPoint offset = _scrollView.contentOffset;
    
    self.transform = CGAffineTransformMakeTranslation(-offset.x, -offset.y);

    NSInteger calculatedIndex = self.layoutType == MCSelectorViewLayoutType_Horizontal ? (NSInteger)roundf(offset.x / _scrollView.frame.size.width) : (NSInteger)roundf(offset.y / _scrollView.frame.size.height);
    calculatedIndex = [self normalizeIndex:calculatedIndex];
    
    // Check if highlighted index should be updated
    if (calculatedIndex != _highlightedIndex && ([self.delegate respondsToSelector:@selector(selectorView:shouldHighlightOptionAtIndex:)] ? [self.delegate selectorView:self shouldHighlightOptionAtIndex:calculatedIndex] : YES)) {
        _highlightedIndex = calculatedIndex;
        
        // Inform delegate
        if ([self.delegate respondsToSelector:@selector(selectorView:didHighlightOptionAtIndex:)]) {
            [self.delegate selectorView:self didHighlightOptionAtIndex:_highlightedIndex];
        }
    }
    
    // Check if index should be updated
    if (calculatedIndex != _index && ([self.delegate respondsToSelector:@selector(selectorView:shouldSelectOptionAtIndex:)] ? [self.delegate selectorView:self shouldSelectOptionAtIndex:calculatedIndex] : YES)) {
        _index = calculatedIndex;
        
        // Inform delegate
        if ([self.delegate respondsToSelector:@selector(selectorView:didSelectOptionAtIndex:)]) {
            [self.delegate selectorView:self didSelectOptionAtIndex:_index];
        }
    }
    
    [self updateOptions];
    
    [self resetTimeout];
}

- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated
{
    [self layoutIfNeeded];
    
    CGPoint contentOffset = self.layoutType == MCSelectorViewLayoutType_Horizontal ? CGPointMake(_scrollView.frame.size.width * index, 0) : CGPointMake(0, _scrollView.frame.size.height * index);
    
    [_scrollView setContentOffset:contentOffset animated:animated];
    if (!animated) {
        [self onContentOffsetChange];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    _hasStopped = NO;
    [self onContentOffsetChange];
}

// Calculate landing position
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (self.layoutType == MCSelectorViewLayoutType_Horizontal) {
        CGFloat pageWidth = scrollView.frame.size.width;
        NSInteger pages = ceilf(scrollView.contentSize.width / pageWidth);
        NSInteger page = roundf(targetContentOffset->x / pageWidth);
        
        if (page>=0 && page<pages) {
            targetContentOffset->x = page * scrollView.frame.size.width;
        }
    } else {
        CGFloat pageHeight = scrollView.frame.size.height;
        NSInteger pages = ceilf(scrollView.contentSize.height / pageHeight);
        NSInteger page = roundf(targetContentOffset->y / pageHeight);
        
        if (page>=0 && page<pages) {
            targetContentOffset->y = page * scrollView.frame.size.height;
        }
    }
    
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    _isDragging = NO;
    
    if (!decelerate) {
        _hasStopped = YES;
        [self onContentOffsetChange];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _hasStopped = YES;
    [self onContentOffsetChange];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _isDragging = YES;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    _hasStopped = YES;
    [self onContentOffsetChange];
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
