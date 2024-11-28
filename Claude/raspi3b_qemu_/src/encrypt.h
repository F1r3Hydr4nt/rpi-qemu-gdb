/* encrypt.h */
#ifndef ENCRYPT_H
#define ENCRYPT_H

#include <stdint.h>
#include <stddef.h>

/* Function declarations */
int encrypt_simple(const uint8_t *data, size_t data_len,
                  const char *passphrase,
                  uint8_t *output, size_t *output_len, const char* derivedKey);

#endif /* ENCRYPT_H */
