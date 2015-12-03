//
//  MHGalleryItem.m
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 01.04.14.
//  Copyright (c) 2014 Mario Hahn. All rights reserved.
//

#import "MHGalleryItem.h"

@implementation MHGalleryItem

- (instancetype)initWithImage:(UIImage*)image{
    self = [super init];
    if (!self)
        return nil;
    self.galleryType = MHGalleryTypeImage;
    self.image = image;
    return self;
}

+ (instancetype)itemWithVimeoVideoID:(NSString*)ID{
    return [self.class.alloc initWithURL:[NSString stringWithFormat:MHVimeoBaseURL,ID]
                             galleryType:MHGalleryTypeVideo];
}

+ (instancetype)itemWithYoutubeVideoID:(NSString*)ID{
    return [self.class.alloc initWithURL:[NSString stringWithFormat:MHYoutubeBaseURL,ID]
                             galleryType:MHGalleryTypeVideo];
}

+(instancetype)itemWithURL:(NSString *)URLString
               galleryType:(MHGalleryType)galleryType{
    
    return [self.class.alloc initWithURL:URLString
                             galleryType:galleryType];
}

- (instancetype)initWithURL:(NSString*)URLString
                galleryType:(MHGalleryType)galleryType{
    self = [super init];
    if (!self)
        return nil;
    self.URLString = URLString;
    self.thumbnailURL = URLString;
    self.titleString = nil;
    self.attributedTitle = nil;
    self.descriptionString = nil;
    self.galleryType = galleryType;
    self.attributedString = nil;
    return self;
}
+(instancetype)itemWithURL:(NSString *)URLString
              thumbnailURL:(NSString*)thumbnailURL{
    
    return [self.class.alloc initWithURL:URLString
                            thumbnailURL:thumbnailURL];
}


- (instancetype)initWithURL:(NSString*)URLString
               thumbnailURL:(NSString*)thumbnailURL{
    self = [super init];
    if (!self)
        return nil;
    self.URLString = URLString;
    self.thumbnailURL = thumbnailURL;
    self.attributedTitle = nil;
    self.descriptionString = nil;
    self.descriptionString = nil;
    self.galleryType = MHGalleryTypeImage;
    self.attributedString = nil;
    return self;
}


+(instancetype)itemWithImage:(UIImage *)image{
    return [self.class.alloc initWithImage:image];
}

@end

