//
//  ISShellOtool.m
//  IPASigner
//
//  Created by 冷秋 on 2019/9/17.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import "ISShellOtool.h"
#import <mach-o/loader.h>

NSArray *ISOtoolLibraries(NSString *path) {
	NSString *resultString = ISShellLaunch(nil, IS_BIN_OTOOL, ^(NSMutableArray *arguments) {
		[arguments addObject:@"-L"];
		[arguments addObject:path];
		[arguments addObject:@">"];
		[arguments addObject:@"/Users/wushuang/aaa.txt"];
	});
	NSLog(@"%@", resultString);
	
	NSMutableArray *libraries = [NSMutableArray array];
	
//	NSRegularExpression *dylibRegular = [NSRegularExpression regularExpressionWithPattern:@"(@|/).* \\(compatibility version "
//																				  options:1 error:nil];
//	for (NSTextCheckingResult *result in [dylibRegular matchesInString:resultString options:1 range:NSMakeRange(0, resultString.length)]) {
//		NSString *matched = [resultString substringWithRange:result.range];
//		matched = [matched substringToIndex:matched.length - @" (compatibility version ".length];
//		NSLog(@"添加路径 %@", matched);
//		[libraries addObject:matched];
//	}
	
	return libraries;
}
