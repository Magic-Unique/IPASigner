//
//  NSData+Reading.h
//  optool
//  Copyright (c) 2014, Alex Zielenski
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  * Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
//  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import <Foundation/Foundation.h>

#define currentOffset   opt_currentOffset

#define nextByte        opt_nextByte
#define byteAtOffset    opt_byteAtOffset

#define nextShort       opt_nextShort
#define shortAtOffset   opt_shortAtOffset

#define nextInt         opt_nextInt
#define intAtOffset     opt_intAtOffset

#define nextLong        opt_nextLong
#define longAtOffset    opt_longAtOffset

@interface NSData (Reading)

@property (nonatomic, assign) NSUInteger opt_currentOffset;

- (Byte)opt_nextByte;
- (Byte)opt_byteAtOffset:(NSUInteger)offset;

- (uint16_t)opt_nextShort;
- (uint16_t)opt_shortAtOffset:(NSUInteger)offset;

- (uint32_t)opt_nextInt;
- (uint32_t)opt_intAtOffset:(NSUInteger)offset;

- (uint64_t)opt_nextLong;
- (uint64_t)opt_longAtOffset:(NSUInteger)offset;

@end
