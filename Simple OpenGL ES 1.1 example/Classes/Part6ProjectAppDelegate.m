//
//  Part6ProjectAppDelegate.m
//  Part6Project
//
//  Created by jeff on 5/31/09.
//  Copyright Jeff LaMarche 2009. All rights reserved.
//

#import "Part6ProjectAppDelegate.h"
#import "GLViewController.h"
#import "GLView.h"



@implementation Part6ProjectAppDelegate
@synthesize window;
@synthesize controller;

- (void)applicationDidFinishLaunching:(UIApplication*)application
{
	CGRect	rect = [[UIScreen mainScreen] bounds];
	
	GLViewController *theController = [[GLViewController alloc] init];
	self.controller = theController;
	[theController release];
	
	GLView *glView = [[GLView alloc] initWithFrame:rect];
	[window addSubview:glView];

	glView.controller = controller;
	glView.animationInterval = 1.0 / kRenderingFrequency;
	[glView startAnimation];
	[glView release];
	
	[window makeKeyAndVisible];

}

- (void)dealloc
{
	[window release];
	[controller release];
	[super dealloc];
}
@end
