function randomInt(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

var dutchSentence = "";

function randomTime() {
    var hour = randomInt(1, 12);
    var minute = randomInt(0, 59);
    setTime(hour, minute);
    dutchSentence = "Het is " + dutchTimeSentence(hour, minute) + ".";
}

function showTime() {
    var div = document.getElementById("dutchanswer");
    div.innerHTML = dutchSentence;
    div.className = "shown";
}

function hideTime() {
    var div = document.getElementById("dutchanswer");
    div.innerHTML = "Hover to show dutch sentence."
    div.className = "hidden";
}

function num(number) {
    return {
        "1":  "een",
        "2":  "twee",
        "3":  "drie",
        "4":  "vier",
        "5":  "vijf",
        "6":  "zes",
        "7":  "zeven",
        "8":  "acht",
        "9":  "negen",
        "10": "tien",
        "11": "elf",
        "12": "twaalf",
        "13": "dertien",
        "14": "veertien"
    }["" + number];
}

function dutchTimeSentence(hour, minute) {
    if (minute == 0) {
        return num(hour) + " uur";
    } else if (minute < 15) {
        return num(minute) + " over " + num(hour);
    } else if (minute == 15) {
        return "kwart over " + num(hour);
    } 
    
    hour = (hour % 12) + 1;
    
    if (minute < 30) {
        return num(30 - minute) + " voor half " + num(hour);
    } else if (minute == 30) {
        return "half " + num(hour);
    } else if (minute < 45) {
        return num(minute - 30) + " over half " + num(hour);
    } else if (minute == 45) {
        return "kwart voor " + num(hour);
    } else {
        return num(60 - minute) + " voor " + num(hour);
    }
}

function setHand(name, minutes) {
    document.getElementById(name).setAttribute("transform", 
        "rotate(" + (minutes * 6) + ")");
}

function setTime(hour, minute) {
    setHand("minutehand", minute);
    setHand("hourhand", (hour + (minute / 60)) * 5);
}