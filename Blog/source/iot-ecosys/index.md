---
title: SDK review
---

Cloud vendors provide SDKs for developers in favour of easy connectivity. The following content summaries how these SDKs are architected, what software techniques have been deployed, and how APIs are designed. It is notable that only embedded C/C++ version is considered.

1. **AWS IoT platform**

AWS IoT provides amazingly detailed documents on the overall architecture, developer’s guide and porting guide. There are two major features offered by AWS IoT services: MQTT connection and Thing Shadow. Both embedded C/C++ SDKs support such features, and they will be presented in the following content.

[Reference 1]: http://aws-iot-device-sdk-embedded-c-docs.s3-website-us-east-1.amazonaws.com/index.html.

[Reference 2]: https://github.com/aws/aws-iot-device-sdk-embedded-C/blob/master/README.md.

[Reference 3]: https://github.com/aws/aws-iot-device-sdk-embedded-C/blob/master/PortingGuide.md.

  1.1 How AWS IoT cloud works.

Thing shadow is defined as “a JSON document which is used to store and retrieve current state information for a thing” (reproduced in http://docs.aws.amazon.com/iot/latest/developerguide/iot-thing-shadows.html). The state of a IoT thing could be obtained or set through MQTT topics. Thing Shadow related implementations could be found under src folder, with prefix ‘aws_iot_shadow’ in names. Specifically, the implementation contains three basic operations, namely UPDATE, GET and DELETE (http://docs.aws.amazon.com/iot/latest/developerguide/using-thing-shadows.html).

AWS IoT defines a set of APIs based on MQTT topics. As mentioned, there are three parent topics:“aws/things/[thingName]/shadow/update”, “aws/things/[thingName]/shadow/update/get” and “aws/things/[thingName]/shadow/update/delete”. Under each parent topic, there are several sub-topics for better connectivity. For example, to improve QoS of a sent message, one could listen to “aws/things/[thingName]/shadow/update/accepted” and “aws/things/[thingName]/shadow/update/rejected”.
```
Note: Each message sent over a topic could be related to a success/failure notification. For instance, if a message was sent over xxxx/update topic, users could get a notification from either xxxx/update/accepted (indicating success) or xxxx/update/rejected (indicating failure).
```
It is also noteworthy that AWS IoT platform does not allow dynamic device registry without a certificate. Take the following scenario as an example. A new device joined the network via a gateway, and the gateway loyally talks to AWS IoT platform about the newly joined device who is ready to upload data. This is, however, rejected by AWS IoT since it finds out the newly joined does not have a valid certificate. The link below specifies how devices correctly connect to AWS IoT platform (https://software.intel.com/en-us/articles/using-amazon-web-services-aws-iot-with-intel-iot-devices-and-gateways).

* AWS IoT embedded C SDK.

The SDK depends on ARM ‘mbedTLS’ library and ‘jsmn’ library (CppUTest is ignored herein). ‘mbedTLS’ offers a light-weight implementation of cryptographic and SSL/TLS (https://en.wikipedia.org/wiki/Transport_Layer_Security) features. ‘jsmn’ offers a JSON parser that could be deployed on resource-limited platforms. One could find MQTT implementation under src folder, with prefix ‘aws_iot_mqtt_client’ in names. The implementation follows the flavour of IBM’s ‘paho-mqtt’ library, and based on wrappers of the underlying mbedTLS connection.

Note: There is one interesting feature implemented in yield() method, which monitors the health of TCP connection. In a single-threaded implementation, yield() method will be frequently called (https://github.com/aws/aws-iot-device-sdk-embedded-C/blob/master/PortingGuide.md).

* AWS C++ SDK.

In C++ version, three ways of network connection could be selected since resource limitation of a platform will no longer be a big issue. These ways are ‘mbedTLS’, ‘openSSL’ and ‘webSocket’. ‘rapidjson’ (http://rapidjson.org/) is used as the JSON parser. Frankly, the provided sample code is a little messy. This may be due to less typedef usage and nested naming space. But the basic operations were similar to C version.
```
Note: Techniques used in AWS C++ SDK.
- Overview: this SDK conforms C++11 standard.
- Smart pointers: std::shared_ptr and std::unique_ptr.
- STL: std::map, std::queue and std::vector.
- String: std::basic_string, std::char_traits, std::basic_stringstream, std::basic_istringstream, std::basic_ostringstream and basic_stringbuf.
- It implements a nice logging system, in which variadic-argument macros were used.
```
2. **IBM Watson IoT platform.**

The SDKs for IBM Watson cloud have NOT gained much attention as I expected. The assertion could be obtained by viewing contributions and stars of their Github projects. The reason behind might be: these SDKs depend heavily on ‘paho-mqtt’ library and the major contributions are wrapper methods, which should be easy to understand since IBM is the inventor and promotor of MQTT protocol, and a huge supporter for ‘paho-mqtt’ project.

* How IBM Watson IoT cloud works.

IBM Bluemix is a platform that contains tons of services and applications, including Watson IoT platform. To start working on IBM’s IoT cloud, one needs to register an account on Bluemix and enable Watson service. Next, on server-end, one could create a thing based on Node-RED. On device-end, an embedded control unit could connected to the thing on the server and starts communicating by using provided SDKs. Since we will be focusing on device-end, and we let readers research server-end. Here is a related link (https://console.ng.bluemix.net/docs/starters/IoT/iot500.html).

* IBM Watson C SDK.

The device-end (including gateway) could talk to IBM Watson via MQTT topics. Given the following example, we introduce three major MQTT communications defined by IBM Watson platform.

[Reference 1]: https://console.ng.bluemix.net/docs/services/IoT/gateways/mqtt.html.

A gateway could publish and subscribe to topics. To be more specific, a gateway could publish an event from itself or on behalf of a device; a gateway itself or on behalf of devices could also subscribe to any topics in interests. IBM Watson provides auto-registration of unknown end-devices from a gateway. This is done during publishing or subscribing to a topic from end-devices. Notifications from the cloud is sent to gateway during the validation of publication and subscription. Errors will be raised if the validation fails. The SDK is based on three components: gatewayclient.c/.h, iotfclient.c/.h and device-managementclient.c/.h. A device application could be created based on iotfclient component; A gateway application could be created based on gatewayclient component; A device management application could be created based on devicemanagementclient component. Also, in devicemanagementclient, multiple handlers are implemented for handling messages from the cloud.

To help understanding the architecture of C++ SDK, doxygen (doxygen link) and dot (dot link) were used to draw UML diagrams. Two critical diagrams are presented in the following figures. One of them is IOTP_MessageHandler (serves as the parent class) and the other is IOTP_Client (serves as the parent class).

Here is a briefing on the structure of this C++ SDK. For conciseness, the name of parent classes represents the names from the parent and its child classes. On the top, IOTP_MessageHandler contains a reference of IOTP_Client. In IOTP_Client, a reference of Properties is included. From the UML diagrams, we should be easy to figure out what are IOTP_MessageHandler and IOTP_Client responsible for. The Properties class, which is defined beyond the range of namespace Watson_IOTP, is able to store properties like device type, device ID, domain name etc, and provides interfaces for fetching those properties. An example could be used to demonstrate how the structure works. Let’s assume an end-device has been registered on Watson platform. A message is pushed from the cloud to the gateway, expecting the end-device to upload its status. The IOT_MessageHandler would parse the message from the cloud and confirm the function this message wants to achieve. Then IOT_MessageHandler may call a method mActionHandler() defined in IOT_Client to fetch the status from the end-device. While mActionHandler processing, the device ID or device type declared in the message would be used to compare with the stored ones in the Properties class. At this point, event flows through three classes. The C++ source code applies some techniques. The following presents a snippet of them.
```
Note: Nested class usage in C++ SDK.
- Definition of nested classes : http://en.cppreference.com/w/cpp/language/nested_types.
- The purpose: ‘nested classes are cool for hiding implementation details’. http://stackoverflow.com/questions/4571355/why-would-one-use-nested-classes-in-c
- Example: a nested Node private class in List class. Node could only be instantiate within List scope.

Note: Shared pointer in C++ SDK.
- “The shared_ptr class template stores a pointer to a dynamically allocated object, typically with a C++ new-expression. The object pointed to is guaranteed to be deleted when the last shared_ptr pointing to it is destroyed or reset.” — From http://www.boost.org/doc/libs/1_63_0/libs/smart_ptr/shared_ptr.htm
- In the source code, the shared pointer is mixed with the usage of typedef to improve code readability, e.g., “typedef std::shared_ptr ptr_t;”.
```
