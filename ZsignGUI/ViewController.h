//
//  ViewController.h
//  t
//
//  Created by Said Al Mujaini on 4/14/22.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController<NSOpenSavePanelDelegate>

@property (strong, nonatomic) NSWindow *window;

@property (strong, nonatomic) NSString *fileExt;

@property (weak) IBOutlet NSTextField *certTextView;
@property (weak) IBOutlet NSTextField *provTextView;
@property (weak) IBOutlet NSTextField *ipaTextView;


@property (unsafe_unretained) IBOutlet NSTextView *debugTextView;
@property (weak) IBOutlet NSButton *browseButton1;
@property (weak) IBOutlet NSButton *browseButton2;
@property (weak) IBOutlet NSButton *browseButton3;
@property (weak) IBOutlet NSButton *signButton;

@end

