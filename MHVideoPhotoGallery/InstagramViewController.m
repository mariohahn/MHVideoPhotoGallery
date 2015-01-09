//
//  InstagramViewController.m
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 18.04.14.
//  Copyright (c) 2014 Mario Hahn. All rights reserved.
//

#import "InstagramViewController.h"

@interface InstagramViewController ()

@end

@implementation InstagramViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Instagram";
    
    NSString *username; //Enter your Username
    NSString *pwd; //Enter your PWD
    NSString *access_token; //Enter your access_token
    
    self.navigationItem.rightBarButtonItem = nil;
    
    NSMutableURLRequest *request = [NSMutableURLRequest.alloc initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.instagram.com/v1/users/self/feed?access_token=%@",access_token]]];
    
    NSData *authData = [[NSString stringWithFormat:@"%@:%@",username,pwd] dataUsingEncoding:NSASCIIStringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:NSDataBase64Encoding76CharacterLineLength]];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    
    __weak typeof(self) weakSelf = self;
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:NSOperationQueue.new
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               
                               
                               NSDictionary *dict =[NSJSONSerialization JSONObjectWithData:data
                                                                                   options:NSJSONReadingAllowFragments
                                                                                     error:nil];
                               
                               NSMutableArray *galleryItems = NSMutableArray.new;
                               for (NSDictionary *dictionary in dict[@"data"]) {
                                   MHGalleryItem *item;
                                   if (dictionary[@"videos"]) {
                                       item = [MHGalleryItem itemWithURL:dictionary[@"videos"][@"standard_resolution"][@"url"]
                                                             galleryType:MHGalleryTypeVideo];
                                       
                                   }else{
                                       item = [MHGalleryItem itemWithURL:dictionary[@"images"][@"standard_resolution"][@"url"]
                                                             galleryType:MHGalleryTypeImage];
                                       
                                   }
                                   
                                   if(![dictionary[@"caption"] isKindOfClass:NSNull.class]){
                                       item.descriptionString = dictionary[@"caption"][@"text"];
                                       
                                   }
                                   
                                   
                                   [galleryItems addObject:item];
                               }
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   weakSelf.galleryItems = galleryItems;
                                   [weakSelf.collectionView reloadData];
                               });
                           }];
    
    self.collectionView.contentInset = UIEdgeInsetsMake(64, 0, 50, 0);
}

-(MHGalleryItem*)itemForIndex:(NSInteger)index{
    return self.galleryItems[index];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.galleryItems.count;
}

-(void)pushToImageViewerForIndexPath:(NSIndexPath *)indexPath{
    __weak typeof(self) weakSelf = self;
    
    MHGalleryController *gallery = [MHGalleryController galleryWithPresentationStyle:MHGalleryViewModeImageViewerNavigationBarShown];
    gallery.galleryItems = self.galleryItems;
    gallery.presentingFromImageView = [(MHMediaPreviewCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:indexPath] thumbnail];
    gallery.presentationIndex = indexPath.row;
    gallery.UICustomization.showOverView = NO;
    
    __weak MHGalleryController *blockGallery = gallery;
    
    gallery.finishedCallback = ^(NSInteger currentIndex,UIImage *image,MHTransitionDismissMHGallery *interactiveTransition,MHGalleryViewMode viewMode){
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:currentIndex inSection:0];
        CGRect cellFrame  = [[weakSelf.collectionView collectionViewLayout] layoutAttributesForItemAtIndexPath:newIndexPath].frame;
        
        [weakSelf.collectionView scrollRectToVisible:cellFrame
                                            animated:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.collectionView reloadItemsAtIndexPaths:@[newIndexPath]];
            
            MHMediaPreviewCollectionViewCell *cell = (MHMediaPreviewCollectionViewCell*)[weakSelf.collectionView cellForItemAtIndexPath:newIndexPath];
            
            [blockGallery dismissViewControllerAnimated:YES dismissImageView:cell.thumbnail completion:^{
                
                [self setNeedsStatusBarAppearanceUpdate];
                
                MPMoviePlayerController *player = interactiveTransition.moviePlayer;
                
                player.controlStyle = MPMovieControlStyleEmbedded;
                player.view.frame = cell.bounds;
                player.scalingMode = MPMovieScalingModeAspectFill;
                [cell.contentView addSubview:player.view];
            }];
        });
    };
    [self presentMHGalleryController:gallery animated:YES completion:nil];
    
}

-(UICollectionViewFlowLayout *)layoutForOrientation:(UIInterfaceOrientation)orientation{
    
    CGSize screenSize = UIScreen.mainScreen.bounds.size;
    
    UICollectionViewFlowLayout *flowLayoutPort = UICollectionViewFlowLayout.new;
    flowLayoutPort.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayoutPort.sectionInset = UIEdgeInsetsMake(4, 0, 0, 0);
    flowLayoutPort.minimumInteritemSpacing = 4;
    flowLayoutPort.minimumLineSpacing = 4;
    flowLayoutPort.itemSize = CGSizeMake(screenSize.width/3.1, screenSize.width/3.1);
    return flowLayoutPort;
}


@end
