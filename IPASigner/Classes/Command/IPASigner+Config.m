//
//  IPASigner+Config.m
//  IPASigner
//
//  Created by 吴双 on 2020/5/16.
//  Copyright © 2020 Magic-Unique. All rights reserved.
//

#import "IPASigner+Config.h"

@implementation IPASigner (Config)

+ (void)__init_config {
	CLCommand *config = [[CLCommand mainCommand] defineSubcommand:@"config"];
	config.explain = @"Configuration settings";
	
	NSArray<NSString *> *keys = IS_CONFIG_ALL_KEYS;
	
	CLCommand *set = [config defineSubcommand:@"set"];
	set.explain = @"Set configuration";
	
	CLCommand *get = [config defineSubcommand:@"get"];
	get.explain = @"Get configuration";
	
	for (NSString *key in keys) {
		CLCommand *setter = [set defineSubcommand:key];
		setter.explain = [NSString stringWithFormat:@"Set the `%@` value", key];
		setter.addRequirePath(@"value").setExample(@"VALUE").setExplain(@"New value");
		[setter handleProcess:^int(CLCommand * _Nonnull command, CLProcess * _Nonnull process) {
			NSString *value = process.paths.firstObject;
			if (value.length) {
				[NSUserDefaults standardUserDefaults][key] = value;
			} else {
				[NSUserDefaults standardUserDefaults][key] = nil;
			}
			return 0;
		}];
		
		CLCommand *getter = [get defineSubcommand:key];
		getter.explain = [NSString stringWithFormat:@"Get the `%@` value", key];
		[getter handleProcess:^int(CLCommand * _Nonnull command, CLProcess * _Nonnull process) {
			id value = [NSUserDefaults standardUserDefaults][key];
			CLInfo(@"%@", value?:@"<null>");
			return 0;
		}];
	}
	
	CLCommand *list = [config defineSubcommand:@"list"];
	list.explain = @"Show all configurations";
	[list handleProcess:^int(CLCommand * _Nonnull command, CLProcess * _Nonnull process) {
		NSUserDefaults *storage = [NSUserDefaults standardUserDefaults];
		for (NSString *key in IS_CONFIG_ALL_KEYS) {
			NSString *value = storage[key];
			CLInfo(@"%@ = %@", key, value ?: @"<null>");
		}
		return 0;
	}];
}

@end
