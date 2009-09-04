/** Mock window centering **/
var WINDOW_CENTERED_ELEMENTS = [];
Utils.centerInWindow = function(element) {
	WINDOW_CENTERED_ELEMENTS.push(element);
};

function assertCenteredInWindow(element) {
	assertTrue("We should see a centering command for this element", 
	WINDOW_CENTERED_ELEMENTS.indexOf(element) >= 0);
};

function assertNotCenteredInWindow(element) {
	assertTrue("We should not see a centering command for this element", 
		WINDOW_CENTERED_ELEMENTS.indexOf(element) < 0);
};