# Debuggable JavaScript in Phoenix via Snowpack

By default, Phoenix integrates webpack into new projects when `mix phx.new` is invoked. That is great for deploying small bundles in production, however it can get in the way of debugging the JavaScript code in your project since webpack rewrites it in a way that is hard to read.

Luckily there is an alternative to webpack called [Snowpack](https://www.snowpack.dev/) that makes debugging easy. Snowpack makes minor enough changes to the source files that they are about as readable as the original source files.

In this tutorial, I'll show how to start a Phoenix project using Snowpack so you can start enjoying its advantages.

Prerequisites:
* Elixir is installed so you have the mix command
* npm is installed
* npx is installed

To begin, create a project in the usual way with `mix phx.new`. In this case I'm leaving out Ecto for simplicity, but in a real project you'd probably include it.

```sh
mix phx.new phx_snowpack_demo --no-ecto
cd phx_snowpack_demo
cd assets && npm install --legacy-peer-deps && cd ..
mix deps.get
# mix ecto.setup # skipping this for the demo
mix phx.server
```
Check that it's working by visiting http://localhost:4000.

That was done with webpack, the default bundler used by Phoenix when this tutorial was written. Open up one of the files it generated and you can see how much harder it makes debugging with breakpoints etc. For example:

```sh
$EDITOR priv/static/js/app.js
```

Next let's bring in Snowpack to fix that:
```sh
cd assets
npm install --save-dev snowpack
npx snowpack init
```

## Development setup

In `assets/snowpack.config.js`, update the `buildOptions` section like this:
```js
  buildOptions: {
    out: "../priv/static",
    watch: true,
  },
```
Here are [the docs](https://www.snowpack.dev/reference/configuration#buildoptions.watch) if you're curious about the reason for the `watch` field.

Also add this to the plugins section to support SCSS:
```js
  plugins: [
    "@snowpack/plugin-sass",
  ],
```
and run
```sh
npm install --save-dev @snowpack/plugin-sass
```

Images have to be copied over as well, so we'll need this in `snowpack.config.js`:
```js
  mount: {
    "static/images": {url: "/images", static: true, resolve: false},
    "js": {url: "/js"},
    "css": {url: "/css"},
  },
```

Now `cd ..` and in `config/dev.exs` edit the watchers bit of the config section to be like this:
```elixir
  watchers: [
    node: [
      "node_modules/snowpack/index.bin.js",
      "build",
      cd: Path.expand("../assets", __DIR__)
    ]
  ]
```

In `lib/snowdemo_web/templates/layout/app.html.eex`, change the `type` attribute of the `script` tag to `module` like this:
```html
<script defer type="module" src="<%= Routes.static_path(@conn, "/js/app.js") %>"></script>
```
That way import statements can work as Snowpack expects them to.

We'll also need to add `_snowpack` to the `only:` field in `lib/phx_snowpack_demo_web/endpoint.ex`:
```elixir
    only: ~w(_snowpack css fonts images js favicon.ico robots.txt)
```

Finally, remove this unneeded webpack-supporting line and associated comments from `assets/js/app.js`:
```javascript
import "../css/app.scss"
```

Now if you run `mix phx.server` and visit http://localhost:4000, the page should load normally with no console errors.

Have a look at `priv/static/js/app.js` now. It's straightforward and readable, thanks to Snowpack.

## Debugging

Next let's try using the browser's debugging tools in the new setup.
In Brave or Chrome, right click somewhere on the page and click Inspect Element to bring up the development panel.
In the Sources tab, open up `localhost:4000 | _snowpack/pkg | phoenix_html.js`. Set a breakpoint in this callback:
```javascript
  window.addEventListener("click", function(e) {
    var element = e.target;

    while (element && element.getAttribute) {
```
Then click somewhere in the page. Execution should pause in the readable JavaScript where you set the breakpoint.

## Adding a package with npm

Let's try adding some confetti with an npm package.
```sh
npm install canvas-confetti --prefix=./assets
```
In `app.js` add this:
```javascript
import confetti from 'canvas-confetti';
confetti.create(document.getElementById('canvas'), {
  resize: true,
  useWorker: true,
 })({ particleCount: 200, spread: 200 });
```
When you reload the page, there should be a burst of confetti.

## Production with Snowpack

First, in `package.json` update the `scripts` section to be like this:
```js
  "scripts": {
    "deploy": "snowpack build --no-watch",
  },
```

From here you can proceed according to https://hexdocs.pm/phoenix/deployment.html.

## Production with webpack

If you find that Snowpack is not meeting your needs in production, you can still use webpack for deployment. To do that, change the `deploy` script in `package.json` back to this:

```js
  "scripts": {
    "deploy": "webpack --mode production"
  },
```

Then you can deploy as described in https://hexdocs.pm/phoenix/deployment.html. Now you've got the best of Snowpack for development debugging and webpack for minified builds in production!

