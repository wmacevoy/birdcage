#ifdef _WIN32
#include <Windows.h>
#include <bcrypt.h>
#include <cstdlib>
#include <stdint.h>
#pragma comment(lib, "bcrypt.lib")
#include "birdcage/randomize.h"
#else
#include <iostream>
#include <fstream>
#include <cstdlib>
#include "birdcage/randomize.h"
#endif

namespace birdcage
{
#ifdef _WIN32
  void randomize(void *data, size_t size)
  {
    while (size > 0)
    {
      uint32_t read = (size <= 0x4000'0000UL) ? size : 0x4000'0000UL;
      if (BCryptGenRandom(NULL, reinterpret_cast<PUCHAR>(data), read, BCRYPT_USE_SYSTEM_PREFERRED_RNG) != ERROR_SUCCESS)
      {
        std::abort();
      }
      size -= read;
      data = (void *)(((uint8_t *)data) + read);
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
