//convenience functions for including groups of js files (dependency trees, etc)

var Include = {
  javascriptPath: "../",
  jsCommonPath: "js-common/",
  cacheBuster: parseInt(new Date().getTime()/(1*1000)),

  projectFile: function(fileName) {
    Include._include(fileName);
  },

  jsCommon: function(fileName) {
    Include._include(this.jsCommonPath + fileName);
  },

  jsUnit: function(fileName) {
    Include._include("jsunit/jsunit/" + fileName);
  },

  commonTest: function(fileName) {
    Include._include(this.jsCommonPath + "test/" + fileName);
  },

  testPageFile: function(fileName) {
    Include._include("test-pages/" + fileName);
  },

  jsUnitCore: function() {
    Include.jsUnit("app/jsUnitCore");
  },

  _include: function(relativePath, javascriptPath) {
    javascriptPath = javascriptPath || this.javascriptPath;
    document.write("<script src='" + javascriptPath + relativePath + ".js" +
                   (Include.cacheBuster ? ("?" + Include.cacheBuster) : "") +
                   "' type='text/javascript'></script>");
  }
}
