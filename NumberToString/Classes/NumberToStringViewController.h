//
//  NumberToStringViewController.h
//  NumberToString
//
//  Created by Alex Nichol on 12/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ANNumberToString.h"

@interface NumberToStringViewController : UIViewController {
	IBOutlet UITextField * numberField;
	IBOutlet UITextView * humanReadable;
}

- (IBAction)humanize:(id)sender;

@end

