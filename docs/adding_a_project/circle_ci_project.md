## CircleCI

__Webhooks__

1. Configure webhooks by creating a `circle.yml` file in your repository. This has the ability to configure your webhooks.

2. copy the following into your `circle.yml` replacing the url with the url you get from clicking the webhooks button below

~~~
notify:
webhooks:
- url: https://site.com/path/to/your/webhooks/url
~~~

__Polling__

1. Add your CircleCI username to the form below
2. Add your repo name to the field Build Name in the form below
2. Add an API token from your [account dashboard](https://circleci.com/account/api).
To test it, view it in your browser or call the API using curl:

~~~
$ curl https://circleci.com/api/v1/me?circle-token=:token
~~~

You should see a response like the following:

~~~
{
"user_key_fingerprint" : null,
"days_left_in_trial" : -238,
"plan" : "p16",
"trial_end" : "2011-12-28T22:02:15Z",
"basic_email_prefs" : "smart",
"admin" : true,
"login" : "pbiggar"
}
~~~

Finally, add the API token to the "Auth Token" field in the form below.

