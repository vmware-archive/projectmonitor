## Semaphore

To configure Semaphore, you must create the Semaphore API URL.

The format of this URL is 

~~~
semaphoreci.com/api/v1/projects/<Project hash_id>/<branch id>?auth_token=<auth_token>
~~~

You can get the Project hash_id and auth_token from your project's settings api page. You can get there from the Semaphore main page by 

1. Clicking the setting button for your project
2. Clicking the API button on the settings screen

In order to get your branch id, you must get it from an api call to Semaphore. One way to do this is enter the following url into your browser window

~~~
semaphoreci.com/api/v1/projects/<Project hash_id>/branches
~~~

where the project hash_id is the same as the one from your API page. Get the ID from the returned json file for the branch you are interested in tracking and insert it in the original URL from the top of these instructions.

Example result

~~~
[{"id":383597,"name":"master","branch_url":"path/to/project/branch"}]
~~~

Finally, enter the finished API URL in the form below