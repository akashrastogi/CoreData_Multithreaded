//
//  Person.h
//  CoreData_Multithreaded
//
//  Created by HealthOne on 24/10/16.
//  Copyright © 2016 akash. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Person : NSManagedObject

@property (nullable, nonatomic, retain) NSString *name;
@property (nonatomic) int16_t serialNumber;

@end