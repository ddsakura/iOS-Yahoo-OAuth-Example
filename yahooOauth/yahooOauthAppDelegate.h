//
//  yahooOauthAppDelegate.h
//  yahooOauth
//
//  Created by ddsakura on 2011/8/26.
//

#import <UIKit/UIKit.h>

@class yahooOauthViewController;

@interface yahooOauthAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet yahooOauthViewController *viewController;

@end
