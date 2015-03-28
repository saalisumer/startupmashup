


#import <Foundation/Foundation.h>

#define kMinimumPasswordLength 8

@interface Validation : NSObject

+(BOOL) validateNotEmpty: (NSString *) candidate;
+(BOOL) validateEmail: (NSString *) candidate;
+(BOOL) validatePhone: (NSString *) candidate;
+(BOOL) validateMinimumLength: (NSString *) candidate parameter: (int) length;
+(BOOL) validateMatchesConfirmation: (NSString *) candidate parameter: (NSString *) confirmation;

@end
