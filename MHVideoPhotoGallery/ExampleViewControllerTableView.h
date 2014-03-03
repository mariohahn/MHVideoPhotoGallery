//
//  ExampleViewControllerTableView.h
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 14.01.14.
//  Copyright (c) 2014 Mario Hahn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHGallery.h"


@interface ImageTableViewCell : UITableViewCell
@property(nonatomic,strong) IBOutlet UIImageView  *iv;
@property(nonatomic,strong) IBOutlet UILabel *labelText;
@end

@interface ExampleViewControllerTableView : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong) IBOutlet UITableView *tableView;
@end
