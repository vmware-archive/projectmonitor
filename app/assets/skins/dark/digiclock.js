	dojo.ready(function() {
		var dimTime = 10 * 1000
			,dimTimeout
			,hasLocalStorage = ('localStorage' in window) && window['localStorage'] !== null
			,prefsKey = "digitalClock.prefs"
			,prefs = loadPrefs({ theme: "green" });
			;

		function loadPrefs(defaults) {
			var p;
			if(hasLocalStorage) p = window.localStorage.getItem(prefsKey);
			return p ? dojo.fromJson(p) : defaults;
		}

		function savePrefs(prefs) {
			if(hasLocalStorage)
				window.localStorage.setItem(prefsKey, dojo.toJson(prefs));
		}

		function updateTime() {
			dojo.query('.colon .element').toggleClass('on');
			dojo.query('.number').removeClass(["d0", "d1", "d2", "d3", "d4", "d5", "d6", "d7", "d8", "d9"]);
			var now = new Date()
				,h = now.getHours()
				,m = now.getMinutes()
				,s = now.getSeconds()
				,n = dojo.query('.number')
				,ap = (h > 11) ? ".pm" : ".am"
				;
			// Adjust h for display.  Only support 12 hour clock right now
			h = (h == 0) ? 12 : (h > 12) ? h % 12 : h;

			// Javascript Pittsburgh-ese .. n.at :)
			// Set all the digits
			if(h > 9) n.at(0).addClass("d1");
			n.at(1).addClass("d" + (h % 10)).end()
				.at(2).addClass("d" + Math.floor(m / 10)).end()
				.at(3).addClass("d" + (m % 10)).end()
				.at(4).addClass("d" + Math.floor(s / 10)).end()
				.at(5).addClass("d" + (s % 10));
			// Set am/pm
			dojo.query('.ampm .element').removeClass("on").filter(ap).addClass('on');
		}

		function brighten() {
			dojo.query(document.body).removeClass("dim");
			setupDim();
		}

		function dim() {
			dojo.query(document.body).addClass("dim");
		}

		function setupDim() {
			clearTimeout(dimTimeout);
			dimTimeout = setTimeout(dim, dimTime);
		}

		function setTheme(theme) {
			dojo.query(document.body).removeClass(["green", "blue", "red"]).addClass(theme);
			dojo.query('.controls .dot.on').removeClass('on');
			dojo.query('.controls .dot.' + theme).addClass('on');
			prefs.theme = theme;
			savePrefs(prefs);
		}

		setTheme(prefs.theme);

		updateTime();
		setInterval(updateTime, 1000);
		dojo.query('.controls .dot.green').onclick(function(e) { setTheme("green"); });
		dojo.query('.controls .dot.blue').onclick(function(e) { setTheme("blue"); });
		dojo.query('.controls .dot.red').onclick(function(e) { setTheme("red"); });

    if (dojo.query('.project .error').length > 0) {
      setTheme('red');
    } else {
      setTheme('green');      
    }
	});