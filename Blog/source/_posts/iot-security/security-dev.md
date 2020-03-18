---
title: Security Development Jotting
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
