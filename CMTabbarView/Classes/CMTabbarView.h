//
//  CMTabbarView.h
//  CMTabbarView
//
//  Created by Moyun on 2016/11/6.
//  Copyright © 2016年 Cmall. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CMTabbarView;

typedef NS_ENUM(NSInteger,CMTabbarSelectionType) {
    CMTabbarSelectionIndicator,
    CMTabbarSelectionBox,
};

typedef NS_ENUM(NSInteger, CMTabbarIndicatorType) {
    CMTabbarIndicatorLocationDown,
    CMTabbarIndicatorLocationUp,
    CMTabbarIndicatorLocationNone
};

typedef NS_ENUM(NSInteger, CMTabbarIndicatorScrollType) {
    CMTabbarIndicatorScrollTypeDefault,
    CMTabbarIndicatorScrollTypeSpring
};

extern NSString *const CMTabIndicatorViewHeight;

extern NSString *const CMTabIndicatorColor;

extern NSString *const CMTabBoxBackgroundColor;

@protocol CMTabbarViewDatasouce <NSObject>

- (NSArray<NSString *> *)tabbarTitlesForTabbarView:(CMTabbarView *)tabbarView;

@end

@protocol CMTabbarViewDelegate <NSObject>

@optional
- (void)tabbarView:(CMTabbarView *)tabbarView didSelectedAtIndex:(NSInteger)index;

@end

@interface CMTabbarView : UIView

@property (weak,   nonatomic) IBOutlet id <CMTabbarViewDatasouce> dataSource;

@property (weak,   nonatomic) IBOutlet id <CMTabbarViewDelegate> delegate;
/**
 Whether the user need color Gradient,Default is true
 */
@property (assign, nonatomic) BOOL needTextGradient;
/**
 Specifies the type of selection (CMTabbarSelectionIndicator,CMTabbarSelectionBox)
 */
@property (assign, nonatomic) CMTabbarSelectionType selectionType;
/**
 Specifies the type of indication(CMTabbarIndicatorLocationDown,CMTabbarIndicatorLocationUp,CMTabbarIndicatorLocationNone)
 */
@property (assign, nonatomic) CMTabbarIndicatorType locationType;
/**
 The scroll Type of the Indicator (CMTabbarIndicatorScrollTypeDefault,CMTabbarIndicatorScrollTypeSpring)
 */
@property (assign, nonatomic) CMTabbarIndicatorScrollType indicatorScrollType;
/**
 The attributes for the tab indicator(CMTabIndicatorViewHeight,CMTabIndicatorColor,CMTabBoxBackgroundColor)
 */
@property (strong, nonatomic) NSDictionary *indicatorAttributes;
/**
 The attributes for tabs (NSForegroundColorAttributeName, NSFontAttributeName, NSBackgroundColorAttributeName)
 */
@property (strong, nonatomic) NSDictionary *normalAttributes;
/**
 The attributes for selected tabs (NSForegroundColorAttributeName, NSFontAttributeName, NSBackgroundColorAttributeName)
 */
@property (strong, nonatomic) NSDictionary *selectedAttributes;
/**
 Whether the user can scroll the tabbar
 */
@property (assign, nonatomic) BOOL scrollEnable;
/**
 padding Value,Default is 5.0
 */
@property (assign, nonatomic) CGFloat tabPadding;
/**
 User default index
 */
@property (assign, nonatomic) IBInspectable NSUInteger defaultSelectedIndex;
/**
 Content Inset
 */
@property (assign, nonatomic) UIEdgeInsets contentInset;
/**
 The tab offsetX of the View.
 */
@property (assign, nonatomic) CGFloat tabbarOffsetX;

@property (assign, nonatomic) BOOL needAutoCenter;
/**
 Set the current selected tab
 
 @param index index
 @param animated animated
 */
- (void)setTabIndex:(NSInteger)index animated:(BOOL)animated;

- (void)reloadData;

@end

