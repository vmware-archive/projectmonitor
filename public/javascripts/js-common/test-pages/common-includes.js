Include.jsCommonPath = "./";

// JsUnit/prototype
Include.jsUnit("jsUnitCore");
//Include.thirdParty("prototype-1.6.0.2");
//Include.thirdParty("scriptaculous-1.8.0/effects");
//Include.thirdParty("yui-2.4.0/yahoo/yahoo");
//Include.thirdParty("yui-2.4.0/dragdrop/dragdrop");
//Include.thirdParty("yui-2.4.0/dom/dom");
//Include.thirdParty("aim");

// Utilities we have
// Prototype is required for some common tests (clock at least),
// but not currently checked into the common project
//Include.jsCommon("prototype");
Include.jsCommon("dombuilder");
Include.jsCommon("utils");
Include.jsCommon("string_utils");
Include.jsCommon("pivotal/pivotal");
Include.jsCommon("pivotal/placement");
Include.jsCommon("pivotal/popup");
Include.jsCommon("pivotal/roundy_corners");

// Test mocks
Include.commonTest("ajax");
Include.commonTest("assertions");
Include.commonTest("clock");
Include.commonTest("gmap");
Include.testPageFile("test_helper");
