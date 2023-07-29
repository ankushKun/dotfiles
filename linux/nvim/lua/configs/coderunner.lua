--------------------------------------------------------------------
--                      CODE RUNNER                               --
--------------------------------------------------------------------

require('code_runner').setup({
    -- put here the commands by filetype
    filetype = {
        java = "cd $dir && javac $fileName && java $fileNameWithoutExt",
        python = "python3 -u",
        cpp = "cd $dir; g++ $fileName -o $fileNameWithoutExt; ./$fileNameWithoutExt",
        c = "cd $dir; g++ $fileName -o $fileNameWithoutExt; ./$fileNameWithoutExt",
        javascript = "node"
    },
    -- mode = "toggleterm",
    -- focus = false
})
