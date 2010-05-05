var defaultRefreshTimeout = 30;
var currentTimeout = null;

function scheduleRefresh() {
  var cookieValue = readCookie("refreshTimeout");
  var refreshTimeInSeconds = cookieValue ? parseInt(cookieValue) : defaultRefreshTimeout;
  clearTimeout(currentTimeout);
  if (cookieValue != "0") {
    currentTimeout = setTimeout("refresh();", refreshTimeInSeconds * 1000);
  }
}

function refresh() {
  var cimonitorUrl = "/cimonitor";
  if (document.location) {
    cimonitorUrl += document.location.search;// copy all the ?params and add them to the cimonitor URL
    window.frames[0].location = cimonitorUrl;
  }

  scheduleRefresh();
}

function setRefreshIntervalDropdown() {
  var cookieValue = readCookie("refreshTimeout");
  document.getElementById("refreshInterval").value = cookieValue ? cookieValue : defaultRefreshTimeout.toString();
}

function onChangeRefreshTimeoutDropdown() {
  createCookie("refreshTimeout", document.getElementById("refreshInterval").value, 365);
  window.parent.scheduleRefresh();
}

function createCookie(name,value,days) {
	if (days) {
		var date = new Date();
		date.setTime(date.getTime()+(days*24*60*60*1000));
		var expires = "; expires="+date.toGMTString();
	}
	else var expires = "";
	document.cookie = name+"="+value+expires+"; path=/";
}

function readCookie(name) {
	var nameEQ = name + "=";
	var ca = document.cookie.split(';');
	for(var i=0;i < ca.length;i++) {
		var c = ca[i];
		while (c.charAt(0)==' ') c = c.substring(1,c.length);
		if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
	}
	return null;
}

function eraseCookie(name) {
	createCookie(name,"",-1);
}

