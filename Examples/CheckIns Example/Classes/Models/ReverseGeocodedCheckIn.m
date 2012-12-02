//
//  ReverseGeocodedCheckIn.m
//  CheckIns Example
//
//  Created by Adam Price on 12/1/12.
//  Copyright (c) 2012 AFNetworking. All rights reserved.
//

#import "ReverseGeocodedCheckIn.h"

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>


@implementation ReverseGeocodedCheckIn

@dynamic postalCode;
@synthesize completionBlock;

- (id)initWithTimestamp:(NSDate *)timestamp inManagedObjectContext:(NSManagedObjectContext *)context
{
	self = [super initWithTimestamp:timestamp inManagedObjectContext:context];
    if (!self) {
        return nil;
    }
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		if (self.latitude && self.longitude)
		{
			CLLocation *location = [[CLLocation alloc] initWithLatitude:[self.latitude doubleValue] longitude:[self.longitude doubleValue]];
			if (CLLocationCoordinate2DIsValid(location.coordinate))
			{
				[self reverseGeocodeLocation:location];
			}
		}
	});

	return self;
}

- (void)reverseGeocodeLocation:(CLLocation *)location
{
	CLGeocoder *geocoder = [[CLGeocoder alloc] init];
	[geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
		if (error)
			self.completionBlock(error);
		else
		{
			MKPlacemark *placemark = [placemarks lastObject];
			self.postalCode = [placemark postalCode];
			self.completionBlock(nil);
		}
	}];
}

@end
