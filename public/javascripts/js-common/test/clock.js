var Clock = {
	timeoutsMade: 0,
	scheduledFunctions: {},
	nowMillis: 0,
  reset: function() {
		this.scheduledFunctions = {};
		this.nowMillis = 0;
		this.timeoutsMade = 0;
	},
	tick: function(millis) {
    var oldMillis = this.nowMillis;
    var newMillis = oldMillis + millis;
		this.runFunctionsWithinRange(oldMillis, newMillis);
		this.nowMillis = newMillis;
	},
  now: function() {
    return this.nowMillis;
  },
	runFunctionsWithinRange: function(oldMillis, nowMillis) {
    var scheduledFunc;
		var funcsToRun = [];
		for (var timeoutKey in this.scheduledFunctions) {
			scheduledFunc = this.scheduledFunctions[timeoutKey];
			if (scheduledFunc != undefined &&
				scheduledFunc.runAtMillis >= oldMillis &&
			    scheduledFunc.runAtMillis <= nowMillis) {
			    	funcsToRun.push(scheduledFunc);
			    	this.scheduledFunctions[timeoutKey] = undefined;
			}
		}

		if (funcsToRun.length > 0) {
			funcsToRun.sort(function(a, b) {return a.runAtMillis - b.runAtMillis;});
			for (var i=0; i<funcsToRun.length; ++i) {
				try {
					this.nowMillis = funcsToRun[i].runAtMillis;
          funcsToRun[i].funcToCall();
					if (funcsToRun[i].recurring) {
						Clock.scheduleFunction(funcsToRun[i].timeoutKey,
							funcsToRun[i].funcToCall,
							funcsToRun[i].millis,
							true);
					}
				} catch(e) {}
			}
			this.runFunctionsWithinRange(oldMillis, nowMillis);
		}
	},
	scheduleFunction: function(timeoutKey, funcToCall, millis, recurring) {
		Clock.scheduledFunctions[timeoutKey] = {
			runAtMillis: Clock.nowMillis + millis,
			funcToCall: funcToCall,
			recurring: recurring,
			timeoutKey: timeoutKey,
			millis: millis
		};
	},

  run: function() {
    try {
      var funcsToRun = $H(this.scheduledFunctions).values();

      while ( funcsToRun.size() > 0 ) {

        funcsToRun.sort(function(a, b) {return a.runAtMillis - b.runAtMillis;});

        this.scheduledFunctions = {};

        this.nowMillis = funcsToRun[0].runAtMillis;
        if (funcsToRun[0].recurring) {
          Clock.scheduleFunction(funcsToRun[0].timeoutKey,
            funcsToRun[0].funcToCall,
            funcsToRun[0].millis,
            true);
        }
        funcsToRun[0].funcToCall();
        delete funcsToRun[0];

        funcsToRun = funcsToRun.concat( $H(this.scheduledFunctions).values() ).compact();

      }
    }  catch(e) {}
  }
};

function setTimeout(funcToCall, millis) {
	if (millis == 0) {
		funcToCall();
		return;
	}
	Clock.timeoutsMade = Clock.timeoutsMade + 1;
	Clock.scheduleFunction(Clock.timeoutsMade, funcToCall, millis, false);
	return Clock.timeoutsMade;
}

function setInterval(funcToCall, millis) {
	Clock.timeoutsMade = Clock.timeoutsMade + 1;
	Clock.scheduleFunction(Clock.timeoutsMade, funcToCall, millis, true);
	return Clock.timeoutsMade;
}

function clearTimeout(timeoutKey) {
	Clock.scheduledFunctions[timeoutKey] = undefined;
}

function clearInterval(timeoutKey) {
	Clock.scheduledFunctions[timeoutKey] = undefined;
}