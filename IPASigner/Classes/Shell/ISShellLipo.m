//
//  ISShellLipo.m
//  IPASigner
//
//  Created by 吴双 on 2021/7/14.
//  Copyright © 2021 Magic-Unique. All rights reserved.
//

#import "ISShellLipo.h"

BOOL ISLipoThin(NSString *binary, NSString *platform, NSString *output) {
	NSString *result = ISShellLaunch(nil, IS_BIN_LIPO, ^(NSMutableArray *arguments) {
		[arguments addObject:binary];
		[arguments addObject:@"-thin"];
		[arguments addObject:platform];
		[arguments addObject:@"-output"];
		[arguments addObject:output];
	});
	if (result) {
		return YES;
	} else {
		return NO;
	}
}

NSArray<NSString *> *ISLipoArchs(NSString *binary) {
	NSString *result = ISShellLaunch(nil, IS_BIN_LIPO, ^(NSMutableArray *arguments) {
		[arguments addObject:binary];
		[arguments addObject:@"-archs"];
	});
	if (result) {
		NSString *trim = [result stringByReplacingOccurrencesOfString:@"\n" withString:@""];
		NSArray *list = [trim componentsSeparatedByString:@" "];
		if (list.count > 5) {
			return nil;
		}
		return list;
	} else {
		return nil;
	}
}
