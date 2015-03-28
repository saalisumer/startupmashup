//
//  ImageUploaderViewController.m
//  Mashup
//
//  Created by Saalis Umer on 28/03/15.
//  Copyright (c) 2015 Saalis Umer. All rights reserved.
//

#import "ImageUploaderViewController.h"
#import "Item.h"
#import "ApplicationModel.h"
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
#import <ImageIO/CGImageSource.h>
#import <ImageIO/CGImageDestination.h>
#import <ImageIO/CGImageProperties.h>

@interface ImageUploaderViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate>
{
    UIImagePickerController * mPickerView;
    CLLocationManager *locationManager;
    Item * mItem;
}

@end

@implementation ImageUploaderViewController

- (void)viewDidLoad {
    mItem = [[Item alloc]init];
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        [locationManager requestWhenInUseAuthorization];
    
    [locationManager startUpdatingLocation];    self.scrollView.minimumZoomScale=1;
    
    self.scrollView.maximumZoomScale=6.0;
    
//    self.scrollView.contentSize=CGSizeMake(1280, 960);
    self.scrollView.contentSize = self.scrollView.bounds.size;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapShare:(id)sender
{
    if (self.imageView.image == nil) {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Can't proceed" message:@"Capture an image first" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    else
    {
        mItem.user = [[ApplicationModel instance] user];
        CGDataProviderRef provider = CGImageGetDataProvider([self imageWithView:self.scrollView].CGImage);
        NSData* data = (id)CFBridgingRelease(CGDataProviderCopyData(provider));
        mItem.imageData = data;
        [[ApplicationModel instance] shareItem:mItem];
    }
}

- (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

- (IBAction)didTapCaptureImage:(id)sender
{
    mPickerView = [[UIImagePickerController alloc]init ];
    mPickerView.delegate = self;
    mPickerView.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:mPickerView animated:YES completion:^{
        
    }];
}

- (IBAction)didTapTagLocation:(id)sender
{
    [locationManager startUpdatingLocation];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    self.imageView.image = image;
    [mPickerView dismissViewControllerAnimated:YES completion:nil];
}

//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
//{
//    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//    [library assetForURL:[info objectForKey:UIImagePickerControllerReferenceURL]
//             resultBlock:^(ALAsset *asset) {
//                 
//                 ALAssetRepresentation *image_representation = [asset defaultRepresentation];
//                 
//                 // create a buffer to hold image data
//                 uint8_t *buffer = (Byte*)malloc(image_representation.size);
//                 NSUInteger length = [image_representation getBytes:buffer fromOffset: 0.0  length:image_representation.size error:nil];
//                 
//                 if (length != 0)  {
//                     
//                     // buffer -> NSData object; free buffer afterwards
//                     NSData *adata = [[NSData alloc] initWithBytesNoCopy:buffer length:image_representation.size freeWhenDone:YES];
//                     
//                     // identify image type (jpeg, png, RAW file, ...) using UTI hint
//                     NSDictionary* sourceOptionsDict = [NSDictionary dictionaryWithObjectsAndKeys:(id)[image_representation UTI] ,kCGImageSourceTypeIdentifierHint,nil];
//                     
//                     // create CGImageSource with NSData
//                     CGImageSourceRef sourceRef = CGImageSourceCreateWithData((__bridge CFDataRef) adata,  (__bridge CFDictionaryRef) sourceOptionsDict);
//                     
//                     // get imagePropertiesDictionary
//                     CFDictionaryRef imagePropertiesDictionary;
//                     imagePropertiesDictionary = CGImageSourceCopyPropertiesAtIndex(sourceRef,0, NULL);
//                     
//                     // get exif data
//                     CFDictionaryRef exif = (CFDictionaryRef)CFDictionaryGetValue(imagePropertiesDictionary, kCGImagePropertyExifDictionary);
//                     NSDictionary *exif_dict = (__bridge NSDictionary*)exif;
//                     NSLog(@"exif_dict: %@",exif_dict);
//                     
//                     // save image WITH meta data
//                     NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//                     NSURL *fileURL = nil;
//                     CGImageRef imageRef = CGImageSourceCreateImageAtIndex(sourceRef, 0, imagePropertiesDictionary);
//                     self.imageView.image = [UIImage imageWithCGImage:imageRef];
//                     if (![[sourceOptionsDict objectForKey:@"kCGImageSourceTypeIdentifierHint"] isEqualToString:@"public.tiff"])
//                     {
//                         fileURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@.%@",
//                                                           documentsDirectory,
//                                                           @"myimage",
//                                                           [[[sourceOptionsDict objectForKey:@"kCGImageSourceTypeIdentifierHint"] componentsSeparatedByString:@"."] objectAtIndex:1]
//                                                           ]];
//                         
//                         CGImageDestinationRef dr = CGImageDestinationCreateWithURL ((__bridge CFURLRef)fileURL,
//                                                                                     (__bridge CFStringRef)[sourceOptionsDict objectForKey:@"kCGImageSourceTypeIdentifierHint"],
//                                                                                     1,
//                                                                                     NULL
//                                                                                     );
//                         CGImageDestinationAddImage(dr, imageRef, imagePropertiesDictionary);
//                         CGImageDestinationFinalize(dr);
//                         CFRelease(dr);
//                     }
//                     else
//                     {
//                         NSLog(@"no valid kCGImageSourceTypeIdentifierHint found …");
//                     }
//                     
//                     // clean up
//                     CFRelease(imageRef);
//                     CFRelease(imagePropertiesDictionary);
//                     CFRelease(sourceRef);
//                 }
//                 else {
//                     NSLog(@"image_representation buffer length == 0");
//                 }
//             }
//            failureBlock:^(NSError *error) {
//                NSLog(@"couldn't get asset: %@", error);
//            }
//     ];
//    
//    [mPickerView dismissViewControllerAnimated:YES completion:nil];
//}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [mPickerView dismissViewControllerAnimated:YES completion:nil];
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView

{
    return self.imageView;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    mItem.location = [locations lastObject];
    self.latitude.text = mItem.location.description;
    
}
@end
