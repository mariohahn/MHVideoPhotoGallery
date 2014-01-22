//
//  ExampleViewController.h
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 30.09.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHVideoImageGalleryGlobal.h"

@interface TestCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@end

@interface ExampleViewControllerCollectionViewInTableView : UIViewController<UITableViewDataSource,UITableViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UIViewControllerTransitioningDelegate>
@property (strong,nonatomic) IBOutlet UITableView *tableView;
@end
