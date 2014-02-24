<p align="center" >
  <img src="https://dl.dropboxusercontent.com/u/17911939/galleryIcon.png" alt="AFNetworking" title="AFNetworking">
</p>
==================

#### Podfile

```ruby
platform :ios, '7.0'
pod 'MHVideoPhotoGallery', '~> 1.4'
```
####Supported Videos
```ruby
Youtube
Vimeo
Weblinks (.mov, .mp4, .mpv)
```
####Dismiss Video (Like Paper App)

![alt tag](https://dl.dropboxusercontent.com/u/17911939/dismissInteractiveVideo.gif)

####Dismiss Image (Like Paper App)

![alt tag](https://dl.dropboxusercontent.com/u/17911939/dismissInteractive.gif)

####Dismiss at the end or start on ScrollDirection (Like Paper App)

![alt tag](https://dl.dropboxusercontent.com/u/17911939/dismissAtTheEnd.gif)

####OverView interactive (dismiss & present)

![alt tag](https://dl.dropboxusercontent.com/u/17911939/interactive.gif)

####Share

![alt tag](https://dl.dropboxusercontent.com/u/17911939/ShareView.gif)

####OverView 

![alt tag](https://dl.dropboxusercontent.com/u/17911939/OverView.gif)


####How to use

```objective-c
 /*MHGallery needs the ImageView from which you want to present the Gallery*/

[MHGallerySharedManager sharedManager].ivForPresentingAndDismissingMHGallery = [(MHGalleryOverViewCell*)[tableView cellForRowAtIndexPath:indexPath] iv];
        
NSArray *galleryData = self.galleryDataSource;
    
[self presentMHGalleryWithItems:galleryData
                       forIndex:indexPath.row
                 finishCallback:^(UINavigationController *galleryNavMH, NSInteger pageIndex, UIImage *image) {
	
			/*set the new ImageView for Dismiss MHGallery*/

                       [MHGallerySharedManager sharedManager].ivForPresentingAndDismissingMHGallery = iv;
                             
                       [galleryNavMH dismissViewControllerAnimated:YES completion:nil];
                	  });
                         
                   } animated:YES];
```

	

