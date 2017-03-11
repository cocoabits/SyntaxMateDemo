#import "AppDelegate.h"

#import "SyntaxMateHighlighter.h"

#import <Cocoa/Cocoa.h>

@interface AppDelegate () <NSApplicationDelegate>

@property (nonatomic, weak) IBOutlet NSWindow *window;
@property (nonatomic, weak) IBOutlet NSTextField *textField;
@property (nonatomic, weak) IBOutlet NSTextView *textView;

@end

@implementation AppDelegate {
	NSUInteger _counter;
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification {
	self.textView.font = [NSFont fontWithName:@"SFMono-Regular" size:NSFont.smallSystemFontSize] ?: [NSFont userFixedPitchFontOfSize:NSFont.smallSystemFontSize];
	self.textField.stringValue = @"https://raw.githubusercontent.com/textmate/textmate/master/Applications/QuickLookGenerator/src/generate.mm";
	[self downloadSourceCode];
}

#pragma mark - User Actions

- (IBAction)changeURL:(id)sender {
	[self downloadSourceCode];
}

#pragma - Private API

- (void)downloadSourceCode {
	NSString *sourceCodeURLString = self.textField.stringValue;
	if (sourceCodeURLString.length == 0) {
		return;
	}
	NSURL *sourceCodeURL = [NSURL URLWithString:sourceCodeURLString];
	if (sourceCodeURL == nil) {
		return;
	}
	typeof(self) __weak weakSelf = self;
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSString *sourceCode = [[NSString alloc] initWithContentsOfURL:sourceCodeURL usedEncoding:NULL error:NULL];
		if (sourceCode == nil) {
			return;
		}
		dispatch_async(dispatch_get_main_queue(), ^{
			if (![weakSelf.textField.stringValue isEqualToString:sourceCodeURLString]) {
				return;
			}
			weakSelf.textView.string = sourceCode;
			[weakSelf highlightSourceCode];
		});
	});
}

- (void)highlightSourceCode {
	static SyntaxMateHighlighter *highlighter = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		highlighter = [[SyntaxMateHighlighter alloc] init];
	});
	NSUInteger counterBeforeRequest = [self counterBeforeRequest:YES];
	typeof(self) __weak weakSelf = self;
	NSTextStorage *textStorage = self.textView.textStorage;
	[highlighter highlightSourceCode:[textStorage copy] withPath:self.textField.stringValue completion:^(NSAttributedString *highlightedSourceCode, NSError *error) {
		if (highlightedSourceCode == nil) {
			weakSelf.textView.string = [NSString stringWithFormat:@"%@", error];
		} else if ([weakSelf counterBeforeRequest:NO] == counterBeforeRequest) {
			[textStorage replaceCharactersInRange:NSMakeRange(0, textStorage.length) withAttributedString:highlightedSourceCode];
		}
	}];
}

- (NSUInteger)counterBeforeRequest:(BOOL)before {
	NSParameterAssert(NSThread.isMainThread);
	if (before) {
		_counter += 1;
	}
	return _counter;
}

@end
