const fs = require('fs')
const csv = require('csv')
const path = require('path')
const EOL = require('os').EOL

if (process.argv.length <= 2){
    console.error('Usage: ' + 'node ' + path.basename(__filename) + ' <full path to input csv file>')
    process.exit(-1 )
}

const fileIn = process.argv[2]

if (!fs.existsSync(fileIn)){
    console.error('File [%s] does not exist. Ensure the full path is entered.', fileIn)
    process.exit(-1 )
}

if (path.extname(fileIn) !== '.csv'){
    console.error('File [%s] is not the correct type. Ensure the file is csv.', fileIn)
    process.exit(-1 )
}

const fileOut = fileIn.replace(/\.csv$/, '-transformed.csv')

console.log('Source file [%s] being processed',  fileIn)

const readStream = fs.createReadStream(fileIn)
const writeStream = fs.createWriteStream(fileOut)
const parse = csv.parse();

const moment = require('moment-timezone')

const transform = csv.transform((row, cb) => {
    
    row[4] = row[4].replace('Warning no', 'No')
    row[5] = moment.tz(row[5], 'DD/MM/YYYY HH:mm:ss', 'Europe/London').toISOString()
    
    const messageRow =
    '"' + row[0] + '",' + // target_area_code
    '"' + row[4] + '",' + // severity
    '"' + row[3] + '",' + // severity_value
    '"' + row[6] + '",' + // situation
    '"' + row[5] + '",' + // situation_changed
    '"' + row[5] + '",' + // severity_changed
    '"' + row[5] + '",' + // message_received
    false + ',' +         // latest
    ',' +
    ',' + 'History Load' +
    EOL
    
    cb(null, messageRow);
});

readStream
.pipe(parse)
.pipe(transform)
.pipe(writeStream)
.on('finish', () => console.log('Transformed file [%s] created.', fileOut))
