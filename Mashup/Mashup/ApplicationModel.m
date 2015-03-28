

#import "ApplicationModel.h"
#import "AppDelegate.h"
#import "Parse/PFObject.h"
#import "Parse/PFGeoPoint.h"
#import "Parse/PFFile.h"

@implementation ApplicationModel
@synthesize user = _user;

static ApplicationModel *singletonInstance = nil;

+ (ApplicationModel *) instance {
	@synchronized(self) {
		if(!singletonInstance) {
			singletonInstance = [[ApplicationModel alloc] init];
            }
	}
    
	return singletonInstance;
}

- (void)shareItem:(Item*)item
{
    PFObject *testObject = [PFObject objectWithClassName:@"Item"];
    if (item.user.userName!=nil)
    testObject[@"userName"] = item.user.userName;
    if (item.user.emailAddress!=nil)
    testObject[@"emailAddress"] = item.user.emailAddress;
    if (item.user.phoneNumber!=nil)
    testObject[@"phoneNumber"] = item.user.phoneNumber;
    if (item.imageData!=nil)
    testObject[@"imageData"] =  [PFFile fileWithData:item.imageData];//image Data
    if (item.location!=nil)
    testObject[@"location"] = [PFGeoPoint geoPointWithLocation:item.location];
    [testObject saveInBackground];
}
@end
