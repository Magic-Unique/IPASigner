//
//  NSArray+IPASigner.m
//  IPASigner
//
//  Created by 冷秋 on 2019/9/24.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import "NSArray+IPASigner.h"

@implementation NSArray (IPASigner)

- (id)filter:(BOOL (^)(id))filter choose:(id (^)(id, id))choose {
	id result = nil;
	for (id obj in self) {
		if (filter(obj)) {
			if (result) {
				result = choose(result, obj);
			} else {
				result = obj;
			}
		}
	}
	return result;
}

- (NSArray *)signer_filte:(BOOL (^)(id))filter {
	NSMutableArray *list = [NSMutableArray array];
	for (id obj in self) {
		if (filter(obj)) {
			[list addObject:obj];
		}
	}
	return [list copy];
}

- (NSDictionary *)signer_mapWithKeyPath:(NSString *)keyPath
								 filter:(BOOL(^)(id))filter
								 choose:(id (^)(id, id))choose {
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	for (id obj in self) {
		if (filter && !filter(obj)) {
			continue;
		}
		NSString *key = [obj valueForKeyPath:keyPath];
		if (result[key]) {
			result[key] = choose(result[key], obj);
		} else {
			result[key] = obj;
		}
	}
	return [result copy];
}

- (NSDictionary *)signer_mergeWithKeyPath:(NSString *)keyPath sort:(NSComparisonResult (^)(id, id))sortBlock {
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	__auto_type GetArray = ^NSMutableArray *(NSString *key) {
		NSMutableArray *list = result[key];
		if (!list) {
			list = [NSMutableArray array];
			result[key] = list;
		}
		return list;
	};
	for (id obj in self) {
		NSString *key = [obj valueForKeyPath:keyPath];
		NSMutableArray *list = GetArray(key);
		[list addObject:obj];
	}
	[result enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSMutableArray *obj, BOOL * _Nonnull stop) {
		[obj sortUsingComparator:sortBlock];
	}];
	return result;
}

@end
