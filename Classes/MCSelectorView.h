//
//  MCSelectorView.h
//  InteractiveVideoTest
//
//  Created by Baglan on 7/25/13.
//  Copyright (c) 2013 MobileCreators. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MCSelectorViewDataSource;
@protocol MCSelectorViewDelegate;

enum MCSelectorViewLayoutType {
    MCSelectorViewLayoutType_Horizontal,
    MCSelectorViewLayoutType_Vertical
};

@interface MCSelectorView : UIView

@property (nonatomic, readonly) NSInteger index;
@property (nonatomic, readonly) NSInteger highlightedIndex;
@property (nonatomic, weak) id<MCSelectorViewDataSource> dataSource;
@property (nonatomic, weak) id<MCSelectorViewDelegate> delegate;
@property (nonatomic, readonly) BOOL isDragging;
@property (nonatomic, readonly) BOOL hasStopped;
@property (nonatomic, readonly) NSArray * optionViews;
@property (nonatomic, assign) enum MCSelectorViewLayoutType layoutType;

- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated;

- (void)reloadData;

- (void)presentWithTimeout:(NSTimeInterval)timeout;
- (void)present;
- (void)dismiss;

- (void)detachPanGestureRecognizer;
- (void)attachPanGestureRecognizerToView:(UIView *)view;

@end

@protocol MCSelectorViewDataSource <NSObject>

- (CGRect)optionRectForSelectorView:(MCSelectorView *)view;
- (NSArray *)optionViewsForSelectorView:(MCSelectorView *)view;

@end

@protocol MCSelectorViewDelegate <NSObject>

@optional

- (BOOL)selectorView:(MCSelectorView *)selectorView shouldHighlightOptionAtIndex:(NSUInteger)index;
- (BOOL)selectorView:(MCSelectorView *)selectorView shouldSelectOptionAtIndex:(NSUInteger)index;

- (void)selectorView:(MCSelectorView *)selectorView didHighlightOptionAtIndex:(NSUInteger)index;
- (void)selectorView:(MCSelectorView *)selectorView didSelectOptionAtIndex:(NSUInteger)index;

- (void)selectorView:(MCSelectorView *)selectorView didTapOnOptionAtIndex:(NSUInteger)index;

- (void)willPresentSelectorView:(MCSelectorView *)selectorView;
- (void)didPresentSelectorView:(MCSelectorView *)selectorView;

- (void)willDismissSelectorView:(MCSelectorView *)selectorView;
- (void)didDismissSelectorView:(MCSelectorView *)selectorView;

- (void)selectorView:(MCSelectorView *)selectorView updateOptionView:(UIView *)view atIndex:(NSUInteger)index;

@end
