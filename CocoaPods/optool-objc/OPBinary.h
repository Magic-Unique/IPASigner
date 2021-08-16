//
//  OPBinary.h
//  optool
//
//  Created by Magic-Unique on 2021/2/26.
//

#import <Foundation/Foundation.h>

@interface OPBinary : NSObject

@property (nonatomic, copy, readonly) NSString *path;

@property (nonatomic, strong, readonly) NSMutableData *contents;

+ (instancetype)binaryWithPath:(NSString *)path;

- (BOOL)readIfNeed;
- (BOOL)read;

- (BOOL)save;
- (BOOL)save:(NSString *)path;

@end


@interface OPBinary (Operation)

- (BOOL)install:(NSString *)path;

- (BOOL)uninstall:(NSString *)path;

@end
