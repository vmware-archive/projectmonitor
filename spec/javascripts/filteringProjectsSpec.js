describe("projectFilters", function() {
  var html, $select, $firstTag, $lastTag;

  beforeEach(function() {
    html = "<select id='tag'><option></option><option>tag1</option><option>tag2</option></select>" +
      "<table class='projects'>" +
      "<tr data-tags='[\"tag1\"]'></tr>" +
      "<tr data-tags='[\"tag2\"]'></tr>" +
      '</table>';


    $("#jasmine_content").append(html);

    ProjectFilters.init();

    $select = $("#jasmine_content").find("select");
    $firstTag = $("#jasmine_content").find("tr").first();
    $lastTag = $("#jasmine_content").find("tr").last();
  });

  afterEach(function() {
    $("#jasmine_content").html("");
  });

  it("filters by tag", function() {
    $select.val("tag1").trigger("change");

    expect($firstTag).toBeVisible();
    expect($lastTag).not.toBeVisible();

    $select.val("tag2").trigger("change");

    expect($firstTag).not.toBeVisible();
    expect($lastTag).toBeVisible();
  });

  it("removes filters", function() {
    $select.val("tag1").trigger("change");
    $select.val("").trigger("change");

    expect($firstTag).toBeVisible();
    expect($lastTag).toBeVisible();
  });
});