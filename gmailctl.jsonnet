
// NOTE: This is a simple example.
// Please refer to https://github.com/mbrt/gmailctl#configuration for docs about
// the config format. Don't forget to change the configuration before to apply it
// to your own inbox!

// Import the standard library
local lib = import 'gmailctl.libsonnet';

// Some useful variables on top
// TODO: Put your email here
local me = 'adwinw01@gmail.com';
local toMe = { to: me };


// The actual configuration
{
  // Mandatory header
  version: 'v1alpha3',

  // TODO: Use your own rules here
  rules: [
    {
      filter: {
        and: [
          { from: 'notifications@github.com' },
          { list: 'rust.rust-lang.github.com' },
          { query: 'header:X-GitHub-Reason:"subscribed"' },
          { 
            not: 
              { query: 'header:X-GitHub-Labels:rollup' },
          },
          {
            or: [
              { query: 'header:X-GitHub-Labels:"T-types"' },
              { query: 'header:X-GitHub-Labels:"WG-trait-system-refactor"' },
              { query: 'header:X-GitHub-Labels:"-Zassumptions-on-binders"' },
            ],
          },
        ],
      },
      actions: {
        labels: ['Rust Types'],
      },
    },
    {
      filter: {
        and: [
          { from: 'notifications@github.com' },
          { list: 'rust.rust-lang.github.com' },
          {
            or: [
              { query: 'header:X-GitHub-Reason:"manual"' },
              { query: 'header:X-GitHub-Reason:"assign"' },
              { query: 'header:X-GitHub-Reason:"author"' },
              { query: 'header:X-GitHub-Reason:"comment"' },
              { query: 'header:X-GitHub-Reason:"mention"' },
              { query: 'header:X-GitHub-Reason:"review_requested"' },
              { query: 'header:X-GitHub-Reason:"team_mention"' },
            ],
          },
        ],
      },
      actions: {
        labels: ['GH Participation'],
      },
    },
  ],
}
