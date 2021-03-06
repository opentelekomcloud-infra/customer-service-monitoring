# Customer service monitoring is a solution for monitoring OTC customer KPIs


### Creating issue / task:

1. Select an appropriate template (if any)
1. Make a short description as the title
2. Make a clean description. If a task contains several sub-tasks, use checkbox list
3. Set appropriate label (bug, task, etc.)
4. If there is a deadline for this issue, set `Due date` to the required date

### Adding new functionality or fixing issue:

1. Create [new issue](https://github.com/opentelekomcloud-infra/customer-service-monitoring/issues) following instructions above
2. Assign the issue to yourself
3. Create new branch named `feature/<feature-short-desc>` for features and `fix/<issue-short-desc>` for bugs.
    Please stick to `<group>/<short-description>` convention for branch naming (slash separator for groups and dashes replacing spaces)
4. Push your local changes to remote branch
5. Create new [pull request](https://github.com/opentelekomcloud-infra/customer-service-monitoring/pulls)
    (*PR*) with clean title, description mentioning your issue:
    `Implementing #N` for new features, `Fixing #N` or `Fixed #N` for the bugfix. Where `N` is your issue number.
    **Please note that PR can be merged only if all discussions are solved and it has at least 1 approval**
6. If you need to change something after creating merge request — just push new commits to
    your branch — pull request will be updated accordingly (approvals will be reset)
7. *For person merging*: branch is to be removed after merge. Merge should be made with **squash commits** option.
