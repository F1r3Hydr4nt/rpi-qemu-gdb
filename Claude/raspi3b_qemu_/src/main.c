#include <stdint.h> 
#include <stddef.h>
#include "sboxes.h"
#include "sha1.h"
// QEMU Versatile PB UART0 address
#define UART0_DR *((volatile uint32_t*)0x101f1000)

// Function prototypes
void uart_putc(char c);
void print(const char* str);
void print_hex(uint8_t byte);
uint8_t hex_to_nibble(char hex);
void hex_to_bytes(const char* hex, uint8_t* bytes, unsigned int len);
void derive_key(const char* password, unsigned int pass_len, uint8_t* key);
void cast5_init(uint32_t* key_schedule, const uint8_t* key);
void cast5_decrypt_block(uint32_t* key_schedule, uint8_t* block);
void cfb_decrypt(uint8_t* data, unsigned int data_len, const uint8_t* iv, const uint8_t* key);

// Encrypted data as a hex string
static const char encrypted_hex[] = "8c0d04030302eb381c55fecc8f2fffd244018c41f4e16990d9c846cafc6b04bc37e07a9248110a6f11104cfe744d2b2646228c15528525668b97f31bab07bfbcedd0628492ee96bf11e8a4be3aa6e9994901d91195";

static const char password[] = "password";

void uart_putc(char c) {
    UART0_DR = c;
}

void print(const char* str) {
    while(*str) {
        uart_putc(*str++);
    }
}

void print_hex(uint8_t byte) {
    const char hex_chars[] = "0123456789ABCDEF";
    uart_putc(hex_chars[byte >> 4]);
    uart_putc(hex_chars[byte & 0x0F]);
}

// Convert a hex character to its 4-bit value
uint8_t hex_to_nibble(char hex) {
    if (hex >= '0' && hex <= '9') return hex - '0';
    if (hex >= 'A' && hex <= 'F') return hex - 'A' + 10;
    if (hex >= 'a' && hex <= 'f') return hex - 'a' + 10;
    return 0;  // Invalid hex character
}

// Convert hex string to bytes
void hex_to_bytes(const char* hex, uint8_t* bytes, unsigned int len) {
    for (unsigned int i = 0; i < len; i++) {
        bytes[i] = (hex_to_nibble(hex[i*2]) << 4) | hex_to_nibble(hex[i*2 + 1]);
    }
}

// Simple XOR "decryption"
void decrypt(uint8_t* data, unsigned int data_len, const char* key, unsigned int key_len) {
    for (unsigned int i = 0; i < data_len; i++) {
        data[i] ^= key[i % key_len];
    }
}


size_t my_strlen(const char *str) {
    size_t len = 0;
    while (str[len] != '\0') {
        len++;
    }
    return len;
}
// Key derivation function using SHA1
void derive_key(const char* password, unsigned int pass_len, uint8_t* key) {
    // Use SHA1 to derive a key from the password
    int byteIndex = 0;
    int totalLen = 8 + my_strlen(password);

  static unsigned char hash_out[21];
  int byteRepeatCount = 65011712;
  SHA1_CTX ctx;
  SHA1Init(&ctx);
  for (int i = 0; i < byteRepeatCount; i++)
  {
    SHA1Update(&ctx, (const unsigned char *)password + byteIndex, 1);
    byteIndex++;
    if (byteIndex == totalLen) // Wrap around end
      byteIndex = 0;
  }

  SHA1Final((unsigned char *)key, &ctx);
  // print_hex("result: ", key, 20);


    SHA1(key,password,pass_len);
}

// CAST5 key schedule initialization
void cast5_init(uint32_t* key_schedule, const uint8_t* key) {
    // Implement CAST5 key schedule initialization
}

// CAST5 block decryption
void cast5_decrypt_block(uint32_t* key_schedule, uint8_t* block) {
    // Implement CAST5 block decryption
}

// CFB mode decryption
void cfb_decrypt(uint8_t* data, unsigned int data_len, const uint8_t* iv, const uint8_t* key) {
    uint32_t key_schedule[32];
    cast5_init(key_schedule, key);

    uint8_t prev_cipher[8];
    for (int i = 0; i < 8; i++) {
        prev_cipher[i] = iv[i];
    }

    for (unsigned int i = 0; i < data_len; i += 8) {
        uint8_t cipher[8];
        for (int j = 0; j < 8; j++) {
            cipher[j] = data[i + j];
        }

        cast5_decrypt_block(key_schedule, prev_cipher);

        for (int j = 0; j < 8; j++) {
            data[i + j] ^= prev_cipher[j];
        }

        for (int j = 0; j < 8; j++) {
            prev_cipher[j] = cipher[j];
        }
    }
}

void main() {
    print("Starting decryption...\r\n");

    // Calculate the length of the encrypted data
    unsigned int encrypted_len = 0;
    while (encrypted_hex[encrypted_len] != '\0') encrypted_len++;
    encrypted_len /= 2;  // Two hex characters per byte

    // Create a buffer for the decrypted data
    uint8_t decrypted_data[encrypted_len];

    // Convert hex string to bytes
    hex_to_bytes(encrypted_hex, decrypted_data, encrypted_len);
    char key[20];
    derive_key(password, sizeof(password) - 1, key);
    // cprint(key);
    for (unsigned int i = 0; i < sizeof(key); i++) {
        print_hex(key[i]);
        // uart_putc(' ');
    }
    print("\n");
    // Perform "decryption"
    /// decrypt(decrypted_data, encrypted_len, password, sizeof(password) - 1);
    

    // // Print decrypted data
    // print("Decrypted data: ");
    // for (unsigned int i = 0; i < encrypted_len; i++) {
    //     print_hex(decrypted_data[i]);
    //     uart_putc(' ');
    // }
    // print("\r\n");

    // // Attempt to print as ASCII
    // print("Decrypted as ASCII: ");
    // for (unsigned int i = 0; i < encrypted_len; i++) {
    //     if (decrypted_data[i] >= 32 && decrypted_data[i] <= 126) {
    //         uart_putc(decrypted_data[i]);
    //     } else {
    //         uart_putc('.');
    //     }
    // }
    // print("\r\n");

    // print("Decryption complete.\r\n");

    while(1) {}
}

