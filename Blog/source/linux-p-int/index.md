---
title: The Linux programming interface
date: 2018-08-16 09:21:16
---

#### **Chapter 56**

1. **Socket file descriptor:**

```c
fd = socket(domain, type, protocol)
```

* The domain param could be chosen from AF_UNIX, AF_INET and AF_INET6, indicating local, IPv4 and IPv6 domains.
* There are two types of sockets: stream and datagram (SOCK_STREAM or SOCK_DGRAM). Stream type is reliable (guaranteed transmission if network link is up), bidirectional and of no limitations about message boundaries (byte-stream). Stream socket could be connected to one peer only.
* >In the internet domain, datagram sockets employ UDP while stream sockets employ TCP.

2. **Socket system calls**

Besides common function calls like socket(), bind(), listen(), accept() and connect() etc., there are ways to operate non-blocking socket I/O. The following contents focus mainly on the client side using TCP stream.

* In Socket(), the protocol param is a fixed value, i.e., 0. Zero value matches the values used in the type param.
* Servers usually employ bind() so that clients can locate the socket.

The interaction between server and client could be think of in the following way:

* The server creates a socket, and then bind a specific address, followed by listening for client connections. It could decide whether to accept a connection.
* The client creates a socket and use this socket to try to connect to the server.

The function call for connect() and the definition of sockaddr are shown as below:
```c
#include <sys/socket.h>

int connect(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
```

```c
struct sockaddr {
  sa_family_t sa_family;    // Address family (AF_* constant)
  char sa_data[14]          // Socket address (size varies according to socket domain)
};
```

>The connect() system call connects the active socket referred to by the file descriptor sockfd to the listening socket whose address is specified by addr and addrlen. If connect() fails and we wish to reattempt the connection, the portable method of doing so is to close the socket, create a new socket, and reattempt the connection with the new.

In 56.5.4, the I/O methods of conducting UNIX domain stream packets are listed. Basically, read(), write(), send() and recv() could be used in either clients or servers. Need more specification on each call like non-blocking or blocking.

***

#### **Chapter 59**

I will be focusing on IPv4 TCP stream in this chapter. Again, internet domain sockets could be implemented on top of TCP. They provide a reliable, bidirectional, byte-stream communication channel.

* We need to use function like htons, htonl to translate host names to network bytes, or use ntohs() and ntohl() vise versa. The naming conversion of htonl follows **h**ost **to** **n**etwork **l**ong.
* *$ telnet host port* could be used to debug applications.

IPv4 socket address, struct sockaddr_in, defined in <netinet/in.h> as follows:

```c
struct in_addr {       // IPv4 4-byte address.
  in_addr_t s_addr;    // Unsigned 32-bit integer.
};

struct sockaddr_in {           // IPv4 socket address.
  sa_family_t sin_family;      // Address family (AF_INET).
  in_port_t   sin_port;        // Port number.
  struct in_addr sin_addr;     // IPv4 address.
  unsigned char __pad[X];      // Pad to size of 'sockaddr' structure (16 bytes).
};
```

Note taht sin_port and sin_addr should be in network byte order. Hence, there should be a conversion from host to the network byte order. More commonly used methods for IPv4/v6 with dotted-decimal or hex-string conversion to presentation format are inet_pton() and inet_ntop(), defined in *arpa/inet.h*.

An example of a TCP client connection could be the following:

```c
// rp is the info collected from available TCP connections. We don't need to find
// available ones if fixed port and address are specified.
int cfd = socket(rp->ai_family, rp->ai_socktype, rp->ai_protocol);
// Handle cfd if equals to -1.
int cnt = connect(cfd, rp->ai_addr, rp->ai_addrlen);
// Handle cnt if equasl to -1. If connection failure, call close().
close(cfd);
```

***

#### **Chapter 61**

Socket-specific I/O system calls: recv() and send():

```c
#include <sys/socket.h>

//Returns number of bytes received, 0 on EOF, or –1 on error.
ssize_t recv(int sockfd, void *buffer, size_t length, int flags);

ssize_t send(int sockfd, const void *buffer, size_t length, int flags);
```

There are some bits could be ORed in flags param. Interesting bits are: MSG_DONTWAIT denotes non-blocking operations. This bit will return error EAGAIN if no data is available, but may not be available to Linux programmers. However, a reference to Chapter 44 section 44.9 elaborates an alternative to configure a nonblocking I/O for a file descriptor, which could be used for read(), write(), recv() and send(). Table 44-1 presents a nice chart of blocking and nonblocking behaviors of I/O. The following code presents an example:

```c
int flags;

flags = fcntl(fd, F_GETFL); // Fetch open files status flags 
flags |= O_NONBLOCK;        // Enable O_NONBLOCK bit
fcntl(fd, F_SETFL, flags);  // Update open files status flags

// And to disable it, we write the following:
flags = fcntl(fd, F_GETFL);
flags &= ~O_NONBLOCK;       // Disable O_NONBLOCK bit
fcntl(fd, F_SETFL, flags);
```

A example of a simple client and server program could be viewed in http://www.linuxhowtos.org/C_C++/socket.htm.