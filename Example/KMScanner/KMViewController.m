//
//  KMViewController.m
//  KMScanner
//
//  Created by shenhao on 04/27/2019.
//  Copyright (c) 2019 shenhao. All rights reserved.
//

#import "KMViewController.h"
#import "KMScannerViewController.h"

@interface KMViewController ()

@end

@implementation KMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)btnClick:(id)sender{
    UIImage *avatar = [UIImage imageNamed:@"avatar"];

    KMScannerViewController *scanner = [[KMScannerViewController alloc] initWithCompletion:^(NSString *stringValue) {
        
        NSLog(@"%@",stringValue);
        
    }];
    
    [self.navigationController pushViewController:scanner animated:YES];}
@end
