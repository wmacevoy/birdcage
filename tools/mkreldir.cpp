#include <string>
#include <string.h>
#include <iostream>
#include <vector>

#ifdef _WIN32
#include <windows.h>
#include <direct.h>
#include <sys/types.h>
#include <sys/stat.h>
#ifdef UNICODE
using sysstring = std::wstring;
#else
using sysstring = std::string;
#endif
#else
#include <unistd.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/stat.h>
using sysstring = std::string;
#endif

#ifndef _WIN32
#define _tmain main
#define _tchdir chdir
#define _T(x) x
#endif

size_t dirsep(const sysstring &dirs, size_t at) {
    ssize_t sepFs = dirs.find('/',at);
    if (sepFs == sysstring::npos) sepFs = dirs.size();
    ssize_t sepBs = dirs.find('\\',at);
    if (sepBs == sysstring::npos) sepBs = dirs.size();
    return (sepBs < sepFs) ? sepBs : sepFs;
}

void makedir(const sysstring &dir) {
#ifdef _WIN32
  int status = _tmkdir(dir.c_str());
  if (status != 0 && errno != EEXIST) {
    exit(1);
  }
#else
  mode_t mode = umask(0);
  umask(mode);
  mode = 0x755 & ~mode;
  int status = mkdir(dir.c_str(),mode);
  if (status != 0 && errno != EEXIST) {
    exit(1);
  }
#endif
}

void changedir(const sysstring &dir) {
  int status = _tchdir(dir.c_str());
  if (status != 0) {
    exit(1);
  }
}

void mkreldir(const sysstring &dirs) {
  std::cout << "mkreldir(" << dirs << ")" << std::endl;
  size_t at = 0;
  int depth = 0;
  while (at < dirs.size()) {
     size_t next = dirsep(dirs,at);
     sysstring subdir = dirs.substr(at,next-at);
     std::cout << "subdir=" << subdir << std::endl;
     if (subdir == _T("") || subdir == _T(".")) {
      // nop
     } else if (subdir == _T("..")) {
      if (depth == 0) { exit(1); }
      --depth;
      changedir(subdir);
     } else {
      makedir(subdir);
      changedir(subdir);
      ++depth;
     }
     at = next+1;
  }
}

int _tmain(int argc, sysstring::value_type *argv[])
{
  for (int i=1; i<argc; ++i) {
    mkreldir(argv[i]);
  }
  return 0;
}
