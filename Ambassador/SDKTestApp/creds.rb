#!/usr/bin/ruby

file_content = <<-CREDS_FILE_STRING

#import <Foundation/Foundation.h>

NSString *const RAINFOREST_UNIVERSAL_ID = @"#{ENV['RAINFOREST_UNIVERSAL_ID']}";
NSString *const RAINFOREST_SDK_TOKEN = @"#{ENV['RAINFOREST_SDK_TOKEN']}";

CREDS_FILE_STRING

file = File.new("SDKTestApp/Constants.m", "w")
file.puts(file_content)
file.close
