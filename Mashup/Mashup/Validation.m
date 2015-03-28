
#import "Validation.h"

@implementation Validation

+(BOOL) validateNotEmpty: (NSString *) candidate {
    return ([candidate length] == 0) ? NO : YES;
}


+(BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}

+(BOOL) validatePhone: (NSString *) candidate {
    BOOL result = NO;
    if(candidate != nil){
        NSError *error = NULL;
        NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypePhoneNumber
                                                                   error:&error];
        
        NSArray *matches = [detector matchesInString:candidate
                                             options:0
                                               range:NSMakeRange(0, [candidate length])];
        if(matches.count == 1)
        {
            for (NSTextCheckingResult *match in matches)
            {
                if ([match resultType] == NSTextCheckingTypePhoneNumber) {
                    result = YES;
                }
            }
        }
        else{
            result = NO;
        }
    }
    return result;
}

+(BOOL) validateMinimumLength: (NSString *) candidate parameter: (int) length {
    return ([candidate length] >= length) ? YES : NO;
}

+(BOOL) validateMatchesConfirmation: (NSString *) candidate parameter: (NSString *) confirmation {
    return [candidate isEqualToString:confirmation];
}
@end
