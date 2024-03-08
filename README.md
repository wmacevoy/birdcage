# Birdcage

Protect your data in birdcage.

`Canary` creates and checks a random canary value.  Modern compilers place a canary value in the stack frame to protect your return, but with canary values you can check for buffer overflows before returning.  The Canary destructor automatically checks the integrity of the canary value.  Since a corrupt canary implies memory corruption, `Canary::check()` simply aborts the process.

`SecureData<Type>` places a `Type` between two canaries, and automatically resets (sets the data to the default constructor value) on initialization and destruction.

`SecureArray<Type,Size>` is a specialization of SecureData to std::array.  The difference is the reset defaults to filling the array with default values.

`randomize` is a helper class for secure random data.  It is only used to initalize the canary reference value.

*Note* *Note* *Note*

Birdcage does not prevent memory corruption.  Honoring buffer sizes does.
It does help you fail early when memory corruption is present.

*Note* *Note* *Note*

# Examples

## SecureArray on stack

The easiest to use is SecureArray, which is a batteries-included secure solution for fixed size secure data buffers.

```C++
#include "birdcage.h"

constexpr size_t bufferSize = 4'096;

void useBuffer() {
  birdcage::SecureArray<uint8_t,bufferSize> safe;
  // buffer is
  //  * of type std::array < uint8_t , bufferSize >
  //  * initialized zeros (default uint8_t)
  //  * locked from page swap
  //  * surrounded by two canary values
  auto& buffer = safe.data;

  // TODO use buffer

  // die if a memory corruption is detected
  safe.check(); 

  // TODO use buffer more

  // Done - destructor automatically zeros buffer again, unlocks from page swap, and checks canary values
}
```

## SecureArray on Heap

Since everything is managed with constructors and destructors, you could instead use

```C++
#include <memory>

constexpr size_t bufferSize = 4'096;

void useBuffer() {
  auto safe = std::make_shared < birdcage::SecureArray<uint8_t,bufferSize> > ();
  auto & buffer = safe->data;

  // use buffer as before, when refence count to safe goes to zero, the destuctor checks and cleans it,
  // with safe->check() as you see fit.
}
```

## SecureData

If you have more structured data to manage, you can create a flat memory struct (no dynamic objects) with
a static `reset(data)` method which describes how to scrub the data before and after use.

```C++
template <size_t _bitsize, uint8_t _rounds>
struct CipherEnv {
  static constexpr size_t bitsize = _bitsize;
  static constexpr size_t bytesize = _bitsize/8;
  static constexpr uint8_t rounds = _rounds;
  
  std::array < uint8_t, bytesize > key;
  std::array < std::array < uint8_t, bytesize > , rounds > states;

  static void reset(CipherEnv &data) {
    data.publicKey.fill(0);
    data.secretKey.fill(0);
    for (auto &round : data.states) round.fill(0);
  }
};

// make a specialized type for a pipelined AES 
using AES256Env = CipherEnv < 256, 14 >;

// use a custom reset for this secure data
using AES256SecEnv = birdcage::SecureData < AES256Env , AES256Env::reset >;

void pipeline(AES256SecEnv &safe) {
  AES256Env &env = safe.data;

  // TODO: Use env and safe.check() here...
  
}

void stackEnv() {
  AES256SecEnv safe;
  pipeline(safe);
}

void heapEnv() {
  auto safe = std::shared_ptr < AES256SecEnv > safe;
  pipeline(*safe);
}

```

# Classes

## Randomize

If you want a block of cryptographically strong random bits,
```C++
   uint8_t u8buf[128];
   randomize(u8buff,sizeof(u8buf));

   std::array < uint32_t , 20 > u32buf;
   randomize(u32buf);

   uint64_t seed = randomize<uint64_t>();
```

*Note* `randomize<double>()` puts uniformly random bits in the double, including the exponent and sign representation bits, so it is very much not a uniform number between 0 and 1.  Use `randomize<uint64_t>()/pow(2,64)` for that.

# Canary
On process creation, this creates a 64 bit random reference value.  `Canary here` adds a local canary value. `alive()` checks that the canary value has not been changed (true/false) and `check()` aborts the program if the local value has been corrupted.

An optimizing compiler may move the location of the canary, so you should use it as "bookmarks" in SecureData and SecureArray, or some struct of your own.  For example, if you don't want the page locking and erase features of secure data, then,

```C++
struct MyData {
  uint8_t header[64];
  birdcage::Canary afterHeader;
  uint8_t message[128];
  birdcage::Canary afterMessage;
  int state;
  void check() {
    afterHeader.check();
    afterMessage.check();    
  }
};
```

Might be plenty for your application. You don't have to explicitly call `check()`, but you can.
Canary values self-check on destruction.

# SecureData
```C++
SecureData < Type , Reset = [](Type &data) { data = Type(); } > secData;
```
Creates a Type data that is
 - Reset on construction and destruction.
 - Has pages locked from swap between construction and destruction.
 - A canary is present before and after the data (because of bus alignment, the compiler may leave a gap of a few bytes).

Constructing a SecureData may throw a std::bad_alloc if the page swap locking fails.
Destructing a SecureData may `std::abort()` if the canaries are corrupt or page-swap unlocking fails.

# SecureArray

This is a specialization of `SecureData` to `std::array`, where the reset action fills with the default value.



