// Import the whatsonchain library
const WhatsOnChain = require('whatsonchain');
const bsv = require('bsv');
// Initialize the WhatsOnChain client for the Bitcoin mainnet
const woc = new WhatsOnChain('main');

// Function to fetch a transaction by its ID
async function fetchTransaction(txid) {
  try {
    // Fetch the transaction details
    const transaction = await woc.txHash(txid);
    console.log('Transaction details:', transaction);
    return transaction
  } catch (error) {
    console.error('Error fetching transaction:', error);
  }
}

// Replace with the transaction ID you want to fetch
const txid = '6c53cd987119ef797d5adccd76241247988a0a5ef783572a9972e7371c5fb0cc';
const extractPythonScript = async () =>{
    // Fetch the transaction
    const satoshiDownloaderTx = await fetchTransaction(txid);
    let bufferData = Buffer.from('')
    satoshiDownloaderTx.vout.map(vout=>{
        // console.log(vout.scriptPubKey)
        const script = bsv.Script.fromHex(vout.scriptPubKey.hex)
        // console.log({script})
        script.chunks.map(c=>{
            if(c.buf){
                console.log(c.buf)
                bufferData = Buffer.concat([bufferData, c.buf])
            }
            // else skip opCode
        })
    })
    console.log(bufferData.toString('utf8'))
}
extractPythonScript()
