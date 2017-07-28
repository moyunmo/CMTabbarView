//
//  DemoCell.h
//  CMTabbarView_Example
//
//  Created by Moyun on 2017/7/28.
//  Copyright © 2017年 momo605654602@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DemoCell : UICollectionViewCell

@property (strong, nonatomic, nullable) UIColor *textColor;

@property (strong, nonatomic, nullable) UIFont *textFont;

@property (strong, nonatomic, nullable) UIColor *selectedTextColor;

@property (strong, nonatomic, nullable) UIFont *selectedTextFont;

@property (nonatomic, copy, nullable) NSString *title;

@end
