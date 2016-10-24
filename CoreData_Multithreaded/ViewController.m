//
//  ViewController.m
//  CoreData_Multithreaded
//
//  Created by HealthOne on 24/10/16.
//  Copyright © 2016 akash. All rights reserved.
//

#import "ViewController.h"
#import "CoreDataStack.h"
#import "Person.h"

@interface ViewController ()<UITableViewDataSource>
{
    CoreDataStack *coreDataStack;
    NSMutableArray *arrPersons;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    coreDataStack = [CoreDataStack defaultStack];
    arrPersons = [NSMutableArray new];
    
    self.tableView.dataSource = self;
}

- (IBAction)btnStartClicked:(UIButton *)sender
{
    [self writeLogger:@"Start insertion into Temporory MOC"];
    NSDate *pushTemp = [NSDate date];
    NSManagedObjectContext *temporaryContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    temporaryContext.parentContext = [coreDataStack managedObjectContext];
    __block NSError *error;
    
    [temporaryContext performBlock:^
     {
         for (int i=1; i<500000; i++)
         {
             Person *person = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:temporaryContext];
             person.name = [[NSProcessInfo processInfo] globallyUniqueString];
             person.serialNumber = i;
         }
         
         if ([temporaryContext save:&error])
         {
             [self writeLogger:[NSString stringWithFormat:@"Temporory MOC insertion time- %f",[[NSDate date]timeIntervalSinceDate:pushTemp]]];
             NSLog(@"Data written on Temporory MOC");
             
             NSDate *fetchStart = [NSDate date];
             [[coreDataStack managedObjectContext]performBlock:^
              {
                  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
                  [fetchRequest setEntity:[NSEntityDescription entityForName:@"Person" inManagedObjectContext:[coreDataStack managedObjectContext]]];
                  NSArray *array = [[coreDataStack managedObjectContext] executeFetchRequest:fetchRequest error:&error];
                  [self writeLogger:[NSString stringWithFormat:@"Total fetch time- %f",[[NSDate date]timeIntervalSinceDate:fetchStart]]];
                  if (array.count>0)
                  {
                      [arrPersons addObjectsFromArray:array];
                      [self.tableView reloadData];
                  }
                  
                  NSDate *pushMain = [NSDate date];
                  if ([[coreDataStack managedObjectContext]save:&error])
                  {
                      [self writeLogger:[NSString stringWithFormat:@"Main MOC insertion time- %f",[[NSDate date]timeIntervalSinceDate:pushMain]]];
                      NSLog(@"Data written on Main MOC");
                      
                      NSDate *pushWriter = [NSDate date];
                      [[coreDataStack writerManagedObjectContext]performBlock:^
                       {
                           if ([[coreDataStack writerManagedObjectContext]save:&error])
                           {
                               [self writeLogger:[NSString stringWithFormat:@"Writer MOC insertion time- %f",[[NSDate date]timeIntervalSinceDate:pushWriter]]];
                               NSLog(@"Data written on Writer MOC");
                           }
                       }];
                  }
              }];
         }
     }];
}

- (void)writeLogger:(NSString *)string
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       NSString *previousText = self.lblLogger.text;
                       NSString *finalText = [NSString stringWithFormat:@"%@\n%@", previousText, string];
                       self.lblLogger.text = finalText;
                   });
}

#pragma mark - Table view DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrPersons.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"defaultCell";
    UITableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    Person *person = [arrPersons objectAtIndex:indexPath.row];
    cell.textLabel.text = person.name;
    return cell;
}


@end
