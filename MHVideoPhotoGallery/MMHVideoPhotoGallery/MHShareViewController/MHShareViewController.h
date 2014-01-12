//
//  MHShareViewController.h
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 10.01.14.
//  Copyright (c) 2014 Mario Hahn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>

@interface MHShareViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate,UIAlertViewDelegate,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate>
@property(nonatomic,strong) UICollectionView *cv;
@property(nonatomic,strong) UITableView *tableViewShare;
@property(nonatomic,strong) UIView *gradientView;
@property(nonatomic) NSInteger pageIndex;

@end
