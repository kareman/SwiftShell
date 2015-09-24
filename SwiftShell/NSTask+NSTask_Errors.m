/*
 * Released under the MIT License (MIT), http://opensource.org/licenses/MIT
 *
 * Copyright (c) 2015 Kåre Morstøl, NotTooBad Software (nottoobadsoftware.com)
 *
 */

#import "NSTask+NSTask_Errors.h"

@implementation NSTask (NSTask_Errors)

- (BOOL) launchWithNSError:(NSError *__autoreleasing *)error {
	@try {
		[self launch];
	}
	@catch (NSException *exception) {
		if ([exception.name isEqualToString:NSInvalidArgumentException]) {
			*error = [NSError errorWithDomain:NSPOSIXErrorDomain code:1 userInfo:exception.userInfo];
			return false;
		} else {
			@throw exception;
		}
	}
	return true;
}

@end
