// CheckInsViewController.m
//
// Copyright (c) 2012 Mattt Thompson (http://mattt.me)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "CheckInsViewController.h"

#import "ReverseGeocodedCheckIn.h"

#import "AFIncrementalStore.h"

@interface CheckInsViewController () <NSFetchedResultsControllerDelegate> {
    NSFetchedResultsController *_fetchedResultsController;
}
@end


@implementation CheckInsViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"CheckIns", nil);
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ReverseGeocodedCheckIn"];
    fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]];
    fetchRequest.returnsObjectsAsFaults = NO;
    fetchRequest.includesPendingChanges = NO;
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[(id)[[UIApplication sharedApplication] delegate] managedObjectContext] sectionNameKeyPath:nil cacheName:nil];
    _fetchedResultsController.delegate = self;
    [_fetchedResultsController performFetch:nil];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refetchData:) forControlEvents:UIControlEventValueChanged];
    [[NSNotificationCenter defaultCenter] addObserverForName:AFIncrementalStoreContextDidFetchRemoteValues object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self.refreshControl endRefreshing];
    }];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(checkIn:)];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

#pragma mark - IBAction

- (void)refetchData:(id)sender {
    _fetchedResultsController.fetchRequest.resultType = NSManagedObjectResultType;
    [_fetchedResultsController performFetch:nil];
}

- (void)checkIn:(id)sender {
    ReverseGeocodedCheckIn *checkIn = [[ReverseGeocodedCheckIn alloc] initWithTimestamp:[NSDate date] inManagedObjectContext:_fetchedResultsController.managedObjectContext];
	
	[checkIn setCompletionBlock:
	 ^(NSError *error)
	{
		if (error)
			NSLog(@"Error: %@", error);
		
		[self.tableView reloadData];
		NSError *saveError = nil;
		[_fetchedResultsController.managedObjectContext save:&saveError];
	}];
    
    [_fetchedResultsController.managedObjectContext insertObject:checkIn];
    
    NSError *error = nil;
    if (![_fetchedResultsController.managedObjectContext save:&error]) {
        NSLog(@"Error: %@", error);
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[_fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[_fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    ReverseGeocodedCheckIn *checkIn = (ReverseGeocodedCheckIn *)[_fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [[checkIn timestamp] description];
	if (checkIn.postalCode)
		cell.detailTextLabel.text = checkIn.postalCode;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ReverseGeocodedCheckIn *checkIn = (ReverseGeocodedCheckIn *)[_fetchedResultsController objectAtIndexPath:indexPath];
    NSLog(@"Checkin: %@", checkIn);
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadData];
}

@end