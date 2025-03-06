import hashlib
import os
from typing import Optional, Tuple, Union
from enum import IntEnum

class S2KMode(IntEnum):
    SIMPLE = 0      # Simple S2K
    SALTED = 1      # Salted S2K
    ITER_SALTED = 3 # Iterated Salted S2K

class OpenPGPKDF:
    def __init__(self, hash_algo: str = 'sha1'):
        """Initialize the KDF with specified hash algorithm."""
        self.hash_algo = hash_algo
    
    def _hash_function(self, data: bytes) -> bytes:
        """Create a new hash object and return the digest of data."""
        h = hashlib.new(self.hash_algo)
        h.update(data)
        return h.digest()
    
    def decode_count(self, encoded_count: int) -> int:
        """
        Decode the S2K iteration count from its encoded form.
        The count is encoded in a single octet using a sliding scale.
        Count = (16 + (encoded_count & 15)) << ((encoded_count >> 4) + 6)
        """
        if encoded_count < 0 or encoded_count > 255:
            raise ValueError("Invalid encoded count")
            
        # RFC 4880 specifies that count = (16 + (encoded_count & 15)) << ((encoded_count >> 4) + 6)
        count = (16 + (encoded_count & 15)) << ((encoded_count >> 4) + 6)
        return count
    
    def derive_key(self, 
                  passphrase: str,
                  key_length: int,
                  mode: S2KMode = S2KMode.ITER_SALTED,
                  salt: Optional[bytes] = None,
                  count: Optional[int] = None) -> Tuple[bytes, bytes]:
        """
        Derive a key using OpenPGP S2K specification.
        
        Args:
            passphrase: The passphrase to derive the key from
            key_length: The desired length of the output key in bytes
            mode: S2K mode (0 = Simple, 1 = Salted, 3 = Iterated+Salted)
            salt: 8-byte salt (required for modes 1 and 3)
            count: Iteration count (required for mode 3)
            
        Returns:
            Tuple of (derived_key, salt)
        """
        if not isinstance(passphrase, str):
            raise TypeError("Passphrase must be a string")
            
        passphrase_bytes = passphrase.encode('utf-8')
        
        if mode in (S2KMode.SALTED, S2KMode.ITER_SALTED):
            if salt is None:
                salt = os.urandom(8)  # Generate random 8-byte salt
            elif len(salt) != 8:
                raise ValueError("Salt must be exactly 8 bytes")
        
        # Buffer to accumulate the derived key material
        derived_key = bytearray()
        
        # Counter for the hash prefix (OpenPGP specification)
        prefix_counter = 0
        
        while len(derived_key) < key_length:
            if mode == S2KMode.SIMPLE:
                # Simple S2K: just hash the passphrase
                prefix = bytes([prefix_counter]) if prefix_counter > 0 else b''
                hash_input = prefix + passphrase_bytes
                derived_key.extend(self._hash_function(hash_input))
                
            elif mode == S2KMode.SALTED:
                # Salted S2K: hash(salt + passphrase)
                prefix = bytes([prefix_counter]) if prefix_counter > 0 else b''
                hash_input = prefix + salt + passphrase_bytes
                derived_key.extend(self._hash_function(hash_input))
                
            elif mode == S2KMode.ITER_SALTED:
                if count is None:
                    raise ValueError("Iteration count required for mode 3")
                
                # Iterated Salted S2K
                prefix = bytes([prefix_counter]) if prefix_counter > 0 else b''
                base_data = prefix + salt + passphrase_bytes
                
                # Create an extended buffer for iteration
                data_to_hash = bytearray()
                remaining_bytes = count
                
                while remaining_bytes > 0:
                    if remaining_bytes > len(base_data):
                        data_to_hash.extend(base_data)
                        remaining_bytes -= len(base_data)
                    else:
                        data_to_hash.extend(base_data[:remaining_bytes])
                        remaining_bytes = 0
                
                derived_key.extend(self._hash_function(bytes(data_to_hash)))
            
            prefix_counter += 1
        
        # Trim to the requested key length
        return bytes(derived_key[:key_length]), salt if salt else b''

# Example usage matching the GPG file parameters:
def example_usage():
    # Create KDF instance with SHA1 (hash 2 in OpenPGP)
    kdf = OpenPGPKDF(hash_algo='sha1')
    
    # Salt from the GPG file
    gpg_salt = bytes([0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x10, 0x11])
    
    # Get iteration count from coded count 255
    iteration_count = kdf.decode_count(255)  # Should be 65011712
    
    # Derive the key using GPG file parameters
    # CAST5 (sym 3) uses 128-bit keys = 16 bytes
    key, salt = kdf.derive_key(
        passphrase="password",
        key_length=16,  # 128 bits for CAST5
        mode=S2KMode.ITER_SALTED,
        salt=gpg_salt,
        count=iteration_count
    )
    
    print(f"Using parameters from GPG file:")
    print(f"Password: 'password'")
    print(f"Salt: {salt.hex()}")
    print(f"Iteration count (coded 255): {iteration_count}")
    print(f"Derived Key (hex): {key.hex()}")

if __name__ == "__main__":
    example_usage()