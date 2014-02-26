//
//  ExampleViewControllerLocal.m
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 28.01.14.
//  Copyright (c) 2014 Mario Hahn. All rights reserved.
//

#import "ExampleViewControllerLocal.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "MHGalleryGlobals.h"
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
@property(nonatomic,strong) MHAnimatorDismissMHGallery *interactive;
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

    MHGallerySectionItem *section = self.allData[indexPath.row];
    NSArray *galleryData = section.galleryItems;
    if (galleryData.count >0) {
                
        [self presentMHGalleryOverViewWithItems:galleryData
                                 finishCallback:^(UINavigationController *galleryNavMH, NSInteger pageIndex, UIImage *image) {
                                     ImageTableViewCell *cell = (ImageTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
                                     [MHGallerySharedManager sharedManager].ivForPresentingAndDismissingMHGallery = cell.iv;
                                     
            [galleryNavMH dismissViewControllerAnimated:YES completion:nil];
        } customAnimationFromImage:NO];
        
    }
}


@end
