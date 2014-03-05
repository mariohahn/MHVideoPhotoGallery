//
//  MHShareViewController.m
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 10.01.14.
//  Copyright (c) 2014 Mario Hahn. All rights reserved.
//

#import "MHShareViewController.h"
#import "MHGalleryCells.h"
#import "MHGallery.h"
#import "UIImageView+WebCache.h"
#import "MHTransitionShowShareView.h"
#import <CoreImage/CoreImage.h>
#import <ImageIO/ImageIO.h>

@implementation MHShareCell

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _thumbnailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width/2-30, 1, 60, 60)];
        self.thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.thumbnailImageView.clipsToBounds = TRUE;
        [[self contentView] addSubview:self.thumbnailImageView];
        
        _descriptionLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.bounds.size.height-40, self.bounds.size.width, 40)];
        self.descriptionLabel.backgroundColor = [UIColor clearColor];
        self.descriptionLabel.textColor = [UIColor blackColor];
        self.descriptionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13];
        [self.descriptionLabel setNumberOfLines:2];
        [[self contentView] addSubview:self.descriptionLabel];
    }
    return self;
}
@end


@interface MHShareViewController ()
@property(nonatomic,strong) NSMutableArray *shareDataSource;
@property(nonatomic,strong) NSArray *shareDataSourceStart;
@property(nonatomic,strong) NSMutableArray *selectedRows;
@property(nonatomic)        CGFloat startPointScroll;
@property(nonatomic,strong) MHShareItem *saveObject;
@property(nonatomic,strong) MHShareItem *mailObject;
@property(nonatomic,strong) MHShareItem *messageObject;
@property(nonatomic,strong) MHShareItem *twitterObject;
@property(nonatomic,strong) MHShareItem *faceBookObject;
@property(nonatomic,getter = isShowingShareViewInLandscapeMode) BOOL showingShareViewInLandscapeMode;
@property (nonatomic, strong) NSNumberFormatter *numberFormatter;

@end

@implementation MHShareViewController

-(void)initShareObjects{
    
    
    self.saveObject = [[MHShareItem alloc]initWithImageName:@"activtyMH"
                                                      title:MHGalleryLocalizedString(@"shareview.save.cameraRoll")
                                       withMaxNumberOfItems:MAXFLOAT
                                               withSelector:@"saveImages:"
                                           onViewController:self];
    
    self.mailObject = [[MHShareItem alloc]initWithImageName:@"mailMH"
                                                      title:MHGalleryLocalizedString(@"shareview.mail")
                                       withMaxNumberOfItems:10
                                               withSelector:@"mailImages:"
                                           onViewController:self];
    
    
    self.messageObject = [[MHShareItem alloc]initWithImageName:@"messageMH"
                                                         title:MHGalleryLocalizedString(@"shareview.message")
                                          withMaxNumberOfItems:15
                                                  withSelector:@"smsImages:"
                                              onViewController:self];
    
    
    self.twitterObject = [[MHShareItem alloc]initWithImageName:@"twitterMH"
                                                         title:@"Twitter"
                                          withMaxNumberOfItems:2
                                                  withSelector:@"twShareImages:"
                                              onViewController:self] ;
    
    self.faceBookObject = [[MHShareItem alloc]initWithImageName:@"facebookMH"
                                                          title:@"Facebook"
                                           withMaxNumberOfItems:10
                                                   withSelector:@"fbShareImages:"
                                               onViewController:self];
}

-(void)cancelPressed{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.delegate = self;
    [self.collectionView.delegate scrollViewDidScroll:self.collectionView];
    
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    self.startPointScroll = scrollView.contentOffset.x;
}

-(void) scrollViewWillEndDragging:(UIScrollView*)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint*)targetContentOffset {
    NSArray *visibleCells = [self sortObjectsWithFrame:self.collectionView.visibleCells];
    
    MHGalleryOverViewCell *cell;
    if ((self.startPointScroll <  targetContentOffset->x) && (visibleCells.count >1)) {
        cell = visibleCells[1];
    }else{
        cell = [visibleCells firstObject];
    }
    if (MHISIPAD) {
        *targetContentOffset = CGPointMake((cell.tag * 330+20), targetContentOffset->y);
        
    }else{
        *targetContentOffset = CGPointMake((cell.tag * 250+20), targetContentOffset->y);
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.navigationController.delegate == self) {
        self.navigationController.delegate = nil;
    }
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC {
    return [MHTransitionShowShareView new];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.numberFormatter = [NSNumberFormatter new];
    [self.numberFormatter setMinimumIntegerDigits:2];
    
    
    
    self.selectedRows = [NSMutableArray new];
    self.view.backgroundColor =[UIColor whiteColor];
    self.navigationItem.hidesBackButton =YES;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                         target:self
                                                                                         action:@selector(cancelPressed)];
    
    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    if (MHISIPAD) {
        flowLayout.itemSize = CGSizeMake(320, self.view.frame.size.height-330);
    }else{
        flowLayout.itemSize = CGSizeMake(240, self.view.frame.size.height-330);
    }
    flowLayout.minimumInteritemSpacing =20;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 60, 0, 0);
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-240)
                                collectionViewLayout:flowLayout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.allowsMultipleSelection=YES;
    self.collectionView.contentInset =UIEdgeInsetsMake(0, 0, 0, 0);
    self.collectionView.showsHorizontalScrollIndicator =NO;
    self.collectionView.backgroundColor =[UIColor whiteColor];
    [self.collectionView registerClass:[MHGalleryOverViewCell class]
            forCellWithReuseIdentifier:@"MHGalleryOverViewCell"];
    
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateNormal;
    [self.view addSubview:self.collectionView];
    
    
    [self.selectedRows addObject:[NSIndexPath indexPathForRow:self.pageIndex inSection:0]];
    
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.pageIndex inSection:0]
                    atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                            animated:NO];
    self.gradientView= [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-240, self.view.frame.size.width,240)];
    
    self.toolbar = [[UIToolbar alloc]initWithFrame:self.gradientView.frame];
    [self.view addSubview:self.toolbar];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.gradientView.bounds;
    gradient.colors = @[(id)[[UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1] CGColor],(id)[[UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1] CGColor]];
    [self.gradientView.layer insertSublayer:gradient atIndex:0];
    [self.view addSubview:self.gradientView];
    
    self.tableViewShare = [[UITableView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-230, self.view.frame.size.width, 240)];
    self.tableViewShare.delegate =self;
    self.tableViewShare.separatorStyle =UITableViewCellSeparatorStyleNone;
    self.tableViewShare.dataSource =self;
    self.tableViewShare.backgroundColor =[UIColor clearColor];
    self.tableViewShare.scrollEnabled =NO;
    [self.tableViewShare registerClass:[MHGalleryCollectionViewCell class]
                forCellReuseIdentifier:@"MHGalleryCollectionViewCell"];
    [self.view addSubview:self.tableViewShare];
    
    UIView *sep = [[UIView alloc]initWithFrame:CGRectMake(0,115, self.view.frame.size.width, 1)];
    sep.backgroundColor = [UIColor colorWithRed:0.63 green:0.63 blue:0.63 alpha:1];
    sep.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.tableViewShare addSubview:sep];
    
    [self initShareObjects];
    [self updateTitle];
    
    NSMutableArray *shareObjectAvailable = [NSMutableArray arrayWithArray:@[self.messageObject,
                                                                            self.mailObject,
                                                                            self.twitterObject,
                                                                            self.faceBookObject]];
    
    
    if(![SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]){
        [shareObjectAvailable removeObject:self.faceBookObject];
    }
    if(![SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]){
        [shareObjectAvailable removeObject:self.twitterObject];
    }
    
    self.shareDataSource = [NSMutableArray arrayWithArray:@[shareObjectAvailable,
                                                            @[[self saveObject]]
                                                            ]];
    
    self.shareDataSourceStart = [NSArray arrayWithArray:self.shareDataSource];
    if([UIApplication sharedApplication].statusBarOrientation != UIInterfaceOrientationPortrait){
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(showShareSheet)];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 119;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = nil;
    cellIdentifier = @"MHGalleryCollectionViewCell";
    
    MHGalleryCollectionViewCell *cell = (MHGalleryCollectionViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell){
        cell = [[MHGalleryCollectionViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.backgroundColor = [UIColor clearColor];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
    layout.itemSize = CGSizeMake(70, 100);
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 10;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    cell.collectionView.collectionViewLayout = layout;
    
    [cell.collectionView registerClass:[MHShareCell class]
            forCellWithReuseIdentifier:@"MHShareCell"];
    [cell.collectionView setShowsHorizontalScrollIndicator:NO];
    [cell.collectionView setDelegate:self];
    [cell.collectionView setDataSource:self];
    [cell.collectionView setBackgroundColor:[UIColor clearColor]];
    [cell.collectionView setTag:indexPath.section];
    [cell.collectionView reloadData];
    
    return cell;
}
-(void)updateTitle{
    NSString *localizedTitle =  MHGalleryLocalizedString(@"shareview.title.select.singular");
    self.title = [NSString stringWithFormat:localizedTitle, @(self.selectedRows.count)];
    if (self.selectedRows.count >1) {
        NSString *localizedTitle =  MHGalleryLocalizedString(@"shareview.title.select.plural");
        self.title = [NSString stringWithFormat:localizedTitle, @(self.selectedRows.count)];
    }
    
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if ([collectionView isEqual:self.collectionView]) {
        return self.galleryItems.count;
    }
    return [self.shareDataSource[collectionView.tag] count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell =nil;
    if ([collectionView isEqual:self.collectionView]) {
        NSString *cellIdentifier = @"MHGalleryOverViewCell";
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        [self makeOverViewDetailCell:(MHGalleryOverViewCell*)cell atIndexPath:indexPath];
    }else{
        NSString *cellIdentifier = @"MHShareCell";
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        NSIndexPath *indexPathNew = [NSIndexPath indexPathForRow:indexPath.row inSection:collectionView.tag];
        [self makeMHShareCell:(MHShareCell*)cell atIndexPath:indexPathNew];
    }
    
    return cell;
}
-(void)makeMHShareCell:(MHShareCell*)cell atIndexPath:(NSIndexPath*)indexPath{
    
    MHShareItem *shareItem = self.shareDataSource[indexPath.section][indexPath.row];
    
    cell.thumbnailImageView.image = [UIImage imageNamed:shareItem.imageName];
    [cell.thumbnailImageView setContentMode:UIViewContentModeCenter];
    if (indexPath.section ==0) {
        cell.thumbnailImageView.layer.cornerRadius =15;
    }
    cell.descriptionLabel.adjustsFontSizeToFitWidth =YES;
    cell.thumbnailImageView.clipsToBounds = YES;
    
    cell.descriptionLabel.textAlignment = NSTextAlignmentCenter;
    cell.descriptionLabel.text = shareItem.title;
    cell.backgroundColor = [UIColor clearColor];
}
-(void)makeOverViewDetailCell:(MHGalleryOverViewCell*)cell atIndexPath:(NSIndexPath*)indexPath{
    __block MHGalleryOverViewCell *blockCell = cell;
    
    MHGalleryItem *item = self.galleryItems[indexPath.row];
    cell.videoDurationLength.text = @"";
    [cell.videoIcon setHidden:YES];
    [cell.videoGradient setHidden:YES];
    if (item.galleryType == MHGalleryTypeImage) {
        
        if ([item.urlString rangeOfString:@"assets-library"].location != NSNotFound) {
            [[MHGallerySharedManager sharedManager] getImageFromAssetLibrary:item.urlString assetType:MHAssetImageTypeFull successBlock:^(UIImage *image, NSError *error) {
                cell.thumbnail.image = image;
            }];
        }else{
            [cell.thumbnail setImageWithURL:[NSURL URLWithString:item.urlString] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                if (!image) {
                    blockCell.thumbnail.image = [UIImage imageNamed:@"error"];
                }
            }];
        }
    }else{
        [[MHGallerySharedManager sharedManager] startDownloadingThumbImage:item.urlString
                                                              successBlock:^(UIImage *image,NSUInteger videoDuration,NSError *error,NSString *newURL) {
                                                                  if (error) {
                                                                      cell.thumbnail.image = [UIImage imageNamed:@"error"];
                                                                  }else{
                                                                      
                                                                      NSNumber *minutes = @(videoDuration / 60);
                                                                      NSNumber *seconds = @(videoDuration % 60);
                                                                      
                                                                      blockCell.videoDurationLength.text = [NSString stringWithFormat:@"%@:%@",
                                                                                                            [self.numberFormatter stringFromNumber:minutes] ,[self.numberFormatter stringFromNumber:seconds]];
                                                                      [blockCell.thumbnail setImage:image];
                                                                      [blockCell.videoIcon setHidden:NO];
                                                                      [blockCell.videoGradient setHidden:NO];
                                                                  }
                                                              }];
    }
    
    
    
    [cell.thumbnail setContentMode:UIViewContentModeScaleAspectFill];
    cell.selectionImageView.hidden =NO;
    
    cell.selectionImageView.layer.borderWidth =1;
    cell.selectionImageView.layer.cornerRadius =11;
    cell.selectionImageView.layer.borderColor =[UIColor whiteColor].CGColor;
    cell.selectionImageView.image =  nil;
    cell.selectionImageView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.45];
    
    if ([self.selectedRows containsObject:indexPath]) {
        cell.selectionImageView.backgroundColor = [UIColor whiteColor];
        cell.selectionImageView.tintColor = [UIColor colorWithRed:0 green:0.46 blue:1 alpha:1];
        cell.selectionImageView.image =  [[UIImage imageNamed:@"EditControlSelected"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    
    cell.tag = indexPath.row;
    
}
-(NSArray*)sortObjectsWithFrame:(NSArray*)objects{
    NSComparator comparatorBlock = ^(id obj1, id obj2) {
        if ([obj1 frame].origin.x > [obj2 frame].origin.x) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        if ([obj1 frame].origin.x < [obj2 frame].origin.x) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    };
    NSMutableArray *fieldsSort = [[NSMutableArray alloc]initWithArray:objects];
    [fieldsSort sortUsingComparator:comparatorBlock];
    return [NSArray arrayWithArray:fieldsSort];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if ([scrollView isEqual:self.collectionView]) {
        NSArray *visibleCells = [self sortObjectsWithFrame:self.collectionView.visibleCells];
        for (MHGalleryOverViewCell *cellOther in visibleCells) {
            if (!cellOther.videoIcon.isHidden){
                cellOther.selectionImageView.frame = CGRectMake(cellOther.bounds.size.width-30,  cellOther.bounds.size.height-50, 22, 22);
            }else{
                cellOther.selectionImageView.frame = CGRectMake(cellOther.bounds.size.width-30,  cellOther.bounds.size.height-30, 22, 22);
            }
        }
        
        MHGalleryOverViewCell *cell = [visibleCells lastObject];
        CGRect rect = [self.view convertRect:cell.thumbnail.frame
                                    fromView:cell.thumbnail.superview];
        
        NSInteger valueToAddYForVideoType =0;
        if (!cell.videoIcon.isHidden){
            valueToAddYForVideoType+=20;
        }
        
        cell.selectionImageView.frame = CGRectMake(self.view.frame.size.width-rect.origin.x-30, cell.bounds.size.height-(30+valueToAddYForVideoType), 22, 22);
        if (cell.selectionImageView.frame.origin.x < 5) {
            cell.selectionImageView.frame = CGRectMake(5,  cell.bounds.size.height-(30+valueToAddYForVideoType), 22, 22);
        }
        
        if (cell.selectionImageView.frame.origin.x > cell.bounds.size.width-30 ) {
            cell.selectionImageView.frame = CGRectMake(cell.bounds.size.width-30,  cell.bounds.size.height-(30+valueToAddYForVideoType), 22, 22);
        }
    }
}

-(void)updateCollectionView{
    
    NSInteger index =0;
    NSArray *storedData = [NSArray arrayWithArray:self.shareDataSource];
    
    self.shareDataSource = [NSMutableArray new];

    for (NSArray *array in self.shareDataSourceStart) {
        NSMutableArray *newObjects  = [NSMutableArray new];
        
        for (MHShareItem *item in array) {
            if (self.selectedRows.count <= item.maxNumberOfItems) {
                if (![storedData[index] containsObject:item]) {
                    [newObjects addObject:item];
                }else{
                    [newObjects addObject:item];
                }
            }
        }
        
        for (NSIndexPath *indexPath in self.selectedRows) {
            MHGalleryItem *item =self.galleryItems[indexPath.row];
            if (item.galleryType == MHGalleryTypeVideo) {
                if ([newObjects containsObject:self.saveObject] ) {
                    [newObjects removeObject:self.saveObject];
                }
            }
        }
        
        [self.shareDataSource addObject:newObjects];
        MHGalleryCollectionViewCell *cell = (MHGalleryCollectionViewCell*)[self.tableViewShare cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index]];
        [cell.collectionView reloadData];
        index++;
    }
}
-(void)presentSLComposeForServiceType:(NSString*)serviceType{
    
    [self getAllImagesForSelectedRows:^(NSArray *images) {
        SLComposeViewController *shareconntroller=[SLComposeViewController composeViewControllerForServiceType:serviceType];
        SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result){
            
            [shareconntroller dismissViewControllerAnimated:YES
                                                 completion:nil];
        };
        NSString *videoURLS = [NSString new];
        for (id data in images) {
            if ([data isKindOfClass:[UIImage class]]) {
                [shareconntroller addImage:data];
            }else{
                videoURLS = [videoURLS stringByAppendingString:[NSString stringWithFormat: @"%@ \n",data]];
            }
        }
        [shareconntroller setInitialText:videoURLS];
        [shareconntroller setCompletionHandler:completionHandler];
        [self presentViewController:shareconntroller
                           animated:YES
                         completion:nil];
    }];
}
-(void)twShareImages:(NSArray*)object{
    [self presentSLComposeForServiceType:SLServiceTypeTwitter];
}

-(void)fbShareImages:(NSArray*)object{
    [self presentSLComposeForServiceType:SLServiceTypeFacebook];
}

-(void)smsImages:(NSArray*)object{
    [self getAllImagesForSelectedRows:^(NSArray *images) {
        MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
        picker.messageComposeDelegate = self;
        NSString *videoURLS = [NSString new];
        
        for (id data in images) {
            if ([data isKindOfClass:[UIImage class]]) {
                
                [picker addAttachmentData:UIImageJPEGRepresentation(data, 1.0)
                           typeIdentifier:@"public.image"
                                 filename:@"image.JPG"];
            }else{
                videoURLS = [videoURLS stringByAppendingString:[NSString stringWithFormat: @"%@ \n",data]];
            }
        }
        picker.body = videoURLS;
        
        
        [self presentViewController:picker
                           animated:YES
                         completion:NULL];
    }];
}

-(void)mailImages:(NSArray*)object{
    [self getAllImagesForSelectedRows:^(NSArray *images) {
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        NSString *videoURLS = [NSString new];
        
        for (id data in images) {
            if ([data isKindOfClass:[UIImage class]]) {
                [picker addAttachmentData:UIImageJPEGRepresentation(data, 1.0)
                                 mimeType:@"image/jpeg"
                                 fileName:@"image"];
            }else{
                videoURLS = [videoURLS stringByAppendingString:[NSString stringWithFormat: @"%@ \n",data]];
                
            }
        }
        [picker setMessageBody:videoURLS isHTML:NO];
        
        if([MFMailComposeViewController canSendMail]){
            [self presentViewController:picker
                               animated:YES
                             completion:NULL];
        }
    }];
}
-(void)messageComposeViewController:(MFMessageComposeViewController *)controller
                didFinishWithResult:(MessageComposeResult)result{
    [controller dismissViewControllerAnimated:YES
                                   completion:^{
                                       [self cancelPressed];
                                   }];
}
-(void)mailComposeController:(MFMailComposeViewController *)controller
         didFinishWithResult:(MFMailComposeResult)result
                       error:(NSError *)error{
    [controller dismissViewControllerAnimated:YES
                                   completion:^{
                                       [self cancelPressed];
                                   }];
}

-(void)getAllImagesForSelectedRows:(void(^)(NSArray *images))SuccessBlock{
    __block NSMutableArray *imagesData = [NSMutableArray new];
    
    for (NSIndexPath *indexPath in self.selectedRows) {
        MHGalleryItem *item =self.galleryItems[indexPath.row];
        
        if (item.galleryType == MHGalleryTypeVideo) {
            [imagesData addObject:item.urlString];
        }
        if (imagesData.count == self.selectedRows.count) {
            SuccessBlock([NSArray arrayWithArray:imagesData]);
            return;
        }
        
        if (item.galleryType == MHGalleryTypeImage) {
            
            [[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:item.urlString]
                                                       options:SDWebImageContinueInBackground
                                                      progress:nil
                                                     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
                                                         [imagesData addObject:image];
                                                         if (imagesData.count == self.selectedRows.count) {
                                                             SuccessBlock([NSArray arrayWithArray:imagesData]);
                                                         }
                                                     }];
        }
    }
}
-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                        duration:(NSTimeInterval)duration{
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                             target:self
                                                                                             action:@selector(cancelPressed)];
        self.navigationItem.rightBarButtonItem = nil;
        self.collectionView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-240);
        self.toolbar.frame = CGRectMake(0, self.view.frame.size.height-240, self.view.frame.size.width,240);
        self.tableViewShare.frame = CGRectMake(0, self.view.frame.size.height-230, self.view.frame.size.width, 240);
        self.gradientView.frame = CGRectMake(0, self.view.frame.size.height-240, self.view.frame.size.width,240);
    }else{
        self.tableViewShare.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 240);
        self.toolbar.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width,240);
        self.collectionView.frame = self.view.bounds;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(showShareSheet)];
    }
    [self.collectionView.collectionViewLayout invalidateLayout];
}
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    
    NSArray *visibleCells = [self sortObjectsWithFrame:self.collectionView.visibleCells];
    NSInteger numberToScrollTo =  visibleCells.count/2;
    MHGalleryOverViewCell *cell =  (MHGalleryOverViewCell*)visibleCells[numberToScrollTo];
    
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:cell.tag inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                        animated:YES];
    if (self.isShowingShareViewInLandscapeMode) {
        self.showingShareViewInLandscapeMode = NO;
    }
    
}
-(void)cancelShareSheet{
    self.showingShareViewInLandscapeMode = NO;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                         target:self
                                                                                         action:@selector(cancelPressed)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Next"
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self
                                                                            action:@selector(showShareSheet)];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.toolbar.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width,240);
        self.tableViewShare.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 240);
    }];
}
-(void)showShareSheet{
    self.showingShareViewInLandscapeMode = YES;
    self.navigationItem.rightBarButtonItem = nil;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelShareSheet)];
    self.toolbar.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width,240);
    self.tableViewShare.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 240);
    
    [UIView animateWithDuration:0.3 animations:^{
        self.toolbar.frame = CGRectMake(0, self.view.frame.size.height-240, self.view.frame.size.width,240);
        self.tableViewShare.frame = CGRectMake(0, self.view.frame.size.height-230, self.view.frame.size.width, 240);
    }];
    
}
-(void)saveImages:(NSArray*)object{
    [self getAllImagesForSelectedRows:^(NSArray *images) {
        for (UIImage *image in images) {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        }
        [self cancelPressed];
    }];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([collectionView isEqual:self.collectionView]) {
        [collectionView deselectItemAtIndexPath:indexPath animated:NO];
        if ([self.selectedRows containsObject:indexPath]) {
            [self.selectedRows removeObject:indexPath];
        }else{
            [self.selectedRows addObject:indexPath];
        }
        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
        
        [self.collectionView.delegate scrollViewDidScroll:self.collectionView];
        [UIView animateWithDuration:0.35 animations:^{
            [self.collectionView scrollToItemAtIndexPath:indexPath
                            atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                    animated:NO];
        } completion:^(BOOL finished) {
            [self.collectionView.delegate scrollViewDidScroll:self.collectionView];
        }];
        
        [self updateCollectionView];
        [self updateTitle];
    }else{
        MHShareItem *item = self.shareDataSource[collectionView.tag][indexPath.row];
        
        SEL selector = NSSelectorFromString(item.selectorName);
        
        SuppressPerformSelectorLeakWarning(
                                           [item.onViewController performSelector:selector
                                                                       withObject:self.selectedRows];
                                           );
        
        
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
