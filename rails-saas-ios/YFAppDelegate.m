//
//  YFAppDelegate.m
//  rails-saas-ios
//
//  Created by Chris Richards on 07/01/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

#import "YFAppDelegate.h"
#import "YFLoginViewController.h"
#import "YFRailsSaasApiClient.h"

@interface YFAppDelegate ()<UIAlertViewDelegate>

@property (strong, nonatomic) YFLoginViewController* loginViewController;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (void)initializeCoreDataStack;
- (void)contextInitialized;

@end

@implementation YFAppDelegate

@synthesize loginViewController = _loginViewController;
@synthesize managedObjectContext;

- (void)showLoginView {
    if (self.loginViewController == nil) {
        self.loginViewController = [[YFLoginViewController alloc] initWithNibName:@"YFLoginView" bundle:nil];
    }
    UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
    [navController presentViewController:self.loginViewController animated:NO completion:nil];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self initializeCoreDataStack];
    
    id controller = nil;
    
    UIUserInterfaceIdiom idiom = [[UIDevice currentDevice] userInterfaceIdiom];
    if (idiom == UIUserInterfaceIdiomPad) {
        id splitViewController = [[self window] rootViewController];
        UINavigationController *navigationController = nil;
        navigationController = [[splitViewController viewControllers] lastObject];
        [splitViewController setDelegate:[navigationController topViewController]];
        
        UINavigationController *masterNC = nil;
        masterNC = [[splitViewController viewControllers] objectAtIndex:0];
        controller = [masterNC topViewController];
    } else {
        id navigationController = [[self window] rootViewController];
        controller = [navigationController topViewController];
    }
    
    [controller setManagedObjectContext:[self managedObjectContext]];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    BOOL isLoginRequired = [[YFRailsSaasApiClient sharedClient] isLoginRequired];
    if (isLoginRequired) {
        [self showLoginView];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)saveContext
{
    NSManagedObjectContext *moc = [self managedObjectContext];
    
    if (!moc) return;
    if (![moc hasChanges]) return;
    
    NSError *error = nil;
    ZAssert([moc save:&error], @"Error saving MOC: %@\n%@", [error localizedDescription], [error userInfo]);
}

- (void)contextInitialized;
{
    //Finish UI initialization
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView*)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    exit(0);
}

#pragma mark - Core Data stack

- (void)initializeCoreDataStack
{
    NSURL *modelURL = nil;
    modelURL = [[NSBundle mainBundle] URLForResource:@"Model"
                                       withExtension:@"momd"];
    ZAssert(modelURL, @"Failed to find model URL");
    
    NSManagedObjectModel *mom = nil;
    mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    ZAssert(mom, @"Failed to initialize model");
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *storeURL = [[fm URLsForDirectory:NSDocumentDirectory
                                  inDomains:NSUserDomainMask] lastObject];
    storeURL = [storeURL URLByAppendingPathComponent:@"Model.sqlite"];
    
    
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    ZAssert(psc, @"Failed to initialize persistent store coordinator");
    
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [moc setPersistentStoreCoordinator:psc];
    
    [self setManagedObjectContext:moc];
    
    dispatch_queue_t queue = nil;
    queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        NSError *error = nil;
        NSPersistentStoreCoordinator *coordinator = nil;
        coordinator = [moc persistentStoreCoordinator];
        
        NSMutableDictionary *options = [NSMutableDictionary dictionary];
        [options setValue:[NSNumber numberWithBool:YES]
                   forKey:NSMigratePersistentStoresAutomaticallyOption];
        [options setValue:[NSNumber numberWithBool:YES]
                   forKey:NSInferMappingModelAutomaticallyOption];
        
        NSPersistentStore *store = nil;
        store = [coordinator addPersistentStoreWithType:NSSQLiteStoreType
                                          configuration:nil
                                                    URL:storeURL
                                                options:options
                                                  error:&error];
        if (!store) {
            ALog(@"Error adding persistent store to coordinator %@\n%@",
                 [error localizedDescription], [error userInfo]);
            
            NSString *msg = nil;
            msg = [NSString stringWithFormat:@"The database %@%@%@\n%@\n%@",
                   @"is either corrupt or was created by a newer ",
                   @"version of this app.  Please contact ",
                   @"support to assist with this error.",
                   [error localizedDescription], [error userInfo]];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:msg
                                                               delegate:self
                                                      cancelButtonTitle:@"Quit"
                                                      otherButtonTitles:nil];
            [alertView show];
            return;
        }
        
//        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Product"];
//        
//        [moc performBlockAndWait:^{
//            NSError *error = nil;
//            NSInteger count = [[self managedObjectContext] countForFetchRequest:request error:&error];
//            ZAssert(count != NSNotFound || !error, @"Failed to count product: %@\n%@", [error localizedDescription], [error userInfo]);
//            
//            if (count) return;
//            
//            NSArray *products = [[[NSBundle mainBundle] infoDictionary] objectForKey:modelProduct];
//            
//            for (NSString *product in products) {
//                NSManagedObject *productMO = [NSEntityDescription insertNewObjectForEntityForName:@"Product" inManagedObjectContext:moc];
//                [productMO setValue:recipeType forKey:@"name"];
//            }
//            
//            ZAssert([moc save:&error], @"Error saving moc: %@\n%@", [error localizedDescription], [error userInfo]);
//        }];
        
        [self contextInitialized];
    });
}

@end
