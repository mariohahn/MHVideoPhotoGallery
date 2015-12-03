
#import "MHGallery.h"
#import "MHOverviewController.h"
#import <objc/runtime.h>

NSString * const MHYoutubeBaseURL          = @"http://www.youtube.com/watch?v=%@";
NSString * const MHYoutubeChannel          = @"https://gdata.youtube.com/feeds/api/users/%@/uploads?&max-results=50&alt=json";
NSString * const MHYoutubePlayBaseURL      = @"https://www.youtube.com/get_video_info?video_id=%@&el=embedded&ps=default&eurl=&gl=US&hl=%@";
NSString * const MHYoutubeInfoBaseURL      = @"http://gdata.youtube.com/feeds/api/videos/%@?v=2&alt=jsonc";
NSString * const MHVimeoThumbBaseURL       = @"http://vimeo.com/api/v2/video/%@.json";
NSString * const MHVimeoVideoBaseURL       = @"http://player.vimeo.com/video/%@/config";
NSString * const MHVimeoBaseURL            = @"http://vimeo.com/%@";
NSString * const MHGalleryViewModeShare    = @"MHGalleryViewModeShare";
NSString * const MHAssetLibrary            = @"assets-library";
NSString * const MHGalleryDurationData     = @"MHGalleryData";

NSDictionary *MHDictionaryForQueryString(NSString *string){
	NSMutableDictionary *dictionary = NSMutableDictionary.new;
	NSArray *allFieldsArray = [string componentsSeparatedByString:@"&"];
	for (NSString *fieldString in allFieldsArray){
		NSArray *pairArray = [fieldString componentsSeparatedByString:@"="];
		if (pairArray.count == 2){
			NSString *key = pairArray[0];
			NSString *value = [pairArray[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			value = [value stringByReplacingOccurrencesOfString:@"+" withString:@" "];
			dictionary[key] = value;
		}
	}
	return dictionary;
}

NSNumberFormatter *MHNumberFormatterVideo(void){
    static NSNumberFormatter *numberFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        numberFormatter = NSNumberFormatter.new;
        numberFormatter.minimumIntegerDigits =2;
    });
    return numberFormatter;
}

NSBundle *MHGalleryBundle(void) {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString* path = [NSBundle.mainBundle pathForResource:kMHGalleryBundleName ofType:kMHGalleryBundleExtension];
        if (!path) {
            // in case of using Swift and embedded frameworks, resources included not in main bundle,
            // but in framework bundle
            path = [[NSBundle bundleForClass:[MHGalleryController class]] pathForResource:kMHGalleryBundleName ofType:kMHGalleryBundleExtension];
        }
        bundle = [NSBundle bundleWithPath:path];
    });
    return bundle;
}

UIImage *MHDefaultImageForFrame(CGRect frame){
    UIView *view = [UIView.alloc initWithFrame:frame];
    view.backgroundColor = UIColor.whiteColor;
    return  MHImageFromView(view);
}

UIView *MHStatusBar(void){
    NSString *key = [NSString.alloc initWithData:[NSData dataWithBytes:(unsigned char []){0x73, 0x74, 0x61, 0x74, 0x75, 0x73, 0x42, 0x61, 0x72} length:9] encoding:NSASCIIStringEncoding];
    id object = UIApplication.sharedApplication;
    UIView *statusBar;
    if ([object respondsToSelector:NSSelectorFromString(key)]) {
        statusBar = [object valueForKey:key];
    }
    return statusBar;
}

BOOL MHShouldShowStatusBar(void){
    UIInterfaceOrientation currentOrientation = UIApplication.sharedApplication.statusBarOrientation;
    BOOL isLandscape = UIInterfaceOrientationIsLandscape(currentOrientation);
    BOOL isPhone = UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone;
    if (MHGalleryOSVersion >= 8.0 && isLandscape && isPhone) {
        return NO;
    }
    return YES;
}

UIImage *MHTemplateImage(NSString *imageName){
    return [MHGalleryImage(imageName) imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}


static NSString* (^ CustomLocalizationBlock)(NSString *localization) = nil;
static UIImage* (^ CustomImageBlock)(NSString *imageToChangeName) = nil;

void MHGalleryCustomImageBlock(UIImage *(^customImageBlock)(NSString *imageToChangeName)){
    CustomImageBlock = customImageBlock;
}
void MHGalleryCustomLocalizationBlock(NSString *(^customLocalizationBlock)(NSString *stringToLocalize)){
    CustomLocalizationBlock = customLocalizationBlock;
}

UIImage *MHImageFromView(UIView *view) {
    CGFloat scale = 1.0;
    if([UIScreen.mainScreen respondsToSelector:@selector(scale)]) {
        CGFloat tmp = UIScreen.mainScreen.scale;
        if (tmp > 1.5) {
            scale = 2.0;
        }
    }
    if(scale > 1.5) {
        UIGraphicsBeginImageContextWithOptions([view bounds].size, NO, scale);
    } else {
        UIGraphicsBeginImageContext([view bounds].size);
    }
    [[view layer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}

NSString *MHGalleryLocalizedString(NSString *localizeString) {
    if (CustomLocalizationBlock) {
        NSString *string = CustomLocalizationBlock(localizeString);
        if (string) {
            return string;
        }
    }
    return  NSLocalizedStringFromTableInBundle(localizeString, @"MHGallery", MHGalleryBundle(), @"");
}


UIImage *MHGalleryImage(NSString *imageName){
    if (CustomImageBlock) {
        UIImage *changedImage = CustomImageBlock(imageName);
        if (changedImage) {
            return changedImage;
        }
    }
    if (MHGalleryOSVersion >= 8.0) {
        return [UIImage imageNamed:imageName inBundle:[NSBundle bundleForClass:[MHGalleryController class]] compatibleWithTraitCollection:nil];
    }
    return [UIImage imageNamed:imageName];
}


