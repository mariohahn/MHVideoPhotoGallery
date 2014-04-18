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

@import AssetsLibrary;

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)



@interface MHImageURL : NSObject
@property (nonatomic,strong) NSString *URL;
@property (nonatomic,strong) UIImage *image;
@end

@interface MHDownloadView : UIView
@property (nonatomic,strong) UIToolbar *blurBackgroundToolbar;
@property (nonatomic,strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic,strong) UILabel *downloadDataLabel;
@property (nonatomic,strong) UIButton *cancelDownloadButton;

-(void)attributedStringForDownloadLabelWithDownloadedDataNumber:(NSNumber*)downloaded maxNumber:(NSNumber*)maxNumber;

@property (nonatomic, copy) void (^cancelCallbackDownloadData)(BOOL cancel);

@end

@interface MHShareItem : NSObject
@property (nonatomic,strong) NSString *imageName;
@property (nonatomic,strong) NSString *title;
@property (nonatomic)        NSInteger maxNumberOfItems;
@property (nonatomic,strong) NSString *selectorName;
@property (nonatomic)        id onViewController;

- (id)initWithImageName:(NSString*)imageName
                  title:(NSString*)title
   withMaxNumberOfItems:(NSInteger)maxNumberOfItems
           withSelector:(NSString*)selectorName
       onViewController:(id)onViewController;

@end


@interface MHCollectionViewTableViewCell : UITableViewCell
@property (strong, nonatomic) UICollectionView *collectionView;
@end

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

@property (nonatomic, copy) void (^finishedCallbackDownloadData)(NSArray *images);

@end
