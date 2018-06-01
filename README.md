# Jekver

Tool to collect documentation from versions tags and update gh-pages branch in target repository

## Configuration

### CLI options

Run jekver with -h options to get latest cli help.

CLI overwrite configuraton loaded from config file so if option defined in config file and passed from CLI jekver will be excuted with values from CLI.

### Configuration file

|path|Type|Example|Comments|
|---|---|---|---|
|project|String|kaa|Project name|
|startFromTag|String|v0.8.1|Minimal version to collect documents|
|latest|String|v0.10.0|Latest version to generate redirection pages|
|addCurrent|boolean|false|Flag to add current branch to the gh-pages|
|jekdocs|Array||Conversion rules to generate documentation|
|jekdocs[n].key|Map||Configuration Item|
|jekdocs[n].key.cmd|String|"mvn compile"|Command to generate documentation|
|jekdocs[n].key.path|String|"path_to_mvm_proj"|Base path from cmd should be executed|
|jekdocs[n].key.target|String|""|Target folder for documentation in gh-pages|
|jekdocs[n].key.copy|Map|dst:src|Coping rules in format destination source #{version}/#{path}/#{src}/ -> #{key}/#{target}/#{dst}/#{version}|

## Basic usage

1. [Install Jekyll](https://jekyllrb.com/docs/installation/#ubuntu).

2. Clone [Jekver repository](https://github.com/kaaproject/jekver) to the directory that contains your project repository with documentation.

3. In the cloned Jekver repository, open the `gh-pages-stub/_config.yml` file, specify `title` and `baseurl` parameter values for your project.

4. Create a Jekver configuration file `jekver.yml` in the root of your project repository with documentation.
For the `docs` parameter, specify the name of the directory that contains your documentation.
If that directory is not in the project root, specify the full path from project root.
See example below.

   ```
   project: MyProject
   latest: "current"
   
   jekdocs:
    - md:
        path: ""
        target: ""
        copy:
          docs: doc
   ```

5. From the root of your cloned Jekver repository, run:

   ```
   ./jekver.rb -c <root path of your project repository>
   ```

   This will generate documentation structure and create two sub-directories in the root of your project repository: `test-MyProject-pages-current` and `tmp`.

6. From the `test-MyProject-pages-current` directory, run `jekyll serve`.
This will generate the documentation and serve it at `http://localhost:4000/<baseurl>/`.