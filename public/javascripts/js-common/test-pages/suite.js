function commonTestSuite() {
  var newsuite = new top.jsUnitTestSuite();

  newsuite.addTestPage("../test-pages/clock_test.html");
  newsuite.addTestPage("../test-pages/dombuilder.html");
  newsuite.addTestPage("../test-pages/placement_test.html");
  newsuite.addTestPage("../test-pages/pivotal_popup_test.html");
  newsuite.addTestPage("../test-pages/utils_test.html");
  newsuite.addTestPage("../test-pages/cookie_test.html");
  newsuite.addTestPage("../test-pages/string_utils_test.html");
  newsuite.addTestPage("../test-pages/roundy_corners_test.html");
  newsuite.addTestPage("../test-pages/aim_test.html");

  return newsuite;
}
