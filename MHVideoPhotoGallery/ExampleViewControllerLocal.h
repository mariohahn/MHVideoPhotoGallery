//
//  ExampleViewControllerLocal.h
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 28.01.14.
//  Copyright (c) 2014 Mario Hahn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MHGallerySectionItem : NSObject
@property (nonatomic, strong) NSString *sectionName;
@property (nonatomic, strong) NSArray *galleryItems;


- (id)initWithSectionName:(NSString*)sectionName
                    items:(NSArray*)galleryItems;

@end


@interface ExampleViewControllerLocal : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) IBOutlet UITableView *tableView;
@end
