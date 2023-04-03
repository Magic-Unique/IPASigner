//
//  ISAuthManager.m
//  IPASigner
//
//  Created by 吴双 on 2023/2/9.
//  Copyright © 2023 Magic-Unique. All rights reserved.
//

#import "ISAuthManager.h"

@interface ISAuthManager ()

@property (nonatomic, strong, readonly) NSMutableDictionary *mNames;

@end



//@property (nonatomic, strong) NSString *appleID;
//@property (nonatomic, strong) NSString *accountName;
//
//@property (nonatomic, strong) NSString *teamName;
//@property (nonatomic, strong) NSString *teamIdentifier;
//
//@property (nonatomic, strong) NSString *alias;

@implementation ISAuthName

- (void)saveTo:(MUPath *)path {
	NSMutableDictionary *json = [NSMutableDictionary dictionary];
	json[@"appleID"] = self.appleID;
	json[@"accountName"] = self.accountName;
	json[@"teamName"] = self.teamName;
	json[@"teamIdentifier"] = self.teamIdentifier;
	json[@"alias"] = self.alias;
	[json writeToFile:path.string atomically:YES];
}

+ (instancetype)nameWithFile:(MUPath *)path {
	NSDictionary *json = [NSDictionary dictionaryWithContentsOfFile:path.string];
	ISAuthName *name = [[self alloc] init];
	name.appleID = json[@"appleID"];
	name.accountName = json[@"accountName"];
	name.teamName = json[@"teamName"];
	name.teamIdentifier = json[@"teamIdentifier"];
	name.alias = json[@"alias"];
	return name;
}

@end



@implementation ISAuthManager

- (instancetype)init {
	self = [super init];
	if (self) {
		_mNames = [NSMutableDictionary dictionary];
		MUPath *path = [MUPath pathWithString:@"~/.ipasigner/auth"];
		for (MUPath *item in path.contents) {
			ISAuthName *name = [ISAuthName nameWithFile:item];
			self.mNames[name.alias] = name;
		}
	}
	return self;
}

- (void)__saveData:(ISAuthName *)name {
	MUPath *path = [MUPath pathWithString:@"~/.ipasigner/auth"];
	if (self.mNames[name.alias]) {
		[path createDirectoryWithCleanContents:NO];
		path = [path subpathWithComponent:name.alias];
		[name saveTo:path];
	} else {
		[[path subpathWithComponent:name.alias] remove];
	}
}

- (void)logout:(NSString *)appleID {
	NSArray *keys = self.mNames.allKeys;
	[keys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		ISAuthName *name = self.mNames[obj];
		if ([name.appleID isEqualToString:appleID]) {
			self.mNames[obj] = nil;
			[self __saveData:name];
		}
	}];
}

- (NSError *)add:(ISAuthName *)name {
	if (self.mNames[name.alias]) {
		NSError *error = [NSError errorWithDomain:@"ISAuthManager" code:__LINE__ userInfo:@{
			NSLocalizedDescriptionKey: @"The alias has exist",
		}];
		return error;
	}
	self.mNames[name.alias] = name;
	[self __saveData:name];
	return nil;
}

- (NSError *)remove:(ISAuthName *)name {
	if (!self.mNames[name.alias]) {
		NSError *error = [NSError errorWithDomain:@"ISAuthManager" code:__LINE__ userInfo:@{
			NSLocalizedDescriptionKey: @"The alias was not found",
		}];
		return error;
	}
	self.mNames[name.alias] = nil;
	[self __saveData:name];
	return nil;
}

- (NSArray<ISAuthName *> *)names {
	return self.mNames.allValues;
}

@end
