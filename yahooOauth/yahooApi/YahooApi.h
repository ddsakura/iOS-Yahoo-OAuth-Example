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
    
    id <YahooApiDelegate> delegate;
}

@property (nonatomic, retain) NSString *apiUrl;
@property (nonatomic, retain) NSString *apiParameter;
@property (nonatomic, assign) id <YahooApiDelegate> delegate;

- (id)initWithApiUrl:(NSString*)theApiUrl withParameters:(NSString*)theApiParameter;
- (void)startRequest;
- (void)initAccessToken;

@end
