//
//  ANWAVFile.m
//  ANAVI
//
//  Created by Alex Nichol on 5/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ANWAVFile.h"


@implementation ANWAVFile

@synthesize wFormatTag;
@synthesize nChannels;
@synthesize nBlockAlign;
@synthesize wBitsPerSample;
@synthesize nSamplesPerSec;
@synthesize nAvgBytesPerSec;
@synthesize samples;

- (NSData *)dataWithASCII:(NSString *)str {
	return [str dataUsingEncoding:NSASCIIStringEncoding];
}
- (NSData *)dataWithInt:(int)i {
	return [NSData dataWithBytes:(const char *)(&i) length:4];
}
- (NSData *)dataWithShort:(short)i {
	return [NSData dataWithBytes:(const char *)(&i) length:2];
}

- (void)addSecond {
	char * c = (char *)malloc(nSamplesPerSec);
	for (int i = 0; i < nSamplesPerSec; i++) {
		c[i] = (char)(0);
	}
	[samples appendBytes:c length:nSamplesPerSec];
	free(c);
}

- (NSData *)wavData {
	NSMutableData * retData = [[NSMutableData alloc] init];
	[retData appendData:[self dataWithASCII:@"RIFF"]];
	[retData appendData:[self dataWithInt:([samples length] + 44)]];
	[retData appendData:[self dataWithASCII:@"WAVE"]];
	[retData appendData:[self dataWithASCII:@"fmt "]];
	[retData appendData:[self dataWithInt:16]];
	[retData appendData:[self dataWithShort:wFormatTag]];
	[retData appendData:[self dataWithShort:nChannels]];
	[retData appendData:[self dataWithInt:nSamplesPerSec]];
	[retData appendData:[self dataWithInt:nAvgBytesPerSec]];
	[retData appendData:[self dataWithShort:nBlockAlign]];
	[retData appendData:[self dataWithShort:wBitsPerSample]];
	[retData appendData:[self dataWithASCII:@"data"]];
	[retData appendData:[self dataWithInt:[samples length]]];
	[retData appendData:samples];
	return [NSData dataWithData:[retData autorelease]];
}

- (void)appendWAV:(ANWAVFile *)wav {
	NSAssert([wav nSamplesPerSec] == [self nSamplesPerSec], @"Invalid samples per second.");
	NSAssert([wav nChannels] == [self nChannels], @"Invalid number of channels");
	NSAssert([wav wBitsPerSample] == [self wBitsPerSample], @"Invalid bits per sample.");
	NSAssert([wav wFormatTag] == [self wFormatTag], @"Invalid format tag.");
	[samples appendData:[wav samples]];
}

- (short int)nextShort:(NSFileHandle *)readableFile {
	NSData * d = [readableFile readDataOfLength:2];
	return ((const short int *)[d bytes])[0];
}
- (int)nextInt:(NSFileHandle *)readableFile {
	NSData * d = [readableFile readDataOfLength:4];
	return ((const int *)[d bytes])[0];
}
- (NSString *)nextFourBytes:(NSFileHandle *)readableFile {
	return [[[NSString alloc] initWithData:[readableFile readDataOfLength:4] encoding:NSASCIIStringEncoding] autorelease];
}
- (void)loadFromFile:(NSString *)fileName {
	NSFileHandle * handle = [NSFileHandle fileHandleForReadingAtPath:fileName];
	[handle readDataOfLength:16]; // read through the headers
	int fmtlen = [self nextInt:handle];
	if (fmtlen != 16) {
		NSLog(@"ERROR, invalid format length");
		return;
	}
	wFormatTag = [self nextShort:handle];
	nChannels = [self nextShort:handle];
	if (wFormatTag != 1) {
		NSLog(@"Unsupported format: %d", wFormatTag);
		return;
	} else if (nChannels /*!= 1*/ > 2) {
		NSLog(@"Only support mono or sterio audio not %d", nChannels);
		return;
	}
	nSamplesPerSec = [self nextInt:handle];
	nAvgBytesPerSec = [self nextInt:handle];
	nBlockAlign = [self nextShort:handle];
	wBitsPerSample = [self nextShort:handle];
	chunkID = [handle readDataOfLength:4];
	//[self nextFourBytes:handle]; // chunk ID
	int size = [self nextInt:handle];
	samples = [[NSMutableData alloc] initWithData:[handle readDataOfLength:size]];
	[handle closeFile];
	/*NSLog(@"Samples per Second: %d\n\
		  nAvgBytesPerSec: %d\n\
		  nBlockAlign: %d\n\
		  wBitsPerSample: %d\n", 
		  nSamplesPerSec, nAvgBytesPerSec,
		  nBlockAlign, wBitsPerSample);	*/
	
}

- (NSData *)dataForNumberSamples:(int)nsamples {
	int dar = nsamples * nBlockAlign;
	return [NSData dataWithBytes:[samples bytes] length:dar];
}

- (int)numberOfSamples:(float)duration {
	int nsamples = [samples length] / nBlockAlign;
	if (nsamples / nSamplesPerSec < duration) {
		return nsamples;
	}
	nsamples = (int)((float)duration * (float)nSamplesPerSec);
	return nsamples;
}

- (void)dealloc {
	[samples release];
	[super dealloc];
}
@end
