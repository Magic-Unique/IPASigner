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

- (id)signer_first:(BOOL (^)(id))filter {
	for (id obj in self) {
		if (filter(obj)) {
			return obj;
		}
	}
	return nil;
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

- (NSDictionary *)signer_mapWithKey:(NSString *(^)(id))keyBlock choose:(id (^)(id, id))choose {
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	for (id obj in self) {
		NSString *key = keyBlock(obj);
		if (result[key]) {
			result[key] = choose(result[key], obj);
		} else {
			result[key] = obj;
		}
	}
	return [result copy];
}

@end
