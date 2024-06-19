const fs = require('fs');
const path = require('path');
const WhatsOnChain = require('whatsonchain');
const bsv = require('bsv');

const woc = new WhatsOnChain('main');

async function fetchTransaction(txid) {
  try {
    const transaction = await woc.getRawTxData(txid);
    return transaction;
  } catch (error) {
    console.error('Error fetching transaction:', error);
  }
}

async function saveTransactionHex(txid, index) {
  const transaction = await fetchTransaction(txid);
  const txObj = bsv.Tx.fromHex(transaction);
  const txHex = txObj.toString();

  const folderPath = path.join(__dirname, 'wlTxs');
  if (!fs.existsSync(folderPath)) {
    fs.mkdirSync(folderPath);
  }

  const filePath = path.join(folderPath, `${txid}.hex`);
  fs.writeFileSync(filePath, txHex);

  console.log(`Transaction ${txid} saved as ${txid}.hex`);
}

async function processTransactions(txids) {
  for (let i = 0; i < txids.length; i++) {
    await saveTransactionHex(txids[i], i + 1);
  }
}

const wikileaksTxs = [
    '691dd277dc0e90a462a3d652a1171686de49cf19067cd33c7df0392833fb986a',
    '6c53cd987119ef797d5adccd76241247988a0a5ef783572a9972e7371c5fb0cc',
    '1c83034ca7c5b9dfe9207c0cbec3d657adb4b6631dcb21a0a78c083ff70b9396',
    '25787352904f4871fee31a76a48df0d77cac67207a182586ea632d4da9ec7fd3',
    'bfb4e91ccc4f0996c76130a8408996f43d2c931a383ec36d3cab1ba1c0974008',
    '757942f87e2eb44ec1d825135dc18e44846cbe0b41068f2cfa9b3ce96c81b404',
    '5af6c330e0119f46bce7e201c98e99c54e56b5dbf297307d019708fd4a633060',
    '8a75514829b6e30b9fea434eef77b1589ff3f4bdfc0056bd087efbfb8314eb59',
    '18a7f0540b5ef6bb8707ad1f24ea93067023fa249791dc3697c10f46299bdd6d',
    'aa353913b68ed3448cbd83ec942067eb4862b34bf88a1cc5d4ccbb10354f94a4',
    '7379ab5047b143c0b6cfe5d8d79ad240b4b4f8cced55aa26f86d1d3d370c0d4c',
    'cce82f3bde0537f82a55f3b8458cb50d632977f85c81dad3e1983a3348638f5c',
    '8f3b90d8de36b424a0afd51dee41d439b364079967ebf161302aa7b5a9094711',
    'ee7881862ceb30d9f957bc6edcae96e27099b126e275ff040672a76c8a6ee1b9',
    'ce81de6360502c6bc603fb77806b07eb52b796914a805196fe83f15cf7b8ff06',
    '57065d22d9d6b26fe05d58d627fb1472baf6d2e3b494f13e7e781252a3c94e8d',
    'd3c1cb2cdbf07c25e3c5f513de5ee36081a7c590e621f1f1eab62e8d4b50b635',
    '4b0cd7e191ef0a14a9b6ab1c5900be534118c20a332ff26407648168d2722a2e'
  ];

processTransactions(wikileaksTxs);