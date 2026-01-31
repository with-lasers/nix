{
  flake.homeModules.git = {namespace, ...}: {
    config = {
      ${namespace}.shell.aliases = {
        g = "git";
      };

      programs.git.settings.alias = {
        alias = "!git config -l | grep ^alias | cut -c 7- | sort";
        aliases = "config --get-regexp alias";

        remotes = "remote -v";
        stashes = "stash list";
        tags = "tag -l";

        # List contributors with number of commits
        contributors = "shortlog --summary --numbered";

        # Credit an author on the latest commit
        credit = "!f() { git commit --amend --author \"$1 <$2>\" -C HEAD; }; f";

        br = "branch";
        branches = "branch -a";

        # TODO: use an env var to change the "protected branches"
        brd = "!f() { git branch --merged | grep -Ev '^[*]|main' | xargs -r git branch -d; }; f";

        cd = "checkout";
        cm = "commit";

        # Amend the currently staged files to the latest commit
        amend = "commit --amend --reuse-message=HEAD";
        discard = "checkout --";
        uncommit = "reset --mixed HEAD~";
        unstage = "reset -q HEAD --";
        untrack = "rm -r --cached";

        d = "diff";
        dc = "diff --cached";

        lg = "log --color --decorate --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an (%G?)>%Creset' --abbrev-commit";
        tree = "log --graph --decorate --pretty=oneline --abbrev-commit";
        graph = "log --graph --color --pretty=format:%C(yellow)%H%C(green)%d%C(reset)%n%x20%cd%n%x20%cn%x20(%ce)%n%x20%s%n";

        pl = "pull --all --prune";
        ps = "push";
        psf = "push --force-with-lease";

        # Interactive rebase with the given number of latest commits
        reb = "!r() { git rebase -i HEAD~$1; }; r";

        # TODO: create alias for continue (with all commands with a continue flag)
        rbc = "rebase --continue";

        s = "status -s";
        st = "status";
      };
    };
  };
}
