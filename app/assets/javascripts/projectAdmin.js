$(function(){
  $('#project_type').live('change', function() {
    var travis_example_feed_url = "http://travis-ci.org/[account]/[project]/cc.xml";
    var field_url = $("#project_feed_url");

    if($(this).val() == 'TravisProject' && field_url.val() === '') {
      field_url.val(travis_example_feed_url);
    } else if($(this).val() != 'TravisProject' && field_url.val() === travis_example_feed_url) {
      field_url.val("");
    }
  });
});
