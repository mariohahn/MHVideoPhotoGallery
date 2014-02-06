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




How to use
--------------------

//MHGallery needs the ImageView from which you want to present the Gallery

 [MHGallerySharedManager sharedManager].ivForPresentingAndDismissingMHGallery = [(MHGalleryOverViewCell*)[tableView cellForRowAtIndexPath:indexPath] iv];
        
 NSArray *galleryData = self.galleryDataSource;
    
    
 [self presentMHGalleryWithItems:galleryData
                        forIndex:indexPath.row
                  finishCallback:^(UINavigationController *galleryNavMH, NSInteger pageIndex, UIImage *image) {

			     //set the new ImageView for Dismiss MHGallery 

                             [MHGallerySharedManager sharedManager].ivForPresentingAndDismissingMHGallery = iv;
                             
                             [galleryNavMH dismissViewControllerAnimated:YES completion:nil];
                         });
                         
                     } animated:YES];


