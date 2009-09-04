function assertVisible(element) {
	assertTrue("Expected element " + element + " to be visible", Element.visible(element));
};

function assertNotVisible(element) {
	assertFalse("Expected element " + element + " to be not visible", Element.visible(element));
};

function assertRevealed(element) {
  assertTrue("Expected element " + element.id + " to be revealed", element.style.visibility == 'visible');
}
function assertConcealed(element) {
  assertTrue("Expected element " + element.id + " to be concealed", element.style.visibility == 'hidden');
}

function assertCentered(innerElementID, outerElementID) {
	var innerElement = $(innerElementID);
	var outerElement = $(outerElementID);
	
	var innerPosition = Position.cumulativeOffset(innerElement);
	var outerPosition = Position.cumulativeOffset(outerElement);
	
	var outerDimensions = Element.getDimensions(outerElement);
	var innerDimensions = Element.getDimensions(innerElement);
	
	assertRoughlyEquals(outerPosition[0] + (outerDimensions.width - innerDimensions.width)/2, innerPosition[0], 3);
	assertRoughlyEquals(outerPosition[1] + (outerDimensions.height - innerDimensions.height)/2, innerPosition[1], 3);
};

function assertArrayEquals(expectedArray, actualArray, msg) {
  if (msg == null) {msg = "";}
  if (_trueTypeOf(actualArray) != 'Array') {
    fail("" + actualArray + " is not an array");
  }
  var arrays = "Expected: " + expectedArray + "\n" +
               "Actual: " + actualArray + "\n";
  assertNotUndefined(msg + "\nTarget was null\n" + arrays, actualArray);
  assertEquals(msg + "\nExpected an array with length " + expectedArray.length + " but was " + actualArray.length + ": \n" + arrays,
          expectedArray.length, actualArray.length);
	for (var i=0; i<actualArray.length; ++i) {
		assertEquals(msg + "\nArrays differ at element " + i + "\n" + arrays, expectedArray[i], actualArray[i]);
	}
};

function assertHashEquals(expectedHash, actualHash) {
	for (var key in expectedHash) {
		assertNotUndefined("Expected hash had key " + key + " that was not found", 
			actualHash[key]);
		assertEquals("Value for key " + key + " mismatch - expected = " +
			expectedHash[key] + ", actual = " + actualHash[key], 
			expectedHash[key], actualHash[key]);
	}
	for (var key in actualHash) {
		assertNotUndefined("Actual hash had key " + key + " that was not expected", 
			expectedHash[key]);
	}
};

function assertHTMLEquals(expectedHTML, actualHTML) {
	assertEquals(standardizeHTML(expectedHTML), standardizeHTML(actualHTML));
}

function assertHTMLContains(expectedHTML, actualHTML) {
	assertContains(standardizeHTML(expectedHTML), standardizeHTML(actualHTML));
}

function assertStyleEquals(expectedStyleHash, actualElement) {
	// Not set up for IE positioning
	for (var key in expectedStyleHash) {
		if (key == 'extend') {
			// do nothing
		} else if ((key == 'top' || key == 'left' || key == 'width' || key == 'height') && Utils.isIE) {
			// skip
		} else {
			assertEquals("Style " + key + " mismatch", expectedStyleHash[key].toString(), actualElement.style[key].toString());
		}
	}
}

function standardizeHTML(html) {
	var translator = document.createElement("DIV");
	translator.innerHTML = html;
	return translator.innerHTML;
}

function assertRoughlyEquals(expected, actual, tolerance) {
	assertTrue("Expected " + expected + ", but got " + actual + " which was more than " + tolerance + " away",
		Math.abs(expected - actual) < tolerance);
};

function assertSrcEquals(expectedSrcValue, actualSrcValue) {
	assertTrue("Source " + actualSrcValue + " did not match " + expectedSrcValue,
		actualSrcValue.indexOf(expectedSrcValue) >= 0);
}

function assertFunctionEquals(expectedFunction, actualFunction) {
	assertEquals(expectedFunction.toString(), actualFunction.toString());
}

function assertContains(expected, container) {
  	assertTrue("Expected to find '" + expected + "' inside '" + container + "' but was not found",
  		container.indexOf(expected) != -1);
}

function assertDoesNotContain(expected, container) {
    assertTrue("Expected not to find '" + expected + "' inside '" + container + "' but it was found",
  		container.indexOf(expected) == -1);
}

function assertDateEquals() {
  _validateArguments(2, arguments);
  var expected = nonCommentArg(1, 2, arguments);
  var actual = nonCommentArg(2, 2, arguments);
  var msg = commentArg(2, arguments);

  assertEquals(msg + ": expected <" + expected + "> but was <" + actual + ">", expected.getTime(), actual.getTime());
}

function assertException(testFunction, expectedExceptionMessage) {
  try {
    testFunction();
    fail();
  } catch (e) {
    if (e.isJsUnitException) {
      throw e;
    }
    assertEquals(expectedExceptionMessage, e);
  }
}