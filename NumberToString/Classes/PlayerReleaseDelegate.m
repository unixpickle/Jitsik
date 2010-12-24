//
//  PlayerReleaseDelegate.m
//  NumberToString
//
//  Created by Alex Nichol on 12/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PlayerReleaseDelegate.h"


@implementation PlayerReleaseDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
	[self autorelease];
	[player autorelease];
}

+ (void)playAudioFile:(NSString *)path {
	PlayerReleaseDelegate * del = [[PlayerReleaseDelegate alloc] init];
	AVAudioPlayer * player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path]
																	error:nil];
	[player setDelegate:del];
	[player play];
}

@end
