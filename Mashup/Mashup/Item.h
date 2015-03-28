//
//  Item.h
//  Mashup
//
//  Created by Saalis Umer on 28/03/15.
//  Copyright (c) 2015 Saalis Umer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import <CoreLocation/CoreLocation.h>

@interface Item : NSObject
@property (nonatomic, strong) User * user;
@property (nonatomic, strong) NSData * imageData;
@property (nonatomic, strong) CLLocation * location;
@end
