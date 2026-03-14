//
//  NSArray+IPASigner.h
//  IPASigner
//
//  Created by 冷秋 on 2019/9/24.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray<ObjectType> (IPASigner)

- (ObjectType)filter:(BOOL(^)(ObjectType obj))filter choose:(ObjectType(^)(ObjectType obj1, ObjectType obj2))choose;

- (NSArray<ObjectType> *)signer_filte:(BOOL (^)(ObjectType obj))filter;

- (NSDictionary<NSString *, ObjectType> *)signer_mapWithKeyPath:(NSString *)keyPath
														 filter:(BOOL(^)(ObjectType obj))filter
														 choose:(ObjectType (^)(ObjectType, ObjectType))choose;

- (NSDictionary *)signer_mergeWithKeyPath:(NSString *)keyPath sort:(NSComparisonResult (^)(id, id))sortBlock;

@end
