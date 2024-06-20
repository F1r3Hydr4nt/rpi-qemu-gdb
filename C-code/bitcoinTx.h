/*
Version no 	currently 1 	4 bytes
In-counter 	positive integer VI = VarInt 	1 - 9 bytes
list of inputs
Out-counter 	positive integer VI = VarInt 	1 - 9 bytes
list of outputs 	the outputs of the first transaction spend the mined bitcoins for the block 	<out-counter>-many outputs
lock_time 	if non-zero and sequence numbers are < 0xFFFFFFFF: block height or timestamp when transaction is final 	4 bytes */

struct TxOutput{
  uint8_t* data;
  size_t* dataLen;
}

struct TxInput{
  uint8_t* data;
  size_t* dataLen;
}

struct BitcoinTx{
  uint8_t* version;// 4 bytes
  uint8_t* vinCountBytes;// 1-9 bytes
  size_t vinCount;
  TxInput[vinCount] txIns;
  uint8_t* voutCountBytes; // 1-9 bytes
  size_t voutCount;
  TxOutput[voutCount] txOuts;
  uint8_t* lockTime; // 4 bytes usually 0xffffffff
};

//   struct Block result = {
//     .msb = block.msb ^ val.msb,
//     .lsb = block.lsb ^ val.lsb
//   };

