//
//  ANNumberToString.h
//  NumberToString
//
//  Created by Alex Nichol on 12/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "ANWAVFile.h"
#import "PlayerReleaseDelegate.h"


@interface ANNumberToString : NSObject {

}

- (NSString *)stringForNumber:(NSNumber *)number;
- (NSString *)stringForSmallNumber:(NSString *)digits3;

@end

@interface NSNumber (ANNumberToString)

- (NSString *)humanReadableString;
- (ANWAVFile *)humanAudioFile;
- (void)speekString;

@end
