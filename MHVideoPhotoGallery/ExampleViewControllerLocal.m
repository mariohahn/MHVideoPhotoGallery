//
//  ExampleViewControllerLocal.m
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 28.01.14.
//  Copyright (c) 2014 Mario Hahn. All rights reserved.
//

#import "ExampleViewControllerLocal.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "MHVideoImageGalleryGlobal.h"
#import "ExampleViewControllerTableView.h"


@implementation MHGallerySectionItem


- (id)initWithSectionName:(NSString*)sectionName
                    items:(NSArray*)galleryItems{
    self = [super init];
    if (!self)
        return nil;
    self.sectionName = sectionName;
    self.galleryItems = galleryItems;
    return self;
}
@end


@interface ExampleViewControllerLocal ()
@property (nonatomic,strong)NSMutableArray *allData;
@property(nonatomic,strong) UIImageView *imageViewForPresentingMHGallery;
@property(nonatomic,strong) AnimatorShowDetailForDismissMHGallery *interactive;
@end

@implementation ExampleViewControllerLocal

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.allData = [NSMutableArray new];
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        [group setAssetsFilter:[ALAssetsFilter allAssets]];
        NSMutableArray *items = [NSMutableArray new];
        [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
            if (alAsset) {
                MHGalleryItem *item = [[MHGalleryItem alloc]initWithURL:[alAsset.defaultRepresentation.url absoluteString]
                                                            galleryType:MHGalleryTypeImage];
                [items addObject:item];
            }
        }];
        if(group){
            MHGallerySectionItem *section = [[MHGallerySectionItem alloc]initWithSectionName:[group valueForProperty:ALAssetsGroupPropertyName]
                                                                                       items:items];
            [self.allData addObject:section];
        }
        if (!group) {
            
            NSLog(@"%@",self.allData);
            
            [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
        
    } failureBlock: ^(NSError *error) {
        
    }];

}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = nil;
    cellIdentifier = @"ImageTableViewCell";
    
    ImageTableViewCell *cell = (ImageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell){
        cell = [[ImageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    MHGallerySectionItem *section = self.allData[indexPath.row];
    
    MHGalleryItem *item = [section.galleryItems firstObject];
    
    [[MHGallerySharedManager sharedManager] getImageFromAssetLibrary:item.urlString
                                                           assetType:MHAssetImageTypeThumb
                                                        successBlock:^(UIImage *image, NSError *error) {
        cell.iv.image = image;
    }];
    
    cell.labelText.text = section.sectionName;
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.allData.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.imageViewForPresentingMHGallery = [(ImageTableViewCell*)[tableView cellForRowAtIndexPath:indexPath] iv];
    MHGallerySectionItem *section = self.allData[indexPath.row];

    NSArray *galleryData = section.galleryItems;
    
    [[MHGallerySharedManager sharedManager] presentMHGalleryWithItems:galleryData
                                                             forIndex:indexPath.row
                                             andCurrentViewController:self
                                                       finishCallback:^(UINavigationController *galleryNavMH,NSInteger pageIndex,AnimatorShowDetailForDismissMHGallery *interactiveTransition,UIImage *image) {
                                                           self.interactive = interactiveTransition;
                                                           [self dismissGalleryForIndexPath:[NSIndexPath indexPathForRow:pageIndex inSection:0]
                                                                              navController:galleryNavMH];
                                                           
                                                       }
                                             withImageViewTransiation:NO];
    
    
}
-(void)dismissGalleryForIndexPath:(NSIndexPath*)indexPath navController:(UINavigationController*)nav{
    [nav dismissViewControllerAnimated:YES completion:nil];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
