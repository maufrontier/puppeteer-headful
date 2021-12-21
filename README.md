# Puppeteer Headful with Commands

This Github Action allows you to run [Puppeteer](https://github.com/GoogleChrome/puppeteer) in headful mode (not headless)—which is crucial for testing [Chrome Extensions](https://pptr.dev/#?product=Puppeteer&version=v1.18.1&show=api-working-with-chrome-extensions)—and to pass in shell commands to be executed.

*Forked from the fantastic [Puppeteer Headful](https://github.com/mujo-code/puppeteer-headful), started and maintained by [Jacob Lowe](https://github.com/jcblw).*

## Purpose of this fork

This fork features an action.yaml, uses bash, and allows you to pass more complex shell commands including operators like the background process operator (&).

This is particularly useful when you need to first start a server and leave it running as a background process so you can then issue commands that interact with the pages being served (see example below).

## Usage

This installs Puppeteer on top of a [NodeJS](https://nodejs.org) container so you have access to run [npm](https://www.npmjs.com) scripts and bash commands in general.

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

      - name: Perform e2e tests with Heaful Puppeteer
        uses: maufrontier/puppeteer-headful@v3
        env:
          CI: 'true'
        with:
          commands: |
            npx http-server ./public &
            sleep 10
            npm run e2e-tests
```

## Setup

#### Step 1 - Launch node, skipping Chromium Download

Notice the PUPPETEER_SKIP_CHROMIUM_DOWNLOAD = 'true' line. This prevents Puppeteer from downloading conflicting Chromium binaries.

```yaml
- name: Use Node.js
  uses: actions/setup-node@v2
  with:
    node-version: '15.x'
    cache: 'npm'
  env:
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD: 'true'
```

#### Step 2 - Call the action (with an optional command)

```yaml
- name: Perform e2e tests with Heaful Puppeteer
  uses: maufrontier/puppeteer-headful@v3
  env:
    CI: 'true'
  with:
    commands: |
      npx http-server ./public &
      sleep 10
      npm run e2e-tests
```

#### Step 3 - Launch Puppeteer with the right exec path

##### Option A) Easiest method

Use the [puppeteer-test-browser-extension](https://www.npmjs.com/package/puppeteer-test-browser-extension) module to launch Puppeteer with all the right settings to test Chrome extensions with this Action.

##### Option B) Manual method

If you'd like to launch Puppeteer manually, make sure you pass the ENV variable  `PUPPETEER_EXEC_PATH` as the value for the `executablePath` option.

This will ensure that Puppeteer uses the right binary when using this Github Action, and in your local environment the variable should be undefined, so it'll be ignored.

```javascript
browser = await puppeteer.launch({
  executablePath: process.env.PUPPETEER_EXEC_PATH, // set by docker container
  headless: false,
  args: [
    `--load-extension=${pathToYourExtension}`,
    `--disable-extensions-except=${pathToYourExtension}`,
    '--no-sandbox',
  ],
  ...
});
```

## Considerations

For maximum freedom in running your shell commands, this action runs your commands via *eval*, which should be used with caution because any commands that are passed to the action will be executed in the context of the container.

To mitigate the risks, eval has been wrapped inside a subshell, but you should still proceed with caution and make sure you're the only one that passes commands to this action.

## Versioning

Starting with version 3.0.0, you can use a specific version of the action by referencing the exact semver number:

    - name: Perform e2e tests with Heaful Puppeteer
      uses: maufrontier/puppeteer-headful@3.0.0

Each major version after v3 also has its own branch, so if you want to use the latest minor version within a major version, you can reference the branch:

    - name: Perform e2e tests with Heaful Puppeteer
      uses: maufrontier/puppeteer-headful@v3

## Website:

- **Github**: [puppeteer-test-browser-extension](https://github.com/maufrontier/puppeteer-headful-with-commands) by [MauFrontier](https://github.com/maufrontier)
- **GitHub Actions Marketplace**: [puppeteer-test-browser-extension](https://github.com/marketplace/actions/puppeteer-headful-with-commands)
- **Inspiration**: [Puppeteer Headful](https://github.com/mujo-code/puppeteer-headful), started and maintained by [Jacob Lowe](https://github.com/jcblw)

## Recommended pairing:

- **NPM Module**: [puppeteer-test-browser-extension](https://www.npmjs.com/package/puppeteer-test-browser-extension) — Launch Puppeteer with all the right settings to test Chrome extensions with this Action.

## License

Like the original [Puppeteer Headful](https://github.com/mujo-code/puppeteer-headful), this fork is licensed under the MIT License. Check LICENSE.md for more information.