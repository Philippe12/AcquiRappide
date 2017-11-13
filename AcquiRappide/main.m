//
//  main.m
//  AcquiRappide
//
//  Created by Philippe Fouquet on 09/09/13.
//  Copyright (c) 2013 Philippe Fouquet. All rights reserved.
//

#import <Cocoa/Cocoa.h>

int main(int argc, char *argv[])
{
    //old osx
    //system("sudo kextunload /System/Library/Extensions/FTDIUSBSerialDriver.kext");
    //10.10
    //system("sudo kextunload /System/Library/Extensions/AppleUSBFTDI.kext");
    return NSApplicationMain(argc, (const char **)argv);
}
