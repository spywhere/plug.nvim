# Design Principles

plug.nvim have a very simple idea of plugin framework: empowering the
existing plugin manager

- Unopinionated where possible  
Make no assumption and allow user choices
- No built-in plugin management  
Put the right (plug)man on the right job, no wheel reinvented
- Unified API while allow flexible preferences  
Setup once use it forever. Customized where needed
- Highly extensible for either niche or future-proof support  
Designed to accommodate specific needs and adapt to future changes

## How It Works

plug.nvim tap into the life cycle of _setting up_ plugins and leverage the
plugin manager backend to manage the plugins itself.

It kicks off by managing the plugin manager backend, allow any options to
passthrough into it.

Each individual plugin then goes for its configuration process, where various
extensions help unified the configuration for different needs from the
backend.

Also, through various extensions, plugins will also go for filtering and
sorting process.

Lastly, it expose a hook into plugin management life cycle where possible, so
each of the configurations can be setup accordingly.

To read more on technical details on how extension works, checkout
[extension authoring](/docs/extensions/api.md).
