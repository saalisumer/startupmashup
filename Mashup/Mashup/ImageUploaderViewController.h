//
//  ImageUploaderViewController.h
//  Mashup
//
//  Created by Saalis Umer on 28/03/15.
//  Copyright (c) 2015 Saalis Umer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageUploaderViewController : UIViewController<UIScrollViewDelegate>
@property (nonatomic, weak) IBOutlet UIImageView * imageView;
@property (nonatomic, weak) IBOutlet UIScrollView * scrollView;
@property (nonatomic, weak) IBOutlet UILabel * latitude;
@property (nonatomic, weak) IBOutlet UILabel * longitude;
- (IBAction)didTapCaptureImage:(id)sender;
- (IBAction)didTapShare:(id)sender;
- (IBAction)didTapTagLocation:(id)sender;
@end
