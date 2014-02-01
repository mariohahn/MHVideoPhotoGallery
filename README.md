MHVideoPhotoGallery
==================


OverView 
--------------------


![alt tag](https://dl.dropboxusercontent.com/u/17911939/OverView.gif)


OverView interactive (dismiss & present)
--------------------


![alt tag](https://dl.dropboxusercontent.com/u/17911939/interactive.gif)

Dismiss Video
--------------------


![alt tag](https://dl.dropboxusercontent.com/u/17911939/dismissvideoMH.gif)

Dismiss Image
--------------------


![alt tag](https://dl.dropboxusercontent.com/u/17911939/dismissMH.gif)

Share
--------------------


![alt tag](https://dl.dropboxusercontent.com/u/17911939/ShareView.gif)

Play Videos
--------------------


![alt tag](https://dl.dropboxusercontent.com/u/17911939/video.gif)




Setup
--------------------


    self.imageViewForPresentingMHGallery = [(MHGalleryOverViewCell*)[collectionView cellForItemAtIndexPath:indexPath] iv];
    
    NSArray *galleryData = self.galleryDataSource[indexPath.section];
    
    [[MHGallerySharedManager sharedManager] presentMHGalleryWithItems:galleryData
                                                             forIndex:indexPath.row
                                             andCurrentViewController:self
                                                       finishCallback:^(NSInteger pageIndex,AnimatorShowDetailForDismissMHGallery *interactiveTransition) {
                                                           self.interactive = interactiveTransition;
                                                           [self dismissGalleryForIndexPath:[NSIndexPath indexPathForRow:pageIndex inSection:0]
                                                                          andCollectionView:collectionView];
                                                           
                                                       }
                                             withImageViewTransiation:YES];


Presenting 
--------------------


    - (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
         AnimatorShowDetailForPresentingMHGallery *detail = [AnimatorShowDetailForPresentingMHGallery new];
         detail.iv = self.imageViewForPresentingMHGallery;
        return detail;
    }


Dismiss
--------------------


    -(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
         AnimatorShowDetailForDismissMHGallery *detail = [AnimatorShowDetailForDismissMHGallery new];
         detail.iv = self.imageViewForPresentingMHGallery;
         return detail;
    }
    -(id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator{
         if ([animator isKindOfClass:[AnimatorShowDetailForDismissMHGallery class]]) {
             return self.interactive;
         }else {
               return nil;
         }
    }

    -(void)dismissGalleryForIndexPath:(NSIndexPath*)indexPath
                andCollectionView:(UICollectionView*)collectionView{
         CGRect cellFrame  = [[collectionView collectionViewLayout] layoutAttributesForItemAtIndexPath:indexPath].frame;
         [collectionView scrollRectToVisible:cellFrame
                               animated:NO];
    
            dispatch_async(dispatch_get_main_queue(), ^{
              [collectionView reloadItemsAtIndexPaths:@[indexPath]];
             self.imageViewForPresentingMHGallery = [(MHGalleryOverViewCell*)[collectionView cellForItemAtIndexPath:indexPath] iv];
                if (self.interactive) {
                   self.interactive.iv = self.imageViewForPresentingMHGallery;
             }
             [self dismissViewControllerAnimated:YES completion:nil];
    });
    
    }



