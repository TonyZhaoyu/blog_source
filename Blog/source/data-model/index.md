---
title: Data model analysis
date: 2018-07-31 11:29:49
---
This article articulates why a protocol-agnostic data model is needed, and what off-the-shelf models could be favorable. It starts with a research of popular ecosystems, and focuses on the ones that supports interoperability. Then we exemplify multiple models using a lighting reference design, and conclude with comments on model definitions and efforts evaluation. This article would fulfil its commitment if it enlightens ideas on interoperations among Silabs’ mesh profolio.

The architecture created by Hemanth addresses the requirements of a multi-protocol gateway. With a PAL (protocol abstraction layer), the architecture separates protocol specific module from upper layer applications, which frees developers hands from ‘dirty’ works in mesh management. We extent the device info APIs from the architecture by arguing about model abstraction. The first concept to be explained is that model abstraction is a mandatory requirement. The code of unification is by nature a standard targets to, and the method of achieving such a unification is through abstraction upon generality and binging on deviation. This code suffices our case in which inter-protocol communication would be conducted on a single platform. From the perspective of a gateway developer, the key to a successful product is to integrate the mesh technology into their favorite ecosystem. During such a integration, their experience teaches us that the data of most interests are from the device (i.e., status report) or to a specific device (i.e., remote control). Therefore, a fine-grained model of such data would be much favorable. The developer could be blunt about specific protocols as the translation is tedious due to heavy protocol-centric operations. Hence, the PAL becomes vital since we are experts on making such a translation. The propose hereby is to offer PAL based data models with full-featured translations in regard to protocols.

Here is a research about public IoT models and protocol based models (i.e., ZCL, Z-Wave device class and  Ble-mesh model). We carefully picked two public IoT models, i.e., OCF and W3C WoT (web of things) and briefly introduces their concepts as below. Notice that the research focuses on modelling, and features like cloud connectivity would be briefly covered.

•	W3C WoT (https://w3c.github.io/wot-architecture/)

The following lines (duplicated from W3CWoT architecture) depicts an excellent explanation of the WoT challenge, and emphasizes the importance of metadata of a ‘thing’.

> “A great challenge for the WoT is to enable interactions with a myriad of different IoT Platforms (e.g., OCF, oneM2M, RESTful devices not following any particular standard but providing an HTTP or CoAP interface, etc.). The IoT uses a variety of protocols for accessing devices, since no one protocol is appropriate in all contexts. W3CWoT is tackling this variety by including communication metadata in the Thing Description. This metadata can be used to configure the communication stack to produce compliant messages for a wide variety of target IoT Platforms and protocols.”

This metadata, or thing description in WoT’s language, describes a thing using three core Properties, Actions and Events (discussions about other aspects like semantic schema and Web Linking is out of scope of this article). Basically, Properties stand for the capability of a thing for example the DCD in Ble-mesh and node description in ZigBee. Actions offer functions to manipulate the internal state of a thing, while Event represents asynchronous messages from a source like reporting in ZigBee. WoT’s metadata model is straightforward, and could to some extent map to our mesh protocols’ models. However, WoT does not specify any device types and property types. For instance, it does not define a light bulb with on/off capability. The detailed definitions are totally user-wise. There is an intriguing technique, namely protocol binding that shows the scalability of WoT’s model. This technique allows nested arrays and objects to extend metadata payload to be ready for different IoT platforms (like OCF batch payload, SenML payload) with different transportation methods (like MQTT or CoAP).

•	OCF (https://openconnectivity.org/developer/specifications)

The goal for OCF is to achieve peer-to-peer, bridging and forwarding, and reporting and control of IoT devices. In marketing’s context, here’s a saying duplicated from their website:

>“OCF goes beyond simple protocol interoperability to capture the rich semantics required for true interoperability in Wearable and Internet of Things ecosystems.”

It utilizes a URI (uniform resource identifier) for attributes, groups and scenes. Also, CoAP is chosen to the transport along with CBOR encoding and RAML/JSON cluster descriptions. Data
management in OCF introduces an object model for resource management.
Details of OCF models could be viewed using the following link: (https://oneiota.org/documents?filter%5Bmedia_type%5D=application%2Fschema%2Bjson). When skimming through OCF models, one could notice the model coverage is hard to satisfy the models in home automation especially those defined by ZigBee and ZWave. To close the gap between models of various types of IoT systems, OCF and oneIoTa (open online tool by OCF) propose a means to derive new models from OCF data models. This means is more like a guideline with examples, leaving automated model derivation unknown.

To illustrate the aforementioned models, we use a lighting reference design, and abstract its properties based on data models of W3CWoT and OCF. We also present how ZCL, ZWave and Ble-mesh models this reference design for translation evaluation. It is noteworthy that all the models are based on JSON schema. Since mesh protocols have not defined JSON interpretation, these JSON models are created by filling in clusters (or SIG model) info pertaining to protocols. Note that some data values are not accurate, but they are irrelevant to the model description.

1.	W3CWoT JSON model of a light. WoT does not specify any properties in detail, and hence ZCL serves as the reference.
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

Object1:
```JSON
{
    "href": "coaps://light1",
    "rt": ["oic.r.light.brightness"],
    "if": ["oic.if.a", "oic.if.baseline"],
    "value": "100"
}
```

Object2:
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

3.	ZCL model.
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
