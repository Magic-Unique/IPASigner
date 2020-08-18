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
	merge.explain = @"将砸壳的 app 和完整的 app 进行合并.";
	merge.setQuery(@"from").setAbbr('f').require().setExplain(@"/path/to/*.[ipa|app]").setExplain(@"只含有砸壳了的可执行文件的 .ipa 或者 .app");
	merge.setQuery(@"to").setAbbr('t').require().setExplain(@"/path/to/*.[ipa|app]").setExplain(@"含有完整资源文件的 .ipa 或者 .app");
	merge.setQuery(@"output").setAbbr('o').require().setExplain(@"/path/to/*.[ipa|app]").setExplain(@"输出路径");
	[merge handleProcess:^int(CLCommand * _Nonnull command, CLProcess * _Nonnull process) {
		MUPath *from	= [MUPath pathWithString:process.queries[@"from"]];
		MUPath *to		= [MUPath pathWithString:process.queries[@"to"]];
		MUPath *output	= [MUPath pathWithString:process.queries[@"output"]];
		
		MUPath *temp = [[MUPath tempPath] subpathWithComponent:@(NSDate.date.timeIntervalSince1970).stringValue];
		[temp createDirectoryWithCleanContents:YES];
		
		MUPath *fromTmp = [temp subpathWithComponent:@"from"]; [fromTmp createDirectoryWithCleanContents:YES];
		MUPath *toTmp = [temp subpathWithComponent:@"to"]; [toTmp createDirectoryWithCleanContents:YES];
		
		MUPath *fromPayload = [fromTmp subpathWithComponent:@"Payload"];
		MUPath *toPayload = [toTmp subpathWithComponent:@"Payload"];
		
		if (from.isIPA) {
			if ([SSZipArchive unzipFileAtPath:from.string toDestination:fromTmp.string] == NO) {
				CLError(@"Can not unzip original ipa.");
				return 1;
			}
			
			// 清空 toTmp 里除了 Payload 以外的全部文件
			[fromTmp enumerateContentsUsingBlock:^(MUPath *content, BOOL *stop) {
				if (!content.isPayload) {
					[content remove];
				}
			}];
		}
		else if (from.isApp) {
			[fromPayload createDirectoryWithCleanContents:YES];
			[from copyInto:fromPayload autoCover:YES];
		}
		else {
			CLError(@"The from path is invalid");
			return 1;
		}
		
		if (to.isIPA) {
			if ([SSZipArchive unzipFileAtPath:to.string toDestination:toTmp.string] == NO) {
				CLError(@"Can not unzip original ipa.");
				return 1;
			}
			
			// 清空 toTmp 里除了 Payload 以外的全部文件
			[toTmp enumerateContentsUsingBlock:^(MUPath *content, BOOL *stop) {
				if (!content.isPayload) {
					[content remove];
				}
			}];
		}
		else if (to.isApp) {
			[toPayload createDirectoryWithCleanContents:YES];
			[to copyInto:toPayload autoCover:YES];
		}
		else {
			CLError(@"The to path is invalid.");
			return 1;
		}
		
		
		MUPath *fromApp = fromPayload.payloadAppPath;
		MUPath *toApp = toPayload.payloadAppPath;
		
		if (![fromApp.lastPathComponent isEqualToString:toApp.lastPathComponent]) {
			CLError(@"The apps are not same.");
			return 1;
		}
		
		[fromApp mergeTo:toApp autoCover:YES step:^(MUPath *from, MUPath *to) {
			CLInfo(@"Merge: %@", [from relativeStringToPath:fromApp]);
		}];
		
		if ([output isA:@"app"]) {
			[toApp copyTo:output autoCover:YES];
			CLSuccess(@"Done!");
		}
		else if ([output isA:@"ipa"]) {
			BOOL result = [SSZipArchive createZipFileAtPath:output.string withContentsOfDirectory:toTmp.string];
			if (result) {
				CLSuccess(@"Done!");
				return 0;
			} else {
				CLError(@"Package failed.");
				return 1;
			}
		}
		else {
			CLError(@"The output path is invald.");
			return 1;;
		}
		
		return 0;
	}];
}

@end
