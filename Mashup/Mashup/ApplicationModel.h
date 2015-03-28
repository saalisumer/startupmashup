
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "User.h"
#import "Item.h"

@interface ApplicationModel : NSObject

//ManagedObjectContext
@property (readonly, strong, nonatomic) NSManagedObjectContext	*managedObjectContext;
@property (nonatomic, strong) User * user;

+ (ApplicationModel *) instance;
- (void)shareItem:(Item*)item;
@end
