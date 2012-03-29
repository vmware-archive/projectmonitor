var defaultRefreshTimeout = 1;
var currentTimeout = null;

function scheduleRefresh() {
  clearTimeout(currentTimeout);
  currentTimeout = setTimeout("refresh();", defaultRefreshTimeout);
}

function refresh() {
  var ProjectDivs = $(".projects div.project:not(.aggregate) div.box");
  for (var i = 0; i < ProjectDivs.length; i++) {
    var currentDiv = ProjectDivs[i];
    var id = $(currentDiv).attr("project_id");
    if (id) {
      $.ajax({
        url: '/projects/'+id+'/load_project_with_status',
        method: 'GET',
        success: function reloadDiv(divContents) {
          var new_project_id = this.url.split('/')[2];
          if (divContents.length > 0) {
            $('.projects div.project:not(.aggregate) div.box[project_id='+new_project_id+']').replaceWith(divContents);
          }
        },
        error: (function(currentDiv) {
          return function errorState(xhr) {
            var new_id = $(currentDiv).attr("project_id");
            $(".projects div.project:not(.aggregate) div.box[project_id="+ new_id +"] div.project_status").addClass('offline');
            $(".projects div.project:not(.aggregate) div.box[project_id="+ new_id +"]").addClass('bluebox');
            $(".projects div.project:not(.aggregate) div.box[project_id="+ new_id +"] div.project_status").removeClass('building');
          }
        })(currentDiv)
      });
    } else {
      id = $(currentDiv).attr("message_id");
      if (id) {
        $.ajax({
          url:"/messages/"+id+"/load_message",
          method: 'GET',
          success: function reloadDiv(divContents) {
            var new_message_id = this.url.split('/')[2];
            if (divContents.length > 0) {
              $('.projects div.box[message_id='+new_message_id+']').replaceWith(divContents);
            } else {
              $('.projects div.box[message_id='+new_message_id+']').remove();
            }
          },
          error: (function(currentDiv) {
            return function errorState(xhr) {
              var new_id = $(currentDiv).attr("message_id");
              $(".projects div.message div.box[message_id="+ new_id +"]").addClass('offline');
            }
          })(currentDiv)
        });
      }
    }
  }
  var aggregateDivs = $(".projects div.project.aggregate div.box");
  for (var i = 0; i < aggregateDivs.length; i++) {
    var currentDiv = aggregateDivs[i];
    var id = $(currentDiv).attr("project_id");
    if (id) {
      $.ajax({
        url: '/aggregate_projects/'+id+'/load_aggregate_project_with_status',
        method: 'GET',
        success: function reloadDiv(divContents) {
          var new_project_id = this.url.split('/')[2];
          if (divContents.length > 0) {
            $('.projects div.project.aggregate div.box[project_id='+new_project_id+']').replaceWith(divContents);
          }
        },
        error: (function(currentDiv) {
          return function errorState(xhr) {
            var new_id = $(currentDiv).attr("project_id");
            $(".projects div.project.aggregate div.box[project_id="+ new_id +"] div.project_status").addClass('offline');
            $(".projects div.project.aggregate div.box[project_id="+ new_id +"]").addClass('bluebox-aggregate');
            $(".projects div.project.aggregate div.box[project_id="+ new_id +"] div.project_status").removeClass('building');
          }
        })(currentDiv)
      });
    }
  }
  var twitterFeeds = $(".projects div.project.message div.tweets");
  for (var j = 0; j < twitterFeeds.length; j++) {
    var currentDiv = twitterFeeds[j];
    var id = $(currentDiv).attr("tweet_id");

    if (id) {
      $.ajax({
        url: '/twitter_searches/'+id+'/load_tweet',
        method: 'GET',
        success: function reloadDiv(divContents) {
          var tweet_id = $(divContents).attr('tweet_id');
          var foundExistingTwitterBox = $('.projects div.project.message div.tweets[tweet_id='+tweet_id+']')
        foundExistingTwitterBox.replaceWith($(divContents));
        },
        error: (function(currentDiv) {
          return function errorState(xhr) {
            var new_id = $(currentDiv).attr("tweet_id");
            $(".projects div.project.message div.tweets[tweet_id="+ new_id +"]").addClass('offline');
          }
        })(currentDiv)
      });
    }
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

$(function(){
  scheduleRefresh();
});
