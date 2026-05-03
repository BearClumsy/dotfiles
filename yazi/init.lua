-- Share yanked files between multiple yazi instances (e.g. two tmux panes)
require("session"):setup {
	sync_yanked = true,
}
