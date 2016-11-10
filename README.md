# Intro

Ansible play book to provision and deploy an app on AWS in one go.
Read more about the rationale behind the whole approach in the last section of
this document.

# Pre requisites

* ansible 2
* access to EC2, secret and key id
* ssh key pair either created or imported on AWS

# Setup

Using ansible-vault, edit the secrets.yml file,  and add your own aws secrets,
password is 'aws':

```
ansible-vault edit secrets.yml
```

Edit the vars.yml file and fill in your own details:

* vpc id
* region and zone
* instance type (micro is fine)
* key pair name
* leave the AMI id as it is

# Run it

WARNING: sometimes registering the instance in the ELB fails. This is because
the ELB hasn't run enough health checks against the instance. I lowered the
check interval and the number of required successful checks, but there is still
a small chance it will happen.

This is what I get for doing this in one single big go :|

One command to run it:

```
ansible-playbook deploy.yml --private-key=/path/to/your/ssh-priv.key
```

Enter the vault pass 'aws' and watch the provisioning and deployment happening.

# Test it

Load balancer frontend DNS name will be printed out as the last step of
the play. Just copy paste in a browser and visit the URL.

The app itself get a name via a POST request then adds it to Redis. There's a
feature to get the list of names as a JSON array.

| url | description |
| --- | --- |
| http://elb | will show a greeting |
| http://elb/_health | will report health, bad means Redis is down |
| http://elb/list | gives back the list |
| http://elb/add  | add a name |

To add a name, send a POST request with a payload similar to this:
```
{ name: "name" }
```

E.g.

```
curl -XPOST -H 'Content-type: application/json' -d '{ "name": "sebastian" }' http://elb/add
```

# Rationale and shortcomings

Since this is just a proof of concept designed to showcase a fully automated
provisioning and deployment plan it is nowhere near complete and several
shortcuts have been taken:

* security is _basic_
* no infrastructure tests
* no redundancy
* a stock AMI is being used
* docker containers are pulled from unsecure/unverified sources
