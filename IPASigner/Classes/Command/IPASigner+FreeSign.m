//
//  IPASigner+FreeSign.m
//  IPASigner
//
//  Created by 吴双 on 2023/2/9.
//  Copyright © 2023 Magic-Unique. All rights reserved.
//

#import "IPASigner+FreeSign.h"
#import <AppleSession/AppleSession.h>
#import <AltSign/AltSign.h>
#import "ISAuthManager.h"

#define ALT_PLUGIN_VERSION_URL @"https://cdn.altstore.io/file/altstore/altserver/altplugin/altplugin.json"

@implementation IPASigner (FreeSign)

+ (void)__init_free {
	CLCommand *free = [[CLCommand mainCommand] defineSubcommand:@"free"];
	free.explain = @"Sign with free developer (Needs Apple ID).";
}

+ (void)__init_init {
	CLCommand *free = [[CLCommand mainCommand] defineSubcommand:@"free"];
	
	CLCommand *install = [free defineSubcommand:@"init"];
	install.explain = @"Init environment in this device (Needs root user)";
	[install handleProcess:^int(CLCommand * _Nonnull command, CLProcess * _Nonnull process) {
		NSString *USERNAME = NSUserName();
		if (![USERNAME isEqualToString:@"root"]) {
			CLError(@"This command need root permission. You can use `sudo ipasigner free init`");
			return EXIT_FAILURE;
		}
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			MUPath *pluginPath = [MUPath pathWithString:@"/Library/Mail/Bundles/AltPlugin.mailbundle"];
			MUPath *downloadPath = [[MUPath tempPath] subpathWithComponent:@"AltPlugin.mailbundle.zip"];
			NSMutableDictionary *versionInfo = [NSMutableDictionary dictionary];
			
			__auto_type fetchVersionInfo = ^{
				@autoreleasepool {
					CLInfo(@"Fetching current AltPlugin info in altstore.io");
					NSData *versionData = [NSData dataWithContentsOfURL:[NSURL URLWithString:ALT_PLUGIN_VERSION_URL]];
					if (!versionData.length) {
						CLError(@"Can not fetch AltPlugin info");
						return NO;
					}
					NSDictionary *version = [NSJSONSerialization JSONObjectWithData:versionData options:kNilOptions error:nil];
					NSDictionary *pluginVersion = version[@"pluginVersion"];
					[versionInfo addEntriesFromDictionary:pluginVersion];
					return YES;
				}
			};
			
			__auto_type download = ^{
				@autoreleasepool {
					NSString *url = versionInfo[@"url"];
					if (!url.length) {
						return NO;
					}
					NSURL *URL = [NSURL URLWithString:url];
					NSData *zipData = [NSData dataWithContentsOfURL:URL];
					if (!zipData.length) {
						return NO;
					}
					if (![zipData writeToFile:downloadPath.string atomically:YES]) {
						return NO;
					}
					return YES;
				}
			};
			
			__auto_type install = ^{
				@autoreleasepool {
					if (!pluginPath.isDirectory) {
						if (!CLLaunch(nil, @"/usr/bin/unzip", @"-d", pluginPath.superpath.string, @"-q", downloadPath.string, nil)) {
						}
					}
				}
				return YES;
			};
			
			
			if (!pluginPath.isDirectory) {
				if (!fetchVersionInfo()) {
					
				}
				if (!download()) {
					
				}
				
				if (!install()) {
					
				}
			}
			else {
				CLInfo(@"The AltPlugin has installed on this Mac.");
				CLInfo(@"Checking AltPlugin update...");
				MUPath *infoPath = [pluginPath subpathWithComponent:@"Contents/Info.plist"];
				NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:infoPath.string];
				NSString *currentVersion = info[@"CFBundleShortVersionString"];
				if (!fetchVersionInfo()) {
					// Fetch failed
					CLWarning(@"Use local version %@", currentVersion);
				} else {
					NSString *remoteVersion = versionInfo[@"version"];
					if (!remoteVersion || ![remoteVersion isEqualToString:currentVersion]) {
						// Newest
						CLInfo(@"The AltPlugin is newest.");
					} else {
						// Needs Update
						CLInfo(@"The AltPlugin has new version, try to update...");
						if (!download()) {
							CLWarning(@"Update failed, use current version.");
						}
						if (!install()) {
							CLWarning(@"Update failed, use current version.");
						}
					}
				}
			}
			
			CLSuccess(@"The mail plugin has installed.");
			exit(EXIT_SUCCESS);
		});
		[[NSRunLoop currentRunLoop] run];
		return EXIT_SUCCESS;
	}];
}

+ (void)__init_list {
	CLCommand *free = [[CLCommand mainCommand] defineSubcommand:@"free"];
	
	CLCommand *list = [free defineSubcommand:@"list"];
	list.explain = @"List all alises.";
	[list handleProcess:^int(CLCommand * _Nonnull command, CLProcess * _Nonnull process) {
		ISAuthManager *authMgr = [[ISAuthManager alloc] init];
		[authMgr.names enumerateObjectsUsingBlock:^(ISAuthName * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			CLInfo(@"%@. %@: %@ (%@)", @(idx+1), obj.alias, obj.teamName, obj.appleID);
		}];
		return EXIT_SUCCESS;
	}];
}

+ (void)__init_login {
	CLCommand *free = [[CLCommand mainCommand] defineSubcommand:@"free"];
	
	CLCommand *login = [free defineSubcommand:@"login"];
	login.explain = @"Login Apple ID and create alias for sign.";
	login.setQuery(@"account").setAbbr('i').setExplain(@"The AppleID");
	login.setQuery(@"password").setAbbr('p').setExplain(@"The AppleID password");
	login.setQuery(@"alias").setAbbr('a').setExplain(@"The account alias for sign");
	[login handleProcess:^int(CLCommand * _Nonnull command, CLProcess * _Nonnull process) {
		NSString *ACCOUNT = process.queries[@"account"];
		NSString *PASSWORD = process.queries[@"password"];
		NSString *ALIAS = process.queries[@"alias"];
		
		ASSessionManager *mgr = [[ASSessionManager alloc] init];
		CLInfo(@"Login to Apple server...");
		[mgr login:ACCOUNT password:PASSWORD verify:^(void (^verify)(NSString *)) {
			printf("Please enter verify code: ");
			int code = 0;
			scanf("%d", &code);
			if (code > 999 && code < 10000) {
				NSString *str = [NSString stringWithFormat:@"%d", code];
				verify(str);
			} else {
				verify(nil);
			}
		} completed:^(ASAccountSession *accountSession, NSError *error) {
			if (error) {
				CLError(@"Login failed: %@", error.localizedDescription);
				exit(EXIT_FAILURE);
			}
			CLInfo(@"Fetching development teams...");
			[accountSession fetchTeams:^(NSArray<ALTTeam *> *teams, NSError *error) {
				if (error) {
					CLError(@"Fetching failed: %@", error.localizedDescription);
					exit(EXIT_FAILURE);
				}
				ALTTeam *team = [teams signer_first:^BOOL(ALTTeam *obj) {
					return obj.type == ALTTeamTypeFree;
				}];
				if (!team) {
					CLError(@"Can not found a team");
					exit(EXIT_FAILURE);
				}
				
				ALTAccount *account = accountSession.account;
				CLInfo(@"---------");
				CLInfo(@"Account: %@ (%@)", account.name, account.appleID);
				CLInfo(@"Team: %@ (%@)", team.name, team.identifier);
				CLInfo(@"---------");
				CLSuccess(@"Login succeed!");
				
				ISAuthManager *authMgr = [[ISAuthManager alloc] init];
				
				ISAuthName *name = [[ISAuthName alloc] init];
				name.appleID = account.appleID;
				name.accountName = account.name;
				name.teamName = team.name;
				name.teamIdentifier = team.identifier;
				name.alias = ALIAS;
				
				NSError *saveError = [authMgr add:name];
				if (saveError) {
					CLError(@"Save alias failed: %@", error.localizedDescription);
					exit(EXIT_FAILURE);
				} else {
					CLSuccess(@"Save alias succeed, now you can use `%@` to sign app", ALIAS);
					exit(EXIT_SUCCESS);
				}
			}];
		}];
		[[NSRunLoop currentRunLoop] run];
		return EXIT_SUCCESS;
	}];
}

+ (void)__init_logout {
	CLCommand *free = [[CLCommand mainCommand] defineSubcommand:@"free"];
	
	CLCommand *logout = [free defineSubcommand:@"logout"];
	logout.explain = @"Logout and remove alias record.";
	logout.setQuery(@"account").setAbbr('i').setExplain(@"The AppleID");
	[logout handleProcess:^int(CLCommand * _Nonnull command, CLProcess * _Nonnull process) {
		NSString *ACCOUNT = process.queries[@"account"];
		
		ISAuthManager *authMgr = [[ISAuthManager alloc] init];
		for (ISAuthName *name in authMgr.names) {
			if ([name.appleID isEqualToString:ACCOUNT]) {
				CLError(@"Remove alias `%@`", name.alias);
				[authMgr remove:name];
			}
		}
		
		CLSuccess(@"Logout succeed!");
		return EXIT_SUCCESS;
	}];
}

+ (void)__init_remove {
	CLCommand *free = [[CLCommand mainCommand] defineSubcommand:@"free"];
	
	CLCommand *remove = [free defineSubcommand:@"remove"];
	remove.explain = @"Remove an alias.";
	remove.setQuery(@"alias").setAbbr('a').setExplain(@"The alias name");
	[remove handleProcess:^int(CLCommand * _Nonnull command, CLProcess * _Nonnull process) {
		NSString *ALIAS = process.queries[@"alias"];
		
		ISAuthManager *authMgr = [[ISAuthManager alloc] init];
		for (ISAuthName *name in authMgr.names) {
			if ([name.alias isEqualToString:ALIAS]) {
				CLError(@"Remove alias `%@`", name.alias);
				[authMgr remove:name];
				return EXIT_SUCCESS;
			}
		}
		
		CLError(@"Can not found alias `%@`", ALIAS);
		return EXIT_FAILURE;
	}];
}

+ (void)__init_sign {
	
}

@end
