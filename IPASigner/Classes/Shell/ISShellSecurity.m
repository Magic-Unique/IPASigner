//
//  ISShellSecurity.m
//  IPASigner
//
//  Created by 冷秋 on 2019/9/17.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import "ISShellSecurity.h"


ISSecurityPolicy ISSecurityCodesigningPolicy = @"codesigning";


static NSString *_ISRemoveStringPrefixAndSuffix(NSString *string, NSUInteger prefixLength, NSUInteger suffixLength) {
	if (prefixLength > 0 && string.length >= prefixLength) {
		string = [string substringFromIndex:prefixLength];
	}
	if (suffixLength > 0 && string.length >= suffixLength) {
		string = [string substringToIndex:string.length - suffixLength];
	}
	return string;
}

NSArray *ISSecurityFindIdentity(ISSecurityPolicy policy, BOOL valid) {
	NSString *result = ISShellLaunch(nil, IS_BIN_SECURITY, ^(NSMutableArray *arguments) {
		[arguments addObject:@"find-identity"];
		if (valid) {
			[arguments addObject:@"-v"];
		}
		if (policy) {
			[arguments addObject:@"-p"];
			[arguments addObject:policy];
		}
	});
	NSRegularExpression *SHA1RegularExpression = [NSRegularExpression regularExpressionWithPattern:@" [0-9A-F]{40} " options:NSRegularExpressionCaseInsensitive error:nil];
	NSRegularExpression *nameRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"\".*\"$" options:NSRegularExpressionCaseInsensitive error:nil];
	NSArray *lines = [result componentsSeparatedByString:@"\n"];
	NSMutableDictionary *identies = [NSMutableDictionary dictionary];
	NSMutableDictionary *validIdentities = [NSMutableDictionary dictionary];
	NSMutableDictionary *currentIdentities = valid ? validIdentities : identies;
	for (NSUInteger i = 0; i < lines.count; i++) {
		NSString *line = lines[i];
		if ([line containsString:@"Matching identities"]) {
			currentIdentities = identies;
			continue;
		}
		else if ([line containsString:@"Valid identities only"]) {
			currentIdentities = validIdentities;
			continue;
		}
		NSTextCheckingResult *sha1Result = [SHA1RegularExpression firstMatchInString:line options:kNilOptions range:NSMakeRange(0, line.length)];
		NSTextCheckingResult *nameResult = [nameRegularExpression firstMatchInString:line options:kNilOptions range:NSMakeRange(0, line.length)];
		if (sha1Result && nameResult) {
			NSString *sha1 = _ISRemoveStringPrefixAndSuffix([line substringWithRange:sha1Result.range], 1, 1);
			NSString *name = _ISRemoveStringPrefixAndSuffix([line substringWithRange:nameResult.range], 1, 1);
			currentIdentities[sha1] = name;
		}
	}
	NSMutableArray *list = [NSMutableArray array];
	for (NSString *sha1 in identies.allKeys) {
		NSMutableDictionary *item = [NSMutableDictionary dictionary];
		item[@"name"] = identies[sha1];
		item[@"SHA1"] = sha1;
		item[@"valid"] = @NO;
		[list addObject:item];
	}
	for (NSString *sha1 in validIdentities.allKeys) {
		NSMutableDictionary *item = [NSMutableDictionary dictionary];
		item[@"name"] = validIdentities[sha1];
		item[@"SHA1"] = sha1;
		item[@"valid"] = @YES;
		[list addObject:item];
	}
	return [list copy];
}
