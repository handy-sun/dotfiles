import os
import ycm_core

flags = [
    '-Wall',
    '-Wextra',
    '-Werror',
    '-Wno-long-long',
    '-Wno-variadic-macros',
    '-fexceptions',
    '-DNDEBUG',
    '-std=c++20',							# 支持的C++版本
    '-x',
    'c++',
    '-I',
    '/usr/include',							# 补全所用的头文件
    '/usr/local/include',		# 补全所用的头文件
    '-isystem',
    #  '/usr/include/c++/9',
  ]

SOURCE_EXTENSIONS = [ '.cpp', '.cxx', '.cc', '.c', '.go']

def FlagsForFile( filename, **kwargs ):
  return {
    'flags': flags,
    'do_cache': True
  }

