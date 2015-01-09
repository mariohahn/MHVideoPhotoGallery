//
//  ExampleViewController.m
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 30.09.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//

#import "ExampleViewControllerCollectionViewInTableView.h"
#import "MHOverviewController.h"

@implementation UITabBarController (autoRotate)
- (BOOL)shouldAutorotate {
    return [self.selectedViewController shouldAutorotate];
}
- (NSUInteger)supportedInterfaceOrientations {
    return [self.selectedViewController supportedInterfaceOrientations];
}


@end


@implementation UINavigationController (autoRotate)

-(UIStatusBarStyle)preferredStatusBarStyle{
    return [self.viewControllers.lastObject preferredStatusBarStyle];
}

- (BOOL)shouldAutorotate {
    return [self.viewControllers.lastObject shouldAutorotate];
}
- (NSUInteger)supportedInterfaceOrientations {
    return [self.viewControllers.lastObject supportedInterfaceOrientations];
}

@end


@implementation TestCell
@end

@interface ExampleViewControllerCollectionViewInTableView ()
@property(nonatomic,strong) NSArray *galleryDataSource;
@end

@implementation ExampleViewControllerCollectionViewInTableView

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.title = @"CollectionView";
    
    MHGalleryItem *localVideo = [MHGalleryItem.alloc initWithURL:[[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Sydney-iPhone" ofType:@"m4v"]] absoluteString]
                                                     galleryType:MHGalleryTypeVideo];
    
    MHGalleryItem *youtube = [MHGalleryItem.alloc initWithURL:@"http://www.youtube.com/watch?v=YSdJtNen-EA"
                                                  galleryType:MHGalleryTypeVideo];
    
    MHGalleryItem *vimeo0 = [MHGalleryItem.alloc initWithURL:@"http://vimeo.com/35515926"
                                                 galleryType:MHGalleryTypeVideo];
    MHGalleryItem *vimeo1 = [MHGalleryItem.alloc initWithURL:@"http://vimeo.com/50006726"
                                                 galleryType:MHGalleryTypeVideo];
    MHGalleryItem *vimeo3 = [MHGalleryItem.alloc initWithURL:@"http://vimeo.com/66841007"
                                                 galleryType:MHGalleryTypeVideo];
    
    MHGalleryItem *landschaft = [MHGalleryItem.alloc initWithURL:@"http://alles-bilder.de/landschaften/HD%20Landschaftsbilder%20(47).jpg"
                                                     galleryType:MHGalleryTypeImage];
    
    MHGalleryItem *landschaft1 = [MHGalleryItem.alloc initWithURL:@"http://de.flash-screen.com/free-wallpaper/bezaubernde-landschaftsabbildung-hd/hd-bezaubernde-landschaftsder-tapete,1920x1200,56420.jpg"
                                                      galleryType:MHGalleryTypeImage];
    
    MHGalleryItem *landschaft2 = [MHGalleryItem.alloc initWithURL:@"http://alles-bilder.de/landschaften/HD%20Landschaftsbilder%20(64).jpg"
                                                      galleryType:MHGalleryTypeImage];
    
    MHGalleryItem *landschaft3 = [MHGalleryItem.alloc initWithURL:@"http://www.dirks-computerseite.de/wp-content/uploads/2013/06/purpleworld1.jpg"
                                                      galleryType:MHGalleryTypeImage];
    
    MHGalleryItem *landschaft4 = [MHGalleryItem.alloc initWithURL:@"http://alles-bilder.de/landschaften/HD%20Landschaftsbilder%20(42).jpg"
                                                      galleryType:MHGalleryTypeImage];
    
    MHGalleryItem *landschaft5 = [MHGalleryItem.alloc initWithURL:@"http://woxx.de/wp-content/uploads/sites/3/2013/02/8X2cWV3.jpg"
                                                      galleryType:MHGalleryTypeImage];
    
    MHGalleryItem *landschaft6 = [MHGalleryItem.alloc initWithURL:@"http://kwerfeldein.de/wp-content/uploads/2012/05/Sharpened-version.jpg"
                                                      galleryType:MHGalleryTypeImage];
    
    MHGalleryItem *landschaft7 = [MHGalleryItem.alloc initWithURL:@"http://eswalls.com/wp-content/uploads/2014/01/sunset-glow-trees-beautiful-scenery.jpg"
                                                      galleryType:MHGalleryTypeImage];
    
    MHGalleryItem *landschaft8 = [MHGalleryItem.alloc initWithURL:@"http://eswalls.com/wp-content/uploads/2014/01/beautiful_scenery_wallpaper_The_Eiffel_Tower_at_night_.jpg"
                                                      galleryType:MHGalleryTypeImage];
    
    MHGalleryItem *landschaft9 = [MHGalleryItem.alloc initWithURL:@"http://p1.pichost.me/i/40/1638707.jpg"
                                                      galleryType:MHGalleryTypeImage];
    
    MHGalleryItem *landschaft10 = [MHGalleryItem.alloc initWithURL:@"http://4.bp.blogspot.com/-8O0ZkAgb6Bo/Ulf_80tUN6I/AAAAAAAAH34/I1L2lKjzE9M/s1600/Beautiful-Scenery-Wallpapers.jpg"
                                                       galleryType:MHGalleryTypeImage];
    
    MHGalleryItem *landschaft11 = [MHGalleryItem.alloc initWithURL:@"http://www.bestfon.info/images/joomgallery/originals/paisajes_18/paisaje_325_20120501_1124813185.jpg"
                                                       galleryType:MHGalleryTypeImage];
    MHGalleryItem *landschaft12 = [MHGalleryItem.alloc initWithURL:@"http://www.stadt-bad-reichenhall.de/medien/landschaft-winter-1.jpg"
                                                       galleryType:MHGalleryTypeImage];
    MHGalleryItem *landschaft13 = [MHGalleryItem.alloc initWithURL:@"http://www.foto-zumstein.ch/fotogalerie/1195564506_Kopie_vonLandschaft_33.jpg"
                                                       galleryType:MHGalleryTypeImage];
    MHGalleryItem *landschaft14 = [MHGalleryItem.alloc initWithURL:@"http://img.galerie.chip.de/imgserver/communityimages/233900/233952/1280x.jpg"
                                                       galleryType:MHGalleryTypeImage];
    MHGalleryItem *landschaft15 = [MHGalleryItem.alloc initWithURL:@"http://www.spreephoto.de/wp-content/uploads/2011/03/toskana-strohballen-landschaft.jpg"
                                                       galleryType:MHGalleryTypeImage];
    MHGalleryItem *landschaft16 = [MHGalleryItem.alloc initWithURL:@"http://kwerfeldein.de/wp-content/uploads/2012/07/landschaft.jpg"
                                                       galleryType:MHGalleryTypeImage];
    
    MHGalleryItem *landschaft17 = [MHGalleryItem.alloc initWithURL:@"http://www.picspack.de/blog/wp-content/uploads/2011/11/Liu2.jpg"
                                                       galleryType:MHGalleryTypeImage];
    
    MHGalleryItem *landschaft18 = [MHGalleryItem.alloc initWithURL:@"http://images.fotocommunity.de/bilder/bach-fluss-see/see-teich-tuempel/symmetrische-landschaft-645f1ee5-f53b-4ae9-ad76-7bf5bde3935d.jpg"
                                                       galleryType:MHGalleryTypeImage];
    
    MHGalleryItem *landschaft19 = [MHGalleryItem.alloc initWithURL:@"http://www.hd-gbpics.de/gbbilder/landschaften/landschaft10.jpg"
                                                       galleryType:MHGalleryTypeImage];
    
    MHGalleryItem *landschaft20 = [MHGalleryItem.alloc initWithURL:@"http://www.stadt-bad-reichenhall.de/medien/landschaft-1.jpg"
                                                       galleryType:MHGalleryTypeImage];
    
    MHGalleryItem *gif1 = [MHGalleryItem.alloc initWithURL:@"http://i.imgur.com/qe8wIgn.gif"
                                                       galleryType:MHGalleryTypeImage];
    
    MHGalleryItem *gif2 = [MHGalleryItem.alloc initWithURL:@"http://i.imgur.com/d86g7Ps.gif"
                                                       galleryType:MHGalleryTypeImage];
    
    
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc]initWithString:@"Awesome!!\nOr isn't it?"];
    
    [string setAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15]} range:NSMakeRange(0, string.length)];
    [string setAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:17]} range:NSMakeRange(0, 9)];
    
    landschaft10.attributedString = string;
    
    self.galleryDataSource = @[@[landschaft,landschaft1,landschaft2,landschaft3,landschaft4,landschaft5,landschaft6,landschaft7,landschaft8,landschaft9,landschaft10,landschaft11,landschaft12,landschaft13,landschaft14,landschaft15,landschaft16,landschaft17,landschaft18,landschaft19,landschaft20],
                               @[vimeo3,youtube,vimeo0,vimeo1,landschaft9,landschaft6,landschaft5,landschaft4,landschaft3,landschaft2,landschaft,landschaft1],
                               @[landschaft9,landschaft6,localVideo,landschaft5,landschaft4,landschaft3,landschaft2,landschaft,landschaft1]
                               ];
    self.tableView.backgroundColor = [UIColor colorWithRed:0.83 green:0.84 blue:0.86 alpha:1];
    [self.tableView reloadData];
    
    [self setNeedsStatusBarAppearanceUpdate];
        
}


-(UIStatusBarStyle)preferredStatusBarStyle{
    if ([self.presentedViewController isKindOfClass:[MHGalleryController class]]) {
        MHGalleryController *gallerController = (MHGalleryController*)self.presentedViewController;
        return gallerController.preferredStatusBarStyleMH;
    }
    return UIStatusBarStyleDefault;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.galleryDataSource.count;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.galleryDataSource[collectionView.tag] count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 330;
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = nil;
    cellIdentifier = @"TestCell";
    
    TestCell *cell = (TestCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell){
        cell = [[TestCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.backView.layer.masksToBounds = NO;
    cell.backView.layer.shadowOffset = CGSizeMake(0, 0);
    cell.backView.layer.shadowRadius = 1.0;
    cell.backView.layer.shadowColor = [UIColor blackColor].CGColor;
    cell.backView.layer.shadowOpacity = 0.5;
    cell.backView.layer.shadowPath = [UIBezierPath bezierPathWithRect:cell.backView.bounds].CGPath;
    cell.backView.layer.cornerRadius = 2.0;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(0, 25, 0, 25);
    layout.itemSize = CGSizeMake(270, 225);
    layout.minimumLineSpacing = 15;
    layout.minimumInteritemSpacing = 15;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    cell.collectionView.collectionViewLayout = layout;
    
    [cell.collectionView registerClass:[MHMediaPreviewCollectionViewCell class] forCellWithReuseIdentifier:@"MHMediaPreviewCollectionViewCell"];
    
    cell.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    [cell.collectionView setShowsHorizontalScrollIndicator:NO];
    [cell.collectionView setDelegate:self];
    [cell.collectionView setDataSource:self];
    [cell.collectionView setTag:indexPath.section];
    [cell.collectionView reloadData];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell =nil;
    NSString *cellIdentifier = @"MHMediaPreviewCollectionViewCell";
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    NSIndexPath *indexPathNew = [NSIndexPath indexPathForRow:indexPath.row inSection:collectionView.tag];
    [self makeOverViewDetailCell:(MHMediaPreviewCollectionViewCell*)cell atIndexPath:indexPathNew];
    
    return cell;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UIImageView *imageView = [(MHMediaPreviewCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath] thumbnail];
    
    NSArray *galleryData = self.galleryDataSource[collectionView.tag];
    
    MHGalleryController *gallery = [MHGalleryController galleryWithPresentationStyle:MHGalleryViewModeImageViewerNavigationBarShown];
    gallery.galleryItems = galleryData;
    gallery.presentingFromImageView = imageView;
    gallery.presentationIndex = indexPath.row;
   // gallery.UICustomization.hideShare = YES;
    //  gallery.galleryDelegate = self;
    //  gallery.dataSource = self;
    __weak MHGalleryController *blockGallery = gallery;
    
    gallery.finishedCallback = ^(NSInteger currentIndex,UIImage *image,MHTransitionDismissMHGallery *interactiveTransition,MHGalleryViewMode viewMode){
        if (viewMode == MHGalleryViewModeOverView) {
            [blockGallery dismissViewControllerAnimated:YES completion:^{
                [self setNeedsStatusBarAppearanceUpdate];
            }];
        }else{
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:currentIndex inSection:0];
            CGRect cellFrame  = [[collectionView collectionViewLayout] layoutAttributesForItemAtIndexPath:newIndexPath].frame;
            [collectionView scrollRectToVisible:cellFrame
                                       animated:NO];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [collectionView reloadItemsAtIndexPaths:@[newIndexPath]];
                [collectionView scrollToItemAtIndexPath:newIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
                
                MHMediaPreviewCollectionViewCell *cell = (MHMediaPreviewCollectionViewCell*)[collectionView cellForItemAtIndexPath:newIndexPath];
                
                [blockGallery dismissViewControllerAnimated:YES dismissImageView:cell.thumbnail completion:^{
                    
                    [self setNeedsStatusBarAppearanceUpdate];
                    
                    MPMoviePlayerController *player = interactiveTransition.moviePlayer;
                    
                    player.controlStyle = MPMovieControlStyleEmbedded;
                    player.view.frame = cell.bounds;
                    player.scalingMode = MPMovieScalingModeAspectFill;
                    [cell.contentView addSubview:player.view];
                }];
            });
        }
    };
    [self presentMHGalleryController:gallery animated:YES completion:nil];
}


-(NSInteger)numberOfItemsInGallery:(MHGalleryController *)galleryController{
    return 10;
}

-(MHGalleryItem *)itemForIndex:(NSInteger)index{
    // You also have to set the image in the Testcell to get the correct Animation
    //    return [MHGalleryItem.alloc initWithImage:nil];
    return [MHGalleryItem itemWithImage:[UIImage imageNamed:@"twitterMH"]];
}

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

-(BOOL)shouldAutorotate{
    return YES;
}

-(void)makeOverViewDetailCell:(MHMediaPreviewCollectionViewCell*)cell atIndexPath:(NSIndexPath*)indexPath{
    MHGalleryItem *item = self.galleryDataSource[indexPath.section][indexPath.row];
    cell.thumbnail.contentMode = UIViewContentModeScaleAspectFill;
    
    cell.thumbnail.layer.shadowOffset = CGSizeMake(0, 0);
    cell.thumbnail.layer.shadowRadius = 1.0;
    cell.thumbnail.layer.shadowColor = [UIColor blackColor].CGColor;
    cell.thumbnail.layer.shadowOpacity = 0.5;
    cell.thumbnail.layer.shadowPath = [UIBezierPath bezierPathWithRect:cell.thumbnail.bounds].CGPath;
    cell.thumbnail.layer.cornerRadius = 2.0;
    
    cell.thumbnail.image = nil;
    cell.galleryItem = item;
}


@end
