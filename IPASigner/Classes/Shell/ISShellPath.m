//
//  ISShellPath.m
//  IPASigner
//
//  Created by 冷秋 on 2019/9/17.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import "ISShellPath.h"

NSString *ISSelectedXcodePath(void) {
    static NSString *_xcode = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _xcode = CLLaunch(nil, IS_BIN_XCODE_SELECT, @"-p", nil);
		_xcode = [_xcode stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    });
    return _xcode;
}

NSString *ISXcodeBinPath(NSString *toolchain, NSString *bin) {
    NSString *xcode = ISSelectedXcodePath();
    NSString *path = [xcode stringByAppendingPathComponent:@"Toolchains"];
    path = [path stringByAppendingPathComponent:[toolchain stringByAppendingPathExtension:@"xctoolchain"]];
    path = [path stringByAppendingString:bin];
    return path;
}

NSString *ISShellLaunch(NSString *at, NSString *bin, void (^concat)(NSMutableArray *arguments)) {
	NSMutableArray *args = [NSMutableArray array];
	[args addObject:bin];
	concat(args);
	CLVerbose(@"%@", [args componentsJoinedByString:@" "]);
	NSString *result = CLLaunch(at, args, nil);
	if (result) {
		CLPushIndent();
		NSMutableArray *components = [[result componentsSeparatedByString:@"\n"] mutableCopy];
		if ([components.lastObject isEqualToString:@""]) {
			[components removeLastObject];
		}
		[components enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			CLVerbose(@"%@", obj);
		}];
		CLPopIndent();
	}
	return result;
}
