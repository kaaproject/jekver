# Jekver

Tool to collect documentation from versions tags and update gh-pages branch in target repository

## Configuration

### CLI options

Run jekver with -h options to get latest cli help.

CLI overwrite configuraton loaded from config file so if option defined in config file and passed from CLI jekver will be excuted with values from CLI.

### Configuration file

|path|Type|Example|Comments|
|project|String|kaa|Project name|
|startFromTag|String|v0.8.1|Minimal version to collect documents|
|latest|String|v0.10.0|Latest version to generate redirection pages|
|addCurrent|boolean|false|Flag to add current branch to the gh-pages|
|jekdocs|Array||Conversion rules to generate documentation|
|jekdocs[n].key|Map||Configuration Item|
|jekdocs[n].key.cmd|String|""|Command to generate documentation|
|jekdocs[n].key.path|String|""|Base path from cmd should be executed|
|jekdocs[n].key.target|String|""|Path modifier|
|jekdocs[n].key.copy|Map|dst:src|Coping rules in format destination source #{version}/#{path}/#{src}/ -> #{key}/#{target}/#{dst}/#{version}|
