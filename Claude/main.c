#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <gpgme.h>
#include <locale.h>

#define MAX_PASSWORD_LENGTH 256

static const char password[] = "password";

// Hex-encoded encrypted data
static const char hex_data[] = "8c0d04030302eb381c55fecc8f2fffd244018c41f4e16990d9c846cafc6b04bc37e07a9248110a6f11104cfe744d2b2646228c15528525668b97f31bab07bfbcedd0628492ee96bf11e8a4be3aa6e9994901d91195";

gpgme_error_t passphrase_cb(void *hook, const char *uid_hint, const char *passphrase_info,
                            int prev_was_bad, int fd) {
    gpgme_error_t err;
    err = gpgme_io_write(fd, password, strlen(password));
    if (err == 0)
        err = gpgme_io_write(fd, "\n", 1);
    return err;
}

// Function to convert hex string to bytes
void hex_to_bytes(const char* hex_str, unsigned char* bytes, size_t length) {
    for (size_t i = 0; i < length; i++) {
        sscanf(hex_str + 2*i, "%2hhx", &bytes[i]);
    }
}

int main() {
    setlocale(LC_ALL, "");
    gpgme_check_version(NULL);
    gpgme_set_locale(NULL, LC_CTYPE, setlocale(LC_CTYPE, NULL));

    gpgme_error_t err;
    gpgme_ctx_t ctx;

    err = gpgme_new(&ctx);
    if (err) {
        fprintf(stderr, "Error creating GPGME context: %s\n", gpgme_strerror(err));
        return 1;
    }

    gpgme_set_protocol(ctx, GPGME_PROTOCOL_OpenPGP);
    gpgme_set_armor(ctx, 0);  // Set to 0 for binary data

    // Set up passphrase callback
    gpgme_set_passphrase_cb(ctx, passphrase_cb, NULL);

    // Convert hex data to bytes
    size_t data_len = strlen(hex_data) / 2;
    unsigned char* encrypted_data = malloc(data_len);
    hex_to_bytes(hex_data, encrypted_data, data_len);

    // Create input data object
    gpgme_data_t in_data;
    err = gpgme_data_new_from_mem(&in_data, (char*)encrypted_data, data_len, 1);
    if (err) {
        fprintf(stderr, "Error creating input data object: %s\n", gpgme_strerror(err));
        gpgme_release(ctx);
        free(encrypted_data);
        return 1;
    }

    // Create output data object
    gpgme_data_t out_data;
    err = gpgme_data_new(&out_data);
    if (err) {
        fprintf(stderr, "Error creating output data object: %s\n", gpgme_strerror(err));
        gpgme_data_release(in_data);
        gpgme_release(ctx);
        free(encrypted_data);
        return 1;
    }

    // Decrypt the data
    err = gpgme_op_decrypt(ctx, in_data, out_data);
    if (err) {
        fprintf(stderr, "Decryption failed: %s\n", gpgme_strerror(err));
        gpgme_data_release(in_data);
        gpgme_data_release(out_data);
        gpgme_release(ctx);
        free(encrypted_data);
        return 1;
    }

    // Retrieve the decrypted data
    size_t decrypted_length;
    char* decrypted_data = gpgme_data_release_and_get_mem(out_data, &decrypted_length);
    if (decrypted_data) {
        printf("Decrypted data: %.*s\n", (int)decrypted_length, decrypted_data);
        gpgme_free(decrypted_data);
    } else {
        fprintf(stderr, "Failed to retrieve decrypted data\n");
    }

    // Clean up
    gpgme_data_release(in_data);
    gpgme_release(ctx);
    free(encrypted_data);

    return 0;
}