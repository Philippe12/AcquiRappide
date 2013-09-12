//
//  RAAppDelegate.h
//  AcquiRappide
//
//  Created by Philippe Fouquet on 09/09/13.
//  Copyright (c) 2013 Philippe Fouquet. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import <CorePlot/CorePlot.h>
#import <PHGraph/PHGraphView.h>

@interface RAAppDelegate : NSObject <NSApplicationDelegate/*, CPTPlotDataSource*/> {
    CPTXYGraph *graph;
    NSArray *plotData;
	PHxAxis* xaxis;
	PHyAxis* yaxis;
	PHCurve* plotting10;
	PHCurve* plotting60;
	PHCurve* plotting110;
	PHCurve* plotting160;
	double xData[20000];
	double yData10[20000];
	double yData60[20000];
	double yData110[20000];
	double yData160[20000];
}

@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;
- (IBAction)Acqui:(id)sender;

- (IBAction)resetZoom:(id)sender;
@property (weak) IBOutlet PHGraphView *graphView;

@end
