//
//  MHGalleryOverViewController.m
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 27.12.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//

#import "MHGalleryOverViewController.h"

@interface MHGalleryOverViewController ()
@property (nonatomic,getter = isStartAnimation) BOOL startAnimation;
@property (nonatomic, strong)                   AnimatorShowDetail *interactivePushTransition;
@property (nonatomic, strong)                   NSArray *galleryItems;
@property (nonatomic, strong)                   NSNumberFormatter *numberFormatter;

@end

@implementation MHGalleryOverViewController


- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.galleryItems = [MHGallerySharedManager sharedManager].galleryItems;
    self.title = @"Overview";

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(donePressed)];
    
    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.cv = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    [self.cv setContentInset:UIEdgeInsetsMake(64, 0, 0, 0)];
    [self.cv setBackgroundColor:[UIColor whiteColor]];
    [self.cv registerClass:[MHGalleryOverViewCell class] forCellWithReuseIdentifier:@"MHGalleryOverViewCell"];
    [self.cv setDataSource:self];

    [self.cv setDelegate:self];
    [self.cv setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self.view addSubview:self.cv];
    [self.cv reloadData];
    
    self.numberFormatter = [NSNumberFormatter new];
    [self.numberFormatter setMinimumIntegerDigits:2];
    
}

-(void)viewWillAppear:(BOOL)animated{
}
-(void)donePressed{
    self.navigationController.transitioningDelegate = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 4;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait ) {
        return 4;
    }
    return 10;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout  *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait ) {
        return CGSizeMake(self.cv.frame.size.width/3.1, self.cv.frame.size.width/3.1) ;
    }
    return CGSizeMake(self.cv.frame.size.height/3.1, self.cv.frame.size.height/3.1) ;
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(4, 0, 0, 0);
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.galleryItems.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell =nil;
    NSString *cellIdentifier = nil;
    cellIdentifier = @"MHGalleryOverViewCell";
    cell = (MHGalleryOverViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    [self makeMHGalleryOverViewCell:(MHGalleryOverViewCell*)cell atIndexPath:indexPath];
    
    return cell;
}

-(void)makeMHGalleryOverViewCell:(MHGalleryOverViewCell*)cell atIndexPath:(NSIndexPath*)indexPath{
    
    MHGalleryItem *item =  self.galleryItems[indexPath.row];
    cell.iv.image = nil;
    
    [cell.videoGradient setHidden:YES];
    [cell.videoIcon setHidden:YES];
    cell.videoDurationLength.text = @"";
    cell.iv.backgroundColor = [UIColor lightGrayColor];
    __block MHGalleryOverViewCell *blockCell = cell;
    
    if (item.galleryType == MHGalleryTypeVideo) {
        [[MHGallerySharedManager sharedManager] startDownloadingThumbImage:item.urlString
                                                                   forSize:CGSizeMake(cell.iv.frame.size.width*2, cell.iv.frame.size.height*2)
                                                                atDuration:MHImageGenerationStart
                                                              successBlock:^(UIImage *image,NSUInteger videoDuration,NSError *error) {
                                                                  
                                                                  if (error) {
                                                                      cell.iv.backgroundColor = [UIColor whiteColor];
                                                                      cell.iv.image = [UIImage imageNamed:@"error"];
                                                                  }else{
                                                                      
                                                                      NSNumber *minutes = @(videoDuration / 60);
                                                                      NSNumber *seconds = @(videoDuration % 60);
                                                                      
                                                                      blockCell.videoDurationLength.text = [NSString stringWithFormat:@"%@:%@",
                                                                                                            [self.numberFormatter stringFromNumber:minutes] ,[self.numberFormatter stringFromNumber:seconds]];
                                                                      [blockCell.iv setImage:image];
                                                                      [blockCell.videoIcon setHidden:NO];
                                                                      [blockCell.videoGradient setHidden:NO];


                                                                  }
                                                                  [[blockCell.contentView viewWithTag:405] setHidden:YES];
                                                              }];
    }else{
        [cell.iv setImageWithURL:[NSURL URLWithString:item.urlString]
                placeholderImage:nil
                         options:SDWebImageContinueInBackground
                        progress:nil
                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                           if (!image) {
                               blockCell.iv.backgroundColor = [UIColor whiteColor];
                               blockCell.iv.image = [UIImage imageNamed:@"error"];
                           }
                           [[blockCell.contentView viewWithTag:405] setHidden:YES];
                       }];
    }
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                         interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
    if ([animationController isKindOfClass:[AnimatorShowDetail class]]) {
        return self.interactivePushTransition;
    }else {
        return nil;
    }
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC {
    
    if (fromVC == self && [toVC isKindOfClass:[MHGalleryImageViewerViewController class]]) {
        return [AnimatorShowDetail new];
    }else {
        return nil;
    }
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.navigationController.delegate == self) {
        self.navigationController.delegate = nil;
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    MHGalleryImageViewerViewController *detail = [MHGalleryImageViewerViewController new];
    detail.pageIndex = indexPath.row;
    if (self.isStartAnimation) {
        self.startAnimation = NO;
        [self.navigationController pushViewController:detail animated:NO];
    }else{
        [self.navigationController pushViewController:detail animated:YES];
    }
}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self.cv.collectionViewLayout invalidateLayout];
}

@end
