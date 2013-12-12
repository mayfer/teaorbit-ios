//
//  TOViewController.m
//  teaorbit
//
//  Created by Murat Ayfer on 12/11/2013.
//  Copyright (c) 2013 tea orbit. All rights reserved.
//

#import "TOViewController.h"

@interface TOViewController ()
@property (strong, nonatomic) IBOutlet UIWebView *TOWebView;

@end

@implementation TOViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	NSString *fullURL = @"http://teaorbit.com";
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [_TOWebView loadRequest:requestObj];}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
