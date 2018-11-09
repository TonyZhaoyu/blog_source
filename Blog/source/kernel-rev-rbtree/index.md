---
title: Kernel review - red-black tree
date: 2018-11-07 10:22:08
---

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

* **Why using rbTree instead of BST?**

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

It's easy to derive tree operations (e.g., search, max, min, insert, delete, etc) for BST take O(n) time where n is the height of the BST, and for rbTree take O(logn) time where n is the number of nodes. From the example we could see that the big-O time for BST is O(4) while for rbTree is O(2).

* **Where has rbTree been used in the Linux kernel?**

> There are a number of red-black trees in use in the kernel. The deadline and CFQ I/O schedulers employ rbtrees to track requests; the packet CD/DVD driver does the same. The high-resolution timer code uses an rbtree to organize outstanding timer requests. The ext3 filesystem tracks directory entries in a red-black tree. Virtual memory areas (VMAs) are tracked with red-black trees, as are epoll file descriptors, cryptographic keys, and network packets in the “hierarchical token bucket” scheduler.

* **A practical example of tree insertion.**

The insertion algorithm to be used in rbTree balancing is explained in https://www.geeksforgeeks.org/red-black-tree-set-2-insert/. Hereby, the explanation will not be reproduced, but a visual example of rbTree insertion is given below:

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

The deletion algorithm described in https://www.geeksforgeeks.org/red-black-tree-set-3-delete-2/ is not as straightforward as the insertion algorithm. The descriptions from http://gauss.ececs.uc.edu/RedBlack/redblack.html could provide some help.

* **An example of using rbTree lib in the kernel.**

An example of using kernel implementation of rbTree could refer to lib/rbtree_test.c, and an online material http://www.infradead.org/~mchehab/kernel_docs/unsorted/rbtree.html. A remarkable thing about the implementation is the code maintains flexibility to users. Users could define own data structures which includes the *rb_node* structure, and use *container_of()* or *rb_entry()* (a wrapper of container_of) to access user defined data. For example:

```c
struct mytype {
      struct rb_node node;
      char *keystring;
};
```

When searching a value in a rbTree, a search function should be defined. *rb_test.c* does not implement a search method. Here's an example from the online material. The method *container_of* is used for accessing user defined *key*, which to be based on to traverse nodes like a binary tree does.

```c
struct mytype *my_search(struct rb_root *root, char *string)
{
      struct rb_node *node = root->rb_node;

      while (node) {
              struct mytype *data = container_of(node, struct mytype, node);
              int result;

              result = strcmp(string, data->keystring);

              if (result < 0)
                      node = node->rb_left;
              else if (result > 0)
                      node = node->rb_right;
              else
                      return data;
      }
      return NULL;
}
```

Inserting a node requires a user defined inserting method. The kernel implementation provides node linking (rb_link_node(). see the code below) and tree re-balancing (rb_insert_color()).

```c
static inline void rb_link_node(struct rb_node *node, struct rb_node *parent,
				struct rb_node **rb_link)
{
	node->__rb_parent_color = (unsigned long)parent;
	node->rb_left = node->rb_right = NULL;

	*rb_link = node;
}
```

The method rb_link_node() store a copy of the parent ptr with the format of *unsigned long*. When reading rb_insert_color(), we could see at the beginning a method, namely *rb_red_parent()* is called. As the new node is initially colored in red (not necessarily store the value in RAM), and hence the function's name could be interpreted like getting the parent from the new red node. The insertion code is duplicated below for reading convenience:

```c
static __always_inline void
__rb_insert(struct rb_node *node, struct rb_root *root,
	    void (*augment_rotate)(struct rb_node *old, struct rb_node *new))
{
	struct rb_node *parent = rb_red_parent(node), *gparent, *tmp;

	while (true) {
		/*
		 * Loop invariant: node is red
		 *
		 * If there is a black parent, we are done.
		 * Otherwise, take some corrective action as we don't
		 * want a red root or two consecutive red nodes.
		 */
		if (!parent) {
			rb_set_parent_color(node, NULL, RB_BLACK);
			break;
		} else if (rb_is_black(parent))
			break;

		gparent = rb_red_parent(parent);

		tmp = gparent->rb_right;
		if (parent != tmp) {	/* parent == gparent->rb_left */
			if (tmp && rb_is_red(tmp)) {
				/*
				 * Case 1 - color flips
				 *
				 *       G            g
				 *      / \          / \
				 *     p   u  -->   P   U
				 *    /            /
				 *   n            n
				 *
				 * However, since g's parent might be red, and
				 * 4) does not allow this, we need to recurse
				 * at g.
				 */
				rb_set_parent_color(tmp, gparent, RB_BLACK);
				rb_set_parent_color(parent, gparent, RB_BLACK);
				node = gparent;
				parent = rb_parent(node);
				rb_set_parent_color(node, parent, RB_RED);
				continue;
			}

			tmp = parent->rb_right;
			if (node == tmp) {
				/*
				 * Case 2 - left rotate at parent
				 *
				 *      G             G
				 *     / \           / \
				 *    p   U  -->    n   U
				 *     \           /
				 *      n         p
				 *
				 * This still leaves us in violation of 4), the
				 * continuation into Case 3 will fix that.
				 */
				tmp = node->rb_left;
				WRITE_ONCE(parent->rb_right, tmp);
				WRITE_ONCE(node->rb_left, parent);
				if (tmp)
					rb_set_parent_color(tmp, parent,
							    RB_BLACK);
				rb_set_parent_color(parent, node, RB_RED);
				augment_rotate(parent, node);
				parent = node;
				tmp = node->rb_right;
			}

			/*
			 * Case 3 - right rotate at gparent
			 *
			 *        G           P
			 *       / \         / \
			 *      p   U  -->  n   g
			 *     /                 \
			 *    n                   U
			 */
			WRITE_ONCE(gparent->rb_left, tmp); /* == parent->rb_right */
			WRITE_ONCE(parent->rb_right, gparent);
			if (tmp)
				rb_set_parent_color(tmp, gparent, RB_BLACK);
			__rb_rotate_set_parents(gparent, parent, root, RB_RED);
			augment_rotate(gparent, parent);
			break;
		} else {
			tmp = gparent->rb_left;
			if (tmp && rb_is_red(tmp)) {
				/* Case 1 - color flips */
				rb_set_parent_color(tmp, gparent, RB_BLACK);
				rb_set_parent_color(parent, gparent, RB_BLACK);
				node = gparent;
				parent = rb_parent(node);
				rb_set_parent_color(node, parent, RB_RED);
				continue;
			}

			tmp = parent->rb_left;
			if (node == tmp) {
				/* Case 2 - right rotate at parent */
				tmp = node->rb_right;
				WRITE_ONCE(parent->rb_left, tmp);
				WRITE_ONCE(node->rb_right, parent);
				if (tmp)
					rb_set_parent_color(tmp, parent,
							    RB_BLACK);
				rb_set_parent_color(parent, node, RB_RED);
				augment_rotate(parent, node);
				parent = node;
				tmp = node->rb_left;
			}

			/* Case 3 - left rotate at gparent */
			WRITE_ONCE(gparent->rb_right, tmp); /* == parent->rb_left */
			WRITE_ONCE(parent->rb_left, gparent);
			if (tmp)
				rb_set_parent_color(tmp, gparent, RB_BLACK);
			__rb_rotate_set_parents(gparent, parent, root, RB_RED);
			augment_rotate(gparent, parent);
			break;
		}
	}
}
```

Here are some notes on the insertion *__rb_insert()* method. Conditions from line 15 to line 19 determine whether the new node is a root node or its parent is a black node. Since adding a red node under a parent in black will suffice all invariants, the loop should end. Next, as the new node's parent is a red node, so we need to know the color of grandparent to perform recoloring and rotating. The line "gparent = rb_red_parent(parent)" is destined to find a valid grandparent (i.e., not NULL), as a child node in red of a red parent always has a black grandparent, and this step should never be reached if a red node to be inserted to a black parent. Now we need to know if the parent is a left child a the grandparent by the conditions in line 24 (rb_left) and line 89 (rb_right).

The kernel implementation also provides removing and replacing functions. One could basically search for the node and call rb_erase() or rb_replace_node() to achieve removing and replacing respectively. Examples are omitted.

---

#### **Appendix: algorithm introduction to rbTree**

This section provides supplemental information for rbTree. Most of the materials are based on the slides in  https://www.cs.purdue.edu/homes/ayg/CS251/slides/chap13a.pdf and http://gauss.ececs.uc.edu/RedBlack/redblack.html. The red-black tree could be derived from 2-3-4 tree, in which a node could have 1/2/3 keys and have 2/3/4 children respectively. The following shows an 2-3-4 tree.

```c
          2-3-4 tree

              n
            /    \
          c,i      t 
        /  |  \    /  \ 
       a  f,g  l  p,r  x
```

2-3-4 trees have the advantages of a balanced distribution and a bounded search time (*O(logN)*). However, they have a drawback of different node structures. To leverage the advantage and to achieve same node structures, red-black tree emerges. The interpretation of rbTree in Purdue's slides is a bit different than what we normally perceive, as the slides use colored edges instead of nodes. We keep the sense of colored node to be aligned with the kernel implementation.