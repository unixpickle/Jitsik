//
//  NumberToStringViewController.m
//  NumberToString
//
//  Created by Alex Nichol on 12/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NumberToStringViewController.h"

@implementation NumberToStringViewController

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	NSLog(@"%@", [[NSNumber numberWithInt:103949] humanReadableString]);
}

- (IBAction)humanize:(id)sender {
	int iv = [[numberField text] intValue];
	if ([[numberField text] floatValue] > pow(2, 32)) {
		[numberField setText:@"Number > 32 bits"];
		return;
	}
	if (iv == 0 && ![[numberField text] isEqual:@"0"]) {
		// not a number
		[numberField setText:@"Enter an INT here"];
		return;
	}
	NSNumber * n = [NSNumber numberWithInt:iv];
	NSString * str = [n humanReadableString];
	[humanReadable setText:str];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
