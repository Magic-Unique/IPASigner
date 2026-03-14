//
//  ISProvisionManager.m
//  IPASigner
//
//  Created by 冷秋 on 2019/9/17.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import "ISProvisionManager.h"
#import "NSArray+IPASigner.h"

@implementation MUPath (Provision)

+ (instancetype)provisionPath {
	// for Xcode 16 and later
	MUPath *path = [MUPath pathWithString:@"~/Library/Developer/Xcode/UserData/Provisioning Profiles"];
	if (path.isDirectory) {
		return path;
	}
	// for Xcode 15 and before
	return [MUPath pathWithString:@"~/Library/MobileDevice/Provisioning Profiles"];
}

@end

@implementation ISProvisionManager

+ (instancetype)sharedInstance {
	static ISProvisionManager *_shared = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_shared = [[self alloc] init];
	});
	return _shared;
}

@synthesize installedProvisions = _installedProvisions;
- (NSArray<ISProvision *> *)installedProvisions {
	if (!_installedProvisions) {
		NSMutableArray *provisions = [NSMutableArray array];
		NSArray *list = [[MUPath provisionPath] contentsWithFilter:^BOOL(MUPath *content) {
			return content.isFile && [content isA:@"mobileprovision"];
		}];
		for (MUPath *path in list) {
			ISProvision *provision = [ISProvision provisionWithPath:path];
			[provisions addObject:provision];
		}
		_installedProvisions = [provisions copy];
	}
	return _installedProvisions;
}

@synthesize nameMap = _nameMap;
- (NSDictionary<NSString *,ISProvision *> *)nameMap {
	if (!_nameMap) {
		_nameMap = [self.installedProvisions signer_mapWithKeyPath:@"provision.Name" filter:nil choose:^ISProvision *(ISProvision *obj1, ISProvision *obj2) {
			return ISGetNewestProvision(obj1, obj2);
		}];
	}
	return _nameMap;
}

@synthesize bundleIDMap = _bundleIDMap;
- (NSDictionary<NSString *,ISProvision *> *)bundleIDMap {
	if (!_bundleIDMap) {
		_bundleIDMap = [self.installedProvisions signer_mapWithKeyPath:@"provision.bundleIdentifier" filter:nil choose:^ISProvision *(ISProvision *obj1, ISProvision *obj2) {
			return ISGetNewestProvision(obj1, obj2);
		}];
	}
	return _bundleIDMap;
}

@end
