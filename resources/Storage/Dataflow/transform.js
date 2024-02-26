function transform(line) {

    if (line.trim().toLowerCase().startsWith('CLOSE')) {
        return;
    }
    var values = line.split(',');
    var obj = {};
    obj.CLOSE = parseFloat(values[0]);
    obj.HIGH = parseFloat(values[1]);
    obj.INDEX = values[2];
    obj.LOW = parseFloat(values[3]);
    obj.OPEN = parseFloat(values[4]);
    obj.SYMBOL = values[5];
    obj.TIMESTAMP = values[6];
    obj.VOLUME = parseInt(values[7]);

    var jsonString = JSON.stringify(obj);
    return jsonString;
}