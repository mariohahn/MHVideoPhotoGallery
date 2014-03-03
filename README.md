<p align="center" >
  <img src="https://dl.dropboxusercontent.com/u/17911939/galleryIcon.png" alt="MHGallery" title="MHGallery">
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

UIImageView *imageView = [(MHGalleryOverViewCell*)[tableView cellForRowAtIndexPath:indexPath] thumbnail];
        
NSArray *galleryData = self.galleryDataSource;
    
[self presentMHGalleryWithItems:galleryData
                       forIndex:indexPath.row
                  fromImageView:imageView
                 finishCallback:^(UINavigationController *galleryNavMH, NSInteger pageIndex, UIImage *image,MHTransitionDismissMHGallery *interactiveTransition) {
                         
                         NSIndexPath *newIndex = [NSIndexPath indexPathForRow:pageIndex inSection:0];
                         
                         [self.tableView scrollToRowAtIndexPath:newIndex atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
                         
                         dispatch_async(dispatch_get_main_queue(), ^{
                             UIImageView *imageView = [(MHGalleryOverViewCell*)[self.tableView cellForRowAtIndexPath:newIndex] thumbnail];
                             [galleryNavMH dismissViewControllerAnimated:YES dismissImageView:imageView completion:nil];
                         });
                         
                     } customAnimationFromImage:YES];
```

	

