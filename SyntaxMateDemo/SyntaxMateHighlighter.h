#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 * Helper object for XPC communications.
 */
@interface SyntaxMateHighlighter : NSObject

/*!
 * Adds current theme attributes to the given attributed string.
 *
 * @param sourceCode Original styled text with custom font.
 * @param path File name that will be used for choosing grammar.
 * @param completion Callback with result.
 */
- (void)highlightSourceCode:(NSAttributedString *)sourceCode withPath:(NSString *)path completion:(void (^)(NSAttributedString * _Nullable highlightedSourceCode, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
