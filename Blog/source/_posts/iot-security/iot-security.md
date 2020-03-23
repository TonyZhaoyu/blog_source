---
title: Basics and Concepts in Secured Connectivity
date: 2020-03-17 17:47:42
categories:
- [IoT Security]
---

Some basics of cryptography will be addressed in the mean time. This is mainly to address secured connectivity to cloud.

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

#### Algorithms and Key Management

##### Randomness

Randomness is critical to **unpredictable** key generation. Some hardware contributes to randomness by what's called RNG. Some cases that is not able to leverage hardware resources could use seed sources of high entropy to produce unpredictable **pesudorandom** numbers. A seed is a number or vector (e.g., `IV` initialization vector) used to initialize a PRNG.

> `Entropy` is a measure of the disorder (randomness) in a system. Hence, we could say that a system has a high entropy source.

##### Algorithms

There are three major types of algorithms: hash functions, ciphers and encoders. Please notice the difference between **hashing** and **hash functions**.

* Hash functions takes *arbitrarily-sized* input ==> a shorter, *fixed-length* output.
* Cyphers are used to encryption and decryption. Refer to the last section.
* Encoders are not related to security. Refer to Base64 for more information.

What are algorithms been used:

* Pseudorandom number generation.
* Key generation and management.
* MAC (**message authentication code**) creation and validation.
* Digital signature creation and validation.
* Digital certification creation and validation.

##### Keys

Symmetric keys are used in cyphers and MAC (message authentication code). Asymmetric keys are used in cyphers and digital signatures.

* Asymmetric keys contains public keys and private keys.
    1. Public keys are used to encrypt plaintext and verify digital signatures.
    2. Private keys are used to decrypt ciphertext and create digital signatures.

A problem comes with public key is that how to ensure the authenticity of the public key's origin? Digital certificate (cert) verifies such an authenticity, and the cert itself is verified by a trusted 3rd-party (namely, CA). See the following section.

* Public key distribution could be done in two ways below:
    1. Out-of-band distribution of public key fingerprints. A fingerprint is a shorter version of the key's characters, e.g., a hash of the key and associated identify info. Recall the method I used to send emails at Silabs security cause. We need Slack to verity the fingerprint of the public key.
    2. Digital certificates. A digital cert is used to prove ownership of a public and private key pair. It usually issued by a trusted 3-party which usually includes:
        2.1 Public key.
        2.2 Key Owner.
        2.3 Key Issuer.
        2.4 Expiration date.
        2.5 A digital signature that validates the integrity of the certificate and the authenticity of the issuer.

* Certificate could be signed by a previous certificate in a chain of trust.

* Public key infrastructure, i.e., PKI supports issuance, maintenance and revocation of digital certs. CA (certificate authority) is part of PKI.

##### Cryptography in Applications

Protected communications could be done on a authentic channel, a confidential channel and a secured channel. Check the following diagram to see certain resistance of each channel:

|  | Disclosure Resistant | Tamper Resistant |
| ---- | ---- | ---- |
| Authentic Channel |  No | Yes |
| Confidential Channel | Yes | No |
| Secure Channel | Yes | Yes |

* Tampering is defined as an attack against integrity, authenticity, or availability.

The tutorial video appears to be very `confusing`.

##### Message Integrity

Tampering is an attack against `integrity`, `authenticity` and `availability`. 

* To understand availability, here is something:
    > When a system is regularly non-functioning, information availability is affected and significantly impacts users.

* Message integrity indicates that the message is not spoofed (e.g., send email impersonate a contact) or forged (modified info):
    1. Replaying message attack.
    2. Creating a message pretending to be someone you are not.

A diagram shows message integrity functions:

> Non-repudiation is the assurance that someone cannot deny something. Typically, non-repudiation refers to the ability to ensure that a party to a contract or a communication cannot deny the authenticity of their signature on a document or the sending of a message that they originated.

|  | Key | Authenticity | Integrity | Non-repudiation |
| -- | -- | -- | -- | -- |
| Hash |  |  | Yes |  |
| Message Authentication Code (MAC) | Symmetric | Yes | Yes |  |
| Digital Signature | Asymmetric | Yes | Yes | Yes |

* Digital signature provides non-repudiation assurance because every party to a communication has a unique key which they sign the message. The following diagrams illustrates a digital signature verification process:

![HACK computer overview](https://github.com/TonyZhaoyu/blog_source/blob/master/pics/digital_signature/Sender.png?raw=true)

![HACK computer overview](https://github.com/TonyZhaoyu/blog_source/blob/master/pics/digital_signature/Receiver.png?raw=true)

* The above method ensures the integrity of the message, and the message itself could be encrypted.