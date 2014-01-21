//
//  ExampleViewController.m
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 30.09.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//

#import "ExampleViewControllerCollectionViewInTableView.h"
#import "MHGalleryOverViewController.h"

@interface ExampleViewControllerCollectionViewInTableView ()
@property(nonatomic,strong)NSArray *galleryDataSource;
@property(nonatomic,strong) UIImageView *imageViewForPresentingMHGallery;
@property(nonatomic,strong) AnimatorShowDetailForDismissMHGallery *interactive;
@end

@implementation ExampleViewControllerCollectionViewInTableView

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.title = @"CollectionInTable";
    
    
    MHGalleryItem *vimeo0 = [[MHGalleryItem alloc]initWithURL:@"http://vimeo.com/35515926"
                                                   galleryType:MHGalleryTypeVideo];
    MHGalleryItem *vimeo1 = [[MHGalleryItem alloc]initWithURL:@"http://vimeo.com/50006726"
                                                  galleryType:MHGalleryTypeVideo];
   
    
    MHGalleryItem *keynote = [[MHGalleryItem alloc]initWithURL:@"http://images.apple.com/media/de/mac-pro/2013/16C1b6b5-1d91-4fef-891e-ff2fc1c1bb58/tour/assembly/macpro-assembly-de-20131022_r848-9dwc.mov?width=848&height=480&expectingMovieJson=true"
                                                 galleryType:MHGalleryTypeVideo];
    
    MHGalleryItem *item0 = [[MHGalleryItem alloc]initWithURL:@"https://dl.dropboxusercontent.com/u/17911939/UIViewios7.png"
                                                 galleryType:MHGalleryTypeImage];
    
    MHGalleryItem *item1 = [[MHGalleryItem alloc]initWithURL:@"http://images.apple.com/ipad-air/built-in-apps/images/reminders_screen_2x.jpg"
                                                                              galleryType:MHGalleryTypeImage];
    MHGalleryItem *item2 = [[MHGalleryItem alloc]initWithURL:@"http://images.apple.com/ipad-air/built-in-apps/images/videos_screen_2x.jpg"
                                                 galleryType:MHGalleryTypeImage];
    MHGalleryItem *item3 = [[MHGalleryItem alloc]initWithURL:@"http://images.apple.com/ipad-air/built-in-apps/images/keynote_screen_2x.jpg"
                                                 galleryType:MHGalleryTypeImage];
    MHGalleryItem *item4 = [[MHGalleryItem alloc]initWithURL:@"http://images.apple.com/ipad-air/built-in-apps/images/iphoto_screen_2x.jpg"
                                                 galleryType:MHGalleryTypeImage];
    MHGalleryItem *item5 = [[MHGalleryItem alloc]initWithURL:@"http://images.apple.com/ipad-air/built-in-apps/images/imovie_screen_2x.jpg"
                                                 galleryType:MHGalleryTypeImage];
    MHGalleryItem *item6 = [[MHGalleryItem alloc]initWithURL:@"http://images.apple.com/iphone/shared/built-in-apps/images/facetime_screen_2x.jpg"
                                                 galleryType:MHGalleryTypeImage];
    MHGalleryItem *item7 = [[MHGalleryItem alloc]initWithURL:@"http://images.apple.com/ipad-air/built-in-apps/images/siri_screen_2x.jpg"
                                                 galleryType:MHGalleryTypeImage];
    MHGalleryItem *item8 = [[MHGalleryItem alloc]initWithURL:@"http://images.apple.com/ipad-air/built-in-apps/images/photos_screen_2x.jpg"
                                                 galleryType:MHGalleryTypeImage];
    MHGalleryItem *item9 = [[MHGalleryItem alloc]initWithURL:@"http://images.apple.com/ipad-air/built-in-apps/images/ibooks_screen_2x.jpg"
                                                 galleryType:MHGalleryTypeImage];
    MHGalleryItem *item10 = [[MHGalleryItem alloc]initWithURL:@"http://images.apple.com/ipad-air/built-in-apps/images/facetime_screen_2x.jpg"
                                                  galleryType:MHGalleryTypeImage];
    MHGalleryItem *item11 = [[MHGalleryItem alloc]initWithURL:@"http://images.apple.com/ipad-air/built-in-apps/images/itunesstore_screen_2x.jpg"
                                                  galleryType:MHGalleryTypeImage];
    MHGalleryItem *item12 = [[MHGalleryItem alloc]initWithURL:@"http://images.apple.com/ipad-air/built-in-apps/images/appstore_screen_2x.jpg"
                                                  galleryType:MHGalleryTypeImage];
    MHGalleryItem *item13 = [[MHGalleryItem alloc]initWithURL:@"http://images.apple.com/ipad-air/built-in-apps/images/garageband_screen_2x.jpg"
                                                  galleryType:MHGalleryTypeImage];
    
    MHGalleryItem *item14 = [[MHGalleryItem alloc]initWithURL:@"http://images.apple.com/ipad-air/built-in-apps/images/safari_screen_2x.jpg"
                                                  galleryType:MHGalleryTypeImage];
    
    MHGalleryItem *item15 = [[MHGalleryItem alloc]initWithURL:@"http://mcms.tailored-apps.com/videos/42/1389279847huhe_Thema.mp4"
                                                 galleryType:MHGalleryTypeVideo];
    
    MHGalleryItem *item16 = [[MHGalleryItem alloc]initWithURL:@"http://images.apple.com/media/us/iphone-5c/2013/10ba527a-1a10-3f70-aae814f8/feature/iphone5c-feature-cc-us-20131003_r848-9dwc.mov?width=848&height=480"
                                                  galleryType:MHGalleryTypeVideo];
    
    MHGalleryItem *item17 = [[MHGalleryItem alloc]initWithURL:@"http://store.storeimages.cdn-apple.com/3769/as-images.apple.com/is/image/AppleInc/H4825_FV2?wid=1204&hei=306&fmt=jpeg&qlt=95&op_sharpen=0&resMode=bicub&op_usm=0.5,0.5,0,0&iccEmbed=0&layer=comp&.v=1367279419213"
                                                  galleryType:MHGalleryTypeImage];
    
    MHGalleryItem *item18 = [[MHGalleryItem alloc]initWithURL:@"http://images.apple.com/media/us/ipad-air/2013/0be12b9f-265c-474c-a0cc-d3c4c304c031/feature/ipadair-feature-cc-us-20131114_r848-9dwc.mov?width=848&height=480"
                                                  galleryType:MHGalleryTypeVideo];
    
    

    MHGalleryItem *errorImage = [[MHGalleryItem alloc]initWithURL:@"http://images.apple.com/ipad-air/bui"
                                                 galleryType:MHGalleryTypeImage];

    item0.description = @"MHValidation Screenshot";
    item1.description = @"App Store App Screenshot from iOS7";
    item2.description = @"Calendar App Screenshot from iOS7";
    item3.description = @"Camera App Screenshot from iOS7";
    item4.description = @"Clock App Screenshot from iOS7";
    item5.description = @"Compass App Screenshot from iOS7";
    item6.description = @"Gamecenter App Screenshot from iOS7";
    
    
    self.galleryDataSource = @[
                               @[vimeo0,vimeo1,keynote,item18,item15,item0,item1,item2,item3,item4,item5,item6,item7,item8,item9,item10,item11,item12,item13,item14,item16,item17,item18,errorImage],
                               @[keynote,item15,item0,item1,item2,item3,item4,item5,item6,item7,item8,item9,item10,item11,item12,item13,item14,item16,item17,item18,errorImage]
                               ];
    
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    [self.tableView registerClass:[MHGalleryCollectionViewCell class]
           forCellReuseIdentifier:@"MHGalleryCollectionViewCell"];
    [self.tableView reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.galleryDataSource.count;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.galleryDataSource[collectionView.tag] count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 210;
    
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    view.backgroundColor = [UIColor clearColor];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(25, 0, 320, 30)];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:20];
    label.text = [NSString stringWithFormat:@"Gallery %@",@(section)];
    label.backgroundColor = [UIColor clearColor];
    
    [view addSubview:label];
    return view;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = nil;
    cellIdentifier = @"MHGalleryCollectionViewCell";

    MHGalleryCollectionViewCell *cell = (MHGalleryCollectionViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell){
        cell = [[MHGalleryCollectionViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [cell.collectionView setShowsHorizontalScrollIndicator:NO];
    [cell.collectionView setDelegate:self];
    [cell.collectionView setDataSource:self];
    [cell.collectionView setBackgroundColor:[UIColor whiteColor]];
    [cell.collectionView setTag:indexPath.section];
    [cell.collectionView reloadData];
    
    return cell;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell =nil;
    NSString *cellIdentifier = @"MHGalleryOverViewCell";
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    NSIndexPath *indexPathNew = [NSIndexPath indexPathForRow:indexPath.row inSection:collectionView.tag];
    [self makeOverViewDetailCell:(MHGalleryOverViewCell*)cell atIndexPath:indexPathNew];
    
    return cell;
}

-(void)dismissGalleryForIndexPath:(NSIndexPath*)indexPath
                andCollectionView:(UICollectionView*)collectionView{
    CGRect cellFrame  = [[collectionView collectionViewLayout] layoutAttributesForItemAtIndexPath:indexPath].frame;
    [collectionView scrollRectToVisible:cellFrame
                               animated:NO];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [collectionView reloadItemsAtIndexPaths:@[indexPath]];
        self.imageViewForPresentingMHGallery = [(MHGalleryOverViewCell*)[collectionView cellForItemAtIndexPath:indexPath] iv];
        if (self.interactive) {
            self.interactive.iv = self.imageViewForPresentingMHGallery;
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    });
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    self.imageViewForPresentingMHGallery = [(MHGalleryOverViewCell*)[collectionView cellForItemAtIndexPath:indexPath] iv];
    
    NSArray *galleryData = self.galleryDataSource[collectionView.tag];
    
    [[MHGallerySharedManager sharedManager] presentMHGalleryWithItems:galleryData
                                                             forIndex:indexPath.row
                                             andCurrentViewController:self
                                                       finishCallback:^(NSInteger pageIndex,AnimatorShowDetailForDismissMHGallery *interactiveTransition,UIImage *image) {
                                                           self.interactive = interactiveTransition;
                                                           [self dismissGalleryForIndexPath:[NSIndexPath indexPathForRow:pageIndex inSection:0]
                                                                          andCollectionView:collectionView];
                                                           
                                                       }
                                             withImageViewTransiation:YES];
}


-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationPortrait;
}


-(BOOL)shouldAutorotate{
    return NO;
}

-(id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator{
    if ([animator isKindOfClass:[AnimatorShowDetailForDismissMHGallery class]]) {
        return self.interactive;
    }else {
        return nil;
    }
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    AnimatorShowDetailForDismissMHGallery *detail = [AnimatorShowDetailForDismissMHGallery new];
    detail.iv = self.imageViewForPresentingMHGallery;
    return detail;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
    AnimatorShowDetailForPresentingMHGallery *detail = [AnimatorShowDetailForPresentingMHGallery new];
    detail.iv = self.imageViewForPresentingMHGallery;
    return detail;
}


-(void)makeOverViewDetailCell:(MHGalleryOverViewCell*)cell atIndexPath:(NSIndexPath*)indexPath{
    MHGalleryItem *item = self.galleryDataSource[indexPath.section][indexPath.row];
    [cell.iv setContentMode:UIViewContentModeScaleAspectFill];
    if (item.galleryType == MHGalleryTypeImage) {
        [cell.iv setImageWithURL:[NSURL URLWithString:item.urlString]];
    }else{
        [[MHGallerySharedManager sharedManager] startDownloadingThumbImage:item.urlString
                                                                   forSize:CGSizeMake(cell.frame.size.width*2, cell.frame.size.height*2)
                                                                atDuration:MHImageGenerationStart
                                                              successBlock:^(UIImage *image, NSUInteger videoDuration, NSError *error,NSString *newURL) {
                                                                  cell.iv.image = image;
        }];
    }
}


@end
