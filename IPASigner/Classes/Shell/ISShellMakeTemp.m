//
//  ISShellMakeTemp.m
//  IPASigner
//
//  Created by 冷秋 on 2019/9/17.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import "ISShellMakeTemp.h"

MUPath *ISMakeTemp(BOOL directory, NSString *prefix) {
	NSString *path = ISShellLaunch(nil, IS_BIN_MKTEMP, ^(NSMutableArray *arguments) {
		if (directory) {
			[arguments addObject:@"-d"];
		}
		if (prefix) {
			[arguments addObject:@"-t"];
			[arguments addObject:prefix];
		}
	});
	if (path) {
		path = [path stringByReplacingOccurrencesOfString:@"\n" withString:@""];
		return [MUPath pathWithString:path];
	} else {
		return nil;
	}
}
