describe("projectFilters", function() {
  var html, $tagSelect, $pollingStatusSelect, $firstProject, $lastProject;

  beforeEach(function() {
    html = "<select id='tag'><option></option><option>tag1</option><option>tag2</option></select>" +
      "<select id='polling_status'><option></option><option>success</option><option>failure</option></select>" +
      "<table class='projects'>" +
      "<tr data-tags='[\"tag1\"]' data-polling-status='success'></tr>" +
      "<tr data-tags='[\"tag2\"]' data-polling-status='failure'></tr>" +
      '</table>';


    $("#jasmine_content").append(html);

    ProjectFilters.init();

    $tagSelect = $("#jasmine_content").find("select#tag");
    $pollingStatusSelect = $("#jasmine_content").find("select#polling_status");
    $firstProject = $("#jasmine_content").find("tr").first();
    $lastProject = $("#jasmine_content").find("tr").last();
  });

  afterEach(function() {
    $("#jasmine_content").html("");
  });

  it("filters by tag", function() {
    $tagSelect.val("tag1").trigger("change");

    expect($firstProject.css("display")).not.toEqual("none");
    expect($lastProject.css("display")).toEqual("none");

    $tagSelect.val("tag2").trigger("change");

    expect($firstProject.css("display")).toEqual("none");
    expect($lastProject.css("display")).not.toEqual("none");
  });

  it("filters by polling status", function() {
    $pollingStatusSelect.val("success").trigger("change");

    expect($firstProject.css("display")).not.toEqual("none");
    expect($lastProject.css("display")).toEqual("none");

    $pollingStatusSelect.val("failure").trigger("change");

    expect($firstProject.css("display")).toEqual("none");
    expect($lastProject.css("display")).not.toEqual("none");
  });

  it("removes filters", function() {
    $tagSelect.val("tag1").trigger("change");
    $tagSelect.val("").trigger("change");

    expect($firstProject.css("display")).not.toEqual("none");
    expect($lastProject.css("display")).not.toEqual("none");
  });
});