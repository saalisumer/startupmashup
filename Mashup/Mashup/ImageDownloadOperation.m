

#import "ImageDownloadOperation.h"
#import "ImageDownloadManager.h"

@interface ImageDownloadOperation() {
    ImageDownloadManager *mImageDownloadManager;
}

- (void)notifyDelegate:(UIImage *)image;
- (void)notifyDelegateForError:(NSError *)error;

@end

@implementation ImageDownloadOperation

@synthesize url = _url; 
@synthesize imageId = _imageId;
@synthesize delegate = _delegate;

#pragma mark - Initialization
- (id)initWithURL:(NSURL *)url imageId:(NSString *)imageId delegate:(id<ImageDownloadManagerDelegate>)delegate{
    self = [self init];
    
    mImageDownloadManager = [ImageDownloadManager instance];
    
    _url = url;
    _imageId = imageId;
    _delegate = delegate;
	
    return self;
}

#pragma mark - Private Methods
- (void)notifyDelegate:(UIImage *)image {
    [self.delegate loadImageForURL:self.url imageId:self.imageId didComplete:image];
}

- (void)notifyDelegateForError:(NSError *)error {
    [self.delegate loadImageForURL:self.url imageId:self.imageId didFailWithError:error];
}

#pragma mark - Main
- (void)main {
    if(self.isCancelled == YES) {
		_delegate = nil;
        return;
    }

    NSError *error = nil;
    
    if(self.url == nil || [self.url.absoluteString isEqualToString:@""] == YES) {
        error = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:EINVAL userInfo:nil];
    } else {
        UIImage *image = [mImageDownloadManager imageForURL:self.url imageId:self.imageId];
        
        if(image == nil) {
            NSData *imageData = [NSData dataWithContentsOfURL:self.url options:NSDataReadingMappedIfSafe error:&error];
            
            if(imageData == nil) {
                if(error == nil) {
                    error = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:ENOENT userInfo:nil];
                }
            } else {
				[mImageDownloadManager saveImageData:imageData forURL:self.url imageId:self.imageId];
                imageData = nil;
				image = [mImageDownloadManager imageForURL:self.url imageId:self.imageId];
            }
        }
        
        if(self.delegate != nil && image != nil &&
           [self.delegate respondsToSelector:@selector(loadImageForURL:imageId:didComplete:)] == YES) {
            [self performSelectorOnMainThread:@selector(notifyDelegate:) withObject:image waitUntilDone:YES];
        }
    }
    
    if(self.delegate != nil && error != nil &&
       [self.delegate respondsToSelector:@selector(loadImageForURL:imageId:didFailWithError:)] == YES) {
        [self performSelectorOnMainThread:@selector(notifyDelegateForError:) withObject:error waitUntilDone:YES];
    }
	
	_delegate = nil;
}

@end