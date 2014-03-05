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

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)


@interface MHShareCell : UICollectionViewCell
@property (strong, nonatomic) UIImageView *thumbnailImageView;
@property (strong, nonatomic) UILabel *descriptionLabel;
@end

@interface MHShareViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate,UIAlertViewDelegate,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate>

@property(nonatomic,strong) UICollectionView *collectionView;
@property(nonatomic,strong) UITableView *tableViewShare;
@property(nonatomic,strong) UIView *gradientView;
@property(nonatomic,strong) UIToolbar *toolbar;
@property(nonatomic)        NSInteger pageIndex;
@property(nonatomic,strong) NSArray *galleryItems;


@end
