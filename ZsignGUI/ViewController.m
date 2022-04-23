//
//  ViewController.m
//  t
//
//  Created by Said Al Mujaini on 4/14/22.
//

#import "ViewController.h"
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>


@implementation ViewController

#pragma mark NSPanel delegate
-(BOOL)panel:(id)sender shouldEnableURL:(nonnull NSURL *)url {
    NSString* ext = [url pathExtension];
    if ([ext isEqual:@""] || [ext isEqual:@"/"] || ext == nil || ext == NULL || [ext length] < 1) {
        return YES;
    }
    NSEnumerator* tagEnumerator = [[NSArray arrayWithObjects:_fileExt, nil] objectEnumerator];
    NSString* allowedExt;
    while ((allowedExt = [tagEnumerator nextObject])){
        if ([ext caseInsensitiveCompare:allowedExt] == NSOrderedSame){
            return YES;
        }
    }
    return NO;
}
- (void)showFileDialogFor:(NSTextField *)textField{
    if(textField == _certTextView){
        _fileExt = @"p12";
    }
    if(textField == _provTextView){
        _fileExt = @"mobileprovision";
    }
    if(textField == _ipaTextView){
        _fileExt = @"ipa";
    }
    
    NSOpenPanel *o = [NSOpenPanel openPanel];
    [o setDelegate:self];
    [o setAllowsMultipleSelection:NO];
    [o setCanChooseFiles:YES];
    [o setCanCreateDirectories:NO];
    [o beginSheetModalForWindow:_window completionHandler:^(NSModalResponse result) {
        if(result == NSModalResponseOK){
            [textField setStringValue:[o URL].absoluteString];
        }
    }];
}


#pragma mark Actions
- (IBAction)browseButton1Clicked:(id)sender {
    [self showFileDialogFor:_certTextView];
}
- (IBAction)browseButton2Clicked:(id)sender {
    [self showFileDialogFor:_provTextView];
}
- (IBAction)browseButton3Clicked:(id)sender {
    [self showFileDialogFor:_ipaTextView];
}
- (IBAction)signButtonClicked:(id)sender {
    // reset debug view
    [[_debugTextView textStorage] setAttributedString:[NSAttributedString new]];
    
    // Open dialog
    NSSavePanel *s = [NSSavePanel savePanel];
    [s beginSheetModalForWindow:_window completionHandler:^(NSModalResponse result) {
            if(result == NSModalResponseOK){
            
                // Collect inputs
                NSURL *zsign_path = [[NSBundle mainBundle] URLForResource:@"zsign" withExtension:@""];
                NSString *out_ipa = [[s URL].absoluteString stringByReplacingOccurrencesOfString:@"file://" withString:@""];
                NSString *certPath = [self->_certTextView.stringValue stringByReplacingOccurrencesOfString:@"file://" withString:@""];
                NSString *provPath = [self->_provTextView.stringValue stringByReplacingOccurrencesOfString:@"file://" withString:@""];
                NSString *ipaPath =  [self->_ipaTextView.stringValue stringByReplacingOccurrencesOfString:@"file://" withString:@""];
                
                // Start a different thread for the signing process
                NSArray *threadArgs = @[zsign_path, out_ipa, certPath, provPath, ipaPath];
                NSThread *sigingThread = [[NSThread alloc] initWithTarget:self selector:@selector(startSigningThread:) object:threadArgs];
                [sigingThread start];
            }
    }];
}


#pragma mark Methods
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)updateDebugTextView:(NSString *)output{
    // Fix
    output = [output stringByReplacingOccurrencesOfString:@"[0m" withString:@""];
    
    // Default
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:output attributes:@{NSForegroundColorAttributeName:[NSColor whiteColor]}];
    
    // Red
    if([output containsString:@"31m"]){
        output = [output stringByReplacingOccurrencesOfString:@"[31m" withString:@""];
        attString = [[NSAttributedString alloc] initWithString:output attributes:@{NSForegroundColorAttributeName:[NSColor redColor]}];
    }
    
    // Green
    if([output containsString:@"32m"]){
        output = [output stringByReplacingOccurrencesOfString:@"[32m" withString:@""];
        attString = [[NSAttributedString alloc] initWithString:output attributes:@{NSForegroundColorAttributeName:[NSColor greenColor]}];
    }
    
    // Yellow
    if([output containsString:@"33m"]){
        output = [output stringByReplacingOccurrencesOfString:@"[33m" withString:@""];
        attString = [[NSAttributedString alloc] initWithString:output attributes:@{NSForegroundColorAttributeName:[NSColor yellowColor]}];
    }
    
    // Update to TextView
    [[_debugTextView textStorage] appendAttributedString:attString];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    // Update the view, if already loaded.
}




#pragma mark THREAD2
- (void)startSigningThread:(NSArray *)threadArgs{
    // Get args
    NSURL* __zsign_path = [threadArgs objectAtIndex:0];
    NSString* __out_ipa = [threadArgs objectAtIndex:1];
    NSString *__certPath = [threadArgs objectAtIndex:2];
    NSString *__provPath = [threadArgs objectAtIndex:3];
    NSString *__ipaPath =  [threadArgs objectAtIndex:4];
    
    // Start command
    NSTask *task = [NSTask new];
    [task setExecutableURL:__zsign_path];
    [task setArguments:@[@"-k", __certPath, @"-m", __provPath, @"-o", __out_ipa, @"-z 9", __ipaPath]];
    
    // Pipe task outputs
    NSPipe *pipe = [NSPipe new];
    task.standardOutput = pipe;
    [task setStandardOutput:pipe];

    // Notify main thread when a message is received
    NSFileHandle *outFile = [pipe fileHandleForReading];
    [outFile waitForDataInBackgroundAndNotify];
    [outFile setReadabilityHandler:^(NSFileHandle * file) {
        NSData *data = file.availableData;
        NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if(output.length >= 3){
            [self performSelectorOnMainThread:@selector(updateDebugTextView:) withObject:output waitUntilDone:YES];
        }
    }];
    [task launch];
    [task waitUntilExit];
}

@end
