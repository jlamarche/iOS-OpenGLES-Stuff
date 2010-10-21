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
    [window addSubview:rootController.view];
    rootController.view.frame = window.frame;
    rootController.view.contentScaleFactor = window.contentScaleFactor;
    [window makeKeyAndVisible];
	[(GLView *)rootController.view startAnimation];

	return YES;
}
- (void)dealloc 
{
    [window release], window = nil;
    [rootController release], rootController = nil;
    [super dealloc];
}


@end
