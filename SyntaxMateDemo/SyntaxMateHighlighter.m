#import "SyntaxMateHighlighter.h"

#import "SyntaxMate.h"

@interface SyntaxMateHighlighter ()

@property (nonatomic, strong, readonly) NSXPCConnection *connection;

@end

#pragma mark

@implementation SyntaxMateHighlighter

- (instancetype)init {
	if ((self = [super init])) {
		// The bundle must be located in XPCServices
		_connection = [[NSXPCConnection alloc] initWithServiceName:@"com.macromates.SyntaxMate"];
		_connection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(SyntaxMate)];
		[_connection resume];
	}
	return self;
}

- (void)dealloc {
	[_connection invalidate];
}

#pragma mark - Public API

- (void)highlightSourceCode:(NSAttributedString *)sourceCode withPath:(NSString *)path completion:(void (^)(NSAttributedString *, NSError *))completion {
	NSParameterAssert(completion);

	// Do not make XPC request for empty string
	if ((sourceCode.length == 0) || (path.length == 0)) {
		completion(sourceCode, nil);
	}

	// Archive the source code into NSData for XPC transfer
	__auto_type const sourceCodeData = [[NSMutableData alloc] init];
	__auto_type const archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:sourceCodeData];
	archiver.requiresSecureCoding = YES;
	[archiver encodeObject:sourceCode forKey:NSKeyedArchiveRootObjectKey];
	[archiver finishEncoding];

	// Make XPC request using proxy object
	id <SyntaxMate> syntaxMate = [self.connection remoteObjectProxyWithErrorHandler:^(NSError *error) {
		[NSOperationQueue.mainQueue addOperationWithBlock:^{
			completion(nil, error);
		}];
	}];
	[syntaxMate highlightSourceCode:sourceCodeData withPath:path reply:^(NSData *data, NSError *error) {
		if (data == nil) {
			[NSOperationQueue.mainQueue addOperationWithBlock:^{
				completion(nil, error);
			}];
			return;
		}

		// Unarchive the source code from NSData
		__auto_type const unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
		unarchiver.requiresSecureCoding = YES;
		NSAttributedString *highlightedSourceCode = [unarchiver decodeObjectOfClass:NSAttributedString.class forKey:NSKeyedArchiveRootObjectKey];
		[unarchiver finishDecoding];
		if (![highlightedSourceCode isKindOfClass:NSAttributedString.class]) {
			highlightedSourceCode = nil;
		}

		// Report result back to the client
		[NSOperationQueue.mainQueue addOperationWithBlock:^{
			completion(highlightedSourceCode, nil);
		}];
	}];
}

@end
