# Puppeteer Headful with Commands

#### Forked from the fantastic [Puppeteer Headful](https://github.com/mujo-code/puppeteer-headful), started and maintained by [Jacob Lowe](https://github.com/jcblw).

[Github Action](https://github.com/features/actions) for [Puppeteer](https://github.com/GoogleChrome/puppeteer) that can be ran "headful" or not headless.

> Versioning of this container is based on the version of NodeJS in the container

## Purpose

This container is available to Github Action because there is some situations ( mostly testing [Chrome Extensions](https://pptr.dev/#?product=Puppeteer&version=v1.18.1&show=api-working-with-chrome-extensions) ) where you can not run Puppeteer in headless mode.

## Purpose of this fork

This fork features an action.yaml, uses bash, and allows you to pass complex shell commands including operators like the background process operator (&).

This is particularly useful when you need to first start a server and leave it running as a background process, so you can then issue commands that interact with the pages being served (see example below).

## Usage

This installs Puppeteer on top of a [NodeJS](https://nodejs.org) container so you have access to run [npm](https://www.npmjs.com) scripts and bash commands in general.

For this hook we hyjack the entrypoint of the [Dockerfile](https://docs.docker.com/engine/reference/builder/) so we can startup [Xvfb](https://www.x.org/releases/X11R7.6/doc/man/man1/Xvfb.1.xhtml) before your testing starts.

```yaml
name: CI
on: push
jobs:
  build-and-test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v2
      
      - name: Use Node.js
        uses: actions/setup-node@v2
        with:
          node-version: '15.x'
          cache: 'npm'
        env:
          PUPPETEER_SKIP_CHROMIUM_DOWNLOAD: 'true'
      
      - name: Install dependencies
        run: npm ci

      - name: Initialize headful puppeteer
        uses: maufrontier/puppeteer-headful@v3
        env:
          CI: 'true'
        with:
          commands: |
            npx http-server ./public &
            sleep 10
            npm run e2e-tests
```

> Note: You will need to let Puppeteer know not to download Chromium. By setting the env of your install task to PUPPETEER_SKIP_CHROMIUM_DOWNLOAD = 'true' so it does not install conflicting versions of Chromium.

Then you will need to change the way you launch Puppeteer. We export out a nifty ENV variable `PUPPETEER_EXEC_PATH` that you set at your `executablePath`. This should be undefined locally so it should function perfectly fine locally and on the action.

```javascript
browser = await puppeteer.launch({
  args: ['--no-sandbox'],
  executablePath: process.env.PUPPETEER_EXEC_PATH, // set by docker container
  headless: false,
  ...
});
```

## Warnings

For maximum freedom in running your shell commands, this action runs your commands via *eval*, which should be used with caution because any commands that are passed to the action will be executed in the context of the container.

To mitigate the risks, eval has been wrapped inside a subshell, but you should still proceed with caution and make sure you're the only one that passes commands to this action.

## License

Like the original [Puppeteer Headful](https://github.com/mujo-code/puppeteer-headful), this fork is licensed under the MIT License. Check LICENSE.md for more information.