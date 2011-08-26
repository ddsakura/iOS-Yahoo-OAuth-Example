//
//  yahooOauthAppDelegate.h
//  yahooOauth
//
//  Created by Eric (yu-wei) Chuang on 2011/8/26.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class yahooOauthViewController;

@interface yahooOauthAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet yahooOauthViewController *viewController;

@end
