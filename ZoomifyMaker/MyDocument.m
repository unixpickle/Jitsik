//
//  MyDocument.m
//  ZoomifyMaker
//
//  Created by Alex Nichol on 12/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MyDocument.h"
#import <sys/stat.h>

@implementation MyDocument

#pragma mark Document

- (id)init {
    self = [super init];
    if (self) {
    
		imagesAndNames = [[NSMutableDictionary alloc] init];
		documentData = [[NSMutableDictionary alloc] init];
		
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
    
    }
    return self;
}

- (NSString *)windowNibName {
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"MyDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController {
    [super windowControllerDidLoadNib:aController];
	[imageList setDataSource:self];
	[imageList setDelegate:self];
	[imagePicker setDelegate:self];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
    NSMutableDictionary * saveDictionary = [[NSMutableDictionary alloc] init];
	[saveDictionary setObject:imagesAndNames forKey:@"images"];
	[saveDictionary setObject:documentData forKey:@"plist"];
	NSData * d = [NSKeyedArchiver archivedDataWithRootObject:saveDictionary];
	[saveDictionary release];
    if (outError != NULL) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain 
										code:unimpErr userInfo:NULL];
	}
	return d;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
    NSDictionary * dict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	[documentData release];
	documentData = [[dict objectForKey:@"plist"] retain];
	[imagesAndNames release];
	imagesAndNames = [[dict objectForKey:@"images"] retain];
    if (outError != NULL) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
    return YES;
}

#pragma mark Lifecycle

- (NSImage *)imageForName:(NSString *)imageName {
	// look it up in our
	// dictionary
	return [[[NSImage alloc] initWithData:[imagesAndNames objectForKey:imageName]] autorelease];
}
- (void)setImage:(NSImage *)img forName:(NSString *)name {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	NSBitmapImageRep * bits = [[img representations] objectAtIndex:0];
	NSData * data;
	data = [bits representationUsingType:NSPNGFileType
							  properties:nil];
	[imagesAndNames setObject:data
					   forKey:name];
	[pool drain];
}
- (IBAction)addImage:(id)sender {
	// create a new image in our options.
	[imagePicker setLargeImage:nil];
	NSMutableDictionary * item = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"Untitled", @"Description",
						   @"", @"Image", @"0 0 100 100", @"Selection", nil];
	NSMutableArray * options = [self getOptionsArray];
	[options addObject:item];
	
	// select the table view index
	[imageList reloadData];
	[self selectTableView:([options count] - 1)];
	
	[item release];
}
- (IBAction)removeImage:(id)sender {
	// remove the selected index
	// if there is no selected index,
	// we will beep and return
	if ([imageList selectedRow] < 0) {
		NSBeep();
		return;
	}
	
	// remove from options
	NSMutableArray * options = [self getOptionsArray];
	NSDictionary * selectedOption;
	int newSelection;
	NSAssert(options != nil, @"Options was unset when removing image.");
	selectedOption = [options objectAtIndex:[imageList selectedRow]];
	NSAssert(selectedOption != nil, @"Selected option not found in list.");
	
	NSString * imageName = [selectedOption objectForKey:@"Image"];
	if ([imagesAndNames objectForKey:imageName]) {
		[imagesAndNames removeObjectForKey:imageName];
	}
	
	[options removeObjectAtIndex:[imageList selectedRow]];
	
	[imageList reloadData];
	
	newSelection = [imageList selectedRow] - 1;
	if (newSelection < 0 || newSelection >= [options count]) {
		// nothing here
		NSLog(@"Cannot find new row to select");
	} else {
		[self selectTableView:newSelection];
	}
	
}

- (IBAction)export:(id)sender {
	// export dialog
	NSSavePanel * spanel = [NSSavePanel savePanel];
	NSString * path = @"/Documents";
	[spanel setDirectory:[path stringByExpandingTildeInPath]];
	[spanel setPrompt:@"Export To Zoomify Format"];
	// [spanel setRequiredFileType:@"tiff"];
	
	[spanel beginSheetForDirectory:[NSHomeDirectory() stringByAppendingPathComponent:@"Desktop"]
							  file:nil
					modalForWindow:[[[self windowControllers] objectAtIndex:0] window]
					 modalDelegate:self
					didEndSelector:@selector(didEndSaveSheet:returnCode:conextInfo:)
					   contextInfo:NULL];
}

- (void)didEndSaveSheet:(NSSavePanel *)savePanel returnCode:(int)returnCode conextInfo:(void *)contextInfo {
	if (returnCode == NSOKButton) {
		NSString * name = [savePanel filename];
		// write to there
		if ([[NSFileManager defaultManager] fileExistsAtPath:name]) {
			NSRunAlertPanel(@"File exists.", @"The file name that you sepcified is already taken.", 
							@"OK", nil, nil);
			return;
		}
		// create the directory
		mkdir([name UTF8String], 0777);
		// make the plist
		NSMutableDictionary * docPlist = [[NSMutableDictionary alloc] initWithDictionary:documentData];
		
		[docPlist setObject:[NSNumber numberWithInt:abs(arc4random())] 
						 forKey:@"UniqueID"];
		[docPlist setObject:[NSNumber numberWithInt:1] 
						 forKey:@"Version"];
		[docPlist setObject:[name lastPathComponent] forKey:@"Catagory Name"];
		
		NSMutableArray * options = [NSMutableArray arrayWithArray:[docPlist objectForKey:@"Options"]];
		[docPlist setObject:options forKey:@"Options"];
		
		for (int i = 0; i < [[docPlist objectForKey:@"Options"] count]; i++) {
			NSMutableDictionary * dictionary = [[docPlist objectForKey:@"Options"] objectAtIndex:i];
			NSMutableDictionary * newDic = [[NSMutableDictionary alloc] initWithDictionary:dictionary];
			NSString * oldName = [newDic objectForKey:@"Image"];
			oldName = [[oldName stringByDeletingPathExtension] stringByAppendingString:@".png"];
			[newDic setObject:oldName forKey:@"Image"];
			[options replaceObjectAtIndex:i withObject:newDic];
			[newDic release];
		}
		
		[docPlist writeToFile:[name stringByAppendingPathComponent:[[name lastPathComponent] stringByAppendingString:@".plist"]] atomically:YES];
		[docPlist release];
		// create the image files
		for (NSString * imageName in imagesAndNames) {
			// write it
			NSImage * image = [self imageForName:imageName];
			// convert to PNG
			NSBitmapImageRep * bits = [[image representations] objectAtIndex:0];
			NSData * data;
			data = [bits representationUsingType:NSPNGFileType
									  properties:nil];
			NSString * newName = [[imageName stringByDeletingPathExtension] stringByAppendingString:@".png"];
			[data writeToFile:[name stringByAppendingPathComponent:newName]
				   atomically:YES];
		}
	}
}

- (IBAction)blockSizeChanged:(id)sender {
	// set block size of custom image
	int size = (int)[blockSize floatValue];
	[imagePicker setSmallFrameSize:size];
}

- (NSMutableArray *)getOptionsArray {
	// get the array if it is in our dictionary
	// or create it if not.
	NSMutableArray * options = [documentData objectForKey:@"Options"];
	if (!options) {
		options = [[NSMutableArray alloc] init];
		[documentData setObject:options forKey:@"Options"];
		[options release];
	}
	return options;
}

#pragma mark Image Picker

- (void)imageSelector:(id)sender didChangeImage:(NSImage *)newImage {
	// set new image
	int selectedIndex;
	if (!newImage) {
		return;
	}
	
	if ([[self getOptionsArray] count] == 0) {
		
		// WORRY ABOUT THIS LATER
		// FOR NOW, ERROR
		[imagePicker setLargeImage:nil];
		NSBeep();
		return;
		
		// add a new image to left bar
		[newImage retain];
		[self addImage:nil];
		// set the new image and do not get called again
		// to prevent unwanted recursion
		[imagePicker setDelegate:nil];
		[imagePicker setLargeImage:newImage];
		[imagePicker setDelegate:self];
		[newImage release];
		selectedIndex = 0;
	} else {
		selectedIndex = [imageList selectedRow];
		if (selectedIndex < 0) {
			// they had no row selected
			// set the large image and stop the delegate
			// once again.
			[imagePicker setDelegate:nil];
			[imagePicker setLargeImage:nil];
			[imagePicker setDelegate:self];
			// beep to show the error to the user
			NSBeep();
			return;
		}
	}
	NSMutableArray * options = [self getOptionsArray];
	NSMutableDictionary * imageOption = [options objectAtIndex:selectedIndex];
	[imageOption setObject:[imagePicker lastFileName] 
					forKey:@"Image"];
	[self setImage:newImage
		   forName:[imagePicker lastFileName]];
	
}
- (void)imageSelector:(id)sender didChangeSelection:(NSRect)selection {
	// display the selection and update it in our list
	int selectedIndex = [imageList selectedRow];
	NSString * rectangleString = [NSString stringWithFormat:@"%d %d %d %d", 
								  (int)(selection.origin.x),
								  (int)(selection.origin.y),
								  (int)(selection.size.width),
								  (int)(selection.size.height)];
	[coordinateText setStringValue:rectangleString];
	// save the text in the listing
	if (selectedIndex < 0) {
		// we have to worry about this a bit
		NSBeep();
		return;
	}
	
	NSMutableArray * options = [self getOptionsArray];
	// read it
	NSMutableDictionary * imageOption = [options objectAtIndex:selectedIndex];
	[imageOption setObject:rectangleString forKey:@"Selection"];
}

#pragma mark Table View

- (void)selectTableView:(int)row {
	NSIndexSet * set = [[NSIndexSet alloc] initWithIndex:row];
	[imageList selectRowIndexes:set
		   byExtendingSelection:NO];
	[set release];
}

- (NSUInteger)numberOfRowsInTableView:(NSTableView *)tv {
	return [[self getOptionsArray] count];
}
- (id)tableView:(NSTableView *)tv objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSUInteger)row {
	NSMutableDictionary * imageObject = [[self getOptionsArray] objectAtIndex:row];
	return [imageObject objectForKey:@"Description"];
}
- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
	NSMutableDictionary * imageItem = [[self getOptionsArray] objectAtIndex:rowIndex];
	[imageItem setObject:anObject forKey:@"Description"];
	[imageList reloadData];
}
- (void)tableViewSelectionDidChange:(NSNotification *)notification {
	// load the new image
	
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	int selectedRow = [imageList selectedRow];
	NSMutableDictionary * imageObject;
	if (selectedRow < 0) {
		[imagePicker setLargeImage:nil];
		[pool drain];
		return;
	}
	// get the image at the index
	// then load the image into the selector
	// along with the rectangle
	imageObject = [[self getOptionsArray] objectAtIndex:selectedRow];
	NSImage * image = [self imageForName:[imageObject objectForKey:@"Image"]];
	NSRect frm = [self rectangleForString:[imageObject objectForKey:@"Selection"]];
	[imagePicker setLargeImage:image];
	[imagePicker setSmallFrame:frm];
	[imagePicker setLastFileName:[imageObject objectForKey:@"Image"]];
	[blockSize setFloatValue:frm.size.width];
	
	[pool drain];
}

#pragma mark Misc

- (NSRect)rectangleForString:(NSString *)fourParts {
	NSArray * parts = [fourParts componentsSeparatedByString:@" "];
	NSRect returnRect;
	if ([parts count] != 4) {
		return NSZeroRect;
	}
	returnRect.origin.x = [[parts objectAtIndex:0] floatValue];
	returnRect.origin.y = [[parts objectAtIndex:1] floatValue];
	returnRect.size.width = [[parts objectAtIndex:2] floatValue];
	returnRect.size.height = [[parts objectAtIndex:3] floatValue];
	return returnRect;
}

- (void)dealloc {
	[imagesAndNames release];
	[documentData release];
	[super dealloc];
}

@end
