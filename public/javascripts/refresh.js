var defaultRefreshTimeout = 60;
var currentTimeout = null;

function scheduleRefresh() {
    var cookieValue = readCookie("refreshTimeout");
    var refreshTimeInSeconds = cookieValue ? parseInt(cookieValue) : defaultRefreshTimeout;
    clearTimeout(currentTimeout);
    if (parseInt(cookieValue) != "0") {
        currentTimeout = setTimeout("refresh();", refreshTimeInSeconds * 1000);
    }
}

function refresh() {
    var ProjectDivs = jQuery(".projects div.project:not(.aggregate) div.box");
    for (var i = 0; i < ProjectDivs.length; i++) {
        var currentDiv = ProjectDivs[i];
        var id = jQuery(currentDiv).attr("project_id");
        if (id) {
            jQuery.get('projects/'+id+'/load_project_with_status', function reloadDiv(divContents) {
                var new_project_id = this.url.split('/')[1];
                if (divContents.length > 0) {
                    jQuery('.projects div.project:not(.aggregate) div.box[project_id='+new_project_id+']').replaceWith(divContents);
                }
            });
        } else {
            id = jQuery(currentDiv).attr("message_id");
            if (id) {
                jQuery.get("messages/"+id+"/load_message", function reloadDiv(divContents) {
                    var new_message_id = this.url.split('/')[1];
                    if (divContents.length > 0) {
                        jQuery('.projects div.box[message_id='+new_message_id+']').replaceWith(divContents);
                    } else {
                        jQuery('.projects div.box[message_id='+new_message_id+']').remove();
                    }

                });
            }
        }
    }
    var aggregateDivs = jQuery(".projects div.project.aggregate div.box");
    for (var i = 0; i < aggregateDivs.length; i++) {
        var currentDiv = aggregateDivs[i];
        var id = jQuery(currentDiv).attr("project_id");
        if (id) {
            jQuery.get('aggregate_projects/'+id+'/load_aggregate_project_with_status', function reloadDiv(divContents) {
                var new_project_id = this.url.split('/')[1];
                if (divContents.length > 0) {
                    jQuery('.projects div.project.aggregate div.box[project_id='+new_project_id+']').replaceWith(divContents);
                }
            });
        }
    }
    var twitterFeeds = jQuery(".projects div.project.message div.tweets");
    for (var j = 0; j < twitterFeeds.length; j++) {
        var currentDiv = twitterFeeds[j];
        console.log(jQuery(currentDiv).attr('tweet_id'));
        if (id) {
            jQuery.get('twitter_searches/'+id+'/load_tweet', function reloadDiv(divContents) {
                    var tweet_id = jQuery(divContents).attr('project_id');
                    jQuery('.projects div.project.message div.tweets[tweet_id='+tweet_id+']').replaceWith(divContents);
                }
            );
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


