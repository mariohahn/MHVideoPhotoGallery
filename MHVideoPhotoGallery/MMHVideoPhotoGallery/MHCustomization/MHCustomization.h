//
//  MHCustomization.h
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 04.03.14.
//  Copyright (c) 2014 Mario Hahn. All rights reserved.
//

typedef NS_ENUM(NSUInteger, MHGalleryViewMode) {
    MHGalleryViewModeImageViewerNavigationBarHidden =0,
    MHGalleryViewModeImageViewerNavigationBarShown =1,
    MHGalleryViewModeOverView =2
};


typedef NS_ENUM(NSUInteger, MHBackButtonState) {
    MHBackButtonStateWithBackArrow,
    MHBackButtonStateWithoutBackArrow
};

@interface MHTransitionCustomization : NSObject
@property (nonatomic)       BOOL interactiveDismiss;
@property (nonatomic)       BOOL dismissWithScrollGestureOnFirstAndLastImage;
@property (nonatomic)       BOOL fixXValueForDismiss;
@end


@interface MHUICustomization : NSObject

@property (nonatomic)        UIBarStyle barStyle;
@property (nonatomic,strong) UIColor *barTintColor;
@property (nonatomic,strong) UIColor *barButtonsTintColor;

@property (nonatomic)        BOOL showMHShareViewInsteadOfActivityViewController;
@property (nonatomic)        BOOL hideShare;
@property (nonatomic)        BOOL useCustomBackButtonImageOnImageViewer;
@property (nonatomic)        BOOL showOverView;
@property (nonatomic)        MHBackButtonState backButtonState;

@property (nonatomic,strong) UICollectionViewFlowLayout *overViewCollectionViewLayoutLandscape;
@property (nonatomic,strong) UICollectionViewFlowLayout *overViewCollectionViewLayoutPortrait;

-(void)setMHGalleryBackgroundColor:(UIColor*)color forViewMode:(MHGalleryViewMode)viewMode;
-(UIColor*)MHGalleryBackgroundColorForViewMode:(MHGalleryViewMode)viewMode;

@end
