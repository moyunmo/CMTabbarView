//
//  ViewController.m
//  StoryboardDemo
//
//  Created by Moyun on 2017/4/24.
//  Copyright © 2017年 momo605654602@gmail.com. All rights reserved.
//

#import "ViewController.h"
#import "CMTabbarView.h"
#import "CMDemoCell.h"

static NSInteger const kDefaultSelectedIndex = 2;

@interface ViewController ()<CMTabbarViewDelegate,CMTabbarViewDatasouce,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet CMTabbarView *tabbarView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSArray *datas;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.datas = @[@"Moyun",@"Penny",@"MoyunMoyun",@"M",@"Pe",@"Moy",@"Moyun",@"Penny",@"Swift",@"Objective-C",@"C++",@"JAVA",@"C"];
//    self.tabbarView.defaultSelectedIndex = kDefaultSelectedIndex;
    [self.collectionView setContentOffset:CGPointMake(self.collectionView.bounds.size.width*kDefaultSelectedIndex, 0)];
    [self.tabbarView reloadData];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([CMDemoCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([CMDemoCell class])];
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_tabbarView setTabbarOffsetX:(scrollView.contentOffset.x)/self.view.bounds.size.width];
}

#pragma mark - UICollectionView Datasource & Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.datas.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CMDemoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CMDemoCell class]) forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.bounds.size.width, collectionView.bounds.size.height);
}

#pragma mark - TabbarView Datasource & Delegate

- (NSArray<NSString *> *)tabbarTitlesForTabbarView:(CMTabbarView *)tabbarView
{
    return self.datas;
}

- (void)tabbarView:(CMTabbarView *)tabbarView didSelectedAtIndex:(NSInteger)index
{
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:false];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
