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
    - uses: chipsalliance/verible-format-action@main
      with:
        github_token: ${{ secrets.GITHUB_TOKEN }}
```

You can provide ``paths`` argument to point files to format.
Directories will be searched recursively for ``*.v`` and ``*.sv`` files.
``paths`` defaults to ``'.'``.

```yaml
- uses: chipsalliance/verible-format-action@main
  with:
    paths: |
      ./rtl
      ./shared
    github_token: ${{ secrets.GITHUB_TOKEN }}
```

Automatic review on PRs from external repositories
--------------------------------------------------

In GitHub Actions, workflows triggered by external repositories may only have
[read access to the main repository](https://docs.github.com/en/actions/reference/authentication-in-a-workflow#permissions-for-the-github_token).
In order to have automatic reviews on external PRs, you need to create two workflows.
One will be triggered on ``pull_request`` and upload the data needed by reviewdog as an artifact.
The artifact shall store the file pointed by ``$GITHUB_EVENT_PATH`` as ``event.json``.
The other workflow will download the artifact and use the Verible action.

For example:
```yaml
name: upload-event-file
on:
  pull_request:

...
      - run: cp "$GITHUB_EVENT_PATH" ./event.json
      - name: Upload event file as artifact
        uses: actions/upload-artifact@v2
        with:
          name: event.json
          path: event.json
```

```yaml
name: review-triggered
on:
  workflow_run:
    workflows: ["upload-event-file"]
    types:
      - completed

jobs:
  review_triggered:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: 'Download artifact'
        id: get-artifacts
        uses: actions/github-script@v3.1.0
        with:
          script: |
            var artifacts = await github.actions.listWorkflowRunArtifacts({
               owner: context.repo.owner,
               repo: context.repo.repo,
               run_id: ${{github.event.workflow_run.id }},
            });
            var matchArtifact = artifacts.data.artifacts.filter((artifact) => {
              return artifact.name == "event.json"
            })[0];
            var download = await github.actions.downloadArtifact({
               owner: context.repo.owner,
               repo: context.repo.repo,
               artifact_id: matchArtifact.id,
               archive_format: 'zip',
            });
            var fs = require('fs');
            fs.writeFileSync('${{github.workspace}}/event.json.zip', Buffer.from(download.data));
      - run: |
          unzip event.json.zip
      - name: Run Verible formatter action
        uses: chipsalliance/verible-formatter-action@main
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
```
