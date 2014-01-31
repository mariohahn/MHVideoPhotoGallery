//
//  MHGalleryCells.m
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 30.12.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//

#import "MHGalleryCells.h"

@implementation MHGalleryOverViewCell
- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _iv = [[UIImageView alloc] initWithFrame:self.bounds];
        self.iv.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        self.iv.contentMode = UIViewContentModeScaleAspectFill;
        self.iv.clipsToBounds = TRUE;
        [[self contentView] addSubview:self.iv];
        
        _act = [[UIActivityIndicatorView alloc]initWithFrame:self.bounds];
        self.act.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        self.act.color = [UIColor whiteColor];
        [self.act setTag:405];
        [[self contentView] addSubview:self.act];
        
        _playButton = [[UIButton alloc]initWithFrame:self.bounds];
        [self.playButton setImage:[UIImage imageNamed:@"playButton"] forState:UIControlStateNormal];
        self.playButton.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [self.playButton setTag:406];
        [self.playButton setHidden:YES];
        [[self contentView] addSubview:self.playButton];
        
        
        _videoGradient = [[UIView alloc]initWithFrame:CGRectMake(0, self.bounds.size.height-30,  self.bounds.size.width, 30)];
        self.videoGradient.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
        [self.videoGradient setHidden:YES];
       
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.videoGradient.bounds;
        gradient.colors = @[(id)[[UIColor clearColor] CGColor],(id)[[UIColor colorWithWhite:0 alpha:0.5] CGColor], (id)[[UIColor colorWithWhite:0 alpha:1.0] CGColor]];
        [self.videoGradient.layer insertSublayer:gradient atIndex:0];
        [[self contentView] addSubview:self.videoGradient];
        
        _videoDurationLength = [[UILabel alloc]initWithFrame:CGRectMake(0, self.bounds.size.height-25, self.bounds.size.width-5, 30)];
        [self.videoDurationLength setTextAlignment:NSTextAlignmentRight];
        self.videoDurationLength.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
        self.videoDurationLength.backgroundColor = [UIColor clearColor];
        self.videoDurationLength.textColor = [UIColor whiteColor];
        self.videoDurationLength.font = [UIFont systemFontOfSize:14];
        [[self contentView] addSubview:self.videoDurationLength];
        

        _videoIcon = [[UIImageView alloc]initWithFrame:CGRectMake(5,  self.bounds.size.height-20, 15, 20)];
        self.videoIcon.image = [UIImage imageNamed:@"videoIcon"];
        [self.videoIcon setContentMode:UIViewContentModeScaleAspectFit];
        [self.videoIcon setHidden:YES];
        [[self contentView] addSubview:self.videoIcon];
        
        _selectionImageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.bounds.size.width-30,  self.bounds.size.height-30, 22, 22)];
        self.selectionImageView.image = [UIImage imageNamed:@"videoIcon"];
        [self.selectionImageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.selectionImageView setHidden:YES];
        [[self contentView] addSubview:self.selectionImageView];
        
    }
    return self;
}

- (void)saveImage:(id)sender {
    self.saveImage(YES);
}

@end

@implementation MHShareCell

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _iv = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width/2-30, 1, 60, 60)];
        self.iv.contentMode = UIViewContentModeScaleAspectFill;
        self.iv.clipsToBounds = TRUE;
        [[self contentView] addSubview:self.iv];
        
        _labelDescription = [[UILabel alloc]initWithFrame:CGRectMake(0, self.bounds.size.height-40, self.bounds.size.width, 40)];
        self.labelDescription.backgroundColor = [UIColor clearColor];
        self.labelDescription.textColor = [UIColor blackColor];
        self.labelDescription.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13];
        [self.labelDescription setNumberOfLines:2];
        [[self contentView] addSubview:self.labelDescription];
    }
    return self;
}
@end
@implementation MHGalleryCollectionViewCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(0, 25, 0, 25);
    layout.itemSize = CGSizeMake(270, 210);
    layout.minimumLineSpacing = 15;
    layout.minimumInteritemSpacing = 15;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds
                                         collectionViewLayout:layout];
    
    [self.collectionView registerClass:[MHGalleryOverViewCell class] forCellWithReuseIdentifier:@"MHGalleryOverViewCell"];
    
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [[self contentView] addSubview:self.collectionView];
    return self;
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds];
        self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [[self contentView] addSubview:self.collectionView];
    }
    return self;
}
-(void)prepareForReuse{
    
}

@end


