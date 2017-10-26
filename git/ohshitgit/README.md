
# [Oh shit, git!](http://ohshitgit.com/)

Git is hard: screwing up is easy, and figuring out how to fix your mistakes is fucking impossible. Git documentation has this chicken and egg problem where you can't search for how to get yourself out of a mess, unless you _already know the name of the thing you need to know about_ in order to fix your problem.

So here are some bad situations I've gotten myself into, and how I eventually got myself out of them _in plain english_*.


## [Oh shit, I did something terribly wrong, please tell me git has a magic time machine!?!](#magic-time-machine)

```

            git reflog
            # you will see a list of every thing you've done in git, across all branches!
            # each one has an index HEAD@{index}
            # find the one before you broke everything
            git reset HEAD@{index}
            # magic time machine

```

You can use this to get back stuff you accidentally deleted, or just to remove some stuff you tried that broke the repo, or to recover after a bad merge, or just to go back to a time when things actually worked. I use `reflog` A LOT. Mega hat tip to the many many many many many people who suggested adding it!


## [Oh shit, I committed and immediately realized I need to make one small change!](#change-last-commit)

```

                # make your change
                git add . # or add individual files
                git commit --amend
                # follow prompts to change or keep the commit message
                # now your last commit contains that change!

```

This usually happens to me if I commit, then run tests/linters... and FML, I didn't put a space after the equals sign. You could also make the change as a new commit and then do `rebase -i` in order to squash them both together, but this is about a million times faster.


## [Oh shit, I need to change the message on my last commit!](#change-last-commit-message)

```

            	git commit --amend
            	# follow prompts to change the commit message

```

Stupid commit message formatting requirements.


## [Oh shit, I accidentally committed something to master that should have been on a brand new branch!](#accidental-commit-master)

```

                # create a new branch from the current state of master
                git branch some-new-branch-name
                # remove the commit from the master branch
                git reset HEAD~ --hard
                git checkout some-new-branch-name
                # your commit lives in this branch now :)

```

Note: this doesn't work if you've already pushed to origin, and if you tried other things first, you might need to `git reset HEAD@{number}` instead of `HEAD~`. Infinite sadness. Also, many many many people suggested an awesome way to make this shorter that I didn't know myself. Thank you all!


## [Oh shit, I accidentally committed to the wrong branch!](#accidental-commit-wrong-branch)

```

                # undo the last commit, but leave the changes available
                git reset HEAD~ --soft
                git stash
                # move to the correct branch
                git checkout name-of-the-correct-branch
                git stash pop
                git add . # or add individual files
                git commit -m "your message here"
                # now your changes are on the correct branch

```

A lot of people have suggested using cherry-pick for this situation too, so take your pick on whatever one makes the most sense to you!

```

                git checkout name-of-the-correct-branch
                # grab the last commit to master
                git cherry-pick master
                # delete it from master
                git checkout master
                git reset HEAD~ --hard

```

## Oh shit, I don't want to commit all these changes, can we go through each one?

```
git add -i
```

A handly little explorer tool that comes right with Git.

## [Oh shit, I tried to run a diff but nothing happened?!](#dude-wheres-my-diff)

```
git diff --staged
```

Git won't do a diff of files that have been `add`-ed to your staging area without this flag. File under `¯\_(ツ)_/¯` (yes, this is a feature, not a bug, but it's baffling and non-obvious the first time it happens to you!)


## [Fuck this noise, I give up.](#fuck-this-noise)

```

                cd ..
                sudo rm -r fucking-git-repo-dir
                git clone https://some.github.url/fucking-git-repo-dir.git
                cd fucking-git-repo-dir

```

Thanks to [@viaz66](https://twitte

<footer class="spaced centered">

<small>Disclaimer: I did not make this; I borrowed it from [here](http://ohshitgit.com/). </small>

</footer>
