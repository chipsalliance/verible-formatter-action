Verible Formatter Action
========================

Usage
-----

See [action.yml](action.yml)

This is a GitHub Action used to format Verilog and SystemVerilog source files
and create change suggestions in Pull Requests automatically.
The GitHub Token input is used to provide
[reviewdog](https://github.com/reviewdog/reviewdog)
access to the PR.

Here's a basic example to format all ``*.v`` and ``*.sv`` files:

```yaml
name: Verible formatter example
on:
  pull_request:
jobs:
  format:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - uses: chipsalliance/verible-formatter-action@main
      with:
        github_token: ${{ secrets.GITHUB_TOKEN }}
```

You can specify the files to format by setting the ``files`` argument to a whitespace-separated list of file patterns.
The patterns are [unix-like globs](https://en.wikipedia.org/wiki/Glob_(programming)#Unix-like) with support for ** (bash's "globstar").
To recursively search for ``*.v`` and ``*.sv`` files in the `my_design` folder, you can set `files` to ``'my_design/**/*.{v,sv}'``

By default ``files`` has the value ``'./**/*.{v,sv}'``. This searches for all ``*.v`` and ``*.sv`` files in the repository.

```yaml
- uses: chipsalliance/verible-formatter-action@main
  with:
    files:
      ./rtl/my_file.sv
      ./rtl/module/*.sv
      ./testbench/**/*.{v,sv}
    github_token: ${{ secrets.GITHUB_TOKEN }}
```

If you want to declare Verible version to be used,
you can pass its release tag in the input ``verible_version``:

```yaml
- uses: actions/checkout@master
- uses: chipsalliance/verible-formatter-action@main
  with:
    verible_version: "v0.0-3100-gd75b1c47"
    github_token: ${{ secrets.GITHUB_TOKEN }}
```

Additionally, you can add various flags to the formatter with the ``parameters`` input:

```yaml
- uses: chipsalliance/verible-formatter-action@main
  with:
    files:
      ./design/**/*.{v,sv}
    parameters:
      --indentation_spaces 4
      --module_net_variable_alignment=preserve
      --case_items_alignment=preserve
    github_token: ${{ secrets.GITHUB_TOKEN }}
```

Automatic review on PRs from external repositories
--------------------------------------------------

In GitHub Actions, workflows triggered by external repositories may only have
[read access to the main repository](https://docs.github.com/en/actions/reference/authentication-in-a-workflow#permissions-for-the-github_token).
In order to have automatic reviews on external PRs, you need to change your workflow to trigger
on ``pull_request_target`` event and manually check out changes from pull request:

```yaml
name: Verible formatter example
on:
  pull_request_target:

jobs:
  format:
    runs-on: ubuntu-latest
    permissions:
      checks: write
      contents: read
      pull-requests: write
    steps:
      - uses: actions/checkout@v3
        with:
          ref: ${{ github.event.pull_request.head.sha }}
      - name: Run Verible formatter action
        uses: chipsalliance/verible-formatter-action@main
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
```
