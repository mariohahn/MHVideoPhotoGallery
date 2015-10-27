//
//  ExampleViewControllerTableView.m
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 14.01.14.
//  Copyright (c) 2014 Mario Hahn. All rights reserved.
//

#import "ExampleViewControllerTableView.h"
#import "MHOverviewController.h"
#import "UIImageView+WebCache.h"

@implementation ImageTableViewCell

@end

@interface ExampleViewControllerTableView ()
@property(nonatomic,strong) NSArray *galleryDataSource;
@end

@implementation ExampleViewControllerTableView

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"TableView";
    

    
    MHGalleryItem *tailored = [[MHGalleryItem alloc]initWithURL:@"http://www.tailored-apps.com/wp-content/uploads/2014/01/wien_cropped-350x300.jpg"
                                                       galleryType:MHGalleryTypeImage];
    
    self.galleryDataSource = @[tailored];
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = nil;
    cellIdentifier = @"ImageTableViewCell";
    
    ImageTableViewCell *cell = (ImageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell){
        cell = [[ImageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    MHGalleryItem *item = self.galleryDataSource[indexPath.row];
    if(item.galleryType == MHGalleryTypeImage){
        [cell.iv sd_setImageWithURL:[NSURL URLWithString:item.URLString]];
    }else{
        [[MHGallerySharedManager sharedManager] startDownloadingThumbImage:item.URLString
                                                              successBlock:^(UIImage *image, NSUInteger videoDuration, NSError *error) {
                                                                  cell.iv.image = image;
                                                              }];
    }
    
    cell.labelText.text = item.descriptionString;
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UIImageView *imageView = [(ImageTableViewCell*)[tableView cellForRowAtIndexPath:indexPath] iv];
    
    NSArray *galleryData = self.galleryDataSource;
    
    
    MHGalleryController *gallery = [[MHGalleryController alloc]initWithPresentationStyle:MHGalleryViewModeImageViewerNavigationBarShown];
    gallery.galleryItems = galleryData;
    gallery.presentingFromImageView = imageView;
    gallery.presentationIndex = indexPath.row;
    
    __weak MHGalleryController *blockGallery = gallery;
    
    gallery.finishedCallback = ^(NSInteger currentIndex,UIImage *image,MHTransitionDismissMHGallery *interactiveTransition,MHGalleryViewMode viewMode){
        
        NSIndexPath *newIndex = [NSIndexPath indexPathForRow:currentIndex inSection:0];
        
        [self.tableView scrollToRowAtIndexPath:newIndex atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImageView *imageView = [(ImageTableViewCell*)[self.tableView cellForRowAtIndexPath:newIndex] iv];
            [blockGallery dismissViewControllerAnimated:YES dismissImageView:imageView completion:nil];
        });
        
    };
    
    [self presentMHGalleryController:gallery animated:YES completion:nil];
    
    
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.galleryDataSource.count;
}


@end
