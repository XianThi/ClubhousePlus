#import "ClubhousePlus.h"
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define alertsender [[[[UIApplication sharedApplication]delegate] window] rootViewController]



static NSNumber *rowCount;
static NSArray *followers;
static NSMutableArray *not_following;
static bool followers_screen = false;
static NSString *AuthToken;
static NSMutableURLRequest *origReq;


@implementation ClubhousePlus
+(void)customAlert:(NSString *)msg sender:(UIViewController*)sender{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"ClubhousePlus" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * actionOK = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];

    [alert addAction:actionOK];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"12.4")) {
        [sender presentViewController:alert animated:YES completion:nil];
    }

    else{
        [[[UIApplication sharedApplication].delegate window].rootViewController presentViewController:alert animated:YES completion:nil];
    }

}

+(void)log2file:(NSString *)textToWrite{
    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0]stringByAppendingPathComponent:@"xianthi.txt"];
    [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    NSString* contents = [NSString stringWithContentsOfFile:filePath
                          encoding:NSUTF8StringEncoding
                          error:nil];
    NSString *temp = [[NSString alloc] initWithString:textToWrite];
    contents = [contents stringByAppendingString:temp];
    [contents writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}
@end


%hook NSURLConnection
- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately {
		origReq = [request mutableCopy];
		return %orig;
}
	
%end 

%hook FollowersTableController
-(void)updateDataWithClubs:(id)clublist users:(NSArray *)userlist{
	%orig;
	if(followers_screen){
		followers = [userlist copy];
	}
}

%new
-(void)tableView:(id)tableView willDisplayCell:(FollowersViewCell*)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
	//[ClubhousePlus customAlert:NSStringFromClass([cell class]) sender:alertsender];
	//if (class_getProperty([cell class], "addButton")) {
	//}
	return;
}
%end



%hook FollowersViewController



-(void)viewDidLoad{
	%orig;
	if([self.title isEqual:@"FOLLOWERS"]){
		followers_screen = true;
	}else{
		followers_screen = false;
		UIButton* button = [UIButton buttonWithType: UIButtonTypeRoundedRect];
		button.frame = CGRectMake(265.0, 60.0, 100.0, 25.0);
		button.backgroundColor=[UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0];
		button.layer.cornerRadius = 10;
		button.clipsToBounds = true;
		[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[button setTitle:[NSString stringWithFormat:@"Unfollow"] forState:UIControlStateNormal];
		[button addTarget:self action:@selector(unfollowbuttonclick) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:button];
	}
}

%new
-(void)unfollowbuttonclick{
	UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
    indicator.center = self.view.center;
    [self.view addSubview:indicator];
    [indicator bringSubviewToFront:self.view];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    [indicator startAnimating];
	NSDictionary *kCachedFollowing = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"kCachedFollowing"];
	not_following = [[NSMutableArray alloc] init];
	NSMutableArray *followers_ex = [[NSMutableArray alloc] init];
	dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
		int i;
		//[ClubhousePlus customAlert:[NSString stringWithFormat:@"my dictionary is %@", kCachedFollowing] sender:alertsender];
		for (i = 0; i < [followers count]; i++) {
			[followers_ex addObject:[((SServerUserInList *)followers[i]).userId stringValue]];
		}
	
		for(NSString *userId in kCachedFollowing){
			if(![followers_ex containsObject:userId]){
				[not_following addObject:userId];
			}
		}
		int j;
		for (j = 0; j < [not_following count]; j++) {
			[origReq setURL:[NSURL URLWithString:@"https://www.clubhouseapi.com/api/unfollow"]];
			[origReq setHTTPMethod:@"POST"];
			[origReq setValue:@"gzip, deflate, br" forHTTPHeaderField:@"Accept-Encoding"];
			[origReq setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
			[origReq setValue:@"application/json" forHTTPHeaderField:@"Accept"];
			NSDictionary *mapData = [[NSDictionary alloc] initWithObjectsAndKeys: [NSNull null], @"username", [NSNull null],@"query_id",@([not_following[j] intValue]),@"user_id",[NSNull null],@"query_result_position",nil];
			NSData *postData = [NSJSONSerialization dataWithJSONObject:mapData options:0 error:nil];
			[origReq setHTTPBody:postData];
			[[[NSURLSession sharedSession] dataTaskWithRequest:origReq] resume];
			[NSThread sleepForTimeInterval:0.5f];
		}
		dispatch_async(dispatch_get_main_queue(), ^(void){
			[indicator stopAnimating];
			[not_following removeAllObjects];
			[ClubhousePlus customAlert:@"Unfollowing all people who doesnt follow you. You need to scroll your screen every tapped." sender:alertsender];
		});
    });
}

%end

%ctor{
	%init(FollowersTableController = objc_getClass("clubhouse.FollowersTableController"));
	NSMutableDictionary *dictionary = [NSMutableDictionary new];
	dictionary[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
	CFTypeRef result = NULL;
	dictionary[(__bridge id)kSecReturnData] = @YES;
    dictionary[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;
    SecItemCopyMatching((__bridge CFDictionaryRef)dictionary, &result);
	NSData *passwordData = (__bridge_transfer NSData *)result;
	AuthToken = [[NSString alloc] initWithData:passwordData encoding:NSUTF8StringEncoding];
}