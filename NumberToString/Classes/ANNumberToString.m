//
//  ANNumberToString.m
//  NumberToString
//
//  Created by Alex Nichol on 12/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ANNumberToString.h"


@implementation ANNumberToString

- (NSString *)onesDigitForNumber:(int)digit {
	switch (digit) {
		case 1:
			return @"One";
			break;
		case 2:
			return @"Two";
			break;
		case 3:
			return @"Three";
			break;
		case 4:
			return @"Four";
			break;
		case 5:
			return @"Five";
			break;
		case 6:
			return @"Six";
			break;
		case 7:
			return @"Seven";
			break;
		case 8:
			return @"Eight";
			break;
		case 9:
			return @"Nine";
			break;
		default:
			return @"";
			break;
	}
	return @"";
}

- (NSString *)tensDigitForNumber:(int)digit {
	switch (digit) {
		case 2:
			return @"Twenty";
			break;
		case 3:
			return @"Thirty";
			break;
		case 4:
			return @"Forty";
			break;
		case 5:
			return @"Fifty";
			break;
		case 6:
			return @"Sixty";
			break;
		case 7:
			return @"Seventy";
			break;
		case 8:
			return @"Eighty";
			break;
		case 9:
			return @"Ninety";
			break;
		default:
			return @"";
			break;
	}
	return @"";
}

- (NSString *)tensAndOnesDigits:(NSString *)under100 {
	if ([under100 length] != 2) {
		NSLog(@"Invalid tens and digits!");
		return nil;
	}
	// read through
	if ([under100 hasPrefix:@"1"]) {
		int oneNumber = [[under100 substringWithRange:NSMakeRange(1, 1)] intValue];
		switch (oneNumber) {
			case 0:
				return @"Ten";
				break;
			case 1:
				return @"Eleven";
				break;
			case 2:
				return @"Twelve";
				break;
			case 3:
				return @"Thirteen";
				break;
			case 4:
				return @"Fourteen";
				break;
			case 5:
				return @"Fifteen";
				break;
			case 6:
				return @"Sixteen";
				break;
			case 7:
				return @"Seventeen";
				break;
			case 8:
				return @"Eighteen";
				break;
			case 9:
				return @"Nineteen";
				break;
			default:
				return @"";
				break;
		}
		return @"";
	} else {
		NSString * tensString = [self tensDigitForNumber:[[under100 substringWithRange:NSMakeRange(0, 1)] intValue]];
		NSString * onesDigit = [self onesDigitForNumber:[[under100 substringWithRange:NSMakeRange(1, 1)] intValue]];
		NSString * returnV = @"";
		if ([tensString length] > 0) {
			returnV = tensString;
		}
		if ([onesDigit length] > 0) {
			if ([tensString length] > 0)
				returnV = [tensString stringByAppendingFormat:@" %@", onesDigit];
			else
				returnV = [tensString stringByAppendingFormat:@"%@", onesDigit];
		}
		return returnV;
	}
}

- (NSString *)hundredsDigitForNumber:(int)n {
	NSString * string = [self onesDigitForNumber:n];
	if ([string length] > 0) {
		string = [string stringByAppendingFormat:@" Hundred"];
	}
	return string;
}

- (NSString *)stringForSmallNumber:(NSString *)string3 {
	if ([string3 length] < 3) {
		NSString * newString = string3;
		for (int i = 0; i < 3 - [string3 length]; i++) {
			newString = [@"0" stringByAppendingString:newString];
		}
		return [self stringForSmallNumber:newString];
	}
	NSString * tens = [self tensAndOnesDigits:[string3 substringFromIndex:1]];
	NSString * hundreds = [self hundredsDigitForNumber:[[string3 substringWithRange:NSMakeRange(0, 1)] intValue]];
	if ([tens length] > 0 && [hundreds length] > 0) {
		return [hundreds stringByAppendingFormat:@" and %@", tens];
	} else {
		return tens;
	}
	return hundreds;
}

- (NSString *)degreeString:(int)loopIt {
	switch (loopIt) {
		case 1:
			return @" Thousand";
			break;
		case 2:
			return @" Million";
			break;
		case 3:
			return @" Billion";
			break;
		case 4:
			return @" Trillion";
			break;
		default:
			break;
	}
	return @"";
}

- (NSString *)stringForNumber:(NSNumber *)number {
	if ([number intValue] == 0) {
		return @"Zero";
	}
	NSString * nstring = [NSString stringWithFormat:@"%d", [number intValue]];
	if ([nstring length] <= 3) {
		return [self stringForSmallNumber:nstring];
	}
	// split it
	NSString * currentString = @"";
	NSMutableArray * components = [NSMutableArray array];
	for (int i = [nstring length] - 1; i >= 0; i--) {
		NSString * cstr = [nstring substringWithRange:NSMakeRange(i, 1)];
		currentString = [cstr stringByAppendingString:currentString];
		if ([currentString length] >= 3) {
			[components addObject:currentString];
			currentString = @"";
		}
	}
	if ([currentString length] > 0) {
		[components addObject:currentString];
	}
	NSMutableArray * strs = [NSMutableArray array];
	int lastIndex = 0;
	for (int i = 0; i < [components count]; i++) {
		NSString * string = [self stringForSmallNumber:[components objectAtIndex:i]];
		// get degree
		NSString * mstr = @"";
		if ([string length] > 0) {
			NSString * degree = [self degreeString:i];
			mstr = [NSString stringWithFormat:@"%@%@", string, degree];
		}
		NSDictionary * strDict = [NSDictionary dictionaryWithObjectsAndKeys:mstr, @"human",
								  [components objectAtIndex:i], @"number", nil];
		[strs insertObject:strDict atIndex:0];
	}
	for (int i = 0; i < [strs count]; i++) {
		NSDictionary * dict = [strs objectAtIndex:i];
		NSString * human = [dict objectForKey:@"human"];
		if ([human length] > 0) {
			lastIndex = i;
		}
	}
	NSMutableString * finalString = [NSMutableString string];
	for (int i = 0; i < [strs count]; i++) {
		[finalString appendFormat:@"%@", [[strs objectAtIndex:i] objectForKey:@"human"]];
		if (i + 1 < [strs count]) {
			if ([[[strs objectAtIndex:i+1] objectForKey:@"human"] length] > 1) {
				if (i + 1 == lastIndex) {
					// check the length
					NSString * numberString = [[strs objectAtIndex:i+1] objectForKey:@"number"];
					if ([numberString hasPrefix:@"0"])
						[finalString appendFormat:@" and "];
					else [finalString appendFormat:@", "];
				} else {
					[finalString appendFormat:@", "];
				}
			}
				
		}
	}
	return finalString;
}

@end

@implementation NSNumber (ANNumberToString)

- (NSString *)humanReadableString {
	NSString * result = nil;
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	ANNumberToString * nts = [[ANNumberToString alloc] init];
	result = [[NSString alloc] initWithString:[nts stringForNumber:self]];
	[nts release];
	[pool drain];
	return [result autorelease];
}

@end

