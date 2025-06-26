# hosting on fly.io

the purpose of this repository is to host a simple FastAPI website on fly.io:  
everytime a change is pushed to the `main` branch, and provided the tests pass,
the new app is automatically deployed to `fly.io`

## prerequisites

you need to go to fly.io` and create an account  
there is a free plan for the first 7 days so you can try it out without
  paying anything

also you need to have your app ready to be deployed, and pushed in a github repository

from these two pieces you will be able to deploy your app on `fly.io` using their web UI  
it takes a few minutes to get it up and running, and you will have a URL
  where your app is hosted, you can play with it

at that point you need to go to [the Access Tokens page on your fly.io
dashboard](`https://fly.io/tokens/create`) and create an API token  
this token will be attached to the app you just created above (at least that was my experience)

in the next step we'll see how to automate the deployment of your app
  using this token, so that every push causes an automatic deployment

## github workflow

each time you push a change to the `main` branch, the following happens:

1. github triggers all the actions defined in `.github/workflows/  
   so in our case it will trigger the `fly.yml` workflow
2. whose job is to install and call the Fly.io CLI to deploy the app

this is on purpose as simple as it gets  
in real life you would probably want to run some tests before deploying, but for
now we want to get the gist of it

## github secrets

when calling the Fly.io CLI, you need to authenticate yourself  
and this is done through an API token - that we have obtained separately at fly.io
now, remember the deploy command will actually be invoked **from the github infrastructure** - and not your laptop !)  
so we need a means to expose this secret information to github, without putting it in the code repository of course, since that is totally public

that's the purpose of the `secrets` feature of github:  
in the repository settings, you go to the *Secrets and Variables* tab and you can define a secret by name, we've called it `FLY_API_TOKEN` in this repo.

## the pieces

now, what do you need to get all this to work ?

### the Python code

of course you need a FastAPI app - here we just have a very simple one in `main.py`  
obviously yours will be more complex and possibly scattered across several
  folders and files, that's not the point here

### a github action workflow

this is in `.github/workflows/fly.yml`  
it will be triggered on every push to the `main` branch

so this is the main piece of the puzzle:  
our single action `fly.yml` does primarily 3 things

- fetch the code from the repository
- install the Fly.io CLI
- call the Fly.io CLI to deploy the app

this last part in turn uses `Dockerfile` under the hood to build the app runtime

### a `Dockerfile`

to build the image of your app; basically, it:

- builds on top of another image (published by someone else) with Python inside
- and uses `pip` to install your app and its dependencies  
  for that it uses in turn a file named `pyproject.toml` that declares the dependencies of your app

> [!NOTE]
> **more on this**  
> here we build on top of the `python` image and more precisely its `3.13.5-slim` tag  
> to see how this image is done you need to dig a bit in dockerhub (https://hub.docker.com/_/python/tags)  
> and [you will end up here](https://hub.docker.com/layers/library/python/3.13.5-slim/images/sha256-8bc85201ccb77449e1c0ec24b5caeaf343a3842da11c3a6921afc5c196170791)  
> which shows you that it's based on `debian`

### a `pyproject.toml` file

to declare your dependencies (among other things)

> [!NOTE]
> **there are alternatives**  
> advanced students could take a look at `uv` to manage their dependencies (and more), which is becoming more and more popular these days in the Python community

below we just want to discuss a few more details,
but for now that's it, you have a simple FastAPI app hosted on fly.io !

### `fly.toml`

Finally, you will also need a `fly.toml` file, which is the configuration file for Fly.io
it contains the configuration of your app, such as the name, the region where it will be

### how to check

navigate to your project's github page, and then to the `Actions` tab  
for each pushed commit you will see a workflow run, and you can click on it to see the details of the run  
when successful, `flyctl` will display the URL, typically in the `.fly.dev` domain, where your app is hosted

so e.g. for this app I have named it `backend-fastapi-flyio` so it is available at https://backend-fastapi-flyio.fly.dev

## further steps

### TLS certificates

Assuming you own another domain name like `mydomain.com`, you're going to want to bind, say,
`tutu.mydomain.com` to your app, so that it is available at `https://tutu.mydomain.com`

to do that you need 2 steps:

1. in your domain dashboard, wherever that is, you need to create a CNAME record
   that points `tutu.mydomain.com` to `tutu.fly.dev`
2. but that would not be enough, as `fly.io` is aware of `tutu.fly.dev` and they can generate a TLS certificate for that domain, but you also need a certificate for `tutu.mydomain.com` to be created as well. To that end you need to run the following command; look for details on the web:

   ```bash
   flyctl certs add tutu.mydomain.com
   ```

### tests

For simplicity we don't have any tests here yet  
but of course you will want to define a minimal amount of tests !  
first because, well, you need to test  
and second, in the context of a continuous deployment like this, you want to avoid deploying a broken version !

for an example of how to add tests in the picture, see the repo mentioned below

## see also

a real-size example of a FastAPI app hosted on fly.io is available here - thanks Aurélien !

https://github.com/ue22-p24/backend-fastapi-pixel-wars/

It implements a backend that serves a pixel wars game, complete with a database and
everything; we use it during the course on frontend development; it is permanently available at
https://pixel-wars.fly.dev/
