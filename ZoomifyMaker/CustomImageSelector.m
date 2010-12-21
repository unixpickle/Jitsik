//
//  CustomImageSelector.m
//  LevelMaker
//
//  Created by Alex Nichol on 11/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CustomImageSelector.h"


@implementation CustomImageSelector

@synthesize delegate, lastFileName;

- (id)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super init]) {
		[self loadUI];
	}
	return self;
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		[self loadUI];
	}
    return self;
}

- (void)loadUI {
	// do nothing for now
	[self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
	
	largeImage = nil;
	smallFrameSize = 200;
	smallFrame = CGRectMake(0, 0, smallFrameSize, smallFrameSize);
	
	noImageWarning = [[NSTextField alloc] initWithFrame:NSMakeRect(0, self.frame.size.height / 2 - 15, self.frame.size.width, 30)];
	[noImageWarning setBordered:NO];
	[noImageWarning setFont:[NSFont boldSystemFontOfSize:20]];
	[noImageWarning setStringValue:@"Drag Image Here"];
	[noImageWarning setBackgroundColor:[NSColor clearColor]];
	[noImageWarning setAlignment:NSCenterTextAlignment];
	[noImageWarning setEditable:NO];
	[self addSubview:noImageWarning];
	
	[self setNeedsDisplay:YES];
}


- (CGPoint)offsetInWindow {
	CGPoint p = self.frame.origin;
	NSView * v = [self superview];
	while ((v = [v superview]) != NULL) {
		p.x += [v frame].origin.x;
		p.y += [v frame].origin.y;
	}
	return p;
}

- (void)setSmallFrameSize:(int)nsize {
	smallFrameSize = nsize;
	smallFrame.size.width = nsize;
	smallFrame.size.height = nsize;
	
	[self setNeedsDisplay:YES];
}

- (void)setSmallFrame:(CGRect)r {
	smallFrame = r;
	smallFrameSize = r.size.width;
	[self setNeedsDisplay:YES];
}

- (void)setSmallFrameCenter:(CGPoint)p {
	
	CGRect imageFrame = [self imageOffset];
	imageFrame.origin.x /= scaleSize.width;
	imageFrame.origin.y /= scaleSize.width;
	
	p.x /= scaleSize.width;
	p.y /= scaleSize.height;
	
	smallFrame = CGRectMake(p.x - (smallFrameSize / 2), p.y - (smallFrameSize / 2), smallFrameSize, smallFrameSize);
	smallFrame.origin.x -= imageFrame.origin.x;
	smallFrame.origin.y -= imageFrame.origin.y;
	
	
	CGRect r = smallFrame;
	CGRect _imageFrame;
	_imageFrame.size = NSSizeToCGSize([largeImage size]);
	/*
	if (r.origin.x < 0) r.origin.x = 0;
	if (r.origin.y < 0) r.origin.y = 0;
	if (r.origin.x + r.size.width > (_imageFrame.size.width + 0)) 
		r.origin.x = (_imageFrame.size.width + 0) - r.size.width;
	if (r.origin.y + r.size.height > (_imageFrame.size.height + 0)) 
		r.origin.y = (_imageFrame.size.height + 0) - r.size.height;
	*/
	smallFrame = r;
	
	[self setNeedsDisplay:YES];
}
- (CGRect)smallFrame {
	return smallFrame;
}
- (CGRect)scaleRect:(CGRect)rect {
	rect.origin.x *= scaleSize.width;
	rect.origin.y *= scaleSize.height;
	rect.size.width *= scaleSize.width;
	rect.size.height *= scaleSize.height;
	return rect;
}
- (void)calculateScale {
	
	[noImageWarning setFrame:NSMakeRect(0, self.frame.size.height / 2 - 15, self.frame.size.width, 30)];
	
	float factorx = [largeImage size].width / [self frame].size.width;
	float factory = [largeImage size].height / [self frame].size.height;
	if (factorx > factory) {
		// it is wider than high
		scaleSize.width = 1 / factorx;
	} else {
		scaleSize.width = 1 / factory;
	}
	scaleSize.height = scaleSize.width;
}
- (void)setLargeImage:(NSImage *)_image {
	
	// fix the resolution of the image
	NSImage * image = [self setDefaultDPI:_image];
	
	[largeImage release];
	largeImage = [image retain];
	[self calculateScale];
	[self setNeedsDisplay:YES];
	
	if (!image) {
		if (![noImageWarning superview]) {
			[self addSubview:noImageWarning];
		}
	} else {
		if ([noImageWarning superview]) {
			[noImageWarning removeFromSuperview];
		}
	}
}
- (NSImage *)largeImage {
	return largeImage;
}

- (void)setFrame:(NSRect)frameRect {
	[super setFrame:frameRect];
	[self calculateScale];
	[self setSmallFrame:[self smallFrame]];
	[self setNeedsDisplay:YES];
}

- (void)mouseDragged:(NSEvent *)theEvent {
	NSPoint p = [theEvent locationInWindow];
	NSPoint offset = [self offsetInWindow];
	p.x -= offset.x;
	p.y -= offset.y;
	[self setSmallFrameCenter:NSPointToCGPoint(p)];
}

- (void)mouseMoved:(NSEvent *)theEvent {
	
}

- (void)drawRect:(NSRect)dirtyRect {
    // Drawing code here.
	if (!largeImage) return;
	CGRect imageFrame = [self imageOffset];
	CGRect _imageFrame = CGRectMake(0, 0, [largeImage size].width, [largeImage size].height);

	
	
	[largeImage drawInRect:NSRectFromCGRect(imageFrame) fromRect:NSZeroRect 
				 operation:NSCompositeSourceOver fraction:1];
	
	
	CGRect r = smallFrame;
	

	imageFrame.origin.x /= scaleSize.width;
	imageFrame.origin.y /= scaleSize.width;
	
	
	//if (r.origin.x < 0) r.origin.x = 0;
//	if (r.origin.y < 0) r.origin.y = 0;
//	if (r.origin.x + r.size.width > (_imageFrame.size.width + 0)) 
//		r.origin.x = (_imageFrame.size.width + 0) - r.size.width;
//	if (r.origin.y + r.size.height > (_imageFrame.size.height + 0)) 
//		r.origin.y = (_imageFrame.size.height + 0) - r.size.height;
	
	
	r.origin.x += imageFrame.origin.x;
	r.origin.y += imageFrame.origin.y;
	
	if (r.origin.x < imageFrame.origin.x) {
		r.origin.x = imageFrame.origin.x;
	}
	if (r.origin.y < imageFrame.origin.y) r.origin.y = imageFrame.origin.y;
	if (r.origin.x + r.size.width > (_imageFrame.size.width + imageFrame.origin.x)) 
		r.origin.x = (_imageFrame.size.width + imageFrame.origin.x) - r.size.width;
	if (r.origin.y + r.size.height > (_imageFrame.size.height + imageFrame.origin.y)) 
		r.origin.y = (_imageFrame.size.height + imageFrame.origin.y) - r.size.height;
		
	
	if ([(id)delegate respondsToSelector:@selector(imageSelector:didChangeSelection:)]) {
		CGRect r1 = r;
		r1.origin.x -= imageFrame.origin.x;
		r1.origin.y -= imageFrame.origin.y;
		r1.origin.x = (int)r1.origin.x;
		r1.origin.y = (int)r1.origin.y;
		
		[delegate imageSelector:self didChangeSelection:r1];
		/*[delegate imageSelector:self 
			 didChangeSelection:smallFrame];*/
	}
	
	
	r = [self scaleRect:r];
	
	
	
	CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
	CGContextSaveGState(ctx);
	CGContextBeginPath(ctx);
	CGContextAddRect(ctx, r);
	CGContextClosePath(ctx);
	CGContextSetStrokeColorWithColor(ctx, CGColorCreateGenericRGB(0, 1, 0, 1));
	CGContextStrokePath(ctx);
	CGContextRestoreGState(ctx);
	
	CGContextSaveGState(ctx);
	CGContextBeginPath(ctx);
	r.origin.x -= 1;
	r.origin.y -= 1;
	r.size.width += 2;
	r.size.height += 2;
	CGContextAddRect(ctx, r);
	CGContextClosePath(ctx);
	CGContextSetStrokeColorWithColor(ctx, CGColorCreateGenericRGB(1, 0, 0, 1));
	CGContextStrokePath(ctx);
	CGContextRestoreGState(ctx);
	
}

- (NSImage *)setDefaultDPI:(NSImage *)fixImage {
	NSBitmapImageRep * irep = [[NSBitmapImageRep alloc] initWithData:[fixImage TIFFRepresentation]];
	
	NSSize rsize = irep.size;
	//float dpix = [irep pixelsWide] / rsize.width;
	//float dpiy = [irep pixelsHigh] / rsize.height;
	rsize.width = 72.0 * (float)[irep pixelsWide] / 72.0;
	rsize.height = 72.0 * (float)[irep pixelsHigh] / 72.0;
	[irep setSize:rsize];
	
	
	NSImage * image = [[NSImage alloc] initWithData:[irep TIFFRepresentation]];
	[irep release];
	return [image autorelease];
}

- (CGRect)imageOffset {
	CGRect _imageFrame = CGRectMake(0, 0, [largeImage size].width, [largeImage size].height);
	
	
	CGRect imageFrame = [self scaleRect:_imageFrame];
	imageFrame.origin.x = ([self frame].size.width / 2) - (imageFrame.size.width / 2);
	imageFrame.origin.y = ([self frame].size.height / 2) - (imageFrame.size.height / 2);
	return imageFrame;
}

- (void)dealloc {
	[largeImage release];
	largeImage = nil;
	[noImageWarning removeFromSuperview];
	[noImageWarning release];
	[super dealloc];
}

#pragma mark Drag and Drop

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    if ((NSDragOperationGeneric & [sender draggingSourceOperationMask]) 
		== NSDragOperationGeneric) {
        //this means that the sender is offering the type of operation we want
        //return that we want the NSDragOperationGeneric operation that they 
		//are offering
        return NSDragOperationGeneric;
    } else {
        //since they aren't offering the type of operation we want, we have 
		//to tell them we aren't interested
        return NSDragOperationNone;
    }
}

- (void)draggingExited:(id<NSDraggingInfo>)sender {
    //we aren't particularily interested in this so we will do nothing
    //this is one of the methods that we do not have to implement
}

- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender {
    if ((NSDragOperationGeneric & [sender draggingSourceOperationMask]) 
		== NSDragOperationGeneric) {
        //this means that the sender is offering the type of operation we want
        //return that we want the NSDragOperationGeneric operation that they 
		//are offering
        return NSDragOperationGeneric;
    } else {
        //since they aren't offering the type of operation we want, we have 
		//to tell them we aren't interested
        return NSDragOperationNone;
    }
}

- (void)draggingEnded:(id<NSDraggingInfo>)sender {
    //we don't do anything in our implementation
    //this could be ommitted since NSDraggingDestination is an infomal
	//protocol and returns nothing
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
    return YES;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    NSPasteboard * paste = [sender draggingPasteboard];
	//gets the dragging-specific pasteboard from the sender
    NSArray * types = [NSArray arrayWithObjects:NSTIFFPboardType, 
					   NSFilenamesPboardType, nil];
	//a list of types that we can accept
    NSString * desiredType = [paste availableTypeFromArray:types];
    NSData * carriedData = [paste dataForType:desiredType];
	
    if (nil == carriedData) {
        //the operation failed for some reason
        NSRunAlertPanel(@"Paste Error", @"Sorry, but the past operation failed", 
						nil, nil, nil);
        return NO;
    } else {
        // the pasteboard was able to give us some meaningful data
        if ([desiredType isEqualToString:NSFilenamesPboardType]) {
            NSArray * fileArray = [paste propertyListForType:@"NSFilenamesPboardType"];
            NSString * path = [fileArray objectAtIndex:0];
			self.lastFileName = [path lastPathComponent];
			NSImage * image = [[NSImage alloc] initWithContentsOfFile:path];
			if (image) {
				[self setLargeImage:image];
				if ([(id)delegate respondsToSelector:@selector(imageSelector:didChangeImage:)]) {
					[delegate imageSelector:self didChangeImage:image];
				}
				[image release];
			} else {
				// there was an error
				[self setLargeImage:nil];
				
				//NSBeep();
			}
        } else {
            // this can't happen
            NSRunAlertPanel(@"Not a file", @"Please drag in a file.", @"OK", nil, nil);
            return NO;
        }
    }
    return YES;
}

- (void)concludeDragOperation:(id<NSDraggingInfo>)sender {
    //re-draw the view with our new data
    [self setNeedsDisplay:YES];
}

@end
