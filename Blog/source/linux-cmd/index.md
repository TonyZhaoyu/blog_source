---
title: Commonly used Linux commands
---

#### **Assign the current network interface to an IP address**

Use : ifconfig netmask . e.g.,

```bash
$ ifconfig eth0 192.168.2.1 netmask 255.255.255.0
```

***

#### **Use nmap to report whether your device uses a Linux TCP/IP stack**

```bash
$ nmap -P0 -O
```

***

#### **Show IP ports**

```bash
$ lsof -i -P -n
```

***

#### **Symbolic link:**

┌── ln(1) link, ln -- make links
│   ┌── Create a symbolic link.
│   │                         ┌── the optional path to the intended symlink
│   │                         │   if omitted, symlink is in . named as destination
│   │                         │   can use . or ~ or other relative paths
│   │                   ┌─────┴────────┐
ln -s /path/to/original /path/to/symlink
      └───────┬───────┘
              └── the path to the original file/folder
                  can use . or ~ or other relative paths

```bash
$ echo content > original
$ ln -s original symlink
$ ls -la original symlink
-rw-r--r--  1 grgarside  staff    8 28 Jan 18:44 original
lrwxr-xr-x  1 grgarside  staff    8 28 Jan 18:44 symlink -> original
$ cat symlink
content
```

Notice MacOS symlink creation may be different. For example, if to create a link for commander of SimplicityStudio, we could:

```bash
$ ln -s /Applications/Simplicity Studio.app/Contents/Eclipse/developer/adapter_packs/commander/Commander.app/Contents/MacOS/commander /usr/local/bin
```

There's no need to specify the name of command under /usr/local/bin, but providing a path is enough.

***

#### **Add a new variable into the PATH environment:**

```bash
$ echo $PATH
```

In Unix systems, we sometimes want to execute a program in a terminal without specifying the its path. In this case, it's easy to add the path of the program being a variable to the PATH environment. To do this, we could follow the command below:

```bash
$ export PATH=$PATH:[path to the program]
```

Notice when the terminal is terminated, the above command has no effect after a new terminal is opened. To ensure the PATH environment is modified permanently, we could add the above command in ~/.bashrc. Editor like vi/vim/nano could be used.

***

#### **GNU screen**
To connect to a serial on a console, we could use screen. The following is an example:

```bash
$ screen /dev/ttyUSB0 115200 8N1
```

On MacOS, you could kill the console (while you're in the screen session) by command + A + \, and typing [y].
Another way to kill a screen session is to first know what sessions are available:

```bash
$ screen -ls
```

Then, kill the specified session Id using the following command:

```bash
$ screen -X -S [Session ID] quit
```

***

#### **Hexo**
Refresh the build after modifications.

```bash
$ hexo clean
$ hexo generate
```

Publish to my github account.

```bash
$ hexo deploy
```

Create a page used for dropdown view:

```bash
$ hexo new page "name"
```

The created path will be: [hexo_directory]/source/[name]/index.md
To add the page in the dropdown list, we need to modify the *_config.yml* file under [hexo_directory]/theme/biture/ directory.
E.g.,
IoT Ecosystems:
   SDK review: /sdk-review/
   Data model analysis: /data-model/

***

#### **Git**

* How to save your ass from a local merge yet being pushed.

The following command would go back to one commit.

```bash
$ git reset --hard HEAD~1
```

* How to add files that were copied from somewhere else (not in the repo). You need the following command to unstage the files:

```bash
$ git reset HEAD path/to/file
```

Then do *git add* and *git commit*.

* How to revert:

Git revert to a commit will eventually roll out a new commit. If git reset is used, there will be no commit.

```bash
# Revert the latest commit.
$ git revert HEAD
# Revert a specific commit.
$ git revert commit [commit No.]
```

* How to un-track a folder but keep the folder on your disk.
Link: https://stackoverflow.com/questions/24290358/remove-a-folder-from-git-tracking

This also works for the situation where an unwanted submodule causing fatal error when 'git add'. The basic idea is to remove the folder from git's cache. 

1. Add the folder to the .gitignore
2. Remove the folder from your local git tracking, but keep it on your disk.

```bash
git rm -r --cached path_to_your_folder/
```
3. Push your changes to your git repo.

>The folder will be considered "deleted" from Git's point of view (i.e. they are in past history, but not in the latest commit, and people pulling from this repo will get the files removed from their trees), but stay on your working directory because you've used --cached.

* How to delete a local branch and a remote branch.

```bash
# Delete local branch
git branch -d {branch name}
# Delete remote branch
git push origin --delete {branch name}
```

* How to add ssh keys to your stash or github account.

Instead of using Http connections, we could use ssh keys to push/pull a git repo. This prevents user from entering username and keys each time using Http connections. For a branch new machine, we need to firstly create ssh private and public keys (also known as key pairs).

```bash
$ ssh-keygen -t rsa -C "your_email@example.com"
```

Notice the email account is optional. You could pass key saving path and passphrase settings. After done, you should be able to see **id_rsa.pub** file under ~/.ssh/ directory. Copy the content of id_rsa.pub to your git or stash account (usually at security, adding keys tab).

Reference:

* https://confluence.atlassian.com/bitbucketserver/creating-ssh-keys-776639788.html
* https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys--2

***

#### **dylib on MacOS**

There could be an error when using dylib (dynamic library) on MacOS. The error could be:

```bash
dyld: Library not loaded: @rpath/libcmocka.0.dylib
  Referenced from: /Users/tozhao/Documents/Stash_Projects/customer-projects/xiaomi/6.3.0/tests-mac/./test
  Reason: image not found
[1]    8541 abort      ./test
```

The problem is this dylib does not specify the execution path. When checking the dylib with otool, we could find:

```bash
libcmocka.0.4.1.dylib:
	@rpath/libcmocka.0.dylib (compatibility version 0.0.0, current version 0.4.1)
	/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1238.60.2)
```

To solve the problem, we could use install_name_tool like the following example:

```bash
$ install_name_tool -change @rpath/libcmocka.0.dylib [path/to/the/exefile] [exefile]
```

The exefile is the binary that is linked with the dylib.

References:

* https://software.intel.com/en-us/forums/intel-c-compiler/topic/698021
* https://stackoverflow.com/questions/17703510/dyld-library-not-loaded-reason-image-not-loaded.

***

#### **SSH**

* Remove ssh known hosts on a Linux machine.

```bash
$ ssh-keygen -R 192.168.42.1 -f "~/.ssh/known_hosts"
```

* Remove ssh known hosts on a MacOS.

```bash
$ ssh-keygen -R 192.168.42.1
```


***

#### **Run Silabs Z3GatewayHost in the back-end**

Z3GatewayHost application forks a child process to handle communications with serial port. Use *&* at the end would cause assertion in the child process. A reliable way to run the application in the back-end could refer to the following init script which was developed for running on OpenWrt.

```bash
start() {
  touch /tmp/silabspipeopen
  mkfifo /tmp/silabs
  while [ -f /tmp/silabspipeopen ]; do sleep 1; done > /tmp/silabs &
  /opt/siliconlabs/zigbeegateway/siliconlabsgateway -n 1 -p ttyS1 < /tmp/silabs &
}

stop() {
  rm /tmp/silabspipeopen
  rm /tmp/silabs
  killall siliconlabsgateway
}
```

***

#### **Some commonly used bash syntax**

* Check if there is a specified directory.

```bash
if [ -d "$DIRECTORY" ]; then
  # Control will enter here if $DIRECTORY exists.
fi
```

Or if there is NOT a specified directory.

```bash
if [ ! -d "$DIRECTORY" ]; then
  # Control will enter here if $DIRECTORY exists.
fi
```

* Check if the system is a MacOS or a Linux:

```bash
SYSTEM=$(uname)

# Check if it's a MacOS
if [[ $SYSTEM == 'Darwin' ]]; then
  # Some actions.
fi

# Check if it's a Linux
if [[ $SYSTEM == 'Linux' ]]; then
  # Some actions.
fi
```

* Conditionally exit a bash script.

```bash
# exit n.

if [ $SOMECONDITION ]; then
  exit 0
fi

echo "This line will never be reached!"
```
