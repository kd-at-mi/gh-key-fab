# gh-key-fab

A dynamic helper script for SSH to select the correct SSH key based on the project's directory path.

This script is designed to be used with the `Match exec` directive in your `~/.ssh/config` file. It allows you to define rules that automatically apply a specific SSH key when you are working inside a designated project folder, simplifying key management for different clients, employers, or personal projects.

All path matching is **recursive**, meaning any subdirectory within a specified path will also trigger a match.

---

## Features

- **Path-Based Key Selection**: Automatically determines if a key should be used based on the current working directory.
- **Cross-Platform**: Written in Bash for compatibility with macOS, Linux, and Windows Subsystem for Linux (WSL).
- **Flexible Configuration**: Specify multiple project paths for a single key.
- **Conditional Logging**: Enable detailed logging to a default or custom file for easy debugging.
- **Log Rotation**: Automatically trims log files to a configurable length to prevent them from growing indefinitely.
- **Named Keys**: Assign a name to your key configurations for clearer log entries.

---

## Setup Instructions

Follow these steps to set up `gh-key-fab` and integrate it with your SSH configuration.

### 1\. Create the `config.d` Directory

First, create a dedicated folder inside your `~/.ssh` directory to hold your SSH configuration snippets.

```bash
mkdir -p ~/.ssh/config.d/
```

### 2\. Make the Script Executable

Place the `gh-key-fab.sh` script in a convenient location (e.g., `~/.ssh/gh-key-fab.sh`) and make it executable.

```bash
chmod +x ~/.ssh/gh-key-fab.sh
```

### 3\. Update Your Main SSH Config

Edit your main SSH config file at `~/.ssh/config` and add the following line at the top. This tells SSH to load all configuration files that end with the `.conf` extension from your new `config.d` directory.

```
# Load all custom configuration snippets
Include ~/.ssh/config.d/*.conf
```

---

## Usage

The script is called from within an SSH config file using the `Match exec` directive. It will exit with a success code if the current directory matches one of the provided paths, causing SSH to use the `IdentityFile` specified in that block.

### Command-Line Arguments

| Flag                    | Alias | Description                                                                            | Example               |
| :---------------------- | :---- | :------------------------------------------------------------------------------------- | :-------------------- |
| `--path <path>`         | `-p`  | **(Required)** The project directory path. Can be used multiple times.                 | `-p ~/work/client-a`  |
| `--name <name>`         | `-n`  | **(Optional)** A friendly name to identify this key rule in the logs.                  | `-n "Work Key"`       |
| `--log [path]`          | `-l`  | **(Optional)** Enables logging. If `[path]` is omitted, logs to `/tmp/gh-key-fab.log`. | `-l ~/.ssh/debug.log` |
| `--log-max-lines <num>` | `-m`  | **(Optional)** Sets the max number of lines in the log file. Defaults to 1000.         | `-m 250`              |

### Example Configuration

Create a new file in your `config.d` directory, for example, `~/.ssh/config.d/work-github.conf`. This file will contain the rule for your work-related projects.

```
# Rule for all Work Projects on GitHub
Match host github.com exec "~/.ssh/gh-key-fab.sh -p ~/projects/work -p ~/clients/project-x"
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_work
```

### Example with Debugging

To debug a configuration, you can add the logging and name flags. This will create a log file at `/tmp/gh-key-fab.log` and label all entries with "Work Projects".

```
# Rule for all Work Projects (with logging enabled)
Match host github.com exec "~/.ssh/gh-key-fab.sh -l -n \"Work Projects\" -p ~/projects/work"
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_work
```

Now, when you run a git command from inside `~/projects/work`, the script will log its activity, helping you verify that the correct key is being selected.

**To view the log file in real-time:**

```bash
tail -f /tmp/gh-key-fab.log
```
