//
//  ISEntitlements.m
//  IPASigner
//
//  Created by 冷秋 on 2019/10/17.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import "ISEntitlements.h"
#import "ISShellMakeTemp.h"

@interface ISEntitlements ()

@property (nonatomic, assign) BOOL isTempFile;

@end

@implementation ISEntitlements

- (instancetype)initWithPath:(MUPath *)path entitlements:(NSDictionary *)entitlements {
    self = [super init];
    if (self) {
        _path = path;
        _entitlements = entitlements;
    }
    return self;
}

+ (instancetype)entitlementsWithPath:(MUPath *)path {
    NSDictionary *entitlements = [NSDictionary dictionaryWithContentsOfFile:path.string];
    return [[self alloc] initWithPath:path entitlements:entitlements];
}

+ (instancetype)entitlementsWithEntitlements:(NSDictionary *)entitlements {
	MUPath *temp = ISMakeTemp(YES, nil);
	MUPath *filePath = [temp subpathWithComponent:@"temp.entitlements"];
	[entitlements writeToFile:filePath.string atomically:YES];
	ISEntitlements *_entitlements = [[ISEntitlements alloc] initWithPath:filePath entitlements:entitlements];
	_entitlements.isTempFile = YES;
	return _entitlements;
}

- (void)dealloc {
	if (_isTempFile) {
		[self.path.superpath remove];
	}
}

@end
