//
//  YahooApi.h
//  yahooOauth
//
//  Created by ddsakura on 2011/8/30.
//

#import <Foundation/Foundation.h>

@protocol YahooApiDelegate <NSObject>
@optional

- (void)apiRequestStart;
- (void)apiRequestFinished:(NSArray *)responseData;

@end

@interface YahooApi : NSObject {
    
    NSString *apiUrl;
    NSString *apiParameter;
    NSString *onlyGetToken;
    
    id <YahooApiDelegate> delegate;
}

@property (nonatomic, retain) NSString *apiUrl;
@property (nonatomic, retain) NSString *apiParameter;
@property (nonatomic, retain) NSString *onlyGetToken;
@property (nonatomic, assign) id <YahooApiDelegate> delegate;

- (id)initOnlyGetToken;
- (id)initWithApiUrl:(NSString*)theApiUrl withParameters:(NSString*)theApiParameter;
- (void)requestApiWithOauthToken:(NSString *)oauthTokenMatch withOauthTokenSecret:(NSString*)oauthTokenSecretMatch;
- (void)refreshToken:(NSString *)oauthToken withOauthTokenSecret:(NSString*)oauthTokenSecret withOauthSessionHandle:(NSString*)oauthSessionHandle;
- (void)startRequest;
- (void)initAccessToken;
- (BOOL)isTokenValid;

@end
