//
//  ISIdentity.m
//  IPASigner
//
//  Created by 冷秋 on 2019/9/17.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import "ISIdentity.h"

@implementation ISIdentity

+ (instancetype)identityWithName:(NSString *)name SHA1:(NSString *)SHA1 valid:(BOOL)valid {
	ISIdentity *identity = [[self alloc] init];
	identity->_name = [name copy];
	identity->_SHA1 = [SHA1 copy];
	identity->_valid = valid;
	return identity;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"Identity %@", self.name];
}

@end
