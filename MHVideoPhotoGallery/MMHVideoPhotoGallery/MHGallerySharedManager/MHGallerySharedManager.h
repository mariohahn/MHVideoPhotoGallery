//
//  MHGallerySharedManager.h
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 01.04.14.
//  Copyright (c) 2014 Mario Hahn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MHGallery.h"


typedef NS_ENUM(NSUInteger, MHAssetImageType) {
    MHAssetImageTypeFull,
    MHAssetImageTypeThumb
};

typedef NS_ENUM(NSUInteger, MHWebPointForThumb) {
    MHWebPointForThumbStart, // Default
    MHWebPointForThumbMiddle, // videoDuration/2
    MHWebPointForThumbEnd //videoDuration
};

typedef NS_ENUM(NSUInteger, MHYoutubeVideoQuality) {
    MHYoutubeVideoQualityHD720, //Default
    MHYoutubeVideoQualityMedium,
    MHYoutubeVideoQualitySmall
};

typedef NS_ENUM(NSUInteger, MHVimeoVideoQuality) {
    MHVimeoVideoQualityHD, //Default
    MHVimeoVideoQualityMobile,
    MHVimeoVideoQualitySD
};

typedef NS_ENUM(NSUInteger, MHVimeoThumbQuality) {
    MHVimeoThumbQualityLarge, //Default
    MHVimeoThumbQualityMedium,
    MHVimeoThumbQualitySmall
};

typedef NS_ENUM(NSUInteger, MHWebThumbQuality) {
    MHWebThumbQualityHD720, //Default
    MHWebThumbQualityMedium,
    MHWebThumbQualitySmall
};

typedef NS_ENUM(NSUInteger, MHYoutubeThumbQuality) {
    MHYoutubeThumbQualityHQ, //Default
    MHYoutubeThumbQualitySQ
};


@interface MHGallerySharedManager : NSObject

/**
 *  default is MHYoutubeThumbQualityHQ
 */
@property (nonatomic,assign) MHYoutubeThumbQuality youtubeThumbQuality;
/**
 *  Default is MHVimeoThumbQualityLarge
 */
@property (nonatomic,assign) MHVimeoThumbQuality vimeoThumbQuality;
/**
 *  default is MHWebThumbQualityHD720
 */
@property (nonatomic,assign) MHWebThumbQuality webThumbQuality;
/**
 *  default is MHWebPointForThumbStart
 */
@property (nonatomic,assign) MHWebPointForThumb webPointForThumb;
/**
 *  default is MHVimeoVideoQualityHD
 */
@property (nonatomic,assign) MHVimeoVideoQuality vimeoVideoQuality;
/**
 *  default is MHYoutubeVideoQualityHD720
 */
@property (nonatomic,assign) MHYoutubeVideoQuality youtubeVideoQuality;

+ (MHGallerySharedManager *)sharedManager;
/**
 *  You can create a Thumbnail from a Video, you can create it from Videos from a Webserver, Youtube and Vimeo
 *
 *  @param urlString    URL as a string
 *  @param duration     the position on whicht the Thumbnail should be created
 *  @param succeedBlock returns the image the duration of the video and an error
 */
-(void)startDownloadingThumbImage:(NSString*)urlString
                     successBlock:(void (^)(UIImage *image,NSUInteger videoDuration,NSError *error))succeedBlock;


-(BOOL)isUIViewControllerBasedStatusBarAppearance;

/**
 *  To get the absolute URL for Vimeo Videos. To change the Quality check vimeoVideoQuality
 *
 *  @param URL          The URL as a String
 *  @param succeedBlock you will get the absolute URL
 */

-(void)getURLForMediaPlayer:(NSString*)URLString
               successBlock:(void (^)(NSURL *URL,NSError *error))succeedBlock;

-(void)getVimeoURLforMediaPlayer:(NSString*)URL
                    successBlock:(void (^)(NSURL *URL,NSError *error))succeedBlock;
/**
 *  To get the absolute URL for Youtube Videos. To change the Quality check youtubeVideoQuality
 *
 *  @param URL          The URL as a String
 *  @param succeedBlock you will get the absolute URL
 */
-(void)getYoutubeURLforMediaPlayer:(NSString*)URL
                      successBlock:(void (^)(NSURL *URL,NSError *error))succeedBlock;

-(void)getImageFromAssetLibrary:(NSString*)urlString
                      assetType:(MHAssetImageType)type
                   successBlock:(void (^)(UIImage *image,NSError *error))succeedBlock;
/**
 *  Returns all MHGalleryObjects for a Youtube channel
 *
 *  @param channelName  set the name of the channel
 *  @param withTitle    if you want the title of the video set it to YES
 *  @param succeedBlock returns the Gallery items
 */
-(void)getMHGalleryObjectsForYoutubeChannel:(NSString*)channelName
                                  withTitle:(BOOL)withTitle
                               successBlock:(void (^)(NSArray *MHGalleryObjects,NSError *error))succeedBlock;

@end