//
//  ViewController.m
//  CustomSearchControlSample
//
//  Created by Mehtab on 16/02/2017.
//  Copyright © 2017 Mehtab. All rights reserved.
//

#import "ViewController.h"
#import "CustomSearchView.h"

@interface ViewController () {
    
    CustomSearchView* _searchView;
}


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialize];
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self showControl];
}


- (void) initialize {
    _searchView = [[CustomSearchView alloc]  initViewWithFrame:[[UIScreen mainScreen] bounds]];
    
}

- (void) showControl {
    
    if(!_searchView)
        return;


   [self.view addSubview:_searchView];
}

- (IBAction)onBtnPressed:(id)sender {
    
    NSLog(@"Press me");
}

@end
