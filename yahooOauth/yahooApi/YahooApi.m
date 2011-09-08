//
//  YahooApi.m
//  yahooOauth
//
//  Created by ddsakura on 2011/8/30.
//

#import "YahooApi.h"
#import "ASIFormDataRequest.h"
#import "RegexKitLite.h"

#import <CommonCrypto/CommonHMAC.h>
#import "NSString+URLEncode.h"
#import "NSData+Base64.h"
#import "JSON.h"


static const NSString *oauth_consumer_key = @"dj0yJmk9MXVqNFVWZFdHa1JuJmQ9WVdrOU1GVXpaMEZ2TldjbWNHbzlORGczTXpneE5qWXkmcz1jb25zdW1lcnNlY3JldCZ4PWY1";
static const NSString *oauth_consumer_secret = @"dc6e6814dd61bf29bc70b8d6da05efade8941ed9";

static const NSString *oauthLogin = @"asbloguser2@yahoo.com";
static const NSString *oauthPasswd = @"test123";

static const NSString *urlGetAuthToken = @"https://login.yahoo.com/WSLogin/V1/get_auth_token";
static const NSString *urlGetToken = @"https://api.login.yahoo.com/oauth/v2/get_token";

@implementation YahooApi

@synthesize delegate;
@synthesize apiUrl, apiParameter;

- (NSString *)oauthGeneratePlaintextSignatureFor:(NSString *)baseString
                                withClientSecret:(NSString *)clientSecret
                                  andTokenSecret:(NSString *)tokenSecret
{
    // Construct the signature key
    return [NSString stringWithFormat:@"%@&%@", clientSecret != nil ? [clientSecret encodeForURL] : @"", tokenSecret != nil ? [tokenSecret encodeForURL] : @""];
}

- (NSString *)oauthGenerateHMAC_SHA1SignatureFor:(NSString *)baseString
                                withClientSecret:(NSString *)clientSecret
                                  andTokenSecret:(NSString *)tokenSecret
{
	
    NSString *key = [self oauthGeneratePlaintextSignatureFor:baseString withClientSecret:clientSecret andTokenSecret:tokenSecret];
    
    const char *keyBytes = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *baseStringBytes = [baseString cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char digestBytes[CC_SHA1_DIGEST_LENGTH];
    
	CCHmacContext ctx;
    CCHmacInit(&ctx, kCCHmacAlgSHA1, keyBytes, strlen(keyBytes));
	CCHmacUpdate(&ctx, baseStringBytes, strlen(baseStringBytes));
	CCHmacFinal(&ctx, digestBytes);
    
	NSData *digestData = [NSData dataWithBytes:digestBytes length:CC_SHA1_DIGEST_LENGTH];
    return [digestData base64EncodedString];
}

#pragma mark - ASIHTTPRequest

- (void)requestFinished:(ASIHTTPRequest *)request
{
    
    NSLog(@"requestFinished");
    // Use when fetching text data
    NSData *data = request.responseData;
    NSString *response = [NSString stringWithCString:[data bytes] encoding:NSUTF8StringEncoding];
    NSLog(@"%@",response);
    
    if ([[request.userInfo valueForKey:@"type"] isEqualToString:@"PreApprovedRequestToken"]) {
        //NSString 
        NSString *regEx = @"RequestToken=(.*)+";
        NSString *match = [response stringByMatching:regEx];
        if ([match isEqual:@""] == NO) {
            NSString *requestToken = [match stringByReplacingOccurrencesOfRegex:@"RequestToken=" withString:@""];
            NSLog(@"requestToken: %@", requestToken);
            
            NSTimeInterval  todaysDate = [[NSDate date] timeIntervalSince1970];
            NSString *timeinNSString = [NSString stringWithFormat:@"%.0f", todaysDate];
            NSLog(@"timeStamp: %@", timeinNSString);
            
            NSString* escapedUrlString = [NSString stringWithFormat:@"%@&", oauth_consumer_secret];
            
            NSLog(@"escapedUrlString: %@", escapedUrlString);
            
            //
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", urlGetToken]];
            ASIFormDataRequest *getTokenRequest = [ASIFormDataRequest requestWithURL:url];
            getTokenRequest.userInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"getToken", @"type", nil];
            [getTokenRequest setPostValue:[NSString stringWithFormat:@"%@", oauth_consumer_key] forKey:@"oauth_consumer_key"];
            [getTokenRequest setPostValue:@"PLAINTEXT" forKey:@"oauth_signature_method"];
            [getTokenRequest setPostValue:@"abcde" forKey:@"oauth_nonce"];
            [getTokenRequest setPostValue:timeinNSString forKey:@"oauth_timestamp"];
            [getTokenRequest setPostValue:escapedUrlString forKey:@"oauth_signature"];
            [getTokenRequest setPostValue:@"oob" forKey:@"oauth_verifier"];
            [getTokenRequest setPostValue:@"1.0" forKey:@"oauth_version"];
            [getTokenRequest setPostValue:requestToken forKey:@"oauth_token"];
            [getTokenRequest setDelegate:self];
            [getTokenRequest startAsynchronous];
            
            
        } else {
            NSLog(@"Not found.");
        }
        
    }
    else if ([[request.userInfo valueForKey:@"type"] isEqualToString:@"getToken"]) {
        
        if (response != NULL) {
            NSString *regEx = @"\\boauth_token=([a-zA-Z0-9%_.+\\-]+)&\\b";
            NSString *oauthTokenSecretReg = @"\\boauth_token_secret=([a-zA-Z0-9%_.+\\-]+)&\\b";
            NSString *match = [response stringByMatching:regEx];
            NSString *match2 = [response stringByMatching:oauthTokenSecretReg];
            NSLog(@"%@", match);
            if ([match isEqual:@""] == NO) {
                
                NSTimeInterval  todaysDate = [[NSDate date] timeIntervalSince1970];
                NSString *timeinNSString = [NSString stringWithFormat:@"%.0f", todaysDate];
                NSLog(@"timeStamp: %@", timeinNSString);
                
                NSString* escapedUrlString = [NSString stringWithFormat:@"%@&", oauth_consumer_secret];
                
                NSLog(@"escapedUrlString: %@", escapedUrlString);
                
                NSString *oauthToken = [match stringByReplacingOccurrencesOfRegex:@"oauth_token=" withString:@""];
                oauthToken = [oauthToken stringByReplacingOccurrencesOfRegex:@"&" withString:@""];
                NSLog(@"oauth_token: %@", oauthToken);
                
                NSString *oauthSecrect = [match2 stringByReplacingOccurrencesOfRegex:@"oauth_token_secret=" withString:@""];
                oauthSecrect = [oauthSecrect stringByReplacingOccurrencesOfRegex:@"&" withString:@""];
                NSLog(@"oauthSecrect: %@", oauthSecrect);
                
                
                NSString *baseUrl = self.apiUrl;
                
                NSMutableDictionary *parameterDic = [NSMutableDictionary dictionaryWithObjects:
                                                       [NSArray arrayWithObjects:@"json", [NSString stringWithFormat:@"%@", oauth_consumer_key], timeinNSString, @"HMAC-SHA1", timeinNSString, oauthToken, @"1.0", nil]
                                                                         forKeys:
                                                       [NSArray arrayWithObjects:@"format", @"oauth_consumer_key", @"oauth_nonce", @"oauth_signature_method", @"oauth_timestamp", @"oauth_token", @"oauth_version", nil]];
                
                
                NSString *searchString = self.apiParameter;
                NSString *regexString  = @"((\\w+)\\=(\\w+))";
                NSString *regexSpiltString  = @"\\=";
                NSArray  *matchArray   = NULL;
                
                matchArray = [searchString componentsMatchedByRegex:regexString];
                NSLog(@"matchArray: %@", matchArray);
                
                for (NSString* pairPara in matchArray) {
                    NSArray  *splitArray   = NULL;
                    splitArray = [pairPara componentsSeparatedByRegex:regexSpiltString];
                    NSLog(@"splitArray: %@", splitArray);
                    [parameterDic setObject:[splitArray objectAtIndex:1] forKey:[splitArray objectAtIndex:0]];
                    
                }
                
               
                
                NSArray *myKeys = [parameterDic allKeys];
                NSArray *sortedKeys = [myKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
                
                NSString *parameters = @"";
                
                for (int k=0; k < [myKeys count]; k++) {
                    parameters = [NSString stringWithFormat:@"%@%@=%@", [parameters isEqualToString:@""]?[NSString stringWithFormat:@""]:[NSString stringWithFormat:@"%@&", parameters] , [sortedKeys objectAtIndex:k],[parameterDic objectForKey: [sortedKeys objectAtIndex:k]]];
                }
                
                NSLog(@"kkkk: %@", parameters);
                
                NSString *parameter = [NSString stringWithFormat:@"%@&format=json&oauth_consumer_key=%@&oauth_nonce=%@&oauth_signature_method=HMAC-SHA1&oauth_timestamp=%@&oauth_token=%@&oauth_version=1.0", self.apiParameter, [NSString stringWithFormat:@"%@", oauth_consumer_key], timeinNSString, timeinNSString, oauthToken];
                
                
                NSString *urlencodebaseUrl = [baseUrl encodeForURL];
                
                NSString *urlencodeParameter = [parameters encodeForURL];
                
                NSString *baseData = [NSString stringWithFormat:@"GET&%@&%@", urlencodebaseUrl, urlencodeParameter];
                NSString *encodeBaseData = [[self oauthGenerateHMAC_SHA1SignatureFor:baseData withClientSecret:[NSString stringWithFormat:@"%@", oauth_consumer_secret] andTokenSecret:oauthSecrect] encodeForURL];
                
                
                NSLog(@"baseUrl: GET&%@", baseUrl);
                NSLog(@"baseData: %@", baseData);
                NSLog(@"encodeBaseData: %@", encodeBaseData);
                
                
                //NSURL *url = [NSURL URLWithString:@"http://wretch.yahooapis.com/v1.2/siteAlbumCategories?format=json"];
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?format=json&%@", baseUrl, self.apiParameter]];
                ASIHTTPRequest *apiRequest = [ASIHTTPRequest requestWithURL:url];
                apiRequest.userInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"accessApi", @"type", nil];
                
                NSString *oauthValue = [NSString stringWithFormat:@"OAuth realm=\"yahooapis.com\", oauth_consumer_key=\"%@\", oauth_nonce=\"%@\", oauth_signature_method=\"HMAC-SHA1\", oauth_timestamp=\"%@\", oauth_token=\"%@\", oauth_version=\"1.0\", oauth_signature=\"%@\"", [NSString stringWithFormat:@"%@", oauth_consumer_key], timeinNSString, timeinNSString, oauthToken, encodeBaseData];
                
                NSLog(@"%@", oauthValue);
                
                [apiRequest addRequestHeader:@"Authorization" value:oauthValue];
                [apiRequest setDelegate:self];
                [apiRequest startAsynchronous];
                /*NSError *error = [apiRequest error];
                if (!error) {
                    NSString *response = [apiRequest responseString];
                    NSLog(@"%@", response);
                }
                else
                {
                    NSLog(@"%@", [error description]);
                }*/
                
            }
        }
        else
        {
            [self initAccessToken];

        }
        

    }
    else if ([[request.userInfo valueForKey:@"type"] isEqualToString:@"accessApi"]) {
        NSArray *jsonDict = [response JSONValue];
        
        [[self delegate] apiRequestFinished:jsonDict];
        //NSLog(@"%@", jsonDict);

    }
}

- (void)initAccessToken
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", urlGetAuthToken]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    request.userInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"PreApprovedRequestToken", @"type", nil];
    [request setPostValue:[NSString stringWithFormat:@"%@", oauth_consumer_key] forKey:@"oauth_consumer_key"];
    [request setPostValue:[NSString stringWithFormat:@"%@", oauthLogin] forKey:@"login"];
    [request setPostValue:[NSString stringWithFormat:@"%@", oauthPasswd] forKey:@"passwd"];
    [request setDelegate:self];
    [request startAsynchronous];

}

- (id)initWithApiUrl:(NSString*)theApiUrl withParameters:(NSString*)theApiParameter
{
	self = [self init];
    if (self) {
        [self setApiUrl:theApiUrl];
        [self setApiParameter:theApiParameter];
    }
    
	return self;
}

-(void)startRequest
{
    [[self delegate] apiRequestStart];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:@"oauth_token"]) {
        //Call init get access token
        NSLog(@"Call init get access token");
        [self initAccessToken];
    }
    else {
        
        //Call Refresh access token
        NSLog(@"Call Refresh access token");
        /*NSString *oauth_token = [defaults objectForKey:@"oauth_token"];
         NSString *oauth_token_secret = [defaults objectForKey:@"oauth_token_secret"];
         NSString *oauth_session_handle = [defaults objectForKey:@"oauth_session_handle"];*/
    }
    
    /*
     NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
     [defaults setObject:@"" forKey:@"FBAccessTokenKey"];
     [defaults setObject:@"" forKey:@"FBExpirationDateKey"];
     [defaults synchronize];*/
}


@end
