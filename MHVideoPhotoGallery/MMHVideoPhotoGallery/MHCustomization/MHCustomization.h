//
//  MHCustomization.h
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 04.03.14.
//  Copyright (c) 2014 Mario Hahn. All rights reserved.
//

#import "MHGradientView.h"

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
@property (nonatomic)       BOOL interactiveDismiss; //Default YES
@property (nonatomic)       BOOL dismissWithScrollGestureOnFirstAndLastImage;//Default YES
@property (nonatomic)       BOOL fixXValueForDismiss; //Default NO
@end

@interface MHUICustomization : NSObject
@property (nonatomic)        NSDictionary *descriptionLinkAttributes;
@property (nonatomic)        NSDictionary *descriptionActiveLinkAttributes;
@property (nonatomic)        NSAttributedString *descriptionTruncationString;
@property (nonatomic)        UIBarStyle barStyle; //Default UIBarStyleDefault
@property (nonatomic,strong) UIColor *barTintColor; //Default nil
@property (nonatomic,strong) UIColor *barButtonsTintColor; //Default nil
@property (nonatomic,strong) UIColor *videoProgressTintColor; //Default Black
@property (nonatomic)        BOOL showMHShareViewInsteadOfActivityViewController; //Default YES
@property (nonatomic)        BOOL hideShare; //Default NO
@property (nonatomic)        BOOL useCustomBackButtonImageOnImageViewer; //Default YES
@property (nonatomic)        BOOL showOverView; //Default YES
@property (nonatomic)        MHBackButtonState backButtonState; //Default MHBackButtonStateWithBackArrow

@property (nonatomic,strong) UIBarButtonItem *customBarButtonItem; //A optional UIBarButtonItem displayed in the lower right corner. Default nil

@property (nonatomic,strong) UICollectionViewFlowLayout *overViewCollectionViewLayoutLandscape;
@property (nonatomic,strong) UICollectionViewFlowLayout *overViewCollectionViewLayoutPortrait;

-(void)setMHGradients:(NSArray<UIColor*>*)colors forDirection:(MHGradientDirection)direction;
-(NSArray<UIColor*>*)MHGradientColorsForDirection:(MHGradientDirection)direction;

-(void)setMHGalleryBackgroundColor:(UIColor*)color forViewMode:(MHGalleryViewMode)viewMode;
-(UIColor*)MHGalleryBackgroundColorForViewMode:(MHGalleryViewMode)viewMode;

@end
