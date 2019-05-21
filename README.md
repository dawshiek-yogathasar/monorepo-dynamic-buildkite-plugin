# monorepo-dynamic-buildkite-plugin

This plugin either triggers or runs commands by watching folers in your monorepo

## Example

### Simple

```yml
steps:
  - label: ":pipeline: Triggering pipelines"
    plugins:
      - dawshiek-yogathasar/monorepo-dynamic#v0.0.1:
          diff: "git diff --name-only HEAD~1"
          watch:
            - path: "Docker-agents/"
              config:
                pipeline:
                  label: "Test"
                  commands:
                    - echo "Test"
```