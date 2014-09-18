//
//  TOViewController.m
//  teaorbit
//
//  Created by Murat Ayfer on 12/11/2013.
//  Copyright (c) 2013 tea orbit. All rights reserved.
//

#import "TOViewController.h"
#import "WebViewJavascriptBridge.h"

@interface TOViewController () <UIWebViewDelegate>
{
    WebViewJavascriptBridge* bridge;
    UIImageView * imageview;
}
@property (strong, nonatomic) IBOutlet UIWebView *TOWebView;


@end

@implementation TOViewController

#define DEFAULT_CHANNEL_KEY @"default_channel"

-(void) saveChannel:(NSString *) channelName
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"saving channel %@", channelName);
    [defaults setObject:channelName forKey:DEFAULT_CHANNEL_KEY];
    [defaults synchronize];
}

-(NSString *) getChannel
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString *channelName = [defaults stringForKey:DEFAULT_CHANNEL_KEY];
    NSLog(@"laoding channel %@", channelName);
    return channelName;
}

- (void)viewWillAppear:(BOOL)animated
{
    imageview = [[UIImageView alloc]init];
    [imageview setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    imageview.contentMode = UIViewContentModeScaleAspectFit;
    [imageview setImage:[UIImage imageNamed:@"tea_red.png"]];
    [self.view addSubview:imageview];
    NSLog(@"SPLASH IS GONE");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    NSString *channelName = [self getChannel];
    if (channelName == nil) {
        channelName = @"";
    }
    [self saveChannel:channelName];

    _TOWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    NSString *url = [NSString stringWithFormat:@"http://teaorbit.com/%@", channelName];
    NSURL *nsurl = [NSURL URLWithString:url];
    NSURLRequest *nsrequest = [NSURLRequest requestWithURL:nsurl];
    [_TOWebView loadRequest:nsrequest];

    _TOWebView.delegate = self;
    bridge = [WebViewJavascriptBridge bridgeForWebView:_TOWebView webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSLog(@"Received message from javascript: %@", data);
        
        if ([data hasPrefix:@"channel:"]) {
            NSString *newChannel = [data substringFromIndex:[@"channel:" length]];
            [self saveChannel:newChannel];
        }
        //responseCallback(@"Right back atcha");
    }];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
}



- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    /*
    NSLog(@"Attempting to send shiet");
    [bridge send:@"Well hello there"];
    [bridge send:[NSDictionary dictionaryWithObject:@"Foo" forKey:@"Bar"]];
    [bridge send:@"Give me a response, will you?" responseCallback:^(id responseData) {
        NSLog(@"ObjC got its response! %@", responseData);
    }];
    */
    [self.view addSubview:_TOWebView];
    NSLog(@"Page loaded");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
    NSMutableDictionary *customHeaders = [NSMutableDictionary dictionary];
    [customHeaders setObject:@"iPhoneTeaOrbit" forKey:@"X-Requested-By"];
    
    // if we have no custom headers to set, just let the request load as normal
    if(customHeaders.count == 0)
    {
        return YES;
    }
    
    // use this flag to track if all custom headers have been set on the request object
    BOOL allHeadersProcessed = YES;
    
    // iterate through all specified custom headers
    for(NSString *customKey in [customHeaders allKeys])
    {
        // grab the value associated with the custom header
        NSString *customValue = (NSString *)[customHeaders objectForKey:customKey];
        
        // use this flag to mark if the custom header/value already exist on the request
        BOOL customHeaderProcessed = NO;
        
        // iterate through all the keys in the request
        for(NSString *existingKey in [[request allHTTPHeaderFields] allKeys])
        {
            // only compare keys which match (ignoring case as the UIWebView may alter case between requests)
            if([customKey caseInsensitiveCompare:existingKey] == NSOrderedSame)
            {
                // grab the value for the existing key - both key and value must match
                NSString *existingValue = (NSString *)[request valueForHTTPHeaderField:existingKey];
                
                // if we have a match here, then key and value match
                if([customValue isEqualToString:existingValue])
                {
                    // mark this custom header as being processed
                    customHeaderProcessed = YES;
                    
                    // no point in looking through other existing headers when we've found a match
                    break;
                }
            }
        }
        
        // if this particular custom header hasn't been processed, then mark that not all headers have been processed
        if(customHeaderProcessed == NO)
        {
            allHeadersProcessed = NO;
            break;
        }
    }
    
    // if all headers exist on the request, no modification is necessary
    if(allHeadersProcessed)
        return YES;
    
    // otherwise, we need to cancel the existing request and create a new (mutable) one
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    
    // for each custom header
    for(NSString *key in [customHeaders allKeys])
    {
        // grab the value needing set
        NSString *value = [customHeaders valueForKey:key];
        
        // set the value to the custom header
        [mutableRequest addValue:value forHTTPHeaderField:key];
        
    }
    
    // load the new mutable request
    [webView loadRequest:mutableRequest];
    
    // cancel the existing request
    return NO;
}

@end
