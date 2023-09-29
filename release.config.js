/**
  * @type {import('semantic-release').GlobalConfig}
  */
module.exports = {
  branches: ['main'],
  plugins: [
    [
      '@semantic-release/commit-analyzer',
      {
        preset: 'conventionalcommits'
      }
    ],
    [
      '@semantic-release/release-notes-generator',
      {
        preset: 'conventionalcommits'
      }
    ],
    '@semantic-release/changelog',
    [
      '@semantic-release/git',
      {
        assets: ['CHANGELOG.md', 'plug.lua']
      }
    ]
  ]
}
