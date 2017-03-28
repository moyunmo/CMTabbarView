//
//  CMTabbarView.m
//  CMTabbarView
//
//  Created by Moyun on 2016/11/6.
//  Copyright © 2016年 Cmall. All rights reserved.
//

#import "CMTabbarView.h"
#import "CMTabbarCollectionViewCell.h"

CGFloat const CMTabbarViewDefaultHeight = 44.0f;
CGFloat const CMTabBarViewTabOffsetInvalid = -1.0f;
CGFloat const CMTabbarViewDefaultPadding = 10.0f;
CGFloat const CMTabbarSelectionBoxDefaultTop = 6.0f;
CGFloat const CMTabbarViewDefaultAnimateTime = .2f;
CGFloat const CMTabbarViewDefaultHorizontalInset = 7.5f;
NSString *  const CMTabIndicatorViewHeight = @"CMIndicatorViewHeight";
NSString *  const CMTabIndicatorColor = @"CMIndicatorViewColor";
NSString *  const CMTabBoxBackgroundColor = @"CMBoxbackgroundColor";

#define CMHEXCOLOR(c) [UIColor colorWithRed:((c>>16)&0xFF)/255.0 green:((c>>8)&0xFF)/255.0 blue:(c&0xFF)/255.0 alpha:1.0]

@interface CMTabbarItem : NSObject

@property (assign, nonatomic, getter=isSelected) BOOL selected;

@property (copy,   nonatomic) NSString *tabTitle;

@end

@implementation CMTabbarItem

@end

@interface CMTabbarView ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) UICollectionView *collectionView;

@property (strong, nonatomic) UIView *indicatorView;

@property (strong, nonatomic) NSArray *tabbarTitles;

@property (assign, nonatomic) BOOL haveShowedDefault;

@property (assign, nonatomic) CGFloat previousTabOffsetX;

@property (assign, nonatomic) BOOL isExecuting;

@end

@implementation CMTabbarView

- (instancetype)init
{
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _scrollEnable = true;
    _tabPadding = 5.0f;
    _needTextGradient = true;
    _tabbarOffsetX = CMTabBarViewTabOffsetInvalid;
    _selectionType = CMTabbarSelectionIndicator;
    _locationType = CMTabbarIndicatorLocationDown;
    _contentInset = UIEdgeInsetsMake(.0f, CMTabbarViewDefaultHorizontalInset, 0, CMTabbarViewDefaultHorizontalInset);
    _indicatorAttributes = @{CMTabIndicatorColor:CMHEXCOLOR(0x3ebd6e),CMTabIndicatorViewHeight:@(2.0f),CMTabBoxBackgroundColor:CMHEXCOLOR(0x3ebd6e)};
    _normalAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:15.0f],NSForegroundColorAttributeName:CMHEXCOLOR(0x6d7989)};
    _selectedAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:15.0f],NSForegroundColorAttributeName:CMHEXCOLOR(0x3ebd6e)};
    _defaultSelectedIndex = 0;
    self.backgroundColor = [UIColor whiteColor];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if (!self.collectionView.superview) {
        [self addSubview:self.collectionView];
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false;
        NSDictionary *views = NSDictionaryOfVariableBindings(_collectionView);
        NSString *verticalConstraints = [NSString stringWithFormat:@"V:|-%f-[_collectionView]-%f-|", .0,.0];
        NSString *horizontalConstraints = [NSString stringWithFormat:@"H:|-%f-[_collectionView]-%f-|",.0,.0];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:horizontalConstraints options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:verticalConstraints options:0 metrics:nil views:views]];
        if (!_defaultSelectedIndex) {
            [self setDefaultSelectedIndex:0];
        }
    }
    if (!self.indicatorView.superview) {
        [self.collectionView addSubview:self.indicatorView];
    }
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_collectionView registerClass:[CMTabbarCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([CMTabbarCollectionViewCell class])];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.showsHorizontalScrollIndicator = false;
        _collectionView.scrollEnabled = _scrollEnable;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.contentInset = self.contentInset;
    }
    return _collectionView;
}

- (UIView *)indicatorView
{
    if (!_indicatorView) {
        _indicatorView = [UIView new];
        _indicatorView.userInteractionEnabled = false;
        _indicatorView.backgroundColor = _indicatorAttributes[CMTabIndicatorColor];
    }
    return _indicatorView;
}

#pragma mark - UICollectionViewDatasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.tabbarTitles.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CMTabbarCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CMTabbarCollectionViewCell class]) forIndexPath:indexPath];
    [self updateCellInterface:cell];
    CMTabbarItem *item = self.tabbarTitles[indexPath.row];
    cell.title = item.tabTitle;
    cell.textColor = item.isSelected ? self.selectedAttributes[NSForegroundColorAttributeName] : self.normalAttributes[NSForegroundColorAttributeName];
    if ((!self.haveShowedDefault && indexPath.row == self.defaultSelectedIndex)) {
        _haveShowedDefault = true;
        [self updateTabWithCurrentCell:cell nextCell:nil progress:1.0f backwards:true];
        [self updateIndicatorWithCell:cell indexPath:indexPath animate:false];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *tabTitle = [self titleAtIndex:indexPath.row];
    CGSize size = [tabTitle sizeWithAttributes:self.normalAttributes];
    return CGSizeMake(size.width+CMTabbarViewDefaultPadding, MIN(size.height+CMTabbarViewDefaultPadding, collectionView.bounds.size.height));
}

#pragma mark - UICollectionViewDeleagte

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.isExecuting = true;
    [self setTabIndex:indexPath.row animated:true];
    [collectionView reloadData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.35f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.isExecuting = false;
    });
    if ([self.delegate respondsToSelector:@selector(tabbarView:didSelectedAtIndex:)]) {
        [self.delegate tabbarView:self didSelectedAtIndex:indexPath.row];
    }
}

#pragma mark - Public Method

- (void)setDataSource:(id<CMTabbarViewDatasouce>)dataSource
{
    NSParameterAssert(dataSource);
    _dataSource = dataSource;
    [self reloadData];
}

- (void)reloadData
{
    NSAssert([_dataSource respondsToSelector:@selector(tabbarTitlesForTabbarView:)], @"Method must be implement");
    NSArray *array = [_dataSource tabbarTitlesForTabbarView:self];
    if (!array.count) {
        return ;
    }
    NSMutableArray *mutaArray = [NSMutableArray array];
    for (NSString *str in array) {
        @autoreleasepool {
            CMTabbarItem *item = [[CMTabbarItem alloc] init];
            item.tabTitle = str;
            item.selected = false;
            [mutaArray addObject:item];
        }
    }
    if (self.tabbarOffsetX == CMTabBarViewTabOffsetInvalid && _defaultSelectedIndex < mutaArray.count) {
        CMTabbarItem *item = mutaArray[_defaultSelectedIndex];
        item.selected = true;
    }
    self.tabbarTitles = [mutaArray copy];
    [self.collectionView reloadData];
}

- (void)setContentInset:(UIEdgeInsets)contentInset
{
    _contentInset = contentInset;
    contentInset.bottom += [self.indicatorAttributes[CMTabIndicatorViewHeight] floatValue];
    self.collectionView.contentInset = contentInset;
}

- (void)setScrollEnable:(BOOL)scrollEnable
{
    _scrollEnable = scrollEnable;
    self.collectionView.scrollEnabled = scrollEnable;
}

- (void)setTabPadding:(CGFloat)tabPadding
{
    _tabPadding = tabPadding;
    [self.collectionView reloadData];
}

- (void)setTabIndex:(NSInteger)index animated:(BOOL)animated
{
    [self setSelectedWithIndex:index];
    if (animated) {
        [UIView animateWithDuration:CMTabbarViewDefaultAnimateTime animations:^{
            [self updateTabbarForIndex:index animated:false];
        }];
    } else {
        [self updateTabbarForIndex:index animated:animated];
    }
}

- (void)setDefaultSelectedIndex:(NSUInteger)defaultSelectedIndex
{
    if (self.tabbarOffsetX == CMTabBarViewTabOffsetInvalid) {
        self.haveShowedDefault = false;
        _tabbarOffsetX = defaultSelectedIndex;
        _defaultSelectedIndex = defaultSelectedIndex;
        [self setSelectedWithIndex:defaultSelectedIndex];
    }
}

- (void)setTabbarOffsetX:(CGFloat)tabbarOffsetX
{
    if (self.isExecuting) {
        return ;
    }
    _previousTabOffsetX = _tabbarOffsetX;
    _tabbarOffsetX = tabbarOffsetX;
    [self updateTabbarForTabbarOffset:tabbarOffsetX];
}

- (void)setSelectionType:(CMTabbarSelectionType)selectionType
{
    _selectionType = selectionType;
    if (selectionType == CMTabbarSelectionBox) {
        self.indicatorView.backgroundColor = [_indicatorAttributes[CMTabBoxBackgroundColor] colorWithAlphaComponent:0.6];
        self.indicatorView.layer.cornerRadius = 3.0f;
    } else if (selectionType == CMTabbarSelectionIndicator) {
        self.indicatorView.backgroundColor = _indicatorAttributes[CMTabIndicatorColor];
    }
}

- (void)setIndicatorAttributes:(NSDictionary *)indicatorAttributes
{
    NSDictionary *defaultAttributes = @{CMTabIndicatorColor:CMHEXCOLOR(0x3ebd6e),CMTabIndicatorViewHeight:@(2.0f),CMTabBoxBackgroundColor:[UIColor orangeColor]};
    NSMutableDictionary *resultAttributes = [NSMutableDictionary dictionaryWithDictionary:defaultAttributes];
    [resultAttributes addEntriesFromDictionary:indicatorAttributes];
    _indicatorAttributes = [resultAttributes copy];
}

- (void)setNormalAttributes:(NSDictionary *)normalAttributes
{
    NSDictionary *defaultAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:15.0f],NSForegroundColorAttributeName:[UIColor blackColor]};
    NSMutableDictionary *resultAttributes = [NSMutableDictionary dictionaryWithDictionary:defaultAttributes];
    [resultAttributes addEntriesFromDictionary:normalAttributes];
    _normalAttributes = [resultAttributes copy];
}

- (void)setSelectedAttributes:(NSDictionary *)selectedAttributes
{
    NSDictionary *defaultAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:15.0f],NSForegroundColorAttributeName:[UIColor orangeColor]};
    NSMutableDictionary *resultAttributes = [NSMutableDictionary dictionaryWithDictionary:defaultAttributes];
    [resultAttributes addEntriesFromDictionary:selectedAttributes];
    _selectedAttributes = [resultAttributes copy];
}

#pragma mark - Private Method

- (void)setSelectedWithIndex:(NSInteger)index
{
    for (CMTabbarItem *item in self.tabbarTitles) {
        @autoreleasepool {
            item.selected = false;
        }
    }
    CMTabbarItem *item = self.tabbarTitles[index];
    item.selected = true;
}

- (void)updateTabbarForIndex:(NSInteger)index animated:(BOOL)animated
{
    CMTabbarCollectionViewCell *cell = [self cellAtIndex:index];
    if (cell) {
        _previousTabOffsetX = _tabbarOffsetX;
        _tabbarOffsetX = index;
        CMTabbarCollectionViewCell *preCell = [self cellAtIndex:_previousTabOffsetX];
        [self updateIndicatorWithCell:cell indexPath:[NSIndexPath indexPathForRow:index inSection:0] animate:animated];
        preCell.textColor = self.normalAttributes[NSForegroundColorAttributeName];
        cell.textColor = self.selectedAttributes[NSForegroundColorAttributeName];
    }
}

- (void)updateIndicatorWithCell:(CMTabbarCollectionViewCell *)cell indexPath:(NSIndexPath *)indexPath animate:(BOOL)animate
{
    if (animate) {
        [UIView animateWithDuration:.2f animations:^{
            CGFloat originX = cell.frame.origin.x;
            CGFloat width = cell.frame.size.width;
            [self updateIndicatorFrameWithOriginX:originX width:width];
        }];
    } else {
        CGFloat originX = cell.frame.origin.x;
        CGFloat width = cell.frame.size.width;
        [self updateIndicatorFrameWithOriginX:originX width:width];
    }
}

- (void)updateIndicatorFrameWithOriginX:(CGFloat)originX width:(CGFloat)width
{
    width -= self.tabPadding;
    originX += (self.tabPadding/2.0f);
    width -= self.tabPadding;
    originX += (self.tabPadding/2.0f);
    CGFloat indicatorHeight = [self.indicatorAttributes[CMTabIndicatorViewHeight] floatValue];
    if (_selectionType == CMTabbarSelectionIndicator) {
        if (_locationType != CMTabbarIndicatorLocationNone) {
            self.indicatorView.frame = CGRectMake(originX, _locationType == CMTabbarIndicatorLocationDown ?  self.bounds.size.height - indicatorHeight : 0, width, indicatorHeight);
        }
    } else if (_selectionType == CMTabbarSelectionBox) {
        self.indicatorView.frame = CGRectMake(originX-CMTabbarViewDefaultPadding/2, CMTabbarSelectionBoxDefaultTop, width+CMTabbarViewDefaultPadding, self.collectionView.frame.size.height-2*CMTabbarSelectionBoxDefaultTop);
    }
    CGFloat scrollViewX = MAX(0, originX+width/2 - self.collectionView.bounds.size.width / 2.0f);
    [self.collectionView scrollRectToVisible:CGRectMake(scrollViewX, self.collectionView.frame.origin.y, self.collectionView.frame.size.width - self.contentInset.left - self.contentInset.right, self.collectionView.frame.size.height) animated:false];
}

- (CMTabbarCollectionViewCell *)cellAtIndex:(NSInteger)index
{
    if (index >= 0 && index < self.tabbarTitles.count) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        return (CMTabbarCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    }
    return nil;
}

- (void)updateCellInterface:(CMTabbarCollectionViewCell *)cell
{
    if (self.normalAttributes) {
        if ([self.normalAttributes valueForKey:NSFontAttributeName]) {
            cell.textFont = self.normalAttributes[NSFontAttributeName];
        }
        if ([self.normalAttributes valueForKey:NSForegroundColorAttributeName]) {
            cell.textColor = self.normalAttributes[NSForegroundColorAttributeName];
        }
    }
    if (self.selectedAttributes) {
        if ([self.selectedAttributes valueForKey:NSFontAttributeName]) {
            cell.selectedTextFont = self.normalAttributes[NSFontAttributeName];
        }
        if ([self.selectedAttributes valueForKey:NSForegroundColorAttributeName]) {
            cell.selectedTextColor = self.normalAttributes[NSForegroundColorAttributeName];
        }
    }
}

- (NSString *)titleAtIndex:(NSInteger)index
{
    return [self.tabbarTitles[index] valueForKey:@"tabTitle"];
}

- (void)updateTabbarForTabbarOffset:(CGFloat)tabOffset
{
    float address;
    CGFloat progress = (CGFloat)modff(tabOffset, &address);
    BOOL isBackwards = !(tabOffset >= self.previousTabOffsetX);
    if (tabOffset < .0f) {
        CMTabbarCollectionViewCell *cell = [self cellAtIndex:0];
        [self updateTabWithCurrentCell:cell nextCell:cell progress:1.0f backwards:false];
        [self updateTabIndicatorWithCurrentCell:cell nextCell:cell progress:1.0f];
        [self setSelectedWithIndex:0];
    } else if (tabOffset > self.tabbarTitles.count - 1) {
        CMTabbarCollectionViewCell *cell = [self cellAtIndex:self.tabbarTitles.count - 1];
        if (![self.collectionView.visibleCells containsObject:cell]) { //fix edge
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.tabbarTitles.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:false];
            return ;
        }
        [self updateTabWithCurrentCell:cell nextCell:cell progress:1.0f backwards:false];
        [self updateTabIndicatorWithCurrentCell:cell nextCell:cell progress:1.0f];
        [self setSelectedWithIndex:self.tabbarTitles.count - 1];
    } else {
        if (fabs(progress) != .0f) {
            NSInteger currentTabIndex = isBackwards ? ceil(tabOffset) : floor(tabOffset);
            NSInteger nextTabIndex = MAX(0, MIN(self.tabbarTitles.count - 1, isBackwards ? floor(tabOffset) : ceil(tabOffset)));
            CMTabbarCollectionViewCell *currentCell = [self cellAtIndex:currentTabIndex];
            CMTabbarCollectionViewCell *nextCell = [self cellAtIndex:nextTabIndex];
            if (![self.collectionView.visibleCells containsObject:currentCell] && ![self.collectionView.visibleCells containsObject:nextCell]) {
                [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:currentTabIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:false];
                [self.collectionView setNeedsLayout];
            }
            if ((currentCell && nextCell) && currentCell != nextCell) {
                [self updateTabWithCurrentCell:currentCell nextCell:nextCell progress:progress backwards:isBackwards];
                [self updateTabIndicatorWithCurrentCell:currentCell nextCell:nextCell progress:progress];
            }
        } else {
            NSInteger index = ceil(tabOffset);
            CMTabbarCollectionViewCell *cell = [self cellAtIndex:index];
            NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
            if (cell && indexPath) {
                [self updateIndicatorWithCell:cell indexPath:indexPath animate:true];
                [self setSelectedWithIndex:index];
                [self.collectionView setNeedsLayout];
            }
        }
    }
}

- (void)updateTabWithCurrentCell:(CMTabbarCollectionViewCell *)currentCell nextCell:(CMTabbarCollectionViewCell *)nextCell progress:(CGFloat)progress backwards:(BOOL)backwards
{
    if (backwards) {
        CMTabbarCollectionViewCell *temp = nextCell;
        nextCell = currentCell;
        currentCell = temp;
    }
    if (!_needTextGradient) {
        currentCell.textColor = progress > .8f ? self.normalAttributes[NSForegroundColorAttributeName] : self.selectedAttributes[NSForegroundColorAttributeName];
        nextCell.textColor = progress > .8f ?  self.selectedAttributes[NSForegroundColorAttributeName] : self.normalAttributes[NSForegroundColorAttributeName];
    } else {
        currentCell.textColor =  [self getColorOfPercent:progress between:self.normalAttributes[NSForegroundColorAttributeName] and:self.selectedAttributes[NSForegroundColorAttributeName]];
        nextCell.textColor = [self getColorOfPercent:progress between:self.selectedAttributes[NSForegroundColorAttributeName] and:self.normalAttributes[NSForegroundColorAttributeName]];
    }
}

- (void)updateTabIndicatorWithCurrentCell:(CMTabbarCollectionViewCell *)currentCell nextCell:(CMTabbarCollectionViewCell *)nextCell progress:(CGFloat)progress
{
    if (!self.tabbarTitles.count) {
        return;
    }
    CGFloat maxX = MAX(nextCell.frame.origin.x, currentCell.frame.origin.x);
    CGFloat minX = MIN(nextCell.frame.origin.x, currentCell.frame.origin.x);
    BOOL isBack = (nextCell.frame.origin.x == minX);
    if (isBack) {
        CMTabbarCollectionViewCell *temp = nextCell;
        nextCell = currentCell;
        currentCell = temp;
    }
    CGFloat currentTabWidth = currentCell.frame.size.width;
    CGFloat nextTabWidth = nextCell.frame.size.width;
    CGFloat widthDiff = (nextTabWidth - currentTabWidth) * progress;
    
    CGFloat newX = minX + ((maxX - minX) * progress);
    CGFloat newWidth = currentTabWidth + widthDiff;
    [self updateIndicatorFrameWithOriginX:newX width:newWidth];
}

- (UIColor *)getColorOfPercent:(CGFloat)percent between:(UIColor *)color1 and:(UIColor *)color2
{
    CGFloat red1, green1, blue1, alpha1;
    [color1 getRed:&red1 green:&green1 blue:&blue1 alpha:&alpha1];
    CGFloat red2, green2, blue2, alpha2;
    [color2 getRed:&red2 green:&green2 blue:&blue2 alpha:&alpha2];
    CGFloat p1 = percent;
    CGFloat p2 = 1.0 - percent;
    UIColor *mid = [UIColor colorWithRed:red1*p1+red2*p2 green:green1*p1+green2*p2 blue:blue1*p1+blue2*p2 alpha:1.0f];
    return mid;
}

@end
