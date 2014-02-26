//
//  MHGalleryOverViewController.m
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 27.12.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//

#import "MHOverViewController.h"

@implementation MHIndexPinchGestureRecognizer
@end

@interface MHOverViewController ()

@property (nonatomic, strong) MHAnimatorShowDetail *interactivePushTransition;
@property (nonatomic, strong) NSArray            *galleryItems;
@property (nonatomic, strong) NSNumberFormatter  *numberFormatter;

@property (nonatomic) CGPoint lastPoint;
@property (nonatomic) CGFloat startScale;


@end

@implementation MHOverViewController


- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.galleryItems = [MHGallerySharedManager sharedManager].galleryItems;
    
    
    self.title =  MHGalleryLocalizedString(@"overview.title.current");

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[MHGalleryImage(@"ic_square") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStyleBordered target:self action:nil];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(donePressed)];
    
    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.cv = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    self.cv.contentInset =UIEdgeInsetsMake(64, 0, 0, 0);
    self.cv.backgroundColor =[UIColor whiteColor];
    [self.cv registerClass:[MHGalleryOverViewCell class] forCellWithReuseIdentifier:@"MHGalleryOverViewCell"];
    self.cv .dataSource =self;
    self.cv.alwaysBounceVertical = YES;
    self.cv.delegate =self;
    self.cv.autoresizingMask =UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.cv];
    [self.cv reloadData];
    
    self.numberFormatter = [NSNumberFormatter new];
    [self.numberFormatter setMinimumIntegerDigits:2];
    
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
    
    UIMenuItem *saveItem = [[UIMenuItem alloc] initWithTitle:MHGalleryLocalizedString(@"overview.menue.item.save")
                                                      action:@selector(saveImage:)];
    #pragma clang diagnostic pop

    [[UIMenuController sharedMenuController] setMenuItems:@[saveItem]];
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
    [self makeMHGalleryOverViewCell:(MHGalleryOverViewCell*)cell
                        atIndexPath:indexPath];
    
    return cell;
}

-(void)makeMHGalleryOverViewCell:(MHGalleryOverViewCell*)cell atIndexPath:(NSIndexPath*)indexPath{
    
    MHGalleryItem *item =  self.galleryItems[indexPath.row];
    cell.iv.image = nil;
    
    
    cell.videoGradient.hidden = YES;
    cell.videoIcon.hidden     = YES;
    
    
    cell.saveImage = ^(BOOL shouldSave){
        [self getImageForItem:item
               finishCallback:^(UIImage *image) {
                   UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        }];
    };
    cell.videoDurationLength.text = @"";
    cell.iv.backgroundColor = [UIColor lightGrayColor];
    __block MHGalleryOverViewCell *blockCell = cell;
    
    if (item.galleryType == MHGalleryTypeVideo) {
        [[MHGallerySharedManager sharedManager] startDownloadingThumbImage:item.urlString
                                                              successBlock:^(UIImage *image,NSUInteger videoDuration,NSError *error,NSString *newURL) {
                                                                  
                                                                  if (error) {
                                                                      blockCell.iv.backgroundColor = [UIColor whiteColor];
                                                                      blockCell.iv.image = MHGalleryImage(@"error");
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
        if ([item.urlString rangeOfString:@"assets-library"].location != NSNotFound) {
            [[MHGallerySharedManager sharedManager] getImageFromAssetLibrary:item.urlString assetType:MHAssetImageTypeThumb successBlock:^(UIImage *image, NSError *error) {
                cell.iv.image = image;
            }];
        }else{
            [cell.iv setImageWithURL:[NSURL URLWithString:item.urlString]
                placeholderImage:nil
                         options:SDWebImageContinueInBackground
                        progress:nil
                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                           if (!image) {
                               blockCell.iv.backgroundColor = [UIColor whiteColor];
                               blockCell.iv.image = MHGalleryImage(@"error");
                           }
                           [[blockCell.contentView viewWithTag:405] setHidden:YES];
                           
                           
                       }];
        }
    }
    cell.iv.userInteractionEnabled =YES;
    
    MHIndexPinchGestureRecognizer *pinch = [[MHIndexPinchGestureRecognizer alloc]initWithTarget:self
                                                                                         action:@selector(userDidPinch:)];
    pinch.indexPath = indexPath;
    [cell.iv addGestureRecognizer:pinch];
    
    UIRotationGestureRecognizer *rotate = [[UIRotationGestureRecognizer alloc]initWithTarget:self
                                                                                      action:@selector(userDidRoate:)];
    rotate.delegate = self;
    [cell.iv addGestureRecognizer:rotate];

    
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}


-(void)userDidRoate:(UIRotationGestureRecognizer*)recognizer{
    if (self.interactivePushTransition) {
        CGFloat angle = recognizer.rotation;
        self.interactivePushTransition.angle = angle;
    }
}
-(void)userDidPinch:(MHIndexPinchGestureRecognizer*)recognizer{
    
    CGFloat scale = recognizer.scale/5;
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (recognizer.scale>1) {
            self.interactivePushTransition = [MHAnimatorShowDetail new];
            self.interactivePushTransition.indexPath = recognizer.indexPath;
            self.lastPoint = [recognizer locationInView:self.view];
            MHGalleryImageViewerViewController *detail = [MHGalleryImageViewerViewController new];
            detail.pageIndex = recognizer.indexPath.row;
            self.startScale = recognizer.scale/8;
            [self.navigationController pushViewController:detail
                                                 animated:YES];
        }else{
            [recognizer setCancelsTouchesInView:YES];
        }
    }else if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        if (recognizer.numberOfTouches <2) {
            [recognizer setEnabled:NO];
            [recognizer setEnabled:YES];
        }
        
        CGPoint point = [recognizer locationInView:self.view];
        self.interactivePushTransition.scale = recognizer.scale/8-self.startScale;
        self.interactivePushTransition.changedPoint = CGPointMake(self.lastPoint.x - point.x, self.lastPoint.y - point.y) ;
        [self.interactivePushTransition updateInteractiveTransition:scale];
        self.lastPoint = point;
    }else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        if (scale > 0.5) {
            [self.interactivePushTransition finishInteractiveTransition];
        }else {
            [self.interactivePushTransition cancelInteractiveTransition];
        }
        self.interactivePushTransition = nil;
    }
    
}


- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                         interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
    if ([animationController isKindOfClass:[MHAnimatorShowDetail class]]) {
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
        return [MHAnimatorShowDetail new];
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
-(void)pushToImageViewerForIndexPath:(NSIndexPath*)indexPath{
    MHGalleryImageViewerViewController *detail = [MHGalleryImageViewerViewController new];
    detail.pageIndex = indexPath.row;
    [self.navigationController pushViewController:detail animated:YES];
    
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    MHGalleryOverViewCell *cell = (MHGalleryOverViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    MHGalleryItem *item =  self.galleryItems[indexPath.row];

    if ([item.urlString rangeOfString:@"assets-library"].location != NSNotFound) {
        
        [[MHGallerySharedManager sharedManager] getImageFromAssetLibrary:item.urlString
                                                               assetType:MHAssetImageTypeFull
                                                            successBlock:^(UIImage *image, NSError *error) {
                                                                cell.iv.image = image;
                                                                [self pushToImageViewerForIndexPath:indexPath];
                                                            }];
    }else{
        [self pushToImageViewerForIndexPath:indexPath];
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    MHGalleryItem *item =  self.galleryItems[indexPath.row];
    if (item.galleryType == MHGalleryTypeImage) {
        if ([NSStringFromSelector(action) isEqualToString:@"copy:"] || [NSStringFromSelector(action) isEqualToString:@"saveImage:"]){
            return YES;
        }
    }
    return NO;
}

-(void)getImageForItem:(MHGalleryItem*)item
        finishCallback:(void(^)(UIImage *image))FinishBlock{
    [[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:item.urlString]
                                               options:SDWebImageContinueInBackground
                                              progress:nil
                                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
                                                 FinishBlock(image);
                                             }];
}


- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if ([NSStringFromSelector(action) isEqualToString:@"copy:"]) {
        UIPasteboard *pasteBoard = [UIPasteboard pasteboardWithName:UIPasteboardNameGeneral create:NO];
        pasteBoard.persistent = YES;
        MHGalleryItem *item =  self.galleryItems[indexPath.row];
        [self getImageForItem:item finishCallback:^(UIImage *image) {
            if (image) {
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                NSData *data = UIImagePNGRepresentation(image);
                [pasteboard setData:data forPasteboardType:@"public.jpeg"];
            }
        }];
    }
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self.cv.collectionViewLayout invalidateLayout];
}

@end
