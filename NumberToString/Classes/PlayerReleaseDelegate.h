//
//  PlayerReleaseDelegate.h
//  NumberToString
//
//  Created by Alex Nichol on 12/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface PlayerReleaseDelegate : NSObject <AVAudioPlayerDelegate> {

}
+ (void)playAudioFile:(NSString *)path;
@end
