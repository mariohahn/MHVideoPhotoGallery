//
//  ExampleViewControllerLocal.m
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 28.01.14.
//  Copyright (c) 2014 Mario Hahn. All rights reserved.
//

#import "ExampleViewControllerLocal.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "MHGallery.h"
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
@property(nonatomic,strong) MHTransitionDismissMHGallery *interactive;
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
    
    [[MHGallerySharedManager sharedManager] getImageFromAssetLibrary:item.URLString
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

    dispatch_async(dispatch_get_main_queue(), ^{
        MHGallerySectionItem *section = self.allData[indexPath.row];
        NSArray *galleryData = section.galleryItems;
        if (galleryData.count >0) {
            
            MHGalleryController *gallery = [[MHGalleryController alloc]initWithPresentationStyle:MHGalleryViewModeOverView];
            gallery.galleryItems = galleryData;
            gallery.presentationIndex = indexPath.row;
            
            __weak MHGalleryController *blockGallery = gallery;
            
            gallery.finishedCallback = ^(NSInteger currentIndex,UIImage *image,MHTransitionDismissMHGallery *interactiveTransition,MHGalleryViewMode viewMode){
                [blockGallery dismissViewControllerAnimated:YES dismissImageView:nil completion:nil];
            };
            
            [self presentMHGalleryController:gallery animated:YES completion:nil];

        }else{
            UIAlertView *alterView = [[UIAlertView alloc]initWithTitle:@"Hint"
                                                               message:@"You don't have images on your Simulator"
                                                              delegate:nil
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil, nil];
            [alterView show];
        }
    });
}


@end
