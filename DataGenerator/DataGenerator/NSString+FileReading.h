//
//  NSString+FileReading.h
//  DataGenerator
//
//  Created by Martin Weißbach on 8/31/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (FileReading)


/**
 *  Get the content of a file as a string.
 *
 *  @param filePath The path to file of which the content should be retrieved.
 *
 *  @return The content of a file as string.
 */
+ (NSString *)contentsOfFile:(NSString *)filePath;
/**
*   Get the content of a file as string that is located in a given directory.
*
*   @param fileName The name of the file.
*   @param directory The directory where the given file lives in.
*
*   @return The content of the file as string.
*/
+ (NSString *)contentsOfFile:(NSString *)fileName inDirectory:(NSString *)directory;
/**
 *  Returns an array of strings that where separated by a "." character.
 *
 *  @param string The string to split into components.
 *
 *  @return An Array of strings that were separated by a "." character.
 */
+ (NSArray *)pointSeparatedComponentsOfString:(NSString *)string;
/**
 *  Returns an array of strings that where separated by a line break character.
 *
 *  @param filePath The string to split into components.
 *
 *  @return An array of strings that were separated by a line break character.
 */
+ (NSArray *)linesOfStringsOfFile:(NSString *)filePath;

/**
*   Returns the given path without a leading 'file://' substring.
*
*   @param filePath The string of the path to eliminate the 'file://' substring from.
*
*   @return A string without leading 'file://' substring.
*/
+ (NSString *)fileLessFilePath:(NSString *)filePath;

@end
