//
//  Hello_GLAppDelegate.h
//  Hello GL
//
//  Created by jeff on 7/1/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GLViewController;

@interface Hello_GLAppDelegate : NSObject <UIApplicationDelegate> 
{

}
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet GLViewController *rootController;
@end

