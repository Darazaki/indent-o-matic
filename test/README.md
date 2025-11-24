# Tests

Test files are located inside the `data` directory

Name of test files: `$some_name.$expected_indentation_result.$filetype`:

- `$some_name`: Some name to make the file unique
- `$expected_indentation_result`: 0 for tabs, N for N spaces, 42 for no indentation detected
- `$filetype`: The filetype used to test specific configurations (see: `expect.lua`)

Content of test files:

```
This is a normal line
    This is an indented line
Adding a "#" at the end marks the whole line as a comment -> #
```
