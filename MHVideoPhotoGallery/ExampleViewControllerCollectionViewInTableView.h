//
//  ExampleViewController.h
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 30.09.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHGallery.h"

@interface UINavigationController (autoRotate)
@end


@interface UITabBarController (autoRotate)
@end

@interface TestCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIView *backView;
@end

@interface ExampleViewControllerCollectionViewInTableView : UIViewController<UITableViewDataSource,UITableViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UIViewControllerTransitioningDelegate,MHGalleryDataSource,MHGalleryDelegate>
@property (strong,nonatomic) IBOutlet UITableView *tableView;
@end


