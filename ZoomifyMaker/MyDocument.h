//
//  MyDocument.h
//  ZoomifyMaker
//
//  Created by Alex Nichol on 12/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import "CustomImageSelector.h"

@interface MyDocument : NSDocument <CustomImageSelectorDelegate> {
	// instance variables
	// ivar: documentData
	// contains the plist data that is used
	// by Zoomify itself when loading packages.
	// This includes the name, and options.
	NSMutableDictionary * documentData;
	// ivar: imagesAndNames
	// a dictionary of NSImage TIFF data objects
	// stored along with the names of the images
	// as keys.
	NSMutableDictionary * imagesAndNames;
	// outlet variables
	IBOutlet CustomImageSelector * imagePicker;
	IBOutlet NSTextField * coordinateText;
	IBOutlet NSTableView * imageList;
	IBOutlet NSSlider * blockSize;
}
- (NSImage *)imageForName:(NSString *)imageName;
- (void)setImage:(NSImage *)img forName:(NSString *)name;
- (IBAction)addImage:(id)sender;
- (IBAction)removeImage:(id)sender;
- (IBAction)blockSizeChanged:(id)sender;
- (IBAction)export:(id)sender;

- (NSMutableArray *)getOptionsArray;
- (void)selectTableView:(int)row;

// misc
- (NSRect)rectangleForString:(NSString *)fourParts;
@end
