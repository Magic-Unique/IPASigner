//
//  IPASigner+Modify.m
//  IPASigner
//
//  Created by 吴双 on 2020/5/14.
//  Copyright © 2020 Magic-Unique. All rights reserved.
//

#import "IPASigner+Modify.h"

@implementation IPASigner (Modify)

+ (void)__init_modify {
	CLCommand *modify = [[CLCommand mainCommand] defineSubcommand:@"modify"];
	modify.explain = @"Modify IPA informations.";
	[self addGeneralArgumentsToCommand:modify];
	[modify handleProcess:^int(CLCommand * _Nonnull command, CLProcess * _Nonnull process) {
		MUPath *input = [self inputPathFromProcess:process];
		MUPath *output = [self outputPathFromProcess:process];
		
		ISIPASignerOptions *options = [self genSignOptionsFromProcess:process];
		options.provisionForBundle = nil;
		options.identityForProvision = nil;
		options.ignoreSign = YES;
		
		BOOL result = [ISIPASigner sign:input options:options output:output];
		if (result) {
			return EXIT_SUCCESS;
		} else {
			return EXIT_FAILURE;
		}
	}];
}

@end
