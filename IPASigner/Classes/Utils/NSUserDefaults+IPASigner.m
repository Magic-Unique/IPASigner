//
//  NSUserDefaults+IPASigner.m
//  IPASigner
//
//  Created by 吴双 on 2020/5/16.
//  Copyright © 2020 Magic-Unique. All rights reserved.
//

#import "NSUserDefaults+IPASigner.h"

@implementation NSUserDefaults (IPASigner)


- (void)setObject:(NSString *)obj forKeyedSubscript:(NSString *)key {
	if (obj) {
		[self setObject:obj forKey:key];
	} else {
		[self removeObjectForKey:key];
	}
}

- (id)objectForKeyedSubscript:(NSString *)key {
	return [self stringForKey:key];
}

@end
