

#import "ImageDownloadManager.h"
#import "ImageDownloadOperation.h"
@interface ImageDownloadManager () {
	NSOperationQueue *downloadQueue;
}

- (NSString *)imagePathForURL:(NSURL *)url imageId:(NSString *)imageId;

@end

@implementation ImageDownloadManager

static ImageDownloadManager *singletonInstance = nil;

- (id)init {
	if(self = [super init]) {
        downloadQueue = [[NSOperationQueue alloc] init];
        downloadQueue.maxConcurrentOperationCount = 2;
	}
    
	return self;
}

+ (ImageDownloadManager *) instance {
	@synchronized(self) {
		if(!singletonInstance) {
			singletonInstance = [[ImageDownloadManager alloc] init];
		}
	}
    
	return singletonInstance;
}

- (UIImage *)imageForURL:(NSURL *)url imageId:(NSString *)imageId {
    UIImage *image;
    NSString* imageName;
    
    //Check for image in cache
    if(url.pathComponents.count > 0) {
        imageName = [url.pathComponents objectAtIndex:url.pathComponents.count - 1];
    }
    
//    if(imageName != nil && [imageName isEqualToString:@""] == NO) {
//        image = (UIImage*)[mApplicationModel.imageCache objectForKey:imageName];
//    }
    
    if(image != nil) {
        return image;
    }
	
    NSString *imagePath = [self imagePathForURL:url imageId:imageId];
    
    if(imagePath != nil
	   && [imagePath isEqualToString:@""] == NO
	   && [[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
        image = [[UIImage alloc] initWithContentsOfFile:imagePath];
    }
    
    return image;
}

- (NSOperationQueuePriority)nextPriorityLowerThan:(NSOperationQueuePriority)priority {
	NSOperationQueuePriority lowerPriority = NSOperationQueuePriorityVeryLow;
	
	switch (priority) {
		case NSOperationQueuePriorityVeryHigh:
			lowerPriority = NSOperationQueuePriorityHigh;
			break;
			
		case NSOperationQueuePriorityHigh:
			lowerPriority = NSOperationQueuePriorityNormal;
			break;
			
		case NSOperationQueuePriorityNormal:
			lowerPriority = NSOperationQueuePriorityLow;
			break;
			
		case NSOperationQueuePriorityLow:
			lowerPriority = NSOperationQueuePriorityVeryLow;
			break;
						
		default:
			break;
	}
	
	return lowerPriority;
}

- (UIImage *)loadImageForURL:(NSURL *)url imageId:(NSString *)imageId delegate:(id<ImageDownloadManagerDelegate>)delegate {
    //Load Image from Disk or Cache
    UIImage *image= [self imageForURL:url imageId:imageId];
	
    //Download image from network
    if(image == nil) {		
		[downloadQueue setSuspended:YES];        
        ImageDownloadOperation *newOperation = [[ImageDownloadOperation alloc] initWithURL:url
                                                                              imageId:imageId
                                                                               delegate:delegate];
        newOperation.queuePriority = NSOperationQueuePriorityVeryHigh;
        [downloadQueue addOperation:newOperation];
		
		NSArray *operations = downloadQueue.operations;
		
		int operationsCount = (int)operations.count;
		ImageDownloadOperation *operation;
		
		NSOperationQueuePriority priority = NSOperationQueuePriorityVeryHigh;
		for(int i = (operationsCount - 1); i >= 0; i--) {
			operation = [operations objectAtIndex:i];
			
			if((operation.isExecuting || operation.isCancelled || operation.isFinished) == NO) {
				[operation setQueuePriority:priority];
				priority = [self nextPriorityLowerThan:priority];
			}
		}
		
		[downloadQueue setSuspended:NO];
    }
    
    return image;
}

- (NSError *)saveImageData:(NSData *)imageData forURL:(NSURL *)url imageId:(NSString*)imageId {
    NSString *imagePath = [self imagePathForURL:url imageId:imageId];
    NSError *error;
    if(imagePath != nil) {
        [imageData writeToFile:imagePath options:NSDataWritingFileProtectionNone error:&error];
        UIImage * image = [UIImage imageWithData:imageData];
        [self saveImageToCacheForURL:url image:image];
     }
    
    return error;
}

- (void)cancelLoadingPendingRequests {
    [downloadQueue cancelAllOperations];
}

#pragma mark - Private Methods
- (NSString *)imagePathForURL:(NSURL *)url imageId:(NSString *)imageId {
    NSString *imageName;
    
    if(url.pathComponents.count > 0) {
        imageName = [url.pathComponents objectAtIndex:url.pathComponents.count - 1];
    }
    
    NSString *imagePath;

    if(imageName != nil && [imageName isEqualToString:@""] == NO) {
        NSString *applicationDocumentDirPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        imagePath = [NSString stringWithFormat:@"%@/%@", applicationDocumentDirPath, imageName];
    }
    
    return imagePath;
}

- (void)saveImageToCacheForURL:(NSURL*)url image:(UIImage*)image {
    NSString *imageName;
    
    if(url.pathComponents.count > 0) {
        imageName = [url.pathComponents objectAtIndex:url.pathComponents.count - 1];
    }
        
//    if(image != nil && imageName != nil && [imageName isEqualToString:@""] == NO) {
//        [mApplicationModel.imageCache setObject:image forKey:imageName];
//    }
}

- (void)pruneImagesFromDocumentsDirectory {
	NSString *extension1 = @"jpg";
	NSString *extension2 = @"png";
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	NSString *documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
	NSArray *imageArray = [fileManager contentsOfDirectoryAtPath:documentsDirectoryPath
														   error:NULL];
	NSEnumerator *enumerator = [imageArray objectEnumerator];
	
	NSString *fileName;
	NSString *filePath;
	
	while ((fileName = [enumerator nextObject])) {
		
		if([fileName.pathExtension isEqualToString:extension1]
		   || [fileName.pathExtension isEqualToString:extension2]) {
			
			filePath = [documentsDirectoryPath stringByAppendingPathComponent:fileName];
			[fileManager removeItemAtPath:filePath error:NULL];
		}
	}
}

- (void)pruneImagesOlderThan:(NSDate *)thresholdDate {
	if(thresholdDate != nil && thresholdDate.timeIntervalSinceNow <= 0) {
		NSString *extension1 = @"jpg";
		NSString *extension2 = @"png";
		
		NSFileManager *fileManager = [NSFileManager defaultManager];
		
		NSString *cacheDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
		NSArray *imageArray = [fileManager contentsOfDirectoryAtPath:cacheDirectoryPath
															   error:NULL];
		NSEnumerator *enumerator = [imageArray objectEnumerator];
		
		NSString *fileName;
		NSString *filePath;
		NSDictionary *fileAttributes;
		NSDate *fileCreationDate;
		
		while ((fileName = [enumerator nextObject])) {
			
			if([fileName.pathExtension isEqualToString:extension1]
			   || [fileName.pathExtension isEqualToString:extension2]) {
				
				filePath = [cacheDirectoryPath stringByAppendingPathComponent:fileName];
				fileAttributes = [fileManager attributesOfItemAtPath:filePath error:NULL];
				
				if(fileAttributes != nil) {
					fileCreationDate = [fileAttributes objectForKey:NSFileCreationDate];
					
					if(fileCreationDate != nil
					   && (fileCreationDate.timeIntervalSince1970 - thresholdDate.timeIntervalSince1970) <= 0) {
						
						[fileManager removeItemAtPath:filePath error:NULL];
					}
				}
			}
		}
	}
}

@end