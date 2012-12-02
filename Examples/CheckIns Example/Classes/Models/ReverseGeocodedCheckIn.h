//
//  ReverseGeocodedCheckIn.h
//  CheckIns Example
//
//  Created by Adam Price on 12/1/12.
//  Copyright (c) 2012 AFNetworking. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CheckIn.h"

typedef void (^ReverseGeocodingCompletionBlock)(NSError *error);

@interface ReverseGeocodedCheckIn : CheckIn

@property (nonatomic, retain) NSString * postalCode;
@property (nonatomic, copy) ReverseGeocodingCompletionBlock completionBlock;

@end
