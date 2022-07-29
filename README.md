# SuperClient analytics

Welcome to the SuperClient [dbt](https://www.getdbt.com/) project.

- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction).
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers.
- Join the [community](https://community.getdbt.com/) on Slack for live discussions and support.
- Find [dbt events](https://events.getdbt.com) near you.
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices.

## Setup

### Install a text editor
[Visual Studio Code](https://code.visualstudio.com) is the recommended text editor. Install from [here](https://code.visualstudio.com/Download).

Once installed, add the following extensions following [this guide](https://code.visualstudio.com/docs/editor/extension-marketplace).
- [vscode-dbt](https://marketplace.visualstudio.com/items?itemName=bastienboutonnet.vscode-dbt)
- [vscode-dbt-language](https://marketplace.visualstudio.com/items?itemName=dorzey.vscode-dbt-language)
- [EditorConfig](https://marketplace.visualstudio.com/items?itemName=EditorConfig.EditorConfig)

### Mac only - install Homebrew

[Install Homebrew](https://brew.sh/)

### Install Git

#### Mac
```
brew install git
```

#### Windows
https://git-scm.com/downloads

### Install dbt

#### Mac
Run the below commands to install [pyenv](https://github.com/pyenv/pyenv), a Python version manager, and Python 3.8.

```
brew install pyenv
echo 'eval "$(pyenv init --path)"' >> ~/.zshrc
eval "$(pyenv init --path)"
pyenv install 3.8.13
pyenv global 3.8.13
```

#### Windows
[Install Python 3.8](https://www.python.org/downloads/windows/), checking the 'Add Python to path' checkbox.

#### Mac and Windows
```
python -m pip install pipx
python -m pipx ensurepath
```

Close your command line and reopen before running

```
pipx install dbtenv-dbt-alias
```

[What is dbtenv?](https://github.com/brooklyn-data/dbtenv)

### Clone the repository

Clone this repository to a folder on your computer, and navigate to it in your command line.

### Configure your database connection
[dbt init docs](https://docs.getdbt.com/reference/commands/init#existing-project)

[profiles.yml docs](https://docs.getdbt.com/dbt-cli/configure-your-profile)

#### Mac and Windows
From within this repository, run
```
dbt init
```
and follow the prompts.


Your models will be built into the database `analytics_dev` under schemas prefixed with your name.


### Install the package dependencies

From inside the newly-cloned Git repository, run `dbt deps` to install all the packages specified in `packages.yml`.

## Development

[dbt commands reference](https://docs.getdbt.com/reference/dbt-commands)

To keep the code consistent please follow the [dbt coding conventions](https://github.com/brooklyn-data/co/blob/dbt-coding-conventions-v2.0/dbt_coding_conventions.md) and [SQL style guide](https://github.com/brooklyn-data/co/blob/sql-style-guide-v2.0/sql_style_guide.md) from [Brooklyn Data Co.](https://brooklyndata.co/)

### Git

We use Git to version control all of our work and peer review any new changes. A standard workflow is as follows:

1. Checkout and pull the latest changes on main:
    - `git checkout main`
    - `git pull origin main`
2. Create a new branch to work from:
    - `git checkout -b <branch_name>`
3. Once you've made your changes, stage them with:
    - `git add -A`
4. Commit your changes:
    - `git commit -m 'Added X, Y and Z'`
5. Push your changes:
    - `git push origin <branch_name>`
6. Open the link shown in the terminal under `Create a pull request...`, and create a pull request to the main branch.

### Updating dbt

New dbt versions are announced in the [Slack group](https://community.getdbt.com/), as well as on [GitHub](https://github.com/dbt-labs/dbt/releases). It is recommended to keep up to date for new features and bug fixes. To upgrade, both local development and automated dbt jobs need to be updated. If on Mac and using brew, the command is:

```

brew upgrade dbt-snowflake

```

and on Windows the command is:

```

pipx upgrade dbt-snowflake

```

### Customizing VSCode

If you wish to have project-specific customizations in this project, you'll need to tell git not to recognize your changes so they don't get commited to the repo.

To do this, run the following command:

```
git update-index --skip-worktree .vscode/settings.json
```
