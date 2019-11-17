//
//  ISShellCodesign.m
//  IPASigner
//
//  Created by 冷秋 on 2019/9/17.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import "ISShellCodesign.h"

BOOL ISCodesign(NSString *identity, BOOL force, BOOL verify, NSString *entitlements, NSString *path) {
    BOOL verbose = [[CLProcess currentProcess] flag:@"verbose"];
	NSString *result = ISShellLaunch(nil, IS_BIN_CODESIGN, ^(NSMutableArray *arguments) {
		if (verify) {
			[arguments addObject:@"--verify"];
		}
		if (verbose) {
			[arguments addObject:@"--verbose"];
		}
		if (force) {
			[arguments addObject:@"--force"];
		}
		if (identity) {
			[arguments addObject:@"--sign"];
			[arguments addObject:identity];
		}
		if (entitlements) {
			[arguments addObject:@"--entitlements"];
			[arguments addObject:entitlements];
		}
		
		[arguments addObject:path];
	});
    if (result) {
        return YES;
    } else {
        return NO;
    }
}

NSDictionary *ISCodesignDisplayEntitlements(NSString *path) {
	NSArray *arguments = @[@"-d", @"--entitlements", @"-", path];
	NSTask *task = [[NSTask alloc] init];
	task.launchPath = IS_BIN_CODESIGN;
	task.arguments = arguments;
	NSPipe *pipe = [NSPipe pipe];
	task.standardOutput = pipe;
	task.standardError = pipe;
	[task launch];
	[task waitUntilExit];
	NSData *data = pipe.fileHandleForReading.availableData;
	NSData *prefix = [@"<plist" dataUsingEncoding:NSUTF8StringEncoding];
	NSData *suffix = [@"</plist>" dataUsingEncoding:NSUTF8StringEncoding];
	NSRange prefixRange = [data rangeOfData:prefix options:kNilOptions range:NSMakeRange(0, data.length)];
	NSRange suffixRange = [data rangeOfData:suffix options:kNilOptions range:NSMakeRange(0, data.length)];
	if (prefixRange.length == 0 || suffixRange.length == 0) {
		return nil;
	}
	NSRange range;
	range.location = prefixRange.location;
	range.length = suffixRange.location + suffixRange.length - range.location;
	data = [data subdataWithRange:range];
	
	NSError *error = nil;
	NSDictionary *JSON = [NSPropertyListSerialization propertyListWithData:data options:0 format:nil error:&error];
	return JSON;
}
