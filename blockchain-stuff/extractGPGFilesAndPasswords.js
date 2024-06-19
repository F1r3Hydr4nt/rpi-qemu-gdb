const gpgFilesTxids = [
  "7379ab5047b143c0b6cfe5d8d79ad240b4b4f8cced55aa26f86d1d3d370c0d4c",
    "d3c1cb2cdbf07c25e3c5f513de5ee36081a7c590e621f1f1eab62e8d4b50b635",
    "cce82f3bde0537f82a55f3b8458cb50d632977f85c81dad3e1983a3348638f5c",
    "8a75514829b6e30b9fea434eef77b1589ff3f4bdfc0056bd087efbfb8314eb59",
    "8f3b90d8de36b424a0afd51dee41d439b364079967ebf161302aa7b5a9094711",
];
const pwTxids = [
    "ee7881862ceb30d9f957bc6edcae96e27099b126e275ff040672a76c8a6ee1b9",
    "",
    "ce81de6360502c6bc603fb77806b07eb52b796914a805196fe83f15cf7b8ff06",
    "aa353913b68ed3448cbd83ec942067eb4862b34bf88a1cc5d4ccbb10354f94a4",
    "57065d22d9d6b26fe05d58d627fb1472baf6d2e3b494f13e7e781252a3c94e8d",
];

const fs = require("fs");
const path = require("path");
const bsv = require("bsv");

function readTransactionHex(txid) {
  const folderPath = path.join(__dirname, "wlTxs");
  const filePath = path.join(folderPath, `${txid}.hex`);
  // console.log({ filePath });
  if (fs.existsSync(filePath)) {
    const txHex = fs.readFileSync(filePath, "utf8");
    const txObj = bsv.Tx.fromHex(txHex);
    return txObj;
  } else {
    console.error(`Transaction file ${txid}.hex not found.`);
    return null;
  }
}

function createTransactionObjects(txids) {
  const transactions = {};
  for (const txid of txids) {
    const txObj = readTransactionHex(txid);
    if (txObj) {
      transactions[txid] = txObj;
    }
  }
  return transactions;
}

function findHexStrings(txHex) {
  const txBuffer = Buffer.from(txHex, "hex");
  const utf8Tx = txBuffer.toString("utf-8");
  const hexStrings = [];
  const regex = /([0-9a-fA-F]{64})/g;
  let match;

  while ((match = regex.exec(utf8Tx)) !== null) {
    hexStrings.push(match[1]);
  }

  return hexStrings;
}

const outputPasswords = async () => {
  const transactionObjects = createTransactionObjects(pwTxids);

  // Print the transaction objects
  for (const txid in transactionObjects) {
    console.log("PW: " + findHexStrings(transactionObjects[txid].toHex()));
  }
};
const extractGpgFile = async (txid) => {
  const folderPath = path.join(__dirname, "wlTxs");
  const filePath = path.join(folderPath, `${txid}.hex`);
  // console.log({ filePath });
  if (fs.existsSync(filePath)) {
    const txHex = fs.readFileSync(filePath, "utf8");
    const txObj = bsv.Tx.fromHex(txHex);
    let bufferData = Buffer.from("");
    txObj.txOuts.map((txOut, idx) => {
      if (idx === 0) {
        console.log(txOut.script.toAsmString());
        txOut.script.chunks.map((c) => {
          if (c.buf) {
            console.log(c.buf.toString("hex"));
            bufferData = Buffer.concat([bufferData, c.buf]);
          }
        });
        // else skip opCode
      }
    });

    // Create the "gpgFiles" folder if it doesn't exist
    const gpgFolderPath = path.join(__dirname, "gpgFiles");
    if (!fs.existsSync(gpgFolderPath)) {
      fs.mkdirSync(gpgFolderPath);
    }

    // Save the bufferData to a file in the "gpgFiles" folder
    const gpgFilePath = path.join(gpgFolderPath, `${txid}.gpg`);
    fs.writeFileSync(gpgFilePath, bufferData.slice(8));

    console.log(`Saved GPG file: ${gpgFilePath}`);
  } else {
    console.error(`Transaction file ${txid}.hex not found.`);
    return null;
  }
};
gpgFilesTxids.map((txid) => {
  extractGpgFile(txid);
});
outputPasswords();
