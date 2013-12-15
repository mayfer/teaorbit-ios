//
//  TOViewController.m
//  teaorbit
//
//  Created by Murat Ayfer on 12/11/2013.
//  Copyright (c) 2013 tea orbit. All rights reserved.
//

#import "TOViewController.h"
#import "WebViewJavascriptBridge.h"

@interface TOViewController () {
    WebViewJavascriptBridge* bridge;
}
@property (strong, nonatomic) IBOutlet UIWebView *TOWebView;

@end

@implementation TOViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	NSString *fullURL = @"http://localhost:8001/dev01";
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [_TOWebView loadRequest:requestObj];
    
    bridge = [WebViewJavascriptBridge bridgeForWebView:_TOWebView handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"Received message from javascript: %@", data);
        responseCallback(@"Right back atcha");
    }];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSLog(@"Attempting to send shiet");
    [bridge send:@"Well hello there"];
    [bridge send:[NSDictionary dictionaryWithObject:@"Foo" forKey:@"Bar"]];
    [bridge send:@"Give me a response, will you?" responseCallback:^(id responseData) {
        NSLog(@"ObjC got its response! %@", responseData);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
