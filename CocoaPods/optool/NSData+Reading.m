//
//  NSData+Reading.m
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

#import "NSData+Reading.h"
#import <objc/runtime.h>

@implementation NSData (Reading)

static char OFFSET;
- (NSUInteger)opt_currentOffset
{
    NSNumber *value = objc_getAssociatedObject(self, &OFFSET);
    return value.unsignedIntegerValue;
}

- (void)setOpt_currentOffset:(NSUInteger)opt_currentOffset
{
    [self willChangeValueForKey:@"currentOffset"];
    objc_setAssociatedObject(self, &OFFSET, @(opt_currentOffset), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"currentOffset"];
}

- (Byte)opt_nextByte
{
    Byte nextByte    = [self opt_byteAtOffset:self.currentOffset];
    self.currentOffset += sizeof(Byte);
    return nextByte;
}

- (Byte)opt_byteAtOffset:(NSUInteger)offset
{
    Byte result;
    [self getBytes:&result range:NSMakeRange(offset, sizeof(result))];
    return result;
}

- (uint16_t)opt_nextShort
{
    uint16_t nextShort = [self opt_shortAtOffset:self.currentOffset];
    self.currentOffset += sizeof(uint16_t);
    return nextShort;
}

- (uint16_t)opt_shortAtOffset:(NSUInteger)offset
{
    uint16_t result;
    [self getBytes:&result range:NSMakeRange(offset, sizeof(result))];
    return result;
}

- (uint32_t)opt_nextInt
{
    uint32_t nextInt = [self opt_intAtOffset:self.currentOffset];
    self.currentOffset += sizeof(uint32_t);
    return nextInt;
}

- (uint32_t)opt_intAtOffset:(NSUInteger)offset
{
    uint32_t result;
    [self getBytes:&result range:NSMakeRange(offset, sizeof(result))];
    return result;
}

- (uint64_t)opt_nextLong
{
    uint64_t nextLong = [self opt_longAtOffset:self.currentOffset];
    self.currentOffset += sizeof(uint64_t);
    return nextLong;
}

- (uint64_t)opt_longAtOffset:(NSUInteger)offset;
{
    uint64_t result;
    [self getBytes:&result range:NSMakeRange(offset, sizeof(result))];
    return result;
}

@end

@implementation NSMutableData (ByteAdditions)

- (void)opt_appendByte:(Byte)value
{
    [self appendBytes:&value length:sizeof(value)];
}

- (void)opt_appendShort:(uint16_t)value
{
    uint16_t swap = CFSwapInt16HostToLittle(value);
    [self appendBytes:&swap length:sizeof(swap)];
}

- (void)opt_appendInt:(uint32_t)value
{
    uint32_t swap = CFSwapInt32HostToLittle(value);
    [self appendBytes:&swap length:sizeof(swap)];
}

- (void)opt_appendLong:(uint64_t)value;
{
    uint64_t swap = CFSwapInt64HostToLittle(value);
    [self appendBytes:&swap length:sizeof(swap)];
}

@end
