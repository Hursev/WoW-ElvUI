# GIT operations

## 1. Prepare local repo

1. Clone  
`git clone https://github.com/Hursev/WoW-ElvUI.git`

1. Add the original repository as a new remote, conventionally named "upstream":  
This allows you to fetch changes from the original repository.  
*This may not be necessary* - check the result of step 3.  
`git remote add upstream https://github.com/tukui-org/ElvUI.git`

1. Verify the remotes:  
You can check that both origin (your fork) and upstream (the original repository) are configured correctly.  
`git remote -v`  
  
- You should see something like:  

  ```x
  origin   https://github.com/Hursev/WoW-ElvUI.git (fetch)
  origin   https://github.com/Hursev/WoW-ElvUI.git (push)
  upstream https://github.com/tukui-org/ElvUI.git (fetch)
  upstream https://github.com/tukui-org/ElvUI.git (push)
  ```

## 2. Bringing new commits from upstream into this repo

1. Fetch the latest changes from the upstream repository  
`git fetch upstream`

1. Switch to local master branch  
   `git checkout main`

   - If there are no conflicts: Git will perform a "fast-forward" merge, meaning your branch pointer will simply move forward to include the new commits, and no new merge commit will be created.

   - If there are conflicts: Git will notify you of merge conflicts. You'll need to manually resolve these conflicts in the affected files. After resolving them, git add the files, and then git commit to complete the merge.

1. Push the updated local branch to repository on GitHub  
   `git push origin main`
