---
title: Paho.mqtt.c library notes
date: 2018-08-16 20:43:20
categories:
- [Coding, Open-Source Notes]
---

#### **Use MQTT client library**

In the library's source code, there are implementations of Socket. The following content tries to figure out what APIs defined in Socket have been used in MQTTAsync.c.

To begin with, here's a briefing of using MQTTAsync.c. An example could be found in 'transport-mqtt' plugin.

1. When emberAfPluginTransportMqttInitCallback() is called by ember AF, a mutex would firstly be created for connection status.
2. In the same callback (i.e., emberAfPluginTransportMqttInitCallback), two MQTT methods are to be called to initialize MQTT comm. They are MQTTAsync_create() and MQTTAsync_setCallbacks().
3. A few callbacks or configurations are of the most interests. They are either been passed to MQTTAsync_setCallback(), or been set in mqttConnectOptions. One of them is **mqttMessageArrivedCallback** where MQTT message would be passed into another callback (i.e., **emberAfPluginTransportMqttMessageArrivedCallback**) whose implementation residing in gateway-relay-mqtt.c. Another configuration is keepAliveInterval, which I guess is to maintain the connection between the client and the broker.
4. In transport-mqtt.h, two APIs are provided: **emberAfPluginTransportMqttSubscribe()** and 
**emberAfPluginTransportMqttPublish()**. They will be called by gateway-relay-mqtt.c.
5. emberAfPluginTransportMqttPublish() calls MQTTAsync_sendMessage defined in MQTTAsync.h.

***

#### **MQTTAsync and Linux Socket**

We could see in the src folder that paho.mqtt.c implement Socket.c. The implementation provides wrapper functions for creating or closing TCP sockets, and for receiving and sending via a socket in a non-blocking fashion. Socket.c also allows multiple socket connection, which I guess such a feature could be used for local or remote server connections.

The APIs of most interests are:

1. **Socket_new()**: in which socket() method is called.
2. **Socket_close()**: in which close() method is called.
3. **Socket_getdata()** or **Socket_getchar()**: in which recv() method is used.
4. **Socket_putdatas()**: calls an internal function Socket_writev().

The internal functions of most interests are:

1. **Socket_writev()**: which eventually calls *writev()* functions defined in *sys/uio.h*.
2. **Socket_setnonblocking()**: which calls *fcntl()* eventually.

A description of readv() and writev() is as below:

>The data transfers performed by readv() and writev() are atomic: the data written by writev() is written as a single block that is not intermingled with output from writes in other processes (but see pipe(7) for an exception); analogously, readv() is guaranteed to read a contiguous block of data from the file, regardless of read operations performed in other threads or processes that have file descriptors referring to the same open file description (see open(2)).

A code example shows combining two strings into one buffer and send them using writev().

```c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/uio.h>

int main()
{
    char *str0 = "hello ";
    char *str1 = "world\n";
    struct iovec iov[2];
    ssize_t nwritten;

    iov[0].iov_base = str0;
    iov[0].iov_len = strlen(str0);
    iov[1].iov_base = str1;
    iov[1].iov_len = strlen(str1);

    nwritten = writev(STDOUT_FILENO, iov, 2);
    printf("%ld bytes written.\n", nwritten);

    exit(EXIT_SUCCESS);
}
```

Execution results:

```bash
$ gcc writevex.c 
$ ./a.out 
hello world
12 bytes written.
```

**Here is the function call tracing for Socket_new()**:

* Socket_new() is called by MQTTProtocol_connect() defined in MQTTProtocolOut.c.
* MQTTProtocol_connect() is called by MQTTAsync_processCommand() defined in MQTTAsync.c, specifically in the case of CONNECT (command->command.type == CONNECT).
* MQTTAsync_processCommand() is called by MQTTAsync_sendThread() defined in MQTTAsync.c. There are two threads created when start up. MQTTAsync_sendThread is one of them, and the other is MQTTAsync_receiveThread.

**Here is the function call tracing for Socket_getdata()**:

* Socket_getdata() is called by WebSocket_getRawSocketData() defined in WebSocket.c.
* WebSocket_getRawSocketData() is a static function and is called mostly by WebSocket_receiveFrame() and WebSocket_upgrade() methods. Pick receiveFrame method as the next tracing function because the name makes more sense.
* WebSocket_receiveFrame() is a static function which is called by either WebSocket_getdata() or WebSocket_getch().
* WebSocket_getdata() is called by MQTTPacket_Factory() defined in MQTTPacket.c.
* MQTTPacket_Factory() is called by either MQTTClient_cycle() defined in MQTTClient.c or MQTTAsync_cycle() defined in MQTTAsync.c. Both of them are static functions. Notice MQTTClient represents synchronous comm, while MQTTAsync represents asynchronous comm.
* **MQTTAsync_cycle()** is called within MQTTAsync_receiveThread().

**Here is the function call tracing for Socket_putdatas()**:

* Socket_putdatas() is called by multiple methods in WebSocket.c. One of them is of the most interest, which is WebSocket_putdatas().
* WebSocket_putdatas() is called by MQTTPacket_send() and MQTTPacket_sends() methods in MQTTPacket.c, indicating sending one-byte or bytes respectively.
* MQTTPacket_sends() is a static method, and is called by MQTTPacket_send_publish(). MQTTPacket_send() is a static method, and is called by MQTTPacket_send_disconnect(). We will focus on tracing MQTTPacket_send_publish().
* MQTTPacket_send_publish() is called by static functions MQTTProtocol_startPublishCommon() and MQTTProtocol_retries() in MQTTProtocolClient.c.  
* MQTTProtocol_startPublishCommon() is called by MQTTProtocol_startPublish().
* MQTTProtocol_startPublish() is called by MQTTAsync_processCommand() in MQTTAsync.c.
* Similar as Socket_new(), MQTTAsync_processCommand() is called by MQTTAsync_sendThread() defined in MQTTAsync.c. There are two threads created when start up. MQTTAsync_sendThread is one of them, and the other is MQTTAsync_receiveThread.

***

#### **Multi-threads in MQTTAsync**

There's a commands list (a linked list) created at startup. This commands list could be inserted with commands by MQTTAsync_addCommand(). MQTTAsync_addCommand() is called in multiple conditions. For example, one condition where MQTTAsync_send() is called by an application, the command initiated by the application will be inserted into the command list and will be processed by MQTTAsync_processCommand().

It's observable that the commands list is shared between the main thread and the MQTTAsync_sendThread as MQTTAsync_processCommand() is called within this thread. The way to synchronize both threads is based on a signal condition namely *send_cond*, and a mutex namely *mqttcommand_mutex*.

As for MQTTAsync_receiveThread(), we could know:

* We need to specify a callback when message is arrived. This callback would be called by MQTTAsync_deliverMessage().
* MQTTAsync_deliverMessage() is called by MQTTAsync_receiveThread() in the condition where the rc set by *MQTTAsync_cycle(&sock, timeout, &rc);* does not equal to SOCKET_ERROR.
* Tracing back, we could find an instance of *MQTTAsyncs* structure type which has a client pointer which points to a message buffer. The code snippet is shown below:

```c
if (m->c->messageQueue->count > 0)
{
  qEntry* qe = (qEntry*)(m->c->messageQueue->first->content);
  int topicLen = qe->topicLen;

  if (strlen(qe->topicName) == topicLen)
    topicLen = 0;

  if (m->ma)
    rc = MQTTAsync_deliverMessage(m, qe->topicName, topicLen, qe->msg);
  else
    rc = 1;
  if (rc)
  {
#if !defined(NO_PERSISTENCE)
    if (m->c->persistence)
      MQTTPersistence_unpersistQueueEntry(m->c, (MQTTPersistence_qEntry*)qe);
#endif
    ListRemove(m->c->messageQueue, qe); /* qe is freed here */
  }
  else
    Log(TRACE_MIN, -1, "False returned from messageArrived for client %s, message remains on queue",
      m->c->clientID);
}
```

* There is a shared buffer storing the incoming MQTT messages. It looks a bit complicated as QoS is involved, but the basic concept is to run MQTTAsync_cycle() once to read from sockets then call the registered callback in the app layer. A mutex namely mqttasync_mutex is used to protect the shared buffer.
* For the timeout of sendThread, it has been set in Thread_wait_cond(), which is 1 second.
* For the timeout of receiveThread, it could eventually calls MQTTAsync_sleep() with value of 100 milliseconds.

***

#### **Ember Application Framework**

The application Z3GatewayHost could be running on a Linux machine. It could also be equipped with a MQTT client and talks to a MQTT broker using the APIs defined in UG129. The MQTT client is based on paho.mqtt.c library, which invokes two threads (total three considering the main thread) when executing. It's nature to wonder how to integrate a multi-threaded library into the Ember application framework without destroying anything. The answer is quite straightforward. In short, multi-threads won't interfere anything in the Ember framework.

Z3GatewayHost is a process which forks a child process to handle UART comm. *paho.mqtt.c* creates two thread when startup, and such a creation is done during the framework's initialization. Since the command to be sent to MQTT server is queued up in a shared buffer, the main thread (where ember framework runs) could send and exit in a non-blocking behavior. This is critical to the framework as ember stack error may happen if blocking operations are conducted. On the other hand, if the MQTT message from the broker is a *command* type, it will call the handleCommandMessage() handler, and add this command to a command list. This also prevents a blocking execution of a command. A looped event (20 milliseconds' period) pops a command from the list and send the command through ezsp or internal handlers.