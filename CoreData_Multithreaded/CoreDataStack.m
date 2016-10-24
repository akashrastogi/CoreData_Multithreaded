//
//  CoreDataStack.m
//  CoreData_Multithreaded
//
//  Created by HealthOne on 24/10/16.
//  Copyright © 2016 akash. All rights reserved.
//

#import "CoreDataStack.h"

@interface CoreDataStack ()
@property (readwrite, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readwrite, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readwrite, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readwrite, strong, nonatomic) NSManagedObjectContext *writerManagedObjectContext;
@end

@implementation CoreDataStack

+(instancetype)defaultStack
{
    static CoreDataStack *coreDataStack = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      coreDataStack = [[CoreDataStack alloc]init];
                  });
    return coreDataStack;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel)
    {
        return _managedObjectModel;
    }
    NSURL *modeurl = [[NSBundle mainBundle]URLForResource:@"CoreData_Multithreaded" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc]initWithContentsOfURL:modeurl];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator)
    {
        return _persistentStoreCoordinator;
    }
    NSURL *storeUrl = [[self  applicationDocumentsDirectory]URLByAppendingPathComponent:@"CoreData_Multithreaded.sqlite"];
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:[self managedObjectModel]];
    NSDictionary *dictOptions = @{
                                  NSMigratePersistentStoresAutomaticallyOption : @(YES),
                                  NSInferMappingModelAutomaticallyOption : @(YES)
                                  };
    NSError *error;
    NSPersistentStore *store = [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:dictOptions error:&error];
    if (!store)
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext)
    {
        return _managedObjectContext;
    }
    
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setParentContext:[self writerManagedObjectContext]];
    return _managedObjectContext;
}

// writer MOC is allocated with NSPrivateQueueConcurrency type and it's persistent store coordinator is set.
- (NSManagedObjectContext *)writerManagedObjectContext
{
    if (_writerManagedObjectContext)
    {
        return _writerManagedObjectContext;
    }
    
    _writerManagedObjectContext = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_writerManagedObjectContext setPersistentStoreCoordinator:[self persistentStoreCoordinator]];
    return _writerManagedObjectContext;
}

#pragma mark - Core Data Saving support
- (void)saveContext
{
    __block NSError *error = nil;
    [[self managedObjectContext]performBlock:^
     {
         if ([[self managedObjectContext]hasChanges] && ![[self managedObjectContext]save:&error])
         {
             [[self writerManagedObjectContext]performBlock:^
              {
                  if ([[self writerManagedObjectContext]hasChanges] && [[self writerManagedObjectContext]save:&error])
                  {
                      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                      abort();
                  }
              }];
         }
     }];
}

#pragma mark - Helper methods
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
