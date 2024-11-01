return {
	"quentingruber/pomodoro.nvim",
	lazy = false, -- needed so the pomodoro can start at launch
	opts = {
		start_at_launch = false,
		work_duration = 25,
		break_duration = 5,
		delay_duration = 1, -- The additionnal work time you get when you delay a break
		long_break_duration = 15,
		breaks_before_long = 4,
	},
}
