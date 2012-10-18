//
//  yahooOauthViewController.m
//  yahooOauth
//
//  Created by ddsakura on 2011/8/26.
//

#import "yahooOauthViewController.h"
#import "ASIFormDataRequest.h"
#import "ASIHTTPRequest.h"
#import "RegexKitLite.h"


#import <CommonCrypto/CommonHMAC.h>
#import "NSString+URLEncode.h"
#import "NSData+Base64.h"

#import "YahooApi.h"

#import "JSON.h"




@implementation yahooOauthViewController

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - ASIHTTPRequest
- (void)apiRequestStart
{
    
    NSLog(@"apiRequestStart delegate");
}

- (void)apiRequestFinished:(NSArray *)responseData
{
    
    NSLog(@"apiRequestFinished delegate:%@", responseData);
}


#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    

    apiRequest = [[YahooApi alloc ]initWithApiUrl:@"http://wretch.yahooapis.com/v1.2/hotAlbums/9" withParameters:@"timespan=Today&start=21&count=20"];
    //apiRequest = [[YahooApi alloc] initOnlyGetToken];
    [apiRequest setDelegate:self];
    //[apiRequest setApiUrl:@"http://wretch.yahooapis.com/v1.2/hotAlbums/9"];
    //[apiRequest setApiParameter:@"timespan=Today&start=21&count=20"];
    //[apiRequest setOnlyGetToken:@"FALSE"];
    
    if ([apiRequest isTokenValid]) {
        NSLog(@"startReqiest");
        [apiRequest startRequest];
    }
    else
    {
        [self performSelector:@selector(performApi:) withObject:[NSNumber numberWithInt:1] afterDelay:0.5];
    }
}

- (void)performApi:(NSNumber*)tryTimes
{
    
    int t = [tryTimes intValue] + 1;
    
    tryTimes = [NSNumber numberWithInt:t];

    if (t > 5) {
        [apiRequest startRequest];
    }
    else
    {
        if ([apiRequest isTokenValid]) {
            [apiRequest startRequest];
        }
        else
        {
            [self performSelector:@selector(performApi:) withObject:tryTimes afterDelay:1];
        }  
    }
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
