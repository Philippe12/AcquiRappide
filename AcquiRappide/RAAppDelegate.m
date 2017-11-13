//
//  RAAppDelegate.m
//  AcquiRappide
//
//  Created by Philippe Fouquet on 09/09/13.
//  Copyright (c) 2013 Philippe Fouquet. All rights reserved.
//

#import "RAAppDelegate.h"
#include "../../ftidAcqui/ftdiAcqui.h"

@implementation RAAppDelegate

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    // If you make sure your dates are calculated at noon, you shouldn't have to
    // worry about daylight savings. If you use midnight, you will have to adjust
    // for daylight savings time.
    NSString* fileName = nil;
    
    xaxis=[[PHxAxis alloc] initWithStyle:PHShowGrid | PHShowGraduationAtBottom | PHShowGraduationAtTop];
    [xaxis setMinimum:0 maximum:1];
    [xaxis setFormat:@"%lg"];
    yaxis=[[PHyAxis alloc] initWithStyle:PHShowGrid | PHShowGraduationAtLeft | PHShowGraduationAtRight | PHBig];
    [yaxis setMinimum:0 maximum:4095];
    [yaxis setFormat:@"%1.7lg"];
    [_graphView addPHxAxis:xaxis];
    [_graphView addPHyAxis:yaxis];
    [_graphView setMouseEventsMode:PHZoomOnSelection];
    int i;
    for (i=0;i<20000;i++)
    {
        xData[i] = 0;
        yData10[i] = 0;
        yData60[i] = 0;
        yData110[i] = 0;
        yData160[i] = 0;
    }

    plotting10 = [[PHCurve alloc]initWithXData:xData yData:yData10 numberOfPoints:20000 xAxis:xaxis yAxis:yaxis ];
    [plotting10 setColor:[NSColor redColor]];
    [plotting10 setWidth:0.5];
    [plotting10 setTitle:@"Voie 10°"];
    [_graphView addPHGraphObject:plotting10];

    plotting60 = [[PHCurve alloc]initWithXData:xData yData:yData60 numberOfPoints:20000 xAxis:xaxis yAxis:yaxis ];
    [plotting60 setColor:[NSColor greenColor]];
    [plotting60 setWidth:0.5];
    [plotting60 setTitle:@"Voie 60°"];
    [_graphView addPHGraphObject:plotting60];

    plotting110 = [[PHCurve alloc]initWithXData:xData yData:yData110 numberOfPoints:20000 xAxis:xaxis yAxis:yaxis ];
    [plotting110 setColor:[NSColor blueColor]];
    [plotting110 setWidth:0.5];
    [plotting110 setTitle:@"Voie 110°"];
    [_graphView addPHGraphObject:plotting110];

    plotting160 = [[PHCurve alloc]initWithXData:xData yData:yData160 numberOfPoints:20000 xAxis:xaxis yAxis:yaxis ];
    [plotting160 setColor:[NSColor blackColor]];
    [plotting160 setWidth:0.5];
    [plotting160 setTitle:@"Voie 160°"];
    [_graphView addPHGraphObject:plotting160];

    [_graphView setHasBorder:YES];
    [_graphView setLeftBorder:65 rightBorder:65 bottomBorder:20 topBorder:20];
    [_graphView setDelegate:self];
}

// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "ph.fouquet.AcquiRappide" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"ph.fouquet.AcquiRappide"];
}

// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"AcquiRappide" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"AcquiRappide.storedata"];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _persistentStoreCoordinator = coordinator;
    
    return _persistentStoreCoordinator;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) 
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];

    return _managedObjectContext;
}

// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[self managedObjectContext] undoManager];
}

// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender
{
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (IBAction)Acqui:(id)sender {
    if( ftdiConnect() == 1 ) {
        pThread = true;
        [NSThread detachNewThreadSelector:@selector(startTheBackgroundJob) toTarget:self withObject:nil];
    }
}

- (IBAction)Stop:(id)sender {
    pThread = false;
}

- (IBAction)OpenSavingFile:(id)sender {
    NSSavePanel* saveDlg = [NSSavePanel savePanel];
    
    // Display the dialog.  If the OK button was pressed,
    // process the files.
    if( [saveDlg runModal] == NSFileHandlingPanelOKButton )
    {
        // Get an array containing the full filenames of all
        // files and directories selected.
        fileName = [[saveDlg URL] path];
    }
}

- (void)startTheBackgroundJob {
    while (pThread)
    {
        NSDate *date = [NSDate date];
        if( fileName == nil)
            ftdiAcqui(NULL);
        else
            ftdiAcqui([fileName fileSystemRepresentation]);
        double timePassed_s = [date timeIntervalSinceNow] * -1;
        double speed = 20000.0 / timePassed_s;
        NSString *txt = [NSString stringWithFormat:@"f acqui = %f p/s", speed];
        [_Sampling setStringValue:txt];
        [self performSelectorOnMainThread:@selector(makeMyGraphMoving) withObject:nil waitUntilDone:NO];
    }
    ftdiClose();
}

- (void)makeMyGraphMoving {
    // Add some data
    int i;
    for (i=0;i<20000;i++)
    {
        xData[i] = i/20000.0;
        yData10[i] = ftdiGetValue((int)i, 0);
        yData60[i] = ftdiGetValue((int)i, 1);
        yData110[i] = ftdiGetValue((int)i, 2);
        yData160[i] = ftdiGetValue((int)i, 3);
    }
    
    [plotting10 setShouldDraw:YES ];
    [plotting60 setShouldDraw:YES ];
    [plotting110 setShouldDraw:YES ];
    [plotting160 setShouldDraw:YES ];
    [_graphView setNeedsDisplay:YES];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}

- (IBAction)resetZoom:(id)sender {
    [xaxis setMinimum:0 maximum:1];
    [yaxis setMinimum:0 maximum:4095];
    [_graphView setNeedsDisplay:YES];
}
@end
