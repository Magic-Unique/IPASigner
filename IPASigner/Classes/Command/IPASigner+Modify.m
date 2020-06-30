//
//  IPASigner+Modify.m
//  IPASigner
//
//  Created by 吴双 on 2020/5/14.
//  Copyright © 2020 Magic-Unique. All rights reserved.
//

#import "IPASigner+Modify.h"
#import "MUPath+IPA.h"

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
		options.entitlementsForBundle = nil;
		options.ignoreSign = YES;
		
		BOOL result = [ISIPASigner sign:input options:options output:output];
		if (result) {
			return EXIT_SUCCESS;
		} else {
			return EXIT_FAILURE;
		}
	}];
	
	CLCommand *merge = [[CLCommand mainCommand] defineSubcommand:@"merge"];
	merge.explain = @"Merge an ipa into another ipa.";
	merge.setQuery(@"from").setAbbr('f').require().setExplain(@"/path/to/*.ipa").setExplain(@"Original ipa");
	merge.setQuery(@"to").setAbbr('t').require().setExplain(@"/path/to/*.ipa").setExplain(@"Target ipa");
	merge.setQuery(@"output").setAbbr('o').require().setExplain(@"/path/to/*.ipa").setExplain(@"Output ipa");
	[merge handleProcess:^int(CLCommand * _Nonnull command, CLProcess * _Nonnull process) {
		MUPath *from = [MUPath pathWithString:process.queries[@"from"]];
		MUPath *to = [MUPath pathWithString:process.queries[@"to"]];
		MUPath *output = [MUPath pathWithString:process.queries[@"output"]];
		
		if (!from.isFile) {
			CLError(@"The original ipa is not exist.");
			return 1;
		}
		
		if (!to.isFile) {
			CLError(@"The target ipa is not exist.");
			return 1;
		}
		
		MUPath *temp = [[MUPath tempPath] subpathWithComponent:@(NSDate.date.timeIntervalSince1970).stringValue];
		[temp createDirectoryWithCleanContents:YES];
		
		MUPath *fromTmp = [temp subpathWithComponent:@"from"]; [fromTmp createDirectoryWithCleanContents:YES];
		MUPath *toTmp = [temp subpathWithComponent:@"to"]; [toTmp createDirectoryWithCleanContents:YES];
		
		if ([SSZipArchive unzipFileAtPath:from.string toDestination:fromTmp.string] == NO) {
			CLError(@"Can not unzip original ipa.");
			return 1;
		}
		
		if ([SSZipArchive unzipFileAtPath:to.string toDestination:toTmp.string] == NO) {
			CLError(@"Can not unzip original ipa.");
			return 1;
		}
		
		MUPath *fromPayload = [fromTmp subpathWithComponent:@"Payload"];
		MUPath *toPayload = [toTmp subpathWithComponent:@"Payload"];
		
		MUPath *fromApp = fromPayload.payloadAppPath;
		MUPath *toApp = toPayload.payloadAppPath;
		if (![fromApp.lastPathComponent isEqualToString:toApp.lastPathComponent]) {
			CLError(@"The apps are not same.");
			return 1;
		}
		
		return 0;
	}];
}

@end
