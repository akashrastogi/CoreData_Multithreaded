//
//  CoreDataStack.h
//  CoreData_Multithreaded
//
//  Created by HealthOne on 24/10/16.
//  Copyright © 2016 akash. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataStack : NSObject

+(instancetype)defaultStack;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectContext *writerManagedObjectContext;

- (void)saveContext;

@end
