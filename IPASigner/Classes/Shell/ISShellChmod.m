//
//  ISShellChmod.m
//  IPASigner
//
//  Created by 冷秋 on 2019/11/14.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import "ISShellChmod.h"

void ISChmod(NSString *path, NSUInteger mode) {
	NSString *result = ISShellLaunch(nil, IS_BIN_CHMOD, ^(NSMutableArray *arguments) {
		[arguments addObject:@(mode).stringValue];
		[arguments addObject:path];
	});
	NSLog(@"%@", result);
}
