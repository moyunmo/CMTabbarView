//
//  CMTabbarCollectionViewCell.h
//  CMTabbarView
//
//  Created by Moyun on 2016/11/6.
//  Copyright © 2016年 Cmall. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMTabbarCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic, nullable) UIColor *textColor;

@property (strong, nonatomic, nullable) UIFont *textFont;

@property (strong, nonatomic, nullable) UIColor *selectedTextColor;

@property (strong, nonatomic, nullable) UIFont *selectedTextFont;

@property (nonatomic, copy, nullable) NSString *title;

@end
