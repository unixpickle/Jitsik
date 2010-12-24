//
//  NumberToStringAppDelegate.h
//  NumberToString
//
//  Created by Alex Nichol on 12/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NumberToStringViewController;

@interface NumberToStringAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    NumberToStringViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet NumberToStringViewController *viewController;

@end

