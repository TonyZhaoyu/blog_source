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

Authentication also provides non-repudiation, which means once authenticated, someone cannot deny any actions.

|  | Key | Authenticity | Integrity | Non-repudiation |
| -- | -- | -- | -- | -- |
| Hash |  |  | Yes |  |
| Message Authentication Code (MAC) | Symmetric | Yes | Yes |  |
| Digital Signature | Asymmetric | Yes | Yes | Yes |

* Digital signature provides non-repudiation assurance because every party to a communication has a unique key which they sign the message. The following diagrams illustrates a digital signature verification process:

![Sender of Digital Signature](https://github.com/TonyZhaoyu/blog_source/blob/master/pics/digital_signature/Sender.png?raw=true)

![Receiver of Digital Signature](https://github.com/TonyZhaoyu/blog_source/blob/master/pics/digital_signature/Receiver.png?raw=true)

* The above method ensures the integrity of the message, and the message itself could be encrypted.

##### Mobile Data with Crypto

* Authenticity verifies the origin of the data, while integrity verifies the message is intact.

* To safely deliver `public keys` to others, we wrap them in x.509 certificates.

* Root of trust:
Trust is central to public key cryptography. To trust a cert, you must trust the cert used to sign that cert. To trust that signing certificate, you must trust its signer. The process continues until you reach a final root cert. The root cert is a special self-signed cert where the private key is highly guarded, and the corresponding public key is distributed with operating systems and web browsers.

* How digital signature works:
Usually use a hash function to hash the whole file to produce a certain length of the string, and then encrypt the string using a private key to create a digital signature. The receiver of the digital signature first decrypts the digital signature, and get the hash. Then produce a hash based on the received message. Next compare the produced hash with the decrypted hash to check authenticity and integrity.

* Cryptographically secured hash function in a nutshell:
    1. Any input produces a completely unique hash output of a fixed length.
    2. Event minor differences between two inputs will create substantially different outputs.
    3. Hash functions are useful for `storing password`, producing file checksums, and to identify specific files or data.

    A typical use-case of hashing to store a password is:
    > To integrate hashing in the password storage workflow, when the user is created, instead of storing the password in cleartext, we hash the password and store the username and hash pair in the database table. When the user logs in, we hash the password sent and compare it to the hash connected with the provided username. If the hashed password and the stored hash match, we have a valid login. It's important to note that we never store the cleartext password in the process, we hash it and then forget it.

    4. A salt is random data added to the hashing process to ensure that no two passwords produce the same hash. The salt is saved as a pseudo-secret that the application later uses when comparing passwords.

* TLS supports various crypto methods by providing a cipher suites (illustrated below).
    ![Cypher suite](https://github.com/TonyZhaoyu/blog_source/blob/master/pics/digital_signature/Cypher_suite.png?raw=true)

* Best practices to ensure secure data communication:

    1. Use TLS on all network comm.
    2. Use built-in libraries.
    3. Only use TLS - never SSL.
    4. Choose strong cypher suites.
    5. Never use `self-signed certs`.
    6. Verify cert chains.
    7. Alert users of invalid certs.
    8. Keep sensitive data out of URL.

#### Architecture Risk Analysis and Remediation

* Impact vs. probability.

* Risk management:

    1. Reduce risk, e.g., TLS to all comm to stop eavesdropping.
    2. Avoid risk, e.g., if a new feature is to violate company's risk tolerance, it may be necessary to exclude the feature.
    3. Transfer risk, e.g., transfer the risk a third party.
    4. Accept risk, e.g., low risk probability and high cost for mitigation.

* Data types:

    1. Data at rest. Best practices include:
        1.1 Choosing appropriate algorithms.
        1.2 Using trusted implementations of such algorithms.
        1.3 Using pseudo-random number generators.
        1.4 Using keys of sufficient length, using strong keys and protecting keys.

        Use AES for encryption. Use CBC (cypher-block chaining) for symmetric algorithms.

    2. Data in transit.
    3. Data in use.

        Least privilege principle: It states that only the least amount of privileges necessary to complete an action should be granted.
        For example: if you have multiple encrypted storage containers and you need to use some data, you should only decrypt the ones that contain the data you need, rather than decrypting all the containers.

        Anonymization: it means removing all the info from the data set that can be used to uniquely identify individuals describe in the data set. 

        Pseudonymization: it is similar with anonymization, except instead of removing personal info, it is replaced with aliases like numbers, strings, or fictional names. When it is applied to a data set, it is still possible to distinguish individuals in the data set, but it should not be possible to link these individuals to their real-world identities.

        > SSID and passphrase might be insensitive if the SSID and passphrase is not linked to any personal data.
        > Key used in RAM should be cleared (like encryption and decryption) as soon as related actions have been done.


#### Some best practices for attack surface analysis

* Shorten the code. Remove what's not necessary.
* Reduce the number of entry points available to anonymous or untrusted users.
* Remove any privileges that are not explicitly required by the application.

#### OWASP 2017 Top10 mitigation


#### Thread modelling basics

* Thread modelling process includes: identify security objectives --> create an application overview --> decompose your application --> identify threats --> identify vulnerabilities --> application overview. It is a iterative process and could be enhanced at run-time.

1. Security objectives could be categorized using: Confidentiality, Integrity and Availability.
    > Availability: ensures that users are always able to access a system. E.g., server uptime under attack and DoS resistance.

    Examples of objectives include `Prevent attackers from obtaining data`, `Meet service-level agreements` and `Protect the company's credibility`.

2. To create an application overview:
    2.1 Could start with end-to-end deployment diagram. Like network topology and interfaces.
    2.2 Add logical layers. Refine the diagram to include physical server boundaries when known.
    2.3 Role identification in the diagram. Like who is able to access which data.
    2.4 Well scope the project.
    2.5 List the tech and key features of the software and platforms.
    2.6 There are some aspects of security mechanisms to be referred to: Input and Data Validation, Authentication, Authorization, Configuration Management, Session Management, Cryptography, Sensitive Data Handling, Parameter Manipulation, Exception Management and Auditing and Logging.

3. To decompose your application:
    3.1 Identify Trust Boundaries.
    3.2 Identify Data Flows.
    3.3 Identify Entry Points.
    3.4 Identify Exit Points.

4. To identify threats:
    Communicate with different roles in the project like architects, developers and testers. Usually the following aspects will be considered:

    4.1 Common Threats.
    4.2 Threats Along Use Cases.
    4.3 Threats Along Data Flows.

5. To identify vulnerabilities:
    Examining the application layer-by-layer based on the identified threats.

Key contents in a report/documentation could include: security objectives, key scenarios, protected resources, threat list and vulnerability list.


#### Fundamentals of IoT Architecture and Design

Think of two classes to categorize security requirements:
    * User access.
        1. How can users access IoT system? Via cloud, device or Mobile App.
        2. What is the user's classification? Resources and services? Changes to info? Features and functions?
        3. What type of security screenings are required? Passwords or pins? Tokens or certs?
    * External device access.
        1. What types of devices can connect to the system? Mobile? Diagnostic tools? IoT devices?
        2. How can devices connect to the IoT system? Wireless?
        3. What is the device's classification? Query info? Features and functions?
        4. What type of security screenings are required? Tokens or cert? Dongles?

Characteristics are needed for securing remote access:

    * How long should an active session last?
    * When should session configuration occur?
    * How dynamic are sessions between devices?
    * Should there be different standards of secure remote access?


Application security (AppSec) implications:

    * During the requirements and design phases, determine how IoT system components interact with outside entities
        1. Software tampering
        2. Configuration management
        3. Session management
        4. Exception management

    * Design the processes necessary to detect and handle these categories
    * Factor in the capability to allow for future updates
    * Review what external support parameters are required to configure these processes
        1. Where stored
        2. How distributed and updated
    
    * Determine what levels of performance are expected between the cloud and IoT devices and between IoT devices themselves.
    * Minimize the number of intervening layers between detection and handling while processing remote access requests.


General rules to follow for cryptographic storage include:
    * Only store sensitive data that you need.
    * Use strong approved authenticated encryption that:
        a. Uses approved cryptographic modes.
        b. Uses strong random numbers.
        c. Uses authenticated encryption of data.
    * Store a one-way and salted value of passwords.
    * Ensure that the cryptographic protection remains even if access control fails. 
    * Ensure that any secret key is protected from unauthorized access that:
        a. Defines a key lifecycle
        b. Stores unencrypted keys away from the encrypted data
        c. Uses independent keys when multiple keys are required
        d. Protests keys in a key vault
        e. Documents concrete procedures for managing keys through lifecycle
        f. Builds support for changing algorithms and keys when needed
        g. Documents concrete procedures to handle a key compromise
        h. Limits quantity of data encrypted with one key
    * Follow applicable regulations on use of cryptography, such as under PCI DSS requirement 3, you must protect cardholder data.

