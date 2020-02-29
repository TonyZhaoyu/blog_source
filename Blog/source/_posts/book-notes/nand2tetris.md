---
title: The Element of Computing Systems (aka., Nand2tetris)
date: 2018-08-14 17:01:04
categories:
- [Book notes, CPU, Nand2tetris]
---

#### Nand2Tetris reference book

<img src="https://static.wixstatic.com/media/44046b_68deee3a58e64efdba36a6813c4ea906~mv2.png/v1/crop/x_73,y_0,w_663,h_654/fill/w_663,h_653,al_c,q_85/44046b_68deee3a58e64efdba36a6813c4ea906~mv2.webp" width="300" style="border-style: none">

The article covers project1 ~ project2 or chapter 1 ~ chapter 6, which are fundamentals of computer architectures based on HDL (an hardware description language defined in the book). Course materials could refer to https://www.nand2tetris.org/course, and videos on Coursera. The goal for this article is to build a Hack computer based on simple combinational and sequential logic elements composed in HDL.

* HACK computer overview:
    ![HACK computer overview](https://github.com/TonyZhaoyu/blog_source/blob/master/pics/HACK_computer.png?raw=true)

* CPU interface:
    ![CPU interface](https://github.com/TonyZhaoyu/blog_source/blob/master/pics/CPU_interface.png?raw=true)

* CPU control/data path:
    ![CPU control/data path](https://github.com/TonyZhaoyu/blog_source/blob/master/pics/CPU_path.png?raw=true)

The code below is HDL implementation of project 1, 2, 3 and 5.

##### Project 1: boolean logic

```c
// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/01/And.hdl

/**
 * And gate:
 * out = 1 if (a == 1 and b == 1)
 *       0 otherwise
 */

CHIP And {
    IN a, b;
    OUT out;

    PARTS:
    // Put your code here:
    Nand (a=a, b=b, out=outNand1);
    Nand (a=outNand1, b=true, out=out);
}


// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/01/And16.hdl

/**
 * 16-bit bitwise And:
 * for i = 0..15: out[i] = (a[i] and b[i])
 */

CHIP And16 {
    IN a[16], b[16];
    OUT out[16];

    PARTS:
    // Put your code here:
    And (a=a[0], b=b[0], out=out[0]);
    And (a=a[1], b=b[1], out=out[1]);
    And (a=a[2], b=b[2], out=out[2]);
    And (a=a[3], b=b[3], out=out[3]);
    And (a=a[4], b=b[4], out=out[4]);
    And (a=a[5], b=b[5], out=out[5]);
    And (a=a[6], b=b[6], out=out[6]);
    And (a=a[7], b=b[7], out=out[7]);
    And (a=a[8], b=b[8], out=out[8]);
    And (a=a[9], b=b[9], out=out[9]);
    And (a=a[10], b=b[10], out=out[10]);
    And (a=a[11], b=b[11], out=out[11]);
    And (a=a[12], b=b[12], out=out[12]);
    And (a=a[13], b=b[13], out=out[13]);
    And (a=a[14], b=b[14], out=out[14]);
    And (a=a[15], b=b[15], out=out[15]);
}

// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/01/DMux.hdl

/**
 * Demultiplexor:
 * {a, b} = {in, 0} if sel == 0
 *          {0, in} if sel == 1
 */

CHIP DMux {
    IN in, sel;
    OUT a, b;

    PARTS:
    // Put your code here:
    Not (in=sel, out=out1);
    And (a=in, b=out1, out=a);
    And (a=in, b=sel, out=b);
}

// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/01/DMux4Way.hdl

/**
 * 4-way demultiplexor:
 * {a, b, c, d} = {in, 0, 0, 0} if sel == 00
 *                {0, in, 0, 0} if sel == 01
 *                {0, 0, in, 0} if sel == 10
 *                {0, 0, 0, in} if sel == 11
 */

CHIP DMux4Way {
    IN in, sel[2];
    OUT a, b, c, d;

    PARTS:
    // Put your code here:
    DMux (in=in, sel=sel[1], a=out1, b=out2);
    DMux (in=out1, sel=sel[0], a=a, b=b);
    DMux (in=out2, sel=sel[0], a=c, b=d);
}

// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/01/DMux8Way.hdl

/**
 * 8-way demultiplexor:
 * {a, b, c, d, e, f, g, h} = {in, 0, 0, 0, 0, 0, 0, 0} if sel == 000
 *                            {0, in, 0, 0, 0, 0, 0, 0} if sel == 001
 *                            etc.
 *                            {0, 0, 0, 0, 0, 0, 0, in} if sel == 111
 */

CHIP DMux8Way {
    IN in, sel[3];
    OUT a, b, c, d, e, f, g, h;

    PARTS:
    // Put your code here:
    DMux (in=in, sel=sel[2], a=out1, b=out2);
    DMux (in=out1, sel=sel[1], a=out3, b=out4);
    DMux (in=out2, sel=sel[1], a=out5, b=out6);
    DMux (in=out3, sel=sel[0], a=a, b=b);
    DMux (in=out4, sel=sel[0], a=c, b=d);
    DMux (in=out5, sel=sel[0], a=e, b=f);
    DMux (in=out6, sel=sel[0], a=g, b=h);
}

// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/01/Mux.hdl

/**
 * Multiplexor:
 * out = a if sel == 0
 *       b otherwise
 */

CHIP Mux {
    IN a, b, sel;
    OUT out;

    PARTS:
    // Put your code here:
    Not (in=sel, out=outNot);
    And (a=a, b=outNot, out=outAnd1);
    And (a=sel, b=b, out=outAnd2);
    Or  (a=outAnd1, b=outAnd2, out=out);
}

// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/01/Mux4Way16.hdl

/**
 * 4-way 16-bit multiplexor:
 * out = a if sel == 00
 *       b if sel == 01
 *       c if sel == 10
 *       d if sel == 11
 */

CHIP Mux4Way16 {
    IN a[16], b[16], c[16], d[16], sel[2];
    OUT out[16];

    PARTS:
    // Put your code here:
    Mux16 (a=a, b=b, sel=sel[0], out=out1);
    Mux16 (a=c, b=d, sel=sel[0], out=out2);
    Mux16 (a=out1, b=out2, sel=sel[1], out=out);
}

// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/01/Mux8Way16.hdl

/**
 * 8-way 16-bit multiplexor:
 * out = a if sel == 000
 *       b if sel == 001
 *       etc.
 *       h if sel == 111
 */

CHIP Mux8Way16 {
    IN a[16], b[16], c[16], d[16],
       e[16], f[16], g[16], h[16],
       sel[3];
    OUT out[16];

    PARTS:
    // Put your code here:
    Mux16 (a=a, b=b, sel=sel[0], out=out1);
    Mux16 (a=c, b=d, sel=sel[0], out=out2);
    Mux16 (a=e, b=f, sel=sel[0], out=out3);
    Mux16 (a=g, b=h, sel=sel[0], out=out4);
    Mux16 (a=out1, b=out2, sel=sel[1], out=out5);
    Mux16 (a=out3, b=out4, sel=sel[1], out=out6);
    Mux16 (a=out5, b=out6, sel=sel[2], out=out);
}

// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/01/Mux16.hdl

/**
 * 16-bit multiplexor:
 * for i = 0..15 out[i] = a[i] if sel == 0
 *                        b[i] if sel == 1
 */

CHIP Mux16 {
    IN a[16], b[16], sel;
    OUT out[16];

    PARTS:
    // Put your code here:
    Mux (a=a[0], b=b[0], sel=sel, out=out[0]);
    Mux (a=a[1], b=b[1], sel=sel, out=out[1]);
    Mux (a=a[2], b=b[2], sel=sel, out=out[2]);
    Mux (a=a[3], b=b[3], sel=sel, out=out[3]);
    Mux (a=a[4], b=b[4], sel=sel, out=out[4]);
    Mux (a=a[5], b=b[5], sel=sel, out=out[5]);
    Mux (a=a[6], b=b[6], sel=sel, out=out[6]);
    Mux (a=a[7], b=b[7], sel=sel, out=out[7]);
    Mux (a=a[8], b=b[8], sel=sel, out=out[8]);
    Mux (a=a[9], b=b[9], sel=sel, out=out[9]);
    Mux (a=a[10], b=b[10], sel=sel, out=out[10]);
    Mux (a=a[11], b=b[11], sel=sel, out=out[11]);
    Mux (a=a[12], b=b[12], sel=sel, out=out[12]);
    Mux (a=a[13], b=b[13], sel=sel, out=out[13]);
    Mux (a=a[14], b=b[14], sel=sel, out=out[14]);
    Mux (a=a[15], b=b[15], sel=sel, out=out[15]);
}

// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/01/Not.hdl

/**
 * Not gate:
 * out = not in
 */

CHIP Not {
    IN in;
    OUT out;

    PARTS:
    // Put your code here:
    Nand (a=in, b=true, out=out);
}

// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/01/Not16.hdl

/**
 * 16-bit Not:
 * for i=0..15: out[i] = not in[i]
 */

CHIP Not16 {
    IN in[16];
    OUT out[16];

    PARTS:
    // Put your code here:
    Not (in=in[0], out=out[0]);
    Not (in=in[1], out=out[1]);
    Not (in=in[2], out=out[2]);
    Not (in=in[3], out=out[3]);
    Not (in=in[4], out=out[4]);
    Not (in=in[5], out=out[5]);
    Not (in=in[6], out=out[6]);
    Not (in=in[7], out=out[7]);
    Not (in=in[8], out=out[8]);
    Not (in=in[9], out=out[9]);
    Not (in=in[10], out=out[10]);
    Not (in=in[11], out=out[11]);
    Not (in=in[12], out=out[12]);
    Not (in=in[13], out=out[13]);
    Not (in=in[14], out=out[14]);
    Not (in=in[15], out=out[15]);
}

// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/01/Or.hdl

 /**
 * Or gate:
 * out = 1 if (a == 1 or b == 1)
 *       0 otherwise
 */

CHIP Or {
    IN a, b;
    OUT out;

    PARTS:
    // Put your code here:
    Nand (a=a, b=true, out=outNot1);
    Nand (a=true, b=b, out=outNot2);
    Nand (a=outNot1, b=outNot2, out=out);
}

// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/01/Or8Way.hdl

/**
 * 8-way Or:
 * out = (in[0] or in[1] or ... or in[7])
 */

CHIP Or8Way {
    IN in[8];
    OUT out;

    PARTS:
    // Put your code here:
    Or (a=in[0], b=in[1], out=outOr1);
    Or (a=in[2], b=outOr1, out=outOr2);
    Or (a=in[3], b=outOr2, out=outOr3);
    Or (a=in[4], b=outOr3, out=outOr4);
    Or (a=in[5], b=outOr4, out=outOr5);
    Or (a=in[6], b=outOr5, out=outOr6);
    Or (a=in[7], b=outOr6, out=out);
}

// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/01/Or16.hdl

/**
 * 16-bit bitwise Or:
 * for i = 0..15 out[i] = (a[i] or b[i])
 */

CHIP Or16 {
    IN a[16], b[16];
    OUT out[16];

    PARTS:
    // Put your code here:
    Or (a=a[0], b=b[0], out=out[0]);
    Or (a=a[1], b=b[1], out=out[1]);
    Or (a=a[2], b=b[2], out=out[2]);
    Or (a=a[3], b=b[3], out=out[3]);
    Or (a=a[4], b=b[4], out=out[4]);
    Or (a=a[5], b=b[5], out=out[5]);
    Or (a=a[6], b=b[6], out=out[6]);
    Or (a=a[7], b=b[7], out=out[7]);
    Or (a=a[8], b=b[8], out=out[8]);
    Or (a=a[9], b=b[9], out=out[9]);
    Or (a=a[10], b=b[10], out=out[10]);
    Or (a=a[11], b=b[11], out=out[11]);
    Or (a=a[12], b=b[12], out=out[12]);
    Or (a=a[13], b=b[13], out=out[13]);
    Or (a=a[14], b=b[14], out=out[14]);
    Or (a=a[15], b=b[15], out=out[15]);
}

// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/01/Xor.hdl

/**
 * Exclusive-or gate:
 * out = not (a == b)
 */

CHIP Xor {
    IN a, b;
    OUT out;

    PARTS:
    // Put your code here:
    Not (in=a, out=nota);
    Not (in=b, out=notb);
    And (a=a, b=notb, out=w1);
    And (a=nota, b=b, out=w2);
    Or  (a=w1, b=w2, out=out);
}
```

##### Project 2: boolean arithmetic

```c
// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/02/Adder16.hdl

/**
 * Adds two 16-bit values.
 * The most significant carry bit is ignored.
 */

CHIP Add16 {
    IN a[16], b[16];
    OUT out[16];

    PARTS:
   // Put you code here:
   FullAdder (a=a[0], b=b[0], c=false, sum=out[0], carry=carry15);
   FullAdder (a=a[1], b=b[1], c=carry15, sum=out[1], carry=carry14);
   FullAdder (a=a[2], b=b[2], c=carry14, sum=out[2], carry=carry13);
   FullAdder (a=a[3], b=b[3], c=carry13, sum=out[3], carry=carry12);
   FullAdder (a=a[4], b=b[4], c=carry12, sum=out[4], carry=carry11);
   FullAdder (a=a[5], b=b[5], c=carry11, sum=out[5], carry=carry10);
   FullAdder (a=a[6], b=b[6], c=carry10, sum=out[6], carry=carry9);
   FullAdder (a=a[7], b=b[7], c=carry9, sum=out[7], carry=carry8);
   FullAdder (a=a[8], b=b[8], c=carry8, sum=out[8], carry=carry7);
   FullAdder (a=a[9], b=b[9], c=carry7, sum=out[9], carry=carry6);
   FullAdder (a=a[10], b=b[10], c=carry6, sum=out[10], carry=carry5);
   FullAdder (a=a[11], b=b[11], c=carry5, sum=out[11], carry=carry4);
   FullAdder (a=a[12], b=b[12], c=carry4, sum=out[12], carry=carry3);
   FullAdder (a=a[13], b=b[13], c=carry3, sum=out[13], carry=carry2);
   FullAdder (a=a[14], b=b[14], c=carry2, sum=out[14], carry=carry1);
   FullAdder (a=a[15], b=b[15], c=carry1, sum=out[15], carry=carry0);
}

// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/02/ALU.hdl

/**
 * The ALU (Arithmetic Logic Unit).
 * Computes one of the following functions:
 * x+y, x-y, y-x, 0, 1, -1, x, y, -x, -y, !x, !y,
 * x+1, y+1, x-1, y-1, x&y, x|y on two 16-bit inputs,
 * according to 6 input bits denoted zx,nx,zy,ny,f,no.
 * In addition, the ALU computes two 1-bit outputs:
 * if the ALU output == 0, zr is set to 1; otherwise zr is set to 0;
 * if the ALU output < 0, ng is set to 1; otherwise ng is set to 0.
 */

// Implementation: the ALU logic manipulates the x and y inputs
// and operates on the resulting values, as follows:
// if (zx == 1) set x = 0        // 16-bit constant
// if (nx == 1) set x = !x       // bitwise not
// if (zy == 1) set y = 0        // 16-bit constant
// if (ny == 1) set y = !y       // bitwise not
// if (f == 1)  set out = x + y  // integer 2's complement addition
// if (f == 0)  set out = x & y  // bitwise and
// if (no == 1) set out = !out   // bitwise not
// if (out == 0) set zr = 1
// if (out < 0) set ng = 1

CHIP ALU {
    IN
        x[16], y[16],  // 16-bit inputs
        zx, // zero the x input?
        nx, // negate the x input?
        zy, // zero the y input?
        ny, // negate the y input?
        f,  // compute out = x + y (if 1) or x & y (if 0)
        no; // negate the out output?

    OUT
        out[16], // 16-bit output
        zr, // 1 if (out == 0), 0 otherwise
        ng; // 1 if (out < 0),  0 otherwise

    PARTS:
    // Put you code here:
    Not16 (in=x, out=notx);
    Mux4Way16 (a=x, b=notx, c=false, d=true, sel[1]=zx, sel[0]=nx, out=outx);
    Not16 (in=y, out=noty);
    Mux4Way16 (a=y, b=noty, c=false, d=true, sel[1]=zy, sel[0]=ny, out=outy);
    And16 (a=outx, b=outy, out=outAnd);
    Add16 (a=outx, b=outy, out=outAdd);
    Mux16 (a=outAnd, b=outAdd, sel=f, out=outsel1);
    Not16 (in=outsel1, out=outsel2);
    Mux16 (a=outsel1, b=outsel2, sel=no, out=out, out[15]=sign, out[15]=out15, out[14]=out14,
           out[13]=out13, out[12]=out12, out[11]=out11, out[10]=out10, out[9]=out9, out[8]=out8,
           out[7]=out7, out[6]=out6, out[5]=out5, out[4]=out4, out[3]=out3, out[2]=out2, out[1]=out1,
           out[0]=out0);
    Or (a=sign, b=false, out=ng);
    Or (a=out0, b=out1, out=and1);
    Or (a=and1, b=out2, out=and2);
    Or (a=and2, b=out3, out=and3);
    Or (a=and3, b=out4, out=and4);
    Or (a=and4, b=out5, out=and5);
    Or (a=and5, b=out6, out=and6);
    Or (a=and6, b=out7, out=and7);
    Or (a=and7, b=out8, out=and8);
    Or (a=and8, b=out9, out=and9);
    Or (a=and9, b=out10, out=and10);
    Or (a=and10, b=out11, out=and11);
    Or (a=and11, b=out12, out=and12);
    Or (a=and12, b=out13, out=and13);
    Or (a=and13, b=out14, out=and14);
    Or (a=and14, b=out15, out=and15);
    Not (in=and15, out=zr);
}

// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/02/FullAdder.hdl

/**
 * Computes the sum of three bits.
 */

CHIP FullAdder {
    IN a, b, c;  // 1-bit inputs
    OUT sum,     // Right bit of a + b + c
        carry;   // Left bit of a + b + c

    PARTS:
    // Put you code here:
    HalfAdder (a=a, b=b, carry=carry1, sum=sum1);
    HalfAdder (a=sum1, b=c, carry=carry2, sum=sum);
    Or (a=carry1, b=carry2, out=carry);
}

// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/02/FullAdder.hdl

/**
 * Computes the sum of three bits.
 */

CHIP FullAdder {
    IN a, b, c;  // 1-bit inputs
    OUT sum,     // Right bit of a + b + c
        carry;   // Left bit of a + b + c

    PARTS:
    // Put you code here:
    HalfAdder (a=a, b=b, carry=carry1, sum=sum1);
    HalfAdder (a=sum1, b=c, carry=carry2, sum=sum);
    Or (a=carry1, b=carry2, out=carry);
}

// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/02/Inc16.hdl

/**
 * 16-bit incrementer:
 * out = in + 1 (arithmetic addition)
 */

CHIP Inc16 {
    IN in[16];
    OUT out[16];

    PARTS:
   // Put you code here:
   Add16 (a=in, b[0]=true, out=out);
}
```

##### Project 3: sequential logic

```c
// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/03/a/Bit.hdl

/**
 * 1-bit register:
 * If load[t] == 1 then out[t+1] = in[t]
 *                 else out does not change (out[t+1] = out[t])
 */

CHIP Bit {
    IN in, load;
    OUT out;

    PARTS:
    // Put your code here:
    Mux (a=dffOut, b=in, sel=load, out=muxOut);
    DFF (in=muxOut, out=out, out=dffOut);
}

// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/03/a/PC.hdl

/**
 * A 16-bit counter with load and reset control bits.
 * if      (reset[t] == 1) out[t+1] = 0
 * else if (load[t] == 1)  out[t+1] = in[t]
 * else if (inc[t] == 1)   out[t+1] = out[t] + 1  (integer addition)
 * else                    out[t+1] = out[t]
 */

CHIP PC {
    IN in[16],load,inc,reset;
    OUT out[16];

    PARTS:
    // Put your code here:
    Inc16 (in=rOut, out=incOut);
    Mux16 (a=in, b=incOut, sel=inc, out=muxOut1);
    Mux16 (a=muxOut1, b=in, sel=load, out=muxOut2);
    And16 (a=in, b=false, out=andOut);
    Mux16 (a=muxOut2, b=andOut, sel=reset, out=muxOut3);
    Register (in=muxOut3, load=true, out=out, out=rOut);
}

// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/03/b/RAM4K.hdl

/**
 * Memory of 4K registers, each 16 bit-wide. Out holds the value
 * stored at the memory location specified by address. If load==1, then
 * the in value is loaded into the memory location specified by address
 * (the loaded value will be emitted to out from the next time step onward).
 */

CHIP RAM4K {
    IN in[16], load, address[12];
    OUT out[16];

    PARTS:
    // Put your code here:
    DMux8Way (in=load, sel[2]=address[11], sel[1]=address[10], sel[0]=address[9],
              a=out1, b=out2, c=out3, d=out4, e=out5, f=out6, g=out7, h=out8);
    RAM512 (in=in, load=out1, address[8]=address[8], address[7]=address[7], address[6]=address[6],
            address[5]=address[5], address[4]=address[4], address[3]=address[3], address[2]=address[2],
            address[1]=address[1], address[0]=address[0], out=outR1);
    RAM512 (in=in, load=out2, address[8]=address[8], address[7]=address[7], address[6]=address[6],
            address[5]=address[5], address[4]=address[4], address[3]=address[3], address[2]=address[2],
            address[1]=address[1], address[0]=address[0], out=outR2);
    RAM512 (in=in, load=out3, address[8]=address[8], address[7]=address[7], address[6]=address[6],
            address[5]=address[5], address[4]=address[4], address[3]=address[3], address[2]=address[2],
            address[1]=address[1], address[0]=address[0], out=outR3);
    RAM512 (in=in, load=out4, address[8]=address[8], address[7]=address[7], address[6]=address[6],
            address[5]=address[5], address[4]=address[4], address[3]=address[3], address[2]=address[2],
            address[1]=address[1], address[0]=address[0], out=outR4);
    RAM512 (in=in, load=out5, address[8]=address[8], address[7]=address[7], address[6]=address[6],
            address[5]=address[5], address[4]=address[4], address[3]=address[3], address[2]=address[2],
            address[1]=address[1], address[0]=address[0], out=outR5);
    RAM512 (in=in, load=out6, address[8]=address[8], address[7]=address[7], address[6]=address[6],
            address[5]=address[5], address[4]=address[4], address[3]=address[3], address[2]=address[2],
            address[1]=address[1], address[0]=address[0], out=outR6);
    RAM512 (in=in, load=out7, address[8]=address[8], address[7]=address[7], address[6]=address[6],
            address[5]=address[5], address[4]=address[4], address[3]=address[3], address[2]=address[2],
            address[1]=address[1], address[0]=address[0], out=outR7);
    RAM512 (in=in, load=out8, address[8]=address[8], address[7]=address[7], address[6]=address[6],
            address[5]=address[5], address[4]=address[4], address[3]=address[3], address[2]=address[2],
            address[1]=address[1], address[0]=address[0], out=outR8);
    Mux8Way16 (a=outR1, b=outR2, c=outR3, d=outR4, e=outR5, f=outR6, g=outR7, h=outR8,
               sel[2]=address[11], sel[1]=address[10], sel[0]=address[9], out=out);
}

// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/03/a/RAM8.hdl

/**
 * Memory of 8 registers, each 16 bit-wide. Out holds the value
 * stored at the memory location specified by address. If load==1, then
 * the in value is loaded into the memory location specified by address
 * (the loaded value will be emitted to out from the next time step onward).
 */

CHIP RAM8 {
    IN in[16], load, address[3];
    OUT out[16];

    PARTS:
    // Put your code here:
    DMux8Way (in=load, sel=address, a=out1, b=out2, c=out3, d=out4, e=out5, f=out6, g=out7, h=out8);
    Register (in=in, load=out1, out=outR1);
    Register (in=in, load=out2, out=outR2);
    Register (in=in, load=out3, out=outR3);
    Register (in=in, load=out4, out=outR4);
    Register (in=in, load=out5, out=outR5);
    Register (in=in, load=out6, out=outR6);
    Register (in=in, load=out7, out=outR7);
    Register (in=in, load=out8, out=outR8);
    Mux8Way16 (a=outR1, b=outR2, c=outR3, d=outR4, e=outR5, f=outR6, g=outR7, h=outR8, sel=address, out=out);
}

// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/03/b/RAM16K.hdl

/**
 * Memory of 16K registers, each 16 bit-wide. Out holds the value
 * stored at the memory location specified by address. If load==1, then
 * the in value is loaded into the memory location specified by address
 * (the loaded value will be emitted to out from the next time step onward).
 */

CHIP RAM16K {
    IN in[16], load, address[14];
    OUT out[16];

    PARTS:
    // Put your code here:
    DMux4Way (in=load, sel[1]=address[13], sel[0]=address[12], a=out1, b=out2, c=out3, d=out4);
    RAM4K (in=in, load=out1, address[11]=address[11], address[10]=address[10], address[9]=address[9],
           address[8]=address[8], address[7]=address[7], address[6]=address[6], address[5]=address[5],
           address[4]=address[4], address[3]=address[3], address[2]=address[2], address[1]=address[1],
           address[0]=address[0], out=outR1);
    RAM4K (in=in, load=out2, address[11]=address[11], address[10]=address[10], address[9]=address[9],
           address[8]=address[8], address[7]=address[7], address[6]=address[6], address[5]=address[5],
           address[4]=address[4], address[3]=address[3], address[2]=address[2], address[1]=address[1],
           address[0]=address[0], out=outR2);
    RAM4K (in=in, load=out3, address[11]=address[11], address[10]=address[10], address[9]=address[9],
           address[8]=address[8], address[7]=address[7], address[6]=address[6], address[5]=address[5],
           address[4]=address[4], address[3]=address[3], address[2]=address[2], address[1]=address[1],
           address[0]=address[0], out=outR3);
    RAM4K (in=in, load=out4, address[11]=address[11], address[10]=address[10], address[9]=address[9],
           address[8]=address[8], address[7]=address[7], address[6]=address[6], address[5]=address[5],
           address[4]=address[4], address[3]=address[3], address[2]=address[2], address[1]=address[1],
           address[0]=address[0], out=outR4);
    Mux4Way16 (a=outR1, b=outR2, c=outR3, d=outR4, sel[1]=address[13], sel[0]=address[12], out=out);
}

// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/03/a/RAM64.hdl

/**
 * Memory of 64 registers, each 16 bit-wide. Out holds the value
 * stored at the memory location specified by address. If load==1, then
 * the in value is loaded into the memory location specified by address
 * (the loaded value will be emitted to out from the next time step onward).
 */

CHIP RAM64 {
    IN in[16], load, address[6];
    OUT out[16];

    PARTS:
    // Put your code here:
    DMux8Way (in=load, sel[2]=address[5], sel[1]=address[4], sel[0]=address[3], a=out1, b=out2, c=out3,
              d=out4, e=out5, f=out6, g=out7, h=out8);
    RAM8 (in=in, load=out1, address[2]=address[2], address[1]=address[1], address[0]=address[0], out=outR1);
    RAM8 (in=in, load=out2, address[2]=address[2], address[1]=address[1], address[0]=address[0], out=outR2);
    RAM8 (in=in, load=out3, address[2]=address[2], address[1]=address[1], address[0]=address[0], out=outR3);
    RAM8 (in=in, load=out4, address[2]=address[2], address[1]=address[1], address[0]=address[0], out=outR4);
    RAM8 (in=in, load=out5, address[2]=address[2], address[1]=address[1], address[0]=address[0], out=outR5);
    RAM8 (in=in, load=out6, address[2]=address[2], address[1]=address[1], address[0]=address[0], out=outR6);
    RAM8 (in=in, load=out7, address[2]=address[2], address[1]=address[1], address[0]=address[0], out=outR7);
    RAM8 (in=in, load=out8, address[2]=address[2], address[1]=address[1], address[0]=address[0], out=outR8);
    Mux8Way16 (a=outR1, b=outR2, c=outR3, d=outR4, e=outR5, f=outR6, g=outR7, h=outR8, sel[2]=address[5],
               sel[1]=address[4], sel[0]=address[3], out=out);
}

// This file is part of the materials accompanying the book
// "The Elements of Computing Systems" by Nisan and Schocken,
// MIT Press. Book site: www.idc.ac.il/tecs
// File name: projects/03/b/RAM512.hdl

/**
 * Memory of 512 registers, each 16 bit-wide. Out holds the value
 * stored at the memory location specified by address. If load==1, then
 * the in value is loaded into the memory location specified by address
 * (the loaded value will be emitted to out from the next time step onward).
 */

CHIP RAM512 {
    IN in[16], load, address[9];
    OUT out[16];

    PARTS:
    // Put your code here:
    DMux8Way (in=load, sel[2]=address[8], sel[1]=address[7], sel[0]=address[6], a=out1, b=out2, c=out3,
              d=out4, e=out5, f=out6, g=out7, h=out8);
    RAM64 (in=in, load=out1, address[5]=address[5], address[4]=address[4], address[3]=address[3],
           address[2]=address[2], address[1]=address[1], address[0]=address[0], out=outR1);
    RAM64 (in=in, load=out2, address[5]=address[5], address[4]=address[4], address[3]=address[3],
           address[2]=address[2], address[1]=address[1], address[0]=address[0], out=outR2);
    RAM64 (in=in, load=out3, address[5]=address[5], address[4]=address[4], address[3]=address[3],
           address[2]=address[2], address[1]=address[1], address[0]=address[0], out=outR3);
    RAM64 (in=in, load=out4, address[5]=address[5], address[4]=address[4], address[3]=address[3],
           address[2]=address[2], address[1]=address[1], address[0]=address[0], out=outR4);
    RAM64 (in=in, load=out5, address[5]=address[5], address[4]=address[4], address[3]=address[3],
           address[2]=address[2], address[1]=address[1], address[0]=address[0], out=outR5);
    RAM64 (in=in, load=out6, address[5]=address[5], address[4]=address[4], address[3]=address[3],
           address[2]=address[2], address[1]=address[1], address[0]=address[0], out=outR6);
    RAM64 (in=in, load=out7, address[5]=address[5], address[4]=address[4], address[3]=address[3],
           address[2]=address[2], address[1]=address[1], address[0]=address[0], out=outR7);
    RAM64 (in=in, load=out8, address[5]=address[5], address[4]=address[4], address[3]=address[3],
           address[2]=address[2], address[1]=address[1], address[0]=address[0], out=outR8);
    Mux8Way16 (a=outR1, b=outR2, c=outR3, d=outR4, e=outR5, f=outR6, g=outR7, h=outR8, sel[2]=address[8],
               sel[1]=address[7], sel[0]=address[6], out=out);
}

// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/03/a/Register.hdl

/**
 * 16-bit register:
 * If load[t] == 1 then out[t+1] = in[t]
 * else out does not change
 */

CHIP Register {
    IN in[16], load;
    OUT out[16];

    PARTS:
    // Put your code here:
    Bit (in=in[0], load=load, out=out[0]);
    Bit (in=in[1], load=load, out=out[1]);
    Bit (in=in[2], load=load, out=out[2]);
    Bit (in=in[3], load=load, out=out[3]);
    Bit (in=in[4], load=load, out=out[4]);
    Bit (in=in[5], load=load, out=out[5]);
    Bit (in=in[6], load=load, out=out[6]);
    Bit (in=in[7], load=load, out=out[7]);
    Bit (in=in[8], load=load, out=out[8]);
    Bit (in=in[9], load=load, out=out[9]);
    Bit (in=in[10], load=load, out=out[10]);
    Bit (in=in[11], load=load, out=out[11]);
    Bit (in=in[12], load=load, out=out[12]);
    Bit (in=in[13], load=load, out=out[13]);
    Bit (in=in[14], load=load, out=out[14]);
    Bit (in=in[15], load=load, out=out[15]);
}
```

##### Project 5: computer architecture

```c
// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/05/CPU.hdl

/**
 * The Hack CPU (Central Processing unit), consisting of an ALU,
 * two registers named A and D, and a program counter named PC.
 * The CPU is designed to fetch and execute instructions written in
 * the Hack machine language. In particular, functions as follows:
 * Executes the inputted instruction according to the Hack machine
 * language specification. The D and A in the language specification
 * refer to CPU-resident registers, while M refers to the external
 * memory location addressed by A, i.e. to Memory[A]. The inM input
 * holds the value of this location. If the current instruction needs
 * to write a value to M, the value is placed in outM, the address
 * of the target location is placed in the addressM output, and the
 * writeM control bit is asserted. (When writeM==0, any value may
 * appear in outM). The outM and writeM outputs are combinational:
 * they are affected instantaneously by the execution of the current
 * instruction. The addressM and pc outputs are clocked: although they
 * are affected by the execution of the current instruction, they commit
 * to their new values only in the next time step. If reset==1 then the
 * CPU jumps to address 0 (i.e. pc is set to 0 in next time step) rather
 * than to the address resulting from executing the current instruction.
 */

CHIP CPU {

    IN  inM[16],         // M value input  (M = contents of RAM[A])
        instruction[16], // Instruction for execution
        reset;           // Signals whether to re-start the current
                         // program (reset==1) or continue executing
                         // the current program (reset==0).

    OUT outM[16],        // M value output
        writeM,          // Write to M?
        addressM[15],    // Address in data memory (of M)
        pc[15];          // address of next instruction

    PARTS:
    // Put your code here:
    // PC block.
    And (a=instruction[2], b=aluNg, out=pcAndOut1);
    And (a=instruction[1], b=aluZr, out=pcAndOut2);
    Not (in=aluNg, out=pcNotOut1);
    Not (in=aluZr, out=pcNotOut2);
    And (a=instruction[0], b=pcNotOut1, out=pcAndOut3);
    And (a=pcAndOut3, b=pcNotOut2, out=pcAndOut4);
    Or (a=pcAndOut1, b=pcAndOut2, out=pcOrOut1);
    Or (a=pcOrOut1, b=pcAndOut4, out=pcOrOut2);
    And (a=instruction[15], b=pcOrOut2, out=pcLoad);
    PC (in=aRegOut, load= pcLoad, inc=true, reset= reset, out[0..14]=pc);
    // Mux16_1 block.
    Mux16 (a=instruction, b=aluOut, sel=instruction[15], out=mux16Out1);
    // A register block.
    Not (in=instruction[15], out=aRegNotOut1);
    And (a=instruction[15], b=instruction[5], out=aRegAndOut1);
    Or (a=aRegNotOut1, b=aRegAndOut1, out=aRegLoad);
    ARegister (in=mux16Out1, load=aRegLoad, out=aRegOut, out[0..14]=addressM);
    // D register block.
    And (a=instruction[15], b=instruction[4], out=dRegLoad);
    DRegister (in=aluOut, load=dRegLoad, out=dRegOut);
    // Mux16_2 block.
    Mux16 (a=aRegOut, b=inM, sel=instruction[12], out=mux16Out2);
    // ALU block.
    ALU(x=dRegOut, y=mux16Out2, zx=instruction[11], nx=instruction[10], zy=instruction[9], ny=instruction[8],
        f=instruction[7], no=instruction[6], out=aluOut, zr=aluZr, ng=aluNg, out=outM);
    // writeM output block.
    Not (in=instruction[9], out=wmNotOut1);
    And (a=instruction[12], b=instruction[3], out=wmAndOut1);
    Not (in=instruction[12], out=wmNotOut2);
    Or (a=wmNotOut2, b=wmAndOut1, out=wmOrOut1);
    And (a=wmOrOut1, b=instruction[3], out=wmAndOut2);
    And (a=wmAndOut2, b=instruction[15], out=writeM);
}

// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/05/Memory.hdl

/**
 * The complete address space of the Hack computer's memory,
 * including RAM and memory-mapped I/O.
 * The chip facilitates read and write operations, as follows:
 *     Read:  out(t) = Memory[address(t)](t)
 *     Write: if load(t-1) then Memory[address(t-1)](t) = in(t-1)
 * In words: the chip always outputs the value stored at the memory
 * location specified by address. If load==1, the in value is loaded
 * into the memory location specified by address. This value becomes
 * available through the out output from the next time step onward.
 * Address space rules:
 * Only the upper 16K+8K+1 words of the Memory chip are used.
 * Access to address>0x6000 is invalid. Access to any address in
 * the range 0x4000-0x5FFF results in accessing the screen memory
 * map. Access to address 0x6000 results in accessing the keyboard
 * memory map. The behavior in these addresses is described in the
 * Screen and Keyboard chip specifications given in the book.
 */

CHIP Memory {
    IN in[16], load, address[15];
    OUT out[16];

    PARTS:
    // Put your code here:
    And (a=address[13], b=true, out=andOut1);
    And (a=address[14], b=true, out=andOut2);
    Not (in=andOut1, out=notOut1);
    Not (in=andOut2, out=notOut2);
    // RAM
    And (a=true, b=notOut2, out=ramAnd1);
    And (a=load, b=ramAnd1, out=ramLoad);
    RAM16K (in=in, load=ramLoad, address=address[0..13], out=ramOut);
    And16 (a[0]=ramAnd1, a[1]=ramAnd1, a[2]=ramAnd1, a[3]=ramAnd1, a[4]=ramAnd1, a[5]=ramAnd1, a[6]=ramAnd1,
          a[7]=ramAnd1, a[8]=ramAnd1, a[9]=ramAnd1, a[10]=ramAnd1, a[11]=ramAnd1, a[12]=ramAnd1, a[13]=ramAnd1,
          a[14]=ramAnd1, a[15]=ramAnd1, b=ramOut, out=ramFinal);
    // SCREEN
    And (a=notOut1, b=andOut2, out=scAnd1);
    And (a=load, b=scAnd1, out=scLoad);
    And16 (a[0]=scAnd1, a[1]=scAnd1, a[2]=scAnd1, a[3]=scAnd1, a[4]=scAnd1, a[5]=scAnd1, a[6]=scAnd1,
           a[7]=scAnd1, a[8]=scAnd1, a[9]=scAnd1, a[10]=scAnd1, a[11]=scAnd1, a[12]=scAnd1, a[13]=scAnd1,
           a[14]=scAnd1, a[15]=scAnd1, b=scOut, out=scFinal);
    Screen (in=in, load=scLoad, address=address[0..12], out=scOut);
    // KEYBOARD
    Keyboard (out=kbOut);
    And (a=andOut1, b=andOut2, out=kbAnd1);
    And16 (a[0]=kbAnd1, a[1]=kbAnd1, a[2]=kbAnd1, a[3]=kbAnd1, a[4]=kbAnd1, a[5]=kbAnd1, a[6]=kbAnd1,
           a[7]=kbAnd1, a[8]=kbAnd1, a[9]=kbAnd1, a[10]=kbAnd1, a[11]=kbAnd1, a[12]=kbAnd1, a[13]=kbAnd1,
           a[14]=kbAnd1, a[15]=kbAnd1, b=kbOut, out=kbFinal);
    // OUTPUT
    Or16 (a=ramFinal, b=scFinal, out=outFinal1);
    Or16 (a=outFinal1, b=kbFinal, out=out);
}

// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/05/Computer.hdl

/**
 * The HACK computer, including CPU, ROM and RAM.
 * When reset is 0, the program stored in the computer's ROM executes.
 * When reset is 1, the execution of the program restarts.
 * Thus, to start a program's execution, reset must be pushed "up" (1)
 * and "down" (0). From this point onward the user is at the mercy of
 * the software. In particular, depending on the program's code, the
 * screen may show some output and the user may be able to interact
 * with the computer via the keyboard.
 */

CHIP Computer {

    IN reset;

    PARTS:
    // Put your code here:
    ROM32K (address=pcOut, out=insOut);
    CPU (inM=memOut, instruction=insOut, reset=reset, outM=cpuOutM, writeM=cpuWm, addressM=cpuAm, pc=pcOut);
    Memory (in=cpuOutM, load=cpuWm, address=cpuAm, out=memOut);
}
```
