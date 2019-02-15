---
title: Notes about BT-Mesh gateway v1.0
date: 2019-02-11 10:48:14
---

#### Field requirement analysis

1. The first goal is to check whether the requirements on the spreadsheet has been logged into the JIRA system.

  * Priority 1 & 2 requirements from the field:

    1) Smartly track the online/offline status of remote nodes.
    https://jira.silabs.com/browse/IOTS_SW_BLE-495
    2) Open up BT-Mesh heartbeat APIs for network status monitoring at user level.
    https://jira.silabs.com/browse/IOTS_SW_BLE-497
    3) Create a unicast interface for individual node controlling without BT-Mesh grouping.
    https://jira.silabs.com/browse/IOTS_SW_BLE-498
    4) Able to add remote node DDB from the gateway to achieve local provision without over-the-air operations.
    https://jira.silabs.com/browse/IOTS_SW_BLE-480
    5) Enable NCP firmware upgrade via the gateway application.
    https://jira.silabs.com/browse/IOTS_SW_BLE-479
    6) Able to import network DDB from a local file or from a file collected via cloud.
    https://jira.silabs.com/browse/IOTS_SW_BLE-499
    7) Support model configuration and message transmitting/receiving for vendor models.
    https://jira.silabs.com/browse/IOTS_SW_BLE-496
    8) Create BGAPI tunneling if BLE methods are to be called.
    https://jira.silabs.com/browse/IOTS_SW_BLE-483

  Some comments about the fourth feature: it may have similarity with https://jira.silabs.com/browse/IOTS_SW_BLE-480 but need more inputs from Jack.

  * Additional testing requirements from the field:
    9) Monitor light model change status.
    https://jira.silabs.com/browse/IOTS_SW_BLE-500
    10) Create maximum 100 groups per node and test the functionality.
    https://jira.silabs.com/browse/IOTS_SW_BLE-501

2. The second goal is to give a technical evaluation based on the requirements and the existing architecture. The outcome could be a list of potential improvements and architectural modifications. Create additional JIRA tickets if necessary.

  * Apart from the field requirement, there are some features worth noting:

    11) Form a network based on user settings.
    https://jira.silabs.com/browse/IOTS_SW_BLE-478
    12) Collaboratively improve device table management, such that no more redundancy is created.
    https://jira.silabs.com/browse/IOTS_SW_BLE-481
    13) Collaboratively complete provision and configuration in a concurrent manner.
    https://jira.silabs.com/browse/IOTS_SW_BLE-482
    14) Offload the add device process to grouping in a much sense-making manner.
    https://jira.silabs.com/browse/IOTS_SW_BLE-491

<span style="color:blue">The following features appear to be very important to performance optimization:</span>

  * Improvements that were left since v0.3.
  - [ ] Group table should use dynamic memory to decrease space complexity.
  - [ ] It could be convenient to expose table (i.e., dt, gt) iterators to either users or lower layers.
  - [ ] Dynamic allocate more device table buckets if device table reaches a threshold. This is to prevent bucket setting from one-time actions.
  - [ ] Reduce O(n^2) complexity when filling with device joined group.

  </br>
  * Feature evaluation.

  The following content evaluates the impact to the existing software given the requirement above.

| index | comments |
| ----- | -------- |
|  1)  | This feature was majorly implemented at the lower layer. </br> User layer opens up API , which draws no impacts to the existing architecture. |
|  2)  | The command definition is done at the lower layer. </br> User layer opens up API, which draws no impacts to the existing architecture. |
|  3)  | As this function by far has not been verified. The workload is unpredictable. </br> The thing needs investigation is the **data** to be passed to the unicast method. </br> Hence, this feature is marked as <span style="color:red">Needs Investigation</span>, but it should provide <span style="color:green">Zero Impact</span> </br> to the existing software. |
|  4)  | This needs investigation as the DDB definition is unknown. There are some questions yet to be answered: </br> 1. Does the NCP already stores the DDB before setting the DDB? </br> 2. Will there be a way to know the network ID since the DB is based on network ID? </br> Hence, this feature is marked as <span style="color:red">Needs Investigation</span>, and it may have <span style="color:red">Profound Impact</span> </br> to the existing software. For example, hash table, API arguments etc. |
|  5)  | This feature is important but has <span style="color:green">Zero Impact</span> on the existing software architecture, although some data need to be stored in a non-volatile memory. |


  * The factors impacting the existing software architecture includes:
    - Table structure (device-table and group-table) refinement (in other words, extension) /reconstruction (in other words, fundamental change). This factor has a profound impact on the permanent storage of tables.
    - Level of concurrency. This factor has a profound impact on the data structure and resource management at user level.
    - Sharing capability between layers. This factor contributes mostly to DB sharing between cmd_host layer and data_hub layer.

  * Rule of thumbs when analyzing the criticality of a feature:
    - The feature that draws impacts of the software architecture has higher criticality. Particularly, reconstruction contributes higher criticality than refinement.
    - The feature that improves the performance significantly and serves as the core value has higher criticality.
    - Notice that amount of work is NOT one of the factors.

Evaluate the criticality of the feature using 1 to 5 scales with 5 being the highest and 1 being the lowest. The following presents a list of scores based on the feature index.

| index | scores | comments |
| :--: | :--: | ------------ |
|  1  |  3 | Have some level of impacts on the data structure of a node. </br> Consider such definitions as refinement. |
|  2  |  1 | Appears to have no impact on the existing software. |
|  3  |  1 | Appears to have no impact on the existing software. |
|  4  |  3 | Have some level of impacts on the data structure of a node. </br> Consider such definitions as refinement. |
|  5  |  2 | Need to create definitions to mark DFU status. |
|  6  |  2 | May need to refine network DDB. |
|  7  |  3 | Need to make new definitions on top of node structure. </br> Consider such definitions as refinement. |
|  8  |  1 | Appears to have no impact on the existing software. |
|  9  | n/a | Not applicable |
|  10 | n/a | Not applicable |

---

#### Action item: 12/02/2019

1. Compile and run dev branch application.

  * Note down the makefile execution path for openSSL.
  * Think of a way to modify the makefile in a user friendly way, e.g., overwrite the path variable when *making*.
  * Compile and flash secure NCP bootloader along with application.

2. Diff the source in mesh_host from different branches. Find the sub-processes in the `add_device` handler.

> To generate HTML version of BGAPI, clone repo `bluegiga/api.git` and checkout the latest release branch. Then type `pipenv run html` for html generation.

---

#### Action item: 13/02/2019

* Discuss with Jack about the task's priority. Results shown as below:

  1. High priority task for Tony:
  • https://jira.silabs.com/browse/IOTS_SW_BLE-491 : Appkey gen to app layer, this one has a big impact on upper layer.
  • https://jira.silabs.com/browse/IOTS_SW_BLE-482:  Concurrent operation, this could be a big improvement on our gateway performance but also has big impact on upper layer, but we believe we relatively have more time one this as it does not impact basic functions. Will finish the part that impacts data struct and leave concurrency management to be solved after other high priorities.
  • https://jira.silabs.com/browse/IOTS_SW_BLE-496 : Vendor model support, it impact a little on upper layer data struct, but relative important as sales put this function as one of the high priorities.
  2. Medium priority task for Tony:
  The final goal is to achieve network duplication (or migration).
  • https://jira.silabs.com/browse/IOTS_SW_BLE-478, https://jira.silabs.com/browse/IOTS_SW_BLE-480 and https://jira.silabs.com/browse/IOTS_SW_BLE-499.
  3. Low priority task for Tony:
  All the isolated issues and true concurrency management.
  4. Lowest priority task for Tony:
  • https://jira.silabs.com/browse/IOTS_SW_BLE-481 :  device table mgmt.
  • https://jira.silabs.com/browse/IOTS_SW_BLE-497 : heartbeat function.

* Some ideas on the 491 task.

  1. Offload the appkey generation to users. In group creation API, add two parameters: one is the string of appkey, the other is the new/old indicator.
  2. Redefine the data structure of group table, monitor keys?

---

#### Action item: 14/02/2019


* Makefile for multiple platforms could be a pain.

1. On MacOS, would expect a executable version without dynamic linking. On Linux, would expect a sample console with dynamic linking.

    My simple solution is to create a new makefile namely test.mk to generate the executable statically.

2. Need to think of a way to remove the shock after inserting a new item in the `ResponseId` enum structure, such that to find the item in an position agnostic way.

    Solved by creating a MACRO which equals to CMD_MAX + 1.


>Q: why a non-secured NCP firmware could not be factory reset on startup?
 A: check if the firmware is correct.

* From app-key to core data structure.

1. Data structure review.

  <span style="color:blue">Principle 1: no keys (except device keys) should be explicitly stored in the library.</span>


>Idea: move timestamp to the API implementation file, and returns the timestamp(handler) when an API is called.
 Comment: may not be difficult for combinational commands decides how many sub-commands were created at datahub layer rather the API layer.

2. AppKey sending procedure analysis.

  - What is the procedure of writing AppKey to the stack and what data will be returned from the stack (like an key index or something)?
    As a reference, checkout the process of Xiaomi's library when dealing with AppKey.

    It is up to user to decide if the key is new key or not. There are two situations:
    - Firstly, if the key is an old key in the group table. Use the generated key index stored in the group table.
    - Secondly, if the key is a new key, there are two sub-situations when generating a key. Sub-situation 1: If the key passed in is valid, generate a new key based on the given key string, and then update key index in related group. Sub-situation 2: If the key passed in is not valid, generate a new key and then update key index. The user is responsible for the consequences of using an invalid key (like failed to conduct gateway migration from A to B). Search for `mesh_prov_create_appkey` in the document for more BGAPI info.

    The group creation API won't tell the user what is the key index. The user could query the library what is the metadata of a specified group so to get the appKey index.

  - From now on, group creation requires a type 1 FSM to track and trace the addAppKey command to the stack.

  - The appkey is bound to an network. It might have a limited number due to limitations of NVM3.

3. AppKey binding to models of a joining node.

  - Add a new state to the join_group procedure. Which is to bind AppKey to lightness group.

  - <span style="color:blue">An improvement could be made is to create state for better code reading. The current solution depends on round 1/2.</span>
