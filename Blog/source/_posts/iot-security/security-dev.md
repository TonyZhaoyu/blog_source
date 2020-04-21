---
title: Software Security Development Jotting
date: 2020-03-16 17:47:42
categories:
- [IoT Security]
---

Multiple roles involved in the security development lifecycle (SDL in short). The following content focuses on software designing, development and testing.

#### Design Architect

##### Character responsibilities

* Identify and document each interfaces of the product, including physical and logical interfaces. This may also be known as `Threat Modeling`. Regarding security, the following is worth noting: 
    1. List security implications and trust boundary per interface.
    2. List possible threats or constrains per interface.
    3. Identify access control to each interface, like whether it needs authentication.

* The concept of defence in depth involves multiple layers of defences. If one layer is compromised, other layers should be able to prevent the system from complete compromise.

#### Software Security Development

Requirements --> Design --> Development --> Testing --> Deployment --> Maintenance

##### Software security requirements

* Legal security requirements.
* Customer security requirements and technical requirements

##### Designing secure software

`Thread modeling` please refers to related topics in `iot-security.md`.

The following aspects could be considered during threat modeling:
    * Attacker-centric: attacker motives and techniques are well understood.
    * Software-centric: provides a service like stock data.
    * Asset-centric: select if sensitive data are processed.

Recall concepts in `iot-security.md`. Some application security principles are listed here:
    * Attack surface reduction.
    * Secure defaults. NOT leave insecure settings in place for the components and services of your application, and design your app to use the most secure settings by default.
    * Least privileges.
    * Defence in depth.
    * Compartmentalization (divide into sections or categories). Could design trust boundaries to isolate components from one another.

##### Security development lifecycle

Tools to be used in SDL (in Microsoft):
    * Threat-modeling tool like MSTT to identify threats early in the Design phase.
    * Fault-injection tool to aid with security testing efforts in the Verification phase.
    * Code analysis like static analysis and binary analysis.

Code review in terms of security:
    * OWASP code review guide.
    * SE top 100 security rules.
    * Compile-time and run-time fault injection like `Fuzz testing` uses an automated tool that provides invalid or random input to an application and monitors how the application behaves.


##### Security code review

Best practices:
    * Identify the scope of the code review.
    * Break code review into chunks.
    * Review code iteratively.
    * Set time limits.
    * Create coding standards.

Control flow analysis (what code is executed under what conditions) and data flow analysis (what code handles what data).

Review for unique issues:
    * Look for custom security code.
    * Look for code that uses cryptography.
    * Review authentication and authorization models.

Security risk management basics:
    * Vulnerability: Weakness in the application.
    * Exploit: An application or set of commands to take advantage of vulnerability, like hack into an application. A valid phrase is `exploit vulnerabilities`.
    * Countermeasure: A step taken to `address` or `reduce` the potential for damage caused by a vulnerability in your application code.
    * Risk: The potential for loss or damage to an asset (like a database).

#### OWASP 2017 Mitigation

OWASP: open web application security project.

##### Mitigating injection

SQL injection is one of the most common example of injection. For instance, a URL may be used to check SQL database by something like https://example.com/showosders?customer-id=224 `or 1`. The `or 1` is injected to the normal URL, and could bypass custer-id checking.

##### Mitigating broken authentication

It talks more on session management and password recovery.

##### Mitigating sensitive data exposure

The issues in sensitive data exposure involves insecure crypto storage and insufficient transport layer protection.

Handshake algorithm:
    * Have to determine whether or not you require `perfect forward secrecy`.
    * Handshake with perfect forward secrecy: ECDHE.
    * Handshake without perfect forward secrecy: ECDH.
    * Notice performance may vary case-by-case.

Authentication algorithm:
    * ECDSA and RSA could be selected.
    * The choice is largely dictated by Certificate Authority that issues the cert.
    * ECDSA has better performance, especially combined with ECDHE (Ephemeral).


Best practices to handle TLC certs:
    * Never use self-signed cert.
    * No MD5 hashing.
    * Use RSA or DSA key > 2048 bits


#### Development of secured embedded software

Some memory issues:
    * Buffer overflow
    * Double free
    * Use after free
    * Invalid memory pointers
    * Out of range access
    * Memory leaks
    * Using uninitialized memory

