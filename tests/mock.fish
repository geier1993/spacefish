function better-mock -a cmd -a argument -a exit_code -a executed_code -d "Mock library for fish shell testing"
	set -l cmd_blacklist "builtin" "functions" "eval" "command"

	if contains $cmd $cmd_blacklist
		echo The function '"'$cmd'"' is reserved and therefore cannot be mocked.
		return 1
	end

	if not contains $cmd $_mocked
		# Generate variable with all mocked functions
		set -g _mocked $cmd $_mocked
	end

	set -l mocked_args "_mocked_"$cmd"_args"
	if not contains $argument $$mocked_args
		# Generate variable with all mocked arguments
		set -g $mocked_args $argument $$mocked_args
	end

	# Create a function for that command and argument combination
	set -l mocked_fn "mocked_"$cmd"_fn_"$argument
	function $mocked_fn -V exit_code -V executed_code
		eval $executed_code
		return $exit_code
	end

	function $cmd -V cmd -V mocked_args
		# Call the mocked function created above
		if contains $argv[1] $$mocked_args
			set -l fn_name "mocked_"$cmd"_fn_"$argv[1]
			eval $fn_name
		else
			# Fallback on runnning the original command
			eval command $cmd $argv
		end
	end

	function unmock -a cmd
		functions -e $cmd
		set -l mocked_args "_mocked_"$cmd"_args"
		functions -e "mocked_"$cmd"_fn_"{$$mocked_args}
		set -e $mocked_args
		set _mocked (string match -v $cmd $_mocked)
		return 0
	end
end
