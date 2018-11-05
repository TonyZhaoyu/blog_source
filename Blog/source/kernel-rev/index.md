---
title: Linux kernel review
date: 2018-11-05 13:14:34
---

#### **The famous "typeof"**

Many dynamic programming language like Javascript has dynamic way of determining the data type with syntax similar to *typeof*. In C code, a compiler extension provides a way to use *typeof*. It is recommended to compile source code with *-std=gnu99* (rather *-std=c99*) for such a feature. In the kernel code, *typeof* has been widely used. Here is an example:

```c
#ifndef _TYPES_H_
#define _TYPES_H_

#define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))

typedef unsigned char		u8;
typedef unsigned short		u16;
typedef unsigned int		u32;
typedef unsigned long long	u64;
typedef signed char		s8;
typedef short			s16;
typedef int			s32;
typedef long long		s64;

#define min(x,y) ({ \
	typeof(x) _x = (x);	\
	typeof(y) _y = (y);	\
	(void) (&_x == &_y);	\
	_x < _y ? _x : _y; })

#define max(x,y) ({ \
	typeof(x) _x = (x);	\
	typeof(y) _y = (y);	\
	(void) (&_x == &_y);	\
	_x > _y ? _x : _y; })

#endif /* _TYPES_H_ */
```

In the example, the statement *typeof(x) _x = (x)* could be explained using a specific type say *int*. That is to say, if x has the *int* type, then *typeof(x) _x = (x)* equals to *int _x = (x)*, which creates a variable and assigned by the value of x.

***

#### **Red-black tree AKA. rbTree**

The rbTree is a kind of self-balancing binary search tree with the following restrictions (quoted from Linux kernel lib/rbtree.c):

```c
/*
 * red-black trees properties:  http://en.wikipedia.org/wiki/Rbtree
 *
 *  1) A node is either red or black
 *  2) The root is black
 *  3) All leaves (NULL) are black
 *  4) Both children of every red node are black
 *  5) Every simple path from root to leaves contains the same number
 *     of black nodes.
 *
 *  4 and 5 give the O(log n) guarantee, since 4 implies you cannot have two
 *  consecutive red nodes in a path and every red node is therefore followed by
 *  a black. So if B is the number of black nodes on every simple path (as per
 *  5), then the longest possible path due to 4 is 2B.
 *
 *  We shall indicate color with case, where black nodes are uppercase and red
 *  nodes will be lowercase. Unknown color nodes shall be drawn as red within
 *  parentheses and have some accompanying text comment.
 */
```

It is a binary search tree (BST for short), and hence it allows efficient in-order-traversal and standard BST insertion. For example, the result of inserting node (int No.10) to a tree with only a root node (int No.8) is a tree with root node (int No.8) and its right child node (int No.10).

* Why using rbTree instead of BST?

The following example shows the difference of two trees (red nodes in rbTree are encapsulated with *[]*). BST on the left shows the height of 4, while rbTree on the right shows the height of 3.

```c
            BST                     rbTree
             1                        3      
            / \                      / \
       (null)  2                    2   4
                \                  /
                 3               [1]
                  \
                   4

```

It's easy to derive tree operations (e.g., search, max, min, insert, delete, etc) for BST take O(n) time where n is the height of the BST, and for rbTree take O(logn) time where n is the number of nodes.

* Where has rbTree been used in the Linux kernel?

> There are a number of red-black trees in use in the kernel. The deadline and CFQ I/O schedulers employ rbtrees to track requests; the packet CD/DVD driver does the same. The high-resolution timer code uses an rbtree to organize outstanding timer requests. The ext3 filesystem tracks directory entries in a red-black tree. Virtual memory areas (VMAs) are tracked with red-black trees, as are epoll file descriptors, cryptographic keys, and network packets in the “hierarchical token bucket” scheduler.

The algorithm to be used in rbTree balancing is explained in https://www.geeksforgeeks.org/red-black-tree-set-2-insert/. Hereby, the explanation will not be reproduced, but an visual example of rbTree insertion is given below:

```c
/*
 * Insert 2, 6 and 13 into the following rbTree ([] indicates red nodes).
 * Leaf nodes are omitted.
 */
              7
            /   \
           3    [18]
                /  \
              10    22
             /  \     \
          [8]  [11]   [26]

// Step1: insert 2. This is fairly simple.
              7
            /   \
           3    [18]
          /      /  \
        [2]    10    22
              /  \     \
           [8]  [11]   [26]
// Step2: insert 6. This is fairly simple.
              7
            /   \
           3    [18]
         /  \    /  \
       [2]  [6] 10    22
               /  \     \
             [8] [11]  [26]
// Step3: standard BST insert 13.
               7
             /   \
            3    [18]
          /  \    /  \
        [2]  [6] 10    22
                /  \     \
              [8] [11]  [26]
                     \
                     [13]
// Step4: The parent of 13 is NOT BLACK and the uncle of 13 is RED.
//        Need to follow case 3a. The result is as below:
                7
              /   \
             3    [18]
           /  \    /  \
        [2]  [6] [10]  22
                 /  \    \
                8   11   [26]
                      \
                     [13]
// Step5: Now the new node becomes 10 which previous being a grandparent.
//        Need to follow case 3 right left situation. After right rotation,
//        the result is as below:
                7
              /   \
             3    [10]
           /  \    /  \
         [2]  [6] 8   [18]
                      /  \
                     11   22  
                       \    \
                      [13]  [26]
// Step6: New the new node (i.e., 10) enters case 3 right right situation.
//        After left rotation and color swapping, the result is as below:
               10
              /   \
            [7]    [18]
           /  \    /   \
          3    8  11    22
        /  \        \     \
      [2]  [6]      [13]   [26]           
```

Concept reference: https://www.geeksforgeeks.org/red-black-tree-set-1-introduction-2/
Usage reference: http://www.infradead.org/~mchehab/kernel_docs/unsorted/rbtree.html
