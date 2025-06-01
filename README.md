# ahb2apbBridge
The AHB to APB Bridge is a protocol converter that enables communication between high-speed AHB (Advanced High-performance Bus) masters and low-power APB (Advanced Peripheral Bus) peripherals. This design implements a fully compliant AMBA protocol bridge with the following key features:

Supports single read and write transfers

Handles AHB NONSEQ transfers only

Implements proper wait state insertion via hready

Provides always-OKAY response (hresp=0)

Supports back-to-back transfers

Maintains full protocol compliance with AMBA specifications

# The overall architecture looks like as:
![image](https://github.com/user-attachments/assets/f874345c-8b88-4675-aa5b-b87ef961539a)
