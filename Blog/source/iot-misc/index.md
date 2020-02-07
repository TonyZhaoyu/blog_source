---
title: Something about IoT
date: 2019-02-05 17:14:25
---

### Introduction

This section contains SDK review of IoT giants and some modeling standards for various IoT nodes. Some big names are listed below:

* AWS IoT: (https://aws.amazon.com/iot/)

* Alibaba IoT: (https://www.alibabacloud.com/solutions/IoT)

* IBM Watson IoT: (https://www.ibm.com/internet-of-things)

* Microsoft Azure: (https://azure.microsoft.com/en-us/services/iot-hub/)

For models:

* W3C WoT (web of things): (https://w3c.github.io/wot-architecture/)

* OCF (https://openconnectivity.org/developer/specifications)

In addition, security in IoT is addressed as the topic is becoming pervasive.

---

### Data model analysis

This article articulates why a protocol-agnostic data model is needed, and what off-the-shelf models could be favorable. It starts with a research of popular ecosystems, and focuses on the ones that supports interoperability. Then we exemplify multiple models using a lighting reference design, and conclude with comments on model definitions and efforts evaluation. This article would fulfil its commitment if it enlightens ideas on interoperations among Silabs’ mesh profolio.

With a PAL (protocol abstraction layer), the architecture separates protocol specific module from upper layer applications, which frees developers hands from ‘dirty’ works in mesh management. We extent the device info APIs from the architecture by arguing about model abstraction. The first concept to be explained is that model abstraction is a mandatory requirement. The code of unification is by nature a standard targets to, and the method of achieving such a unification is through abstraction upon generality and binging on deviation. This code suffices our case in which inter-protocol communication would be conducted on a single platform. From the perspective of a gateway developer, the key to a successful product is to integrate the mesh technology into their favorite ecosystem. During such a integration, their experience teaches us that the data of most interests are from the device (i.e., status report) or to a specific device (i.e., remote control). Therefore, a fine-grained model of such data would be much favorable. The developer could be blunt about specific protocols as the translation is tedious due to heavy protocol-centric operations. Hence, the PAL becomes vital since we are experts on making such a translation. The propose hereby is to offer PAL based data models with full-featured translations in regard to protocols.

Here is a research about public IoT models and protocol based models (i.e., ZCL, Z-Wave device class and  Ble-mesh model). We carefully picked two public IoT models, i.e., OCF and W3C WoT (web of things) and briefly introduces their concepts as below. Notice that the research focuses on modelling, and features like cloud connectivity would be briefly covered.

*	[**W3C WoT**](https://w3c.github.io/wot-architecture/)

The following lines (duplicated from W3CWoT architecture) depicts an excellent explanation of the WoT challenge, and emphasizes the importance of metadata of a ‘thing’.

> “A great challenge for the WoT is to enable interactions with a myriad of different IoT Platforms (e.g., OCF, oneM2M, RESTful devices not following any particular standard but providing an HTTP or CoAP interface, etc.). The IoT uses a variety of protocols for accessing devices, since no one protocol is appropriate in all contexts. W3CWoT is tackling this variety by including communication metadata in the Thing Description. This metadata can be used to configure the communication stack to produce compliant messages for a wide variety of target IoT Platforms and protocols.”

This metadata, or thing description in WoT’s language, describes a thing using three core Properties, Actions and Events (discussions about other aspects like semantic schema and Web Linking is out of scope of this article). Basically, Properties stand for the capability of a thing for example the DCD in Ble-mesh and node description in ZigBee. Actions offer functions to manipulate the internal state of a thing, while Event represents asynchronous messages from a source like reporting in ZigBee. WoT’s metadata model is straightforward, and could to some extent map to our mesh protocols’ models. However, WoT does not specify any device types and property types. For instance, it does not define a light bulb with on/off capability. The detailed definitions are totally user-wise. There is an intriguing technique, namely protocol binding that shows the scalability of WoT’s model. This technique allows nested arrays and objects to extend metadata payload to be ready for different IoT platforms (like OCF batch payload, SenML payload) with different transportation methods (like MQTT or CoAP).

*	[**OCF**](https://openconnectivity.org/developer/specifications)

The goal for OCF is to achieve peer-to-peer, bridging and forwarding, and reporting and control of IoT devices. In marketing’s context, here’s a saying duplicated from their website:

>“OCF goes beyond simple protocol interoperability to capture the rich semantics required for true interoperability in Wearable and Internet of Things ecosystems.”

It utilizes a URI (uniform resource identifier) for attributes, groups and scenes. Also, CoAP is chosen to the transport along with CBOR encoding and RAML/JSON cluster descriptions. Data
management in OCF introduces an object model for resource management.
Details of OCF models could be viewed using the following link: (https://oneiota.org/documents?filter%5Bmedia_type%5D=application%2Fschema%2Bjson). When skimming through OCF models, one could notice the model coverage is hard to satisfy the models in home automation especially those defined by ZigBee and ZWave. To close the gap between models of various types of IoT systems, OCF and oneIoTa (open online tool by OCF) propose a means to derive new models from OCF data models. This means is more like a guideline with examples, leaving automated model derivation unknown.

To illustrate the aforementioned models, we use a lighting reference design, and abstract its properties based on data models of W3CWoT and OCF. We also present how ZCL, ZWave and Ble-mesh models this reference design for translation evaluation. It is noteworthy that all the models are based on JSON schema. Since mesh protocols have not defined JSON interpretation, these JSON models are created by filling in clusters (or SIG model) info pertaining to protocols. Note that some data values are not accurate, but they are irrelevant to the model description.

1. W3CWoT JSON model of a light. WoT does not specify any properties in detail, and hence ZCL serves as the reference.

  ```JSON
  {
    "id": "0x000B000000000000-1",
    "name": "light1",
    "properties": {
  "status": {
          "writable": false,
          "observable": false,
          "type": "string",
          "forms": [{
              "href": "coaps://light1/status",
              "mediaType": "application/json"
          }]
      }},
      "actions": {
      "toggle": {
          "forms": [{
              "href": "coaps://light1/toggle",
              "mediaType": "application/json"
          }]}},
      "events": {
          "overheating": {
              "type": "string",
              "forms": [{
                  "href": "coaps://light1/oh",
                  "mediaType": "application/json"
              }]
          }}
  }
  ```

2.	OCF model (on the basis of public available OCF models). Could not find a light with on/off capability, and hence use the light enabling brightness control. The second JSON object presents the OCF definition of the oic.r.light.brightness.

  2.1. Object1:

  ```JSON
  {
      "href": "coaps://light1",
      "rt": ["oic.r.light.brightness"],
      "if": ["oic.if.a", "oic.if.baseline"],
      "value": "100"
  }
  ```

  2.2. Object2:

  ```JSON
  {
    "id":       
    "http://openinterconnect.org/iotdatamodels/schemas/oic.r.light.brightness.json#",
    "$schema": "http://json-schema.org/draft-04/schema#",
    "description" : "Copyright (c) 2016, 2017 Open Connectivity Foundation, Inc. All rights  
    reserved.",
    "title": "Brightness",
    "definitions": {
      "oic.r.light.brightness": {
        "type": "object",
        "properties": {
          "brightness": {
            "type": "integer",
            "description": "Quantized representation in the range 0-100 of the current
            sensed or set value for Brightness",
            "minimum": 0,
            "maximum": 100
          }
        }
      }
    },
    "type": "object",
    "allOf": [
      {"$ref": "oic.baseResource.json#/definitions/oic.r.baseresource"},
      {"$ref": "#/definitions/oic.r.light.brightness"}
    ],
    "required": [ "brightness" ]
  }
  ```

3. ZCL model.

  ```JSON
  {
    "nodeId": 0x0A00,
    "deviceState": 0x10,
    "deviceType": 0xXXXX,
    "timeSinceLastMessage": 0x23,
    "deviceEndpoint":{
        "eui64": 0x000B000000000000,
        "endpoint": 0x01,
        "clusterInfo":[{
            "clusterId": 0x0006,
            "clusterType": "out"
        }]
    }
  }
  ```

4.	BLE-mesh model.

  ```JSON
  {
    "uuid": "53696C6162734465762DAF8D64570B00",
    "mac": "xx:xx:xx:xx",
    "models":[
        0x1006,
        0x0002,
        0x1304,
        0x1002
    ]
  }
  ```

5.	ZWave model.

  ```JSON
  {
    "id": "xx:xx:xx:xx",
    "deviceType": "xxxx",
    "roleType": "xxxx"
    "deviceClass":[
        XXXX,
    ]
  }
  ```

From the public documents, ZWave model utilizes device classes to describe control and reporting commands. Although the aforementioned ZWave model may not be accurate, it should sketch major parts after communicating with ZWave AEs.

In summary, what we could learn from W3C WoT model is the concept of actions and events abstraction. Despite the implicit declarations of ZCL and ZWave of such an abstraction, WoT’s declaration shows the light on the arguably most useful functions to emphasis interoperability. When investigating OCF models, it is not hard to find the model is too Restful-oriented to be augmented into ours. Moreover, OCF has limitations to support all ZCL models, and the death end of ZCL/IP integration in 2016 proved the difficulty. One direction for the next action item is to create a superset-alike definition by leveraging the concept of WoT, and by extracting common descriptions of ZCL, ZWave as well as Ble-mesh. We could start with light and switch reference design, and add more when new types come to play.

---

### IOT Ecosystems

Cloud vendors provide SDKs for developers in favour of easy connectivity. The following content summaries how these SDKs are architected, what software techniques have been deployed, and how APIs are designed. It is notable that only embedded C/C++ version is considered.

#### **AWS IoT platform**

AWS IoT provides amazingly detailed documents on the overall architecture, developer’s guide and porting guide. There are two major features offered by AWS IoT services: MQTT connection and Thing Shadow. Both embedded C/C++ SDKs support such features, and they will be presented in the following content.

[Reference 1]: http://aws-iot-device-sdk-embedded-c-docs.s3-website-us-east-1.amazonaws.com/index.html.

[Reference 2]: https://github.com/aws/aws-iot-device-sdk-embedded-C/blob/master/README.md.

[Reference 3]: https://github.com/aws/aws-iot-device-sdk-embedded-C/blob/master/PortingGuide.md.

* **How AWS IoT cloud works?**

Thing shadow is defined as “a JSON document which is used to store and retrieve current state information for a thing” (reproduced in http://docs.aws.amazon.com/iot/latest/developerguide/iot-thing-shadows.html). The state of a IoT thing could be obtained or set through MQTT topics. Thing Shadow related implementations could be found under src folder, with prefix ‘aws_iot_shadow’ in names. Specifically, the implementation contains three basic operations, namely UPDATE, GET and DELETE (http://docs.aws.amazon.com/iot/latest/developerguide/using-thing-shadows.html).

AWS IoT defines a set of APIs based on MQTT topics. As mentioned, there are three parent topics:“aws/things/[thingName]/shadow/update”, “aws/things/[thingName]/shadow/update/get” and “aws/things/[thingName]/shadow/update/delete”. Under each parent topic, there are several sub-topics for better connectivity. For example, to improve QoS of a sent message, one could listen to “aws/things/[thingName]/shadow/update/accepted” and “aws/things/[thingName]/shadow/update/rejected”.
```
Note: Each message sent over a topic could be related to a success/failure notification. For instance, if a message was sent over xxxx/update topic, users could get a notification from either xxxx/update/accepted (indicating success) or xxxx/update/rejected (indicating failure).
```
It is also noteworthy that AWS IoT platform does not allow dynamic device registry without a certificate. Take the following scenario as an example. A new device joined the network via a gateway, and the gateway loyally talks to AWS IoT platform about the newly joined device who is ready to upload data. This is, however, rejected by AWS IoT since it finds out the newly joined does not have a valid certificate. The link below specifies how devices correctly connect to AWS IoT platform (https://software.intel.com/en-us/articles/using-amazon-web-services-aws-iot-with-intel-iot-devices-and-gateways).

* **AWS IoT embedded C SDK**

The SDK depends on ARM ‘mbedTLS’ library and ‘jsmn’ library (CppUTest is ignored herein). ‘mbedTLS’ offers a light-weight implementation of cryptographic and SSL/TLS (https://en.wikipedia.org/wiki/Transport_Layer_Security) features. ‘jsmn’ offers a JSON parser that could be deployed on resource-limited platforms. One could find MQTT implementation under src folder, with prefix ‘aws_iot_mqtt_client’ in names. The implementation follows the flavour of IBM’s ‘paho-mqtt’ library, and based on wrappers of the underlying mbedTLS connection.

Note: There is one interesting feature implemented in yield() method, which monitors the health of TCP connection. In a single-threaded implementation, yield() method will be frequently called (https://github.com/aws/aws-iot-device-sdk-embedded-C/blob/master/PortingGuide.md).

* **AWS C++ SDK**

In C++ version, three ways of network connection could be selected since resource limitation of a platform will no longer be a big issue. These ways are ‘mbedTLS’, ‘openSSL’ and ‘webSocket’. ‘rapidjson’ (http://rapidjson.org/) is used as the JSON parser. Frankly, the provided sample code is a little messy. This may be due to less typedef usage and nested naming space. But the basic operations were similar to C version.
```
Note: Techniques used in AWS C++ SDK.
- Overview: this SDK conforms C++11 standard.
- Smart pointers: std::shared_ptr and std::unique_ptr.
- STL: std::map, std::queue and std::vector.
- String: std::basic_string, std::char_traits, std::basic_stringstream, std::basic_istringstream, std::basic_ostringstream and basic_stringbuf.
- It implements a nice logging system, in which variadic-argument macros were used.
```

#### **IBM Watson IoT platform**

The SDKs for IBM Watson cloud have NOT gained much attention as I expected. The assertion could be obtained by viewing contributions and stars of their Github projects. The reason behind might be: these SDKs depend heavily on ‘paho-mqtt’ library and the major contributions are wrapper methods, which should be easy to understand since IBM is the inventor and promotor of MQTT protocol, and a huge supporter for ‘paho-mqtt’ project.

* **How IBM Watson IoT cloud works**

IBM Bluemix is a platform that contains tons of services and applications, including Watson IoT platform. To start working on IBM’s IoT cloud, one needs to register an account on Bluemix and enable Watson service. Next, on server-end, one could create a thing based on Node-RED. On device-end, an embedded control unit could connected to the thing on the server and starts communicating by using provided SDKs. Since we will be focusing on device-end, and we let readers research server-end. Here is a related link (https://console.ng.bluemix.net/docs/starters/IoT/iot500.html).

* **IBM Watson C SDK**

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
