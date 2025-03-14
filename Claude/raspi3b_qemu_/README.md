./runTest.sh -t 1 -l && ./runTest.sh -t 2 -l -d


// Runs good and then bad with asm op tracking then diffs (needs human intervention at midpoint)

It looks like the KDF is good when we compare:
Can you help explain the diffs here:
--- results/kernel1.in_asm.log    2025-03-14 11:58:30.086840582 +0000
+++ results/kernel2.in_asm.log    2025-03-14 11:58:53.123164443 +0000
@@ -91,13 +91,8 @@

 ----------------
 IN: main
-0x00013844:  
-OBJD-T: 64409fe504408fe0cdffffea
-
-----------------
-IN: main
-0x00013788:  
-OBJD-T: 0400a0e1b0edffeb
+0x00013780:  
+OBJD-T: 10419fe504408fe00400a0e1b0edffeb

 ----------------
 IN: strlen
@@ -401,13 +396,8 @@

 ----------------
 IN: main
-0x00013860:  
-OBJD-T: 50209fe550309fe5e1ffffea
-
-----------------
-IN: main
-0x000137f4:  
-OBJD-T: 022097e70500a0e1031097e7
+0x000137ec:  
+OBJD-T: ac209fe5ac309fe5022097e70500a0e1031097e7

 ----------------
 IN: main
@@ -1606,8 +1596,13 @@

 ----------------
 IN: tfp_format
-0x000120f8:  
-OBJD-T: 0e20a0e1a1ffffea
+0x00011f6c:  
+OBJD-T: 0a10a0e3910303e01ef332e7090052e3fbffff8a
+
+----------------
+IN: tfp_format
+0x00011f80:  
+OBJD-T: 000053e35d00000a

 ----------------
 IN: tfp_format
@@ -1627,6 +1622,12 @@

 ----------------
 IN: tfp_format
+0x00011fac:  
+OBJD-T: 1ef13ce70130a0e1992381e000205ae20800a0e10120a01301a08ae293ec6ee0
+OBJD-T: 090053e30120829300005ce3012082c330c08ce2a111a0e1000052e3ebffff1a
+
+----------------
+IN: tfp_format
 0x000120cc:  
 OBJD-T: 0c809de508a09de50010a0e30010c0e50830a0e100b08de50520a0e10710a0e1
 OBJD-T: 0600a0e1b1feffeb
@@ -1852,11 +1853,6 @@
 OBJD-T: 0810a0e10b00a0e1015085e2101100eb

 ----------------
-IN: derive_key
-0x0000f0a0:  
-OBJD-T: 050057e10030a0e30140a0e30300009a
-
-----------------
 IN: SHA1Update
 0x00013534:  
 OBJD-T: 404068e21c0088e2000085e00420a0e129f2ffeb
@@ -2078,6 +2074,11 @@

 ----------------
 IN: derive_key
+0x0000f0a0:  
+OBJD-T: 050057e10030a0e30140a0e30300009a
+
+----------------
+IN: derive_key
 0x0000f0c0:  
 OBJD-T: 0b80a0e1a8009fe50510a0e1a4609fe500008fe006608fe0100c00eb

Edit
I'll explain the key differences between these two assembly logs. These logs show changes in the object code (OBJD-T) at various memory addresses for different functions.

Here's a breakdown of the major changes:

Function: main
The two separate blocks at 0x00013844 and 0x00013788 in kernel1 have been combined into a single block at 0x00013780 in kernel2.
Original code: 64409fe504408fe0cdffffea and 0400a0e1b0edffeb
New code: 10419fe504408fe00400a0e1b0edffeb
This appears to be a code consolidation or optimization.
Function: main (second instance)
Similarly, two separate blocks at 0x00013860 and 0x000137f4 in kernel1 have been combined into a single block at 0x000137ec in kernel2.
Original code: 50209fe550309fe5e1ffffea and 022097e70500a0e1031097e7
New code: ac209fe5ac309fe5022097e70500a0e1031097e7
The registers and addresses being used have changed (from 50/50 to ac/ac).
Function: tfp_format
In kernel1, there was a single block at 0x000120f8 with code: 0e20a0e1a1ffffea
In kernel2, this has been expanded to three separate blocks at:
0x00011f6c: 0a10a0e3910303e01ef332e7090052e3fbffff8a
0x00011f80: 000053e35d00000a
0x00011fac: (longer code block) starting with 1ef13ce70130a0e1...
This suggests a significant expansion or rewrite of the tfp_format function, possibly adding new functionality.
Function: derive_key
The block at 0x0000f0a0 with code 050057e10030a0e30140a0e30300009a has been moved.
In kernel1, it appears before the SHA1Update function (at 0x00013534).
In kernel2, it appears later in the file (after address 0x00013534), but with the same code.
This is just a reordering of the assembly listing, not a functional change.
These changes indicate:

Code consolidation in the main function
Significant expansion of the tfp_format function
Reordering of some assembly blocks
The most substantial change appears to be in the tfp_format function, which has been significantly expanded in kernel2, possibly to add new formatting capabilities or fix bugs in the implementation.


