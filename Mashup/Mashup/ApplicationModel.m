

#import "ApplicationModel.h"
#import "AppDelegate.h"

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
    
}
@end
