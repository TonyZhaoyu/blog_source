---
title: Security Processes in WiFi Devices
date: 2020-03-17 17:47:42
categories:
- [IoT Security]
---

This article analyzes common ways to secure connectivity between a WiFi device and cloud. Some basics of cryptography will be addressed in the mean time.

#### Basics of Cryptography

* `Encoding` and `Decoding` offer no **confidentiality** to information. And hence no keys involved.

    > `Base64` is a method to encode. Encode helps to store, transmit or read binary data. If ASCII is used to represent a binary, it is very likely to fail encoding many characters as it ranges from 0x00 ~ 0x7F.

* There are two types of `Encryption` and `Decryption`: symmetric and asymmetric, which involves two types of ciphers and keys.
    
    1. `Cyphers` are computation methods (like algorithms) that require a `key` to conduct computation.
    2. Symmetric cyphers require only one key to encrypt and decrypt. And it has the following advantage and disadvantage to asymmetric cyphers.
        *Advantage 1*: In general, symmetric cyphers are faster than asymmetric cyphers, and usually hardware acceleration supports such cyphers.
        *Advantage 2*: Symmetric cyphers require shorter key length to achieve a given strength.
        *Disadvantage 1*: Key distribution. If it's compromised, any messages will be transparent.

    > HTTPS leverages the TLS, which use both symmetric and asymmetric ciphers. After a encrypted connection is established using asymmetric cipher, the client and server will exchange a symmetric key and establish a new encrypted connection to improve efficiency.

* `Hashing` is a way to ensure **integrity** of a message. A given hash function always produce the **same length hash value**, regardless of the size of the input.

    > A good hash function is able to indicate minor changes of the message. In other words, a minor change of the message would result in significant changes in the hash value. Examples are SHA-1 and SHA-256.

