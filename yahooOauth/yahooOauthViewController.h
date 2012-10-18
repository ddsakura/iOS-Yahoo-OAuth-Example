//
//  yahooOauthViewController.h
//  yahooOauth
//
//  Created by ddsakura on 2011/8/26.
//

#import <UIKit/UIKit.h>
#import "YahooApi.h"

@interface yahooOauthViewController : UIViewController<YahooApiDelegate> {
    YahooApi *apiRequest;
}

//@property (nonatomic, retain) NSString *apiUrl;

@end
