#import "Hello_GLAppDelegate.h"
#import "GLViewController.h"
#import "GLView.h"
@implementation Hello_GLAppDelegate
@synthesize window, rootController;
#pragma mark -
#pragma mark Application lifecycle
- (BOOL)application:(UIApplication *)application 
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{    
    //[window addSubview:rootController.view];
    rootController.view.frame = window.frame;
    rootController.view.contentScaleFactor = window.contentScaleFactor;
    [window makeKeyAndVisible];
	[(GLView *)rootController.view startAnimation];
    
      // Set RootViewController to window
    if ( [[UIDevice currentDevice].systemVersion floatValue] < 6.0)
    {
        // warning: addSubView doesn't work on iOS6
        [window addSubview: rootController.view];
    }
    else
    {
        // use this method on ios6
        [window setRootViewController:rootController];
    }
    [window makeKeyAndVisible];

	return YES;
}
- (void)dealloc 
{
    [window release], window = nil;
    [rootController release], rootController = nil;
    [super dealloc];
}


@end
