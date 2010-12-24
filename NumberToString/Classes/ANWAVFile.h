//
//  ANWAVFile.h
//  ANAVI
//
//  Created by Alex Nichol on 5/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ANWAVFile : NSObject {
	short int wFormatTag;
	short int nChannels;
	int nSamplesPerSec, nAvgBytesPerSec;
	short int nBlockAlign;
	short int wBitsPerSample;
	NSMutableData * samples;
	NSData * chunkID;
}
- (void)addSecond;
- (NSData *)wavData;
- (void)appendWAV:(ANWAVFile *)wav;
- (int)numberOfSamples:(float)duration;
@property (readwrite) short int wFormatTag;
@property (readwrite) short int nChannels;
@property (readwrite) short int nBlockAlign;
@property (readwrite) short int wBitsPerSample;
@property (readwrite) int nSamplesPerSec;
@property (readwrite) int nAvgBytesPerSec;
@property (nonatomic, readonly) NSMutableData * samples;
- (short int)nextShort:(NSFileHandle *)readableFile;
- (int)nextInt:(NSFileHandle *)readableFile;
- (NSString *)nextFourBytes:(NSFileHandle *)readableFile;
- (void)loadFromFile:(NSString *)fileName;
- (NSData *)dataForNumberSamples:(int)nsamples;
@end
