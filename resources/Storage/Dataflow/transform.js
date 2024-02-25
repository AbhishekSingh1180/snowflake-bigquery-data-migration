function transform(line) {

    if (line.trim().toLowerCase().startsWith('index')) {
        return;
    }
    var values = line.split(',');
    var obj = {};
    obj.INDEX = values[0];
    obj.SYMBOL = values[1];
    obj.TIMESTAMP = values[2];
    obj.OPEN = parseFloat(values[3]);
    obj.CLOSE = parseFloat(values[4]);
    obj.HIGH = parseFloat(values[5]);
    obj.LOW = parseFloat(values[6]);
    obj.VOLUME = parseInt(values[7]);

    var jsonString = JSON.stringify(obj);
    return jsonString;
}