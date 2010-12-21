//
//  CustomImageSelector.h
//  LevelMaker
//
//  Created by Alex Nichol on 11/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@protocol CustomImageSelectorDelegate

@optional
- (void)imageSelector:(id)sender didChangeImage:(NSImage *)newImage;
- (void)imageSelector:(id)sender didChangeSelection:(NSRect)selection;

@end


@interface CustomImageSelector : NSView {
	CGSize scaleSize;
	CGRect smallFrame;
	NSImage * largeImage;
	NSString * lastFileName;
	NSTextField * noImageWarning;
	int smallFrameSize;
	id <CustomImageSelectorDelegate> delegate;
}
@property (nonatomic, retain) NSString * lastFileName;
@property (nonatomic, assign) id <CustomImageSelectorDelegate> delegate;
- (CGPoint)offsetInWindow;
- (void)setSmallFrameSize:(int)nsize;
- (void)setSmallFrameCenter:(CGPoint)p;
- (void)setSmallFrame:(CGRect)r;
- (CGRect)smallFrame;
- (CGRect)scaleRect:(CGRect)rect;
- (void)calculateScale;
- (void)setLargeImage:(NSImage *)image;
- (NSImage *)largeImage;
- (void)loadUI;
- (CGRect)imageOffset;

- (NSImage *)setDefaultDPI:(NSImage *)image;

@end
