# Priority Extension

This extension will allow you to configure a plugin loading priority

## Configurations

```lua
require('plug').extension.priority {
  -- plugin option name to used for prioritization
  --   set to empty string to not use it at all
  priority = 'priority',
  -- plugin option name to used for plugin sequencing
  --   set to empty string to not use it at all
  after = 'after'
}
```

**Tips:** Setting to an empty string might improve plugin processing
performance when it is not necessary

## Usage

### By specify priority number

```lua
require('plug').setup {}

{
  -- this plugin will load after 'another-user/another-repo'
  'user/repo',
  priority = 2
}

{
  -- this plugin will load before 'user/repo'
  'another-user/another-repo',
  priority = 1
}

{
  -- default priority is 0, so this plugin will load first
  'other-user/other-repo'
}

''
```

### By plugin sequence

```lua
require('plug').setup {}

{
  -- this plugin will load after 'another-user/another-repo'
  'user/repo',
  after = 'another-user/another-repo'
}

{
  'another-user/another-repo',
  -- a table of plugin names would work too
  after = {
    'other-user/other-repo',
    -- non-existing plugin has no effect
    'bad-user/bad-repo'
  }
}

{
  'other-user/other-repo'
}

''
```

## Caveats

- Prioritization will happens before plugin sequencing
- This extension only perform plugin prioritization for loading sequence. It
is not guarantee the loading requirements. In the following example, `plug2`
will guarantee to load after `plugin1` regardless if `plugin1` is loaded or
not

```lua
require('plug').setup {}

{
  'plugin2',
  after = 'plugin1'
}

{
  'plugin1'
}

''
```

## Event Handling

The extension will use the following events for its functionality

### `plugin_collected`

Perform a plugin prioritization to make sure it being loaded in order
