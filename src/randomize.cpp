#ifdef _WIN32
#include <Windows.h>
#include <bcrypt.h>
#pragma comment(lib, "bcrypt.lib")
#include "birdcage/randomize.h"
#else
#include <iostream>
#include <fstream>
#include "birdcage/randomize.h"
#endif

namespace birdcage
{
#ifdef _WIN32
  void randomize(void *data, size_t size)
  {
    if (BCryptGenRandom(NULL, reinterpret_cast<PUCHAR>(data), size, BCRYPT_USE_SYSTEM_PREFERRED_RNG) != ERROR_SUCCESS)
    {
      std::abort();
    }
  }
#else
  void randomize(void *data, size_t size)
  {
    static std::ifstream dev_random("/dev/random", std::ios::in | std::ios::binary);
    if (!dev_random.read(reinterpret_cast<char *>(data), size))
    {
      std::cerr << "dev random read failed" << std::endl;
      std::abort();
    }
  }
#endif
} // namespace birdcage
