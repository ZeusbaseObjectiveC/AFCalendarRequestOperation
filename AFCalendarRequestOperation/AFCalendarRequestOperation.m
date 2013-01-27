// Copyright (c) 2013 Christoph Jerolimov
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

#import "AFCalendarRequestOperation.h"

#import "AFCalendarParser.h"

@implementation AFCalendarRequestOperation

+ (NSSet *)acceptableContentTypes {
	return [NSSet setWithObjects:@"text/calendar", nil];
}

+ (BOOL)canProcessRequest:(NSURLRequest *)request {
	return [[[request URL] pathExtension] isEqualToString:@"ics"] || [super canProcessRequest:request];
}

- (void)setCompletionBlockWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
							  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
	self.completionBlock = ^{
		if (self.error) {
			if (failure) {
				dispatch_async(self.failureCallbackQueue ?: dispatch_get_main_queue(), ^{
					failure(self, self.error);
				});
			}
		} else {
			if (success) {
				dispatch_async(self.successCallbackQueue ?: dispatch_get_main_queue(), ^{
					AFCalendarParser* parser = [[AFCalendarParser alloc] init];
					[parser parse:self.responseString];
					success(self, parser.calendar);
				});
			}
		}
	};
#pragma clang diagnostic pop
}

@end
