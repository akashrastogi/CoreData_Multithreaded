//
//  ViewController.h
//  CoreData_Multithreaded
//
//  Created by HealthOne on 24/10/16.
//  Copyright © 2016 akash. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *btnStart;
- (IBAction)btnStartClicked:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UILabel *lblLogger;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

