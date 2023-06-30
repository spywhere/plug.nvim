# Requires Extension

This extension will allow you to specified plugin requirements for a plugin

**Note** that nested requirements are not yet supported

## Compatibility

- vim-plug: Polyfilled
- packer.nvim: Proxy to `requires`
- lazy.nvim: Proxy to `dependencies`

## Configurations

```lua
require('plug').extension.requires {}
```

## Usage

```lua
require('plug').setup {}

{
  'user/repo',
  -- a single plugin name will setup this required plugin without any options
  requires = 'another-user/another-repo',
  -- or it could be a table of...
  requires = {
    -- ...either a plugin name...
    'another-user/another-repo',
    -- ...or a plugin setup
    {
      'other-user/other-repo',
      options = {
        ['for'] = 'qf'
      }
    }
  },
}

''
```

```lua
require('plug').setup {}

{
  'user/repo',
  requires = {
    'another-user/another-repo',
    -- this plugin will setup with options below
    'other-user/other-repo'
  },
}

{
  -- setup with its own options
  'other-user/other-repo',
  -- do not install this plugin unless required by another plugin
  optional = true,
  options = {
    ['for'] = 'qf'
  }
}

''
```

## Event Handling

The extension will use the following events for its functionality

### `plugin`

Check if the plugin is optional, if so prevent the plugin from loading. If
required or not specified, it will load other required plugins if needed
