var pdfFiller   = require('pdffiller')

// get argument list
args = process.argv;
var json = JSON.parse(args[2])
var source_path = args[3]
var destination_path = args[4]

pdfFiller.fillForm( source_path, destination_path, json, function(err) {
    if (err) {
      process.exit(1)
    }
    else {
      process.stdout.write(destination_path)
    }
});
