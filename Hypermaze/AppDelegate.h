//
//  AppDelegate.h
//  Hypermaze
//
//  Created by Jakub Gruszecki on 11-07-15.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPConfiguration.h"
#import "HPSound.h"
#import "Game.h"

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
