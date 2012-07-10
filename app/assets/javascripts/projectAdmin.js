$(function(){
  $('#project_type').live('change', function() {
    var field_url = $("#project_feed_url");
    if($(this).val() == 'TravisProject' && field_url.val() === '') {
      field_url.val('http://travis-ci.org/[account]/[project]/cc.xml');
    }
  });
});
