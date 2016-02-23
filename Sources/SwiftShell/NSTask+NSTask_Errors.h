/*
 * Released under the MIT License (MIT), http://opensource.org/licenses/MIT
 *
 * Copyright (c) 2015 Kåre Morstøl, NotTooBad Software (nottoobadsoftware.com)
 *
 */

#import <Foundation/Foundation.h>

@interface NSTask (NSTask_Errors)

- (BOOL) launchWithNSError: (NSError**) error;

@end
